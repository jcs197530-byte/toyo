## 6. 영속화 설계

> toyo 프로젝트 신규 영속화 설계다. 기준 문서(`6.영속화설계(기존).md`)의 구조(전환 전략 → 트랜잭션 예시 → 커밋/롤백 원칙)를 그대로 따르되, toyo는 "pickle"이 아니라 **`ENGINE=MyISAM`** 이 1차였다는 점이 다르다. `toyo테이블스키마DB_덤프.sql` 전수 조사 결과 toyo_* 핵심 테이블 42개 전부 MyISAM이며, PRIMARY KEY·FOREIGN KEY·UNIQUE KEY 선언이 **단 한 건도 없다.** 아래 내용은 이 사실에서 출발한다.

### 6-1. MyISAM 대비 전환 전략

| 구분 | 1차(MyISAM, 기존) | 2차(PostgreSQL, 신규) |
|---|---|---|
| 트랜잭션 | 미지원 — 각 SQL 문이 실행 즉시 확정 | `BEGIN`~`COMMIT`으로 여러 문을 원자적으로 묶음 |
| 동시 쓰기 | **테이블 단위 락** — 한 반이 출석부를 저장하는 동안 다른 반 저장도 대기 | 행 단위 락(MVCC) — 서로 다른 행이면 동시 처리 |
| 정합성 보장 | PK/FK/UNIQUE 미선언 → 전적으로 애플리케이션 코드 신뢰에 의존 | 제약조건을 DB가 강제, 위반 시 `IntegrityError` |
| 비정상 종료 | 커밋 개념이 없어 특정 문장까지만 반영된 상태로 남을 수 있음 | WAL 기반 복구 — 커밋된 트랜잭션만 반영 |
| 이력 적재 | DB 트리거가 부가 INSERT를 수행하나, 원본 INSERT와 트리거 INSERT가 하나의 트랜잭션으로 묶이지 않음 | 애플리케이션 트랜잭션 하나로 원본 데이터+이력을 함께 커밋/롤백 |

> ⚠️ **실측 근거 1 — 트리거가 스스로 실패할 가능성**: `toyo_stud_score` 테이블에는 INSERT/UPDATE 후 `toyo_stud_score_hist`에 이력을 적재하는 트리거(`TOYO_STUD_SCORE_TRI_INSERT/UPDATE`)가 있다. 트리거는 `SEQ` 컬럼에 `NULL`을 넣지만, 덤프상 `toyo_stud_score_hist.SEQ`는 `int(9) NOT NULL`이고 `AUTO_INCREMENT` 속성이 컬럼에 붙어있지 않다(테이블 옵션에 `AUTO_INCREMENT=153528`이라는 메타값만 남아있다 — 과거엔 컬럼에 있었으나 유실된 것으로 추정). 즉 덤프 기준으로는 성적을 등록/수정할 때마다 이 트리거가 `NOT NULL` 위반으로 실패할 소지가 있다. **DB 트리거로 부가 로직을 숨겨두면 이런 문제가 운영 환경에서만, 그것도 조용히 드러난다** — 신규 설계는 이력 적재를 트리거가 아니라 애플리케이션 트랜잭션 코드로 명시한다(6-2).

> ⚠️ **실측 근거 2 — 제약조건 부재가 실제로 기능을 무력화한 사례**: 로그인 시 `TOYO_ID_INFO_HIST`에 `INSERT ... ON DUPLICATE KEY UPDATE`를 실행하는 코드가 있다(`loginFormProc.php`). 그러나 이 테이블에는 PRIMARY KEY도 UNIQUE KEY도 없다. `ON DUPLICATE KEY`는 **위반할 KEY 자체가 없으므로 절대 발동하지 않는다** — 개발자는 "하루 1건으로 갱신되겠지"라고 의도했겠지만 실제로는 로그인마다 새 행이 계속 쌓인다. 애플리케이션 코드가 아무리 정확해도 DB가 제약을 강제하지 않으면 의도한 정합성이 보장되지 않는다는 것을 보여주는 실제 사례다.

> ⚠️ **동시성 관점의 추가 근거**: toyo는 토요학교 특성상 매주 토요일 오전, 여러 반 교사가 거의 동시에 출석·성적을 입력한다. MyISAM의 테이블 단위 락 하에서는 이 트래픽이 몰릴 때 서로 다른 반의 저장 요청까지 순차 대기하게 된다. 신규 설계(PostgreSQL, 행 단위 락)에서는 서로 다른 반의 요청이 자연스럽게 병렬 처리된다.

---

### 6-2. 트랜잭션 예시 — 성적 등록(+ 이력 적재)

기존 시스템의 트리거(DB단 부가 INSERT)를 애플리케이션 트랜잭션으로 명시적으로 옮긴 예시다. `SEQ`는 이제 진짜 `AUTO_INCREMENT` 컬럼으로 선언하고 애플리케이션은 값을 지정하지 않는다.

```python
def register_score(db: Session, data: schemas.ScoreIn, user: models.User) -> models.Score:
    score = models.Score(
        enroll_date=data.enroll_date,
        ban=data.ban,
        stud_no=data.stud_no,
        subject=data.subject,
        score=data.score,
        reg_id=user.id,
        mod_id=user.id,
    )
    db.add(score)
    db.flush()  # score 확정(commit 아님) — 이력에 참조할 값 확보

    hist = models.ScoreHist(
        gubun="I",
        enroll_date=score.enroll_date,
        ban=score.ban,
        stud_no=score.stud_no,
        subject=score.subject,
        score=score.score,
        reg_id=user.id,
        mod_id=user.id,
    )
    db.add(hist)
    db.commit()  # 성적 원본 + 이력, 전부 성공 또는 전부 실패
    db.refresh(score)
    return score
```

> 💡 기존 트리거 로직(INSERT/UPDATE 구분 `GUBUN='I'/'U'`)은 그대로 유지하되, "DB가 알아서 처리"가 아니라 **서비스 함수가 원본과 이력을 한 트랜잭션 안에서 직접 책임진다.** 이력 적재가 실패하면(예: 제약 위반) 성적 원본 등록도 함께 롤백되므로, 6-1에서 지적한 "트리거만 조용히 실패해 원본과 이력이 어긋나는" 상황 자체가 구조적으로 발생하지 않는다.

---

### 6-3. 커밋/롤백 원칙

| 원칙 | 설명 |
|---|---|
| 요청 단위 트랜잭션 | 성공 시 commit, 예외 시 자동 rollback |
| get_db()의 역할 | 요청마다 세션 개설, 종료 시(성공/실패 무관) 반드시 close |
| 부분 실패 방지 | 연관 INSERT(원본+이력 등)는 commit 전 flush로 중간 상태 확인, 최종 commit은 1회 |
| FK 위반 처리 | `IntegrityError`를 라우터가 포착해 409로 변환 |
| **레거시 대비 신규 원칙** | `stud_no` 등 참조 컬럼에 실제 FK 제약을 건다. 기존에는 FK가 없어 학생을 삭제해도 출석·성적·암송 기록이 고아 행으로 남을 수 있었다(제약이 없으니 오류조차 나지 않는다) — 신규 설계에서는 삭제 시 FK 위반으로 즉시 409가 반환되거나, `ondelete="CASCADE"` 정책을 명시적으로 선택해야 한다(§3-3 SQLAlchemy 모델 참고) |
