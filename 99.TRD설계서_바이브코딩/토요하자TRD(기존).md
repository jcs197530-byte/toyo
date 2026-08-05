# 토요하자 관리 웹 서비스 — TRD (기술 요구사항 정의서)

| 항목 | 내용 |
|---|---|
| 문서 유형 | Technical Requirements Document |
| 대상 언어/환경 | Python 3.12+ / FastAPI 0.139.0 / SQLAlchemy 2.0.51 / PostgreSQL 16(Docker) |
| 의존성 | 외부 패키지 다수 — requirements.txt 버전 고정 필수 |
| 버전 | v1.1 (개선판 — 리뷰 코멘트 반영) |
| 상태 | 확정(Baseline) |

PRD(04문서)가 "무엇을"이라면 본 문서는 "어떻게"를 규정한다. 00~04 문서에서 확정된 요구사항의 기술적 구현 방식을 정의하며, 문서 세트의 최종 산출물이다.

## A. 이미지 생성 기준
필요한 플로우나 아키텍쳐를 머메이드로 그려주고, 옵시디언과 github에서 정상적으로 렌더링 될수 있도록 만들어줘
페르소나가 이해하기 쉽도록 자세하게 그려줘.
항목별로 글을 작성할때마다 머메이드를 최대한 그려주세요.
머메이드로 그려진 것을 보면서 이해를 하는것을 원합니다.
"Be direct and concrete. Show all intermediate states. Explain like I'm 12."

---

> **📝 리뷰어 노트 (20년차 기획/설계 관점)**
> TRD는 이 문서 세트의 최종 산출물이자, 실제로 개발자가 코드를 칠 때 펼쳐놓고 보는 문서입니다. 그만큼 여기서 놓친 디테일은 곧바로 버그가 됩니다. 이번 리뷰에서 잡은 것은 3가지입니다.
> 1. **`phone_exists`/`category_name_exists`에 자기 자신을 제외하는 파라미터가 빠져 있었습니다** (§7-2, §9-3에서 코드로 직접 수정).
> 2. **쿠키 보안 속성이 HttpOnly만 있고 SameSite가 없었습니다** (§5-5에서 추가).
> 3. **ASCII 그림이 많아 옵시디언/깃허브에서 다이어그램으로서의 가독성이 떨어졌습니다** — 전부 머메이드로 전환했습니다.
> 이 문서만 따로 떼어서 신규 개발자에게 줘도 코드를 짤 수 있어야 하는 것이 TRD의 존재 이유이므로, 이번 개선은 "그림을 예쁘게 그리는 것"보다 "빠진 조건문 하나를 찾아내는 것"에 더 무게를 뒀습니다.

---

## 1. 기술 스택 (toyo 프로젝트, 재검증본)

> contact-manager 예시 문서를 toyo 프로젝트 기준으로 재검증한 결과, 버전 정보 자체는 모두 실존하는 정식 릴리스로 확인되었으나(2026년 8월 기준), "테이블 4개" 등 예시 프로젝트 내용이 그대로 남아있던 부분과, toyo 규모(35개 테이블·운영 이관)에 필요한 구성요소 2개가 빠져 있어 보강했다.

| 구성요소 | 선택 | 버전 | 역할/비고 |
|---|---|---|---|
| 언어 | Python | 3.12.3(검증) / 3.14.x(안정 라인) | FastAPI 0.139.0은 3.10+ 요구 |
| 웹 프레임워크 | FastAPI | 0.139.0 | REST API, 자동 문서화(/docs) |
| 데이터 검증 | Pydantic | 2.13.4 | 요청/응답 스키마 검증(422) |
| ORM | SQLAlchemy | 2.0.51 | Mapped 문법 |
| **DB 마이그레이션** | **Alembic** | 최신 안정 버전 | **(신규 추가)** 35개 테이블 스키마 변경 이력 관리 — `create_all()`만으로는 운영 이관 프로젝트를 안전하게 관리할 수 없음(§11 참고) |
| DB 드라이버 | psycopg | 3.3.4 | 3세대(psycopg2 아님) |
| 비밀번호 해싱 | pwdlib[argon2] | 0.3.0 | Argon2, FastAPI 공식 권장 |
| **개인정보 암호화** | **cryptography** | 최신 안정 버전 | **(신규 추가)** 레거시의 `AES_ENCRYPT(컬럼, 하드코딩키)`를 대체. `parents_no_hp_enc`, `ban_hp_enc`, `teacher_hp_no_enc` 3개 컬럼의 애플리케이션 레벨 암호화에 사용(§1 원본 문서에는 언급만 있고 스택에는 누락되어 있었음) |
| ASGI 서버 | Uvicorn | 0.50.0 | `uvicorn main:app --reload` |
| 세션 토큰 | secrets(표준) | — | `token_hex(32)` |
| DB | PostgreSQL 16(Docker) | — | **테이블 35개** (원본 문서의 "테이블 4개"는 contact-manager 예시가 그대로 남아있던 오기) |

### 재검증 시 확인한 사항

- **버전 유효성**: FastAPI 0.139.0(2026-07-01), Pydantic 2.13.4(2026-05-06), SQLAlchemy 2.0.51(2026-06-15), psycopg 3.3.4(2026-05), Uvicorn 0.50.0 — 전부 PyPI에 실제로 존재하는 정식 릴리스가 맞다(참고: 2026년 8월 기준 각 라이브러리의 최신판은 이보다 앞서 있으나, 실무에서 흔히 그렇듯 프로젝트 시작 시점에 고정한 버전으로 보이며 문제되는 조합은 아니다).
- **`테이블 4개` 오기**: contact-manager 원본 문서를 그대로 복사한 흔적으로, toyo 실제 대상은 35개 테이블이다.
- **Alembic 누락**: §11(디렉터리 구조 및 실행)에서 이미 `alembic upgrade head`를 실행 절차에 포함시켰음에도, 정작 기술 스택 표에는 Alembic 자체가 빠져 있었다. 실행 절차와 기술 스택이 서로 어긋나 있던 불일치를 바로잡았다.
- **암호화 라이브러리 누락**: 레거시 DB에 `_enc`로 끝나는 컬럼 3개(`parents_no_hp_enc`, `ban_hp_enc`, `teacher_hp_no_enc`)가 존재하고, §1(기술 스택 원본 문서 취지)에서도 "AES 키 하드코딩 금지"를 언급했지만 실제로 이를 구현할 라이브러리가 스택 표에 없었다. `cryptography` 패키지 추가로 보강했다.


### 1-1. 버전 호환성 검증 (toyo 프로젝트, 재검증본)

동일 venv에 전 구성요소를 설치하여 실제 실행으로 충돌 여부를 검증한다. contact-manager(외부 패키지 7종)보다 toyo는 **①마이그레이션 도구(Alembic), ②암호화 라이브러리(cryptography)가 추가**되어 외부 패키지 9종이 되므로, 버전 고정 전략이 더 중요해진다.

| 점검 항목 | 결과 |
|---|---|
| 외부 패키지 의존성 | 있음(9개) — 원본(7개) 대비 Alembic, cryptography 추가 |
| requirements.txt | 필요(버전 고정) |
| 가상환경(venv) | 필수 |
| FastAPI↔Pydantic 궁합 | FastAPI 0.139.0은 Pydantic v2 계열 필요 |
| SQLAlchemy↔psycopg | 접속 문자열 `postgresql+psycopg://` 명시 필요 |
| pwdlib[argon2] | `pip install "pwdlib[argon2]"` extras 지정 필요 |
| **Alembic↔SQLAlchemy 궁합 (신규)** | Alembic은 SQLAlchemy 2.0 `Mapped`/`mapped_column` 문법의 `Base.metadata`를 그대로 인식하므로 별도 브릿지 불필요. 단 `alembic/env.py`에서 `models/__init__.py`를 반드시 import해 35개 테이블 전부가 `Base.metadata`에 등록된 상태에서 `autogenerate`를 실행해야 함(빠뜨리면 일부 테이블이 마이그레이션에서 누락됨) |
| **cryptography 사용 범위 (신규)** | `parents_no_hp_enc`/`ban_hp_enc`/`teacher_hp_no_enc` 3개 컬럼은 DB 타입이 `BYTEA`이므로, `cryptography`로 암호화한 결과(bytes)를 그대로 저장 — SQLAlchemy 모델에서 `LargeBinary` 타입과 궁합 확인 필요 |
| **python-multipart 필요 여부 (확정)** | 엑셀 일괄 등록 기능은 이번 범위에 없음(확정). 대신 **학생/교사 사진 업로드**(`stud_img_path`/`stud_img_name`, `id_img_path`/`id_img_name`) 기능이 있어, FastAPI가 `multipart/form-data`(파일 업로드)를 처리하려면 여전히 `python-multipart`가 필요하다 — 용도만 엑셀에서 이미지 업로드로 바뀌었을 뿐 패키지는 그대로 필요 |

```
# requirements.txt
fastapi==0.139.0
uvicorn[standard]==0.50.0
pydantic==2.13.4
sqlalchemy==2.0.51
alembic==1.14.0          # (신규 추가) 35개 테이블 마이그레이션 이력 관리 — 최신 안정 버전으로 설치 시 재확인
psycopg[binary]==3.3.4
pwdlib[argon2]==0.3.0
cryptography==43.0.3     # (신규 추가) 개인정보 컬럼 암호화 — 최신 안정 버전으로 설치 시 재확인
python-multipart==0.0.7  # 학생/교사 사진 업로드(파일 업로드) 처리에 필요 — 엑셀 업로드 기능은 범위에 없음(확정)

# 설치
python -m venv venv && source venv/bin/activate
pip install -r requirements.txt
```

### 재검증 결과 요약

- **제거한 것은 없음**: 원본 7개 패키지는 toyo에도 전부 그대로 필요하다(버전도 실제 PyPI 배포본으로 확인됨).
- **추가한 것**: `alembic`, `cryptography` — 둘 다 1번 문서(기술 스택)에서 이미 필요하다고 결정했는데, 정작 `requirements.txt`에는 반영되어 있지 않았던 누락을 바로잡았다.
- **확정된 것**: 엑셀 일괄 등록 기능은 범위에 없음. 대신 학생/교사 사진 업로드 기능이 있으므로 `python-multipart`는 그대로 유지(용도만 변경), `openpyxl`은 필요 없음.
- Alembic/cryptography의 정확한 최신 안정 버전은 설치 시점에 `pip install alembic cryptography` 후 `pip freeze`로 재고정하는 것을 권장한다(위 버전은 예시이며, 설치 시점 기준으로 재확인 필요).





## 2. 시스템 아키텍처 (toyo 프로젝트, 재검증본)

4계층 구조는 그대로 유효하나, contact-manager(테이블 2개·단일 파일 구조)를 그대로 복사한 흔적이 남아있어 **①패키지 분리(§11), ②격리 기준(user_id→ban), ③사진 업로드 파일 저장소, ④Alembic 위치**를 반영해 재검증했다.

```mermaid
flowchart TB
    subgraph L1["화면 계층 (브라우저)"]
        F1["static/index.html (일반 교사)"]
        F2["static/admin.html (SCR-901, 관리자 전용)"]
        F3["static/app.js"]
    end

    subgraph L2["표현 계층"]
        P1["routers/*.py (auth/students/attendance/scores/dreams/admin)<br/>라우팅, 세션 확인(401), 권한 확인(403), 상태 코드 결정"]
        P2["schemas/*.py<br/>도메인별 입출력 양식+자동 검증(422)"]
    end

    subgraph L3["로직 계층"]
        C1["crud/*.py (도메인별 7개)<br/>CRUD, ban 기반 격리, 소프트/하드 삭제"]
        C2["security.py<br/>비밀번호 해싱/대조(pwdlib[argon2])"]
        C3["encryption.py<br/>연락처 컬럼 암호화(cryptography)"]
    end

    subgraph L4["데이터 계층"]
        D1["models/*.py (도메인별 7개, 35개 테이블)"]
        D2["database.py"]
        D3["alembic/ (스키마 마이그레이션 이력)"]
    end

    STORE[("파일 저장소<br/>학생/교사 사진")]
    DB[("PostgreSQL 16<br/>Docker")]

    L1 -- "HTTP(JSON)" --> L2
    L1 -- "HTTP(multipart/form-data, 사진)" --> L2
    L2 -- "함수 호출" --> L3
    L3 -- "SQL(ORM)" --> L4
    L3 -- "파일 저장/조회" --> STORE
    L4 --> DB

    style L1 fill:#F4F6F8,stroke:#5B7A9D
    style L2 fill:#EAF1FB,stroke:#3B6EA5
    style L3 fill:#FCEFE3,stroke:#D8964C
    style L4 fill:#EFEAF8,stroke:#6E4FA5
    style DB fill:#1B2A41,color:#ffffff,stroke:#1B2A41
    style STORE fill:#1B2A41,color:#ffffff,stroke:#1B2A41
```

| 계층 | 책임 | 위치 | 비고 |
|---|---|---|---|
| 화면 | 입력 수집, fetch 호출, DOM 갱신 | static/*.html, *.js | 일반 교사 화면과 관리자 화면(SCR-901)이 정적 파일 단계에서부터 분리 |
| 표현 | 라우팅, 인증/권한 확인, 검증, 응답 포장 | main.py, routers/*, schemas/* | 401(세션) + 403(권한, 신규) 둘 다 이 계층에서 처리 |
| 로직 | CRUD, ban 격리, 소프트/하드 삭제, 해싱, 암호화, 중복/채번 검증 | crud/*, security.py, encryption.py | `user_id` 격리가 아니라 **`ban`(담당 반) 격리**, 삭제는 소프트 기본/하드 CASCADE 예외(§9) |
| 데이터 | 테이블, 연결, 스키마 이력, 영속화 | models/*, database.py, alembic/, PostgreSQL | 35개 테이블, 마이그레이션 이력 관리 포함 |

### 재검증 결과 — 수정/추가한 부분

1. **`user_id` 격리 → `ban`(담당 반) 격리로 정정**: contact-manager는 "내 데이터만" 필터였지만, toyo는 "내가 담당하는 반의 데이터만"이 격리 기준이다(§9). 원본 표를 그대로 쓰면 로직 계층 책임 설명이 toyo 실제 구조와 어긋난다.
2. **단일 파일(`crud.py`, `models.py`, `schemas.py`) → 도메인별 패키지로 정정**: §11에서 이미 `models/`, `schemas/`, `crud/` 각 7개 파일로 분리하기로 결정했는데, 원본 아키텍처 표에는 여전히 단일 파일로 남아 있었다. 35개 테이블을 파일 하나에 담는 구조는 유지보수가 불가능하므로 반드시 정정이 필요하다.
3. **화면 계층에 관리자 화면 분리 추가**: §13에서 결정한 대로, 일반 교사용 `index.html`과 관리자 전용 `admin.html`(SCR-901, 하드 삭제/기준정보 관리)을 화면 계층에서부터 분리했다. 원본에는 화면이 하나였다.
4. **표현 계층에 403(권한 확인) 추가**: 원본은 401(인증)만 명시했지만, toyo는 관리자 전용 API가 있으므로 403(권한) 검증도 표현 계층의 책임으로 명시해야 한다(§9).
5. **로직 계층에 `encryption.py` 신규 추가**: `parents_no_hp_enc` 등 3개 컬럼 암호화(`cryptography`)는 `security.py`(비밀번호 해싱)와 책임이 다르므로 별도 모듈로 분리했다. 하나로 합치면 "인증"과 "개인정보 보호"라는 서로 다른 관심사가 섞인다.
6. **데이터 계층에 `alembic/` 추가**: §1/§1-1에서 결정한 Alembic이 원본 아키텍처 그림에는 전혀 반영되어 있지 않았다. 마이그레이션 이력은 데이터 계층의 책임이므로 명시했다.
7. **파일 저장소(사진) 신규 추가**: 원본 4계층에는 없던 개념이다. 학생/교사 사진은 DB(BYTEA)에 직접 넣지 않고 **파일시스템 또는 오브젝트 스토리지에 저장 + DB에는 경로만 저장**(레거시의 `stud_img_path`/`stud_img_name` 방식과 동일한 원칙)하는 것을 권장하며, 로직 계층이 이 저장소를 별도로 호출하는 흐름을 다이어그램에 추가했다.
8. **DB 표기에서 `pg-lab`(contact-manager 컨테이너 이름) 제거**: toyo 프로젝트의 실제 컨테이너/서비스 이름으로 바꿔야 한다(미정이면 `docker-compose.yml`의 `services:` 이름을 그대로 사용).

**설계 원칙 (원본과 동일하게 유지)**: 계층 간 의존은 위→아래 단방향이며, 로직 계층은 표현 계층을 참조하지 않는다. 화면을 모바일 앱으로 교체해도 로직/데이터 계층은 재사용 가능해야 하며, DB 교체 시 표현 계층은 영향받지 않아야 한다. 이 원칙 자체는 toyo 규모에서도 동일하게 유효하므로 수정하지 않았다.


## 3. 데이터 구조 설계

## 3-1. ERD (검증본)

> **검증 근거**: `toyo테이블스키마DB_덤프.sql`(원본 MySQL 5.5 덤프, toyo_ 테이블 56개) 및 PHP 소스 256개 파일 전수 대조.
>
> **⚠️ 전제 조건 (반드시 읽을 것)**
> 원본 MySQL 스키마에는 **56개 `toyo_` 테이블 전체에 PRIMARY KEY, FOREIGN KEY, 보조 INDEX가 단 하나도 선언되어 있지 않습니다.** (`md5enc` 포함) 아래 ERD의 PK/FK는 전부 PHP 소스의 실제 쿼리 패턴(WHERE 절, JOIN, 반복 저장 키)을 근거로 **역설계(reverse-engineering)한 논리적 키**이며, 원본 DB에 이미 존재하던 제약조건이 아닙니다. PostgreSQL로 마이그레이션 시 이 키들을 물리적 제약조건으로 새로 생성해야 합니다.
>
> **테이블 커버리지 검증 결과**: 원본 56개 `toyo_` 테이블 중 백업/임시 테이블 22개(날짜가 붙은 `_backup` 계열 12개, `_pack`/`_temp`/`_2017_grade` 계열 8개, 기타 2개)는 애플리케이션 코드에서 전혀 참조되지 않아 정상적으로 제외되었습니다. 나머지 34개 + `md5enc` = 35개 노드가 이 ERD의 대상이며, 이는 실사용 테이블 전체와 정확히 일치합니다(누락 없음).

```mermaid
---
title: 토요하자 DB ERD (PostgreSQL 16)
---
erDiagram

    %% ⚠️ 범용 코드마스터 테이블
    %% 코드 전체에서 OPT 컬럼값으로 최소 20개 이상 서로 다른 도메인을 조회함:
    %% CHUL_KIND, BIBLE_CHUL, DEGREE_NO, PASS_NO, PRESENT, MEMORY_KIND,
    %% FIELD_ATTEND_KIND/BUS/NAUSEA, REG_FEE_KIND, REREG_KIND, POINT_EVENT_KIND, TEAM_KIND 등
    %% EAV(OPT+CODE) 구조라 물리적 FK로 표현이 불가능하므로 관계선 대신 이 주석으로 명시함.
    %% toyo_stud_chul / toyo_stud_bible_memory / toyo_stud_memory / toyo_stud_reg_fee /
    %% toyo_stud_field_attend / toyo_point 등 대다수 트랜잭션 테이블이 이 테이블을 소프트 참조함.
    toyo_code_name {
        varchar opt PK
        varchar code PK
        varchar code_name
        varchar kind_name
        varchar contents
        varchar use_yn
        timestamp reg_date
        varchar reg_id
        timestamp mod_date
        varchar mod_id
    }

    toyo_ban_code_name {
        varchar ban PK
        varchar ban_name
        varchar ban_hp
        bytea ban_hp_enc
        varchar use_yn
        timestamp reg_date
        varchar reg_id
        timestamp mod_date
        varchar mod_id
    }

    toyo_ban_menu_name {
        varchar menu PK
        varchar menu_name
        varchar src_name
        varchar order_by
        varchar mobile_order_by
        varchar level
        varchar group_no
        varchar use_yn
        varchar mobile_use_yn
        varchar menu_code
        timestamp reg_date
        varchar reg_id
        timestamp mod_date
        varchar mod_id
        varchar go_but_yn
        varchar go_but_nm
        varchar go_but_order_by
        varchar mobile_menu_name
        varchar mobile_but_yn
        varchar mobile_but_nm
        varchar mobile_but_order_by
    }

    toyo_bible_contest {
        varchar contest_code PK
        varchar contest_rank
        varchar contest_point
        varchar use_yn
        timestamp reg_date
        varchar reg_id
        timestamp mod_date
        varchar mod_id
    }

    toyo_dream_kind {
        varchar dream_kind PK
        varchar dream_kind_name
        varchar grade
        varchar year_course
        varchar year
        varchar quarter
        varchar use_yn
        timestamp reg_date
        varchar reg_id
        timestamp mod_date
        varchar mod_id
    }

    toyo_kind_name {
        varchar kind PK
        varchar kind_name
        varchar use_yn
        timestamp reg_date
        varchar reg_id
        timestamp mod_date
        varchar mod_id
    }

    %% ⚠️ 미사용 확인: PHP 소스 256개 전체에서 이 테이블 참조 0건.
    %% toyo_stud_score.subject FK로 그려져 있으나 실제 점수 조회는 SUBJECT='001'~'004' 하드코딩.
    %% 유지/삭제 여부 고객 확인 필요.
    toyo_stud_code_name {
        varchar subject PK
        varchar subject_name
        timestamp reg_date
        varchar reg_id
        timestamp mod_date
        varchar mod_id
    }

    %% ⚠️ 미사용 확인: PHP 소스 256개 전체에서 이 테이블 참조 0건. 삭제 검토 대상.
    toyo_stud_dream_support_grade {
        varchar dream_kind PK,FK
        varchar support_grade
        varchar use_yn
        timestamp reg_date
        varchar reg_id
        timestamp mod_date
        varchar mod_id
    }

    toyo_stud_field_attend_teacher {
        varchar teacher_no PK
        varchar teacher_name
        varchar sex
        varchar hp
        varchar field_attend_kind
        varchar field_attend_nausea
        varchar field_attend_bus
        varchar teacher_kind
        varchar field_attend_insurance
        varchar use_yn
        timestamp reg_date
        varchar reg_id
        timestamp mod_date
        varchar mod_id
        varchar reason
    }

    toyo_teacher_chul_code_name {
        varchar teacher_kind PK
        varchar ban PK,FK
        varchar ban_name
        varchar use_yn
        timestamp reg_date
        varchar reg_id
        timestamp mod_date
        varchar mod_id
    }

    toyo_id_info {
        varchar id PK
        varchar passwd
        varchar k_name
        varchar use_yn
        varchar ssn
        varchar token
        varchar auth
        timestamp login_first_time
        timestamp login_last_time
        timestamp reg_date
        varchar reg_id
        timestamp mod_date
        varchar mod_id
        varchar id_img_path
        varchar id_img_name
        varchar group_code
        bytea teacher_hp_no_enc
    }

    %% ⚠️ 특수 목적 테이블: 일반 사용자 계정이 아니라 USERID='jcs1975' 하드코딩된
    %% 단일 관리자 마스터 비밀번호 검증용 게이트 (banTeamModifyProc.php, menuManagerModifyProc.php).
    %% 다른 테이블과 FK 관계가 없는 것이 정상이며, 원본에 PK가 없어 seq를 논리 PK로 승격함.
    md5enc {
        integer seq PK
        varchar userid
        varchar passwd
        varchar use_yn
        timestamp reg_date
        varchar reg_id
        timestamp mod_date
        varchar mod_id
    }

    toyo_id_info_hist {
        varchar id PK,FK
        varchar enroll_date PK
        varchar mac_address
        timestamp reg_date
        varchar reg_id
        timestamp mod_date
        varchar mod_id
    }

    toyo_stud_info {
        varchar stud_no PK
        varchar ban FK
        varchar stud_name
        varchar grade
        varchar team
        varchar sex
        varchar one_year_yn
        varchar dream_kind FK
        bytea parents_no_hp_enc
        varchar use_yn
        timestamp reg_date
        varchar reg_id
        timestamp mod_date
        varchar mod_id
        varchar attend_yn
        varchar stud_img_path
        varchar stud_img_name
        varchar parents_name
    }

    toyo_stud_2hakgi_info {
        varchar stud_no PK,FK
        varchar ban FK
        varchar stud_name
        varchar grade
        varchar team
        varchar rereg_kind
        varchar reason
        varchar enroll_date
        timestamp reg_date
        varchar reg_id
        timestamp mod_date
        varchar mod_id
    }

    %% 비고: dream_kind_1/2/3 은 원본이 반복 컬럼(비정규화)으로 되어 있어 FK로 표현 불가.
    %% toyo_dream_kind.dream_kind 값을 3개 컬럼에 나눠 저장하는 1NF 위반 구조. 재정규화 검토 권장.
    toyo_stud_2hakgi_new_info {
        varchar stud_no PK,FK
        varchar stud_name
        varchar sex
        varchar grade
        varchar parent_name
        varchar parent_hp
        varchar request_teacher_name
        varchar request_method
        varchar church_reg_status
        varchar etc
        varchar reg_fee_kind
        varchar progress_status
        varchar enroll_date
        timestamp reg_date
        varchar reg_id
        timestamp mod_date
        varchar mod_id
        varchar dream_kind_1
        varchar dream_kind_2
        varchar dream_kind_3
    }

    toyo_stud_new_info {
        varchar stud_no PK,FK
        varchar stud_name
        varchar sex
        varchar grade
        varchar parent_name
        varchar parent_hp
        varchar request_teacher_name
        varchar request_method
        varchar church_reg_status
        varchar etc
        varchar reg_fee_kind
        varchar progress_status
        varchar enroll_date
        timestamp reg_date
        varchar reg_id
        timestamp mod_date
        varchar mod_id
        varchar dream_kind_1
        varchar dream_kind_2
        varchar dream_kind_3
    }

    toyo_stud_reg_fee {
        varchar stud_no PK,FK
        varchar reg_fee_kind
        varchar reason
        varchar new_yn
        varchar year
        varchar quarter
        varchar enroll_date
        timestamp reg_date
        varchar reg_id
        timestamp mod_date
        varchar mod_id
    }

    toyo_stud_field_attend {
        varchar enroll_date PK
        varchar ban PK,FK
        varchar stud_no PK,FK
        varchar field_attend_kind
        varchar reason
        varchar field_attend_nausea
        varchar field_attend_bus
        varchar field_attend_insurance
        varchar confirm_yn
        timestamp reg_date
        varchar reg_id
        timestamp mod_date
        varchar mod_id
    }

    toyo_stud_bible_memory {
        varchar enroll_date PK
        varchar ban PK,FK
        varchar stud_no PK,FK
        varchar degree_no
        varchar pass_no
        timestamp reg_date
        varchar reg_id
        timestamp mod_date
        varchar mod_id
        varchar present
        varchar bible_chul
    }

    toyo_stud_chul {
        varchar enroll_date PK
        varchar ban PK,FK
        varchar stud_no PK,FK
        varchar chul_kind
        varchar reason
        timestamp reg_date
        varchar reg_id
        timestamp mod_date
        varchar mod_id
    }

    toyo_stud_dream {
        varchar enroll_date PK
        varchar ban PK,FK
        varchar stud_no PK,FK
        varchar dream_kind_1
        varchar dream_kind_2
        varchar dream_kind_3
        varchar use_yn
        timestamp reg_date
        varchar reg_id
        timestamp mod_date
        varchar mod_id
    }

    %% ⚠️ 미사용 확인: toyo_stud_dream_year_course와 컬럼 구성이 완전히 동일한 중복 테이블.
    %% PHP 소스 256개 전체에서 두 테이블 다 참조 0건. 통합 또는 삭제 검토 필요.
    toyo_stud_dream_course {
        varchar stud_no PK,FK
        varchar year PK
        varchar quarter PK
        varchar dream_kind PK,FK
        varchar use_yn
        timestamp reg_date
        varchar reg_id
        timestamp mod_date
        varchar mod_id
    }

    %% ⚠️ 미사용 확인: toyo_stud_dream_course와 컬럼 구성이 완전히 동일한 중복 테이블.
    %% PHP 소스 256개 전체에서 두 테이블 다 참조 0건. 통합 또는 삭제 검토 필요.
    toyo_stud_dream_year_course {
        varchar stud_no PK,FK
        varchar year PK
        varchar quarter PK
        varchar dream_kind PK,FK
        varchar use_yn
        timestamp reg_date
        varchar reg_id
        timestamp mod_date
        varchar mod_id
    }

    toyo_stud_memory {
        varchar enroll_date PK
        varchar ban PK,FK
        varchar stud_no PK,FK
        varchar memory_kind_1
        varchar memory_kind_2
        varchar memory_kind_3
        timestamp reg_date
        varchar reg_id
        timestamp mod_date
        varchar mod_id
    }

    toyo_stud_score {
        varchar enroll_date PK
        varchar ban PK,FK
        varchar stud_no PK,FK
        varchar subject PK,FK
        integer score
        timestamp reg_date
        varchar reg_id
        timestamp mod_date
        varchar mod_id
    }

    %% ⚠️ 미사용 확인: PHP 소스 256개 전체에서 이 테이블 참조 0건 (INSERT/SELECT 모두 없음).
    %% 이력 적재 로직이 DB 트리거 등 이 코드셋 밖에 존재하는지 확인 필요.
    toyo_stud_score_hist {
        integer seq PK
        varchar gubun PK
        varchar enroll_date PK
        varchar ban PK,FK
        varchar stud_no PK,FK
        varchar subject PK,FK
        integer score
        timestamp reg_date
        varchar reg_id
        timestamp mod_date
        varchar mod_id
    }

    toyo_teacher_chul {
        varchar enroll_date PK
        varchar teacher_kind PK,FK
        varchar ban PK,FK
        varchar chul_yn
        varchar reason
        timestamp reg_date
        varchar reg_id
        timestamp mod_date
        varchar mod_id
    }

    toyo_team_game_score {
        varchar enroll_date PK
        varchar kind PK
        varchar team PK
        integer score
        varchar display_yn
        timestamp reg_date
        varchar reg_id
        timestamp mod_date
        varchar mod_id
    }

    toyo_team_game_score_rows {
        varchar enroll_date PK
        varchar kind PK
        varchar team PK
        integer seq PK
        integer score
        timestamp reg_date
        varchar reg_id
        timestamp mod_date
        varchar mod_id
    }

    toyo_team_score_plus {
        varchar enroll_date PK
        varchar kind PK
        varchar ban PK
        varchar team PK
        integer score
        timestamp reg_date
        varchar reg_id
        timestamp mod_date
        varchar mod_id
    }

    toyo_point {
        varchar enroll_date PK
        varchar kind PK,FK
        varchar stud_no PK,FK
        varchar point
        varchar etc
        varchar ban FK
        varchar team
        varchar top_team_kor
        varchar chul_kind
        varchar point_reg_kind
        varchar point_event_kind
        timestamp reg_date
        varchar reg_id
        timestamp mod_date
        varchar mod_id
    }

    toyo_point_payment {
        varchar enroll_date PK
        varchar stud_no PK,FK
        varchar point
        varchar etc
        timestamp reg_date
        varchar reg_id
        timestamp mod_date
        varchar mod_id
    }

    toyo_reg_date_poss {
        varchar seq PK
        varchar poss_date PK
        varchar use_yn
        timestamp reg_date
        varchar reg_id
        timestamp mod_date
        varchar mod_id
    }

    toyo_notice_info {
        varchar notice_no PK
        varchar title
        varchar contents
        varchar notice_start_date
        varchar notice_end_date
        varchar use_yn
        timestamp reg_date
        varchar reg_id
        timestamp mod_date
        varchar mod_id
    }

    toyo_ban_code_name ||--o{ toyo_stud_info : "ban FK"
    toyo_dream_kind ||--o{ toyo_stud_info : "dream_kind FK"
    toyo_ban_code_name ||--o{ toyo_stud_2hakgi_info : "ban FK"
    toyo_stud_info ||--o{ toyo_stud_2hakgi_info : "stud_no FK"
    toyo_stud_info ||--o{ toyo_stud_2hakgi_new_info : "stud_no FK"
    toyo_stud_info ||--o{ toyo_stud_new_info : "stud_no FK"
    toyo_stud_info ||--o{ toyo_stud_reg_fee : "stud_no FK"
    toyo_ban_code_name ||--o{ toyo_stud_field_attend : "ban FK"
    toyo_stud_info ||--o{ toyo_stud_field_attend : "stud_no FK"
    toyo_ban_code_name ||--o{ toyo_stud_bible_memory : "ban FK"
    toyo_stud_info ||--o{ toyo_stud_bible_memory : "stud_no FK"
    toyo_ban_code_name ||--o{ toyo_stud_chul : "ban FK"
    toyo_stud_info ||--o{ toyo_stud_chul : "stud_no FK"
    toyo_ban_code_name ||--o{ toyo_stud_dream : "ban FK"
    toyo_stud_info ||--o{ toyo_stud_dream : "stud_no FK"
    toyo_stud_info ||--o{ toyo_stud_dream_course : "stud_no FK"
    toyo_dream_kind ||--o{ toyo_stud_dream_course : "dream_kind FK"
    toyo_stud_info ||--o{ toyo_stud_dream_year_course : "stud_no FK"
    toyo_dream_kind ||--o{ toyo_stud_dream_year_course : "dream_kind FK"
    toyo_dream_kind ||--o{ toyo_stud_dream_support_grade : "dream_kind FK"
    toyo_ban_code_name ||--o{ toyo_stud_memory : "ban FK"
    toyo_stud_info ||--o{ toyo_stud_memory : "stud_no FK"
    toyo_ban_code_name ||--o{ toyo_stud_score : "ban FK"
    toyo_stud_info ||--o{ toyo_stud_score : "stud_no FK"
    toyo_stud_code_name ||--o{ toyo_stud_score : "subject FK"
    toyo_ban_code_name ||--o{ toyo_stud_score_hist : "ban FK"
    toyo_stud_info ||--o{ toyo_stud_score_hist : "stud_no FK"
    toyo_stud_code_name ||--o{ toyo_stud_score_hist : "subject FK"
    toyo_ban_code_name ||--o{ toyo_teacher_chul : "ban FK"
    toyo_teacher_chul_code_name ||--o{ toyo_teacher_chul : "teacher_kind+ban FK"
    toyo_ban_code_name ||--o{ toyo_teacher_chul_code_name : "ban FK"
    toyo_id_info ||--o{ toyo_id_info_hist : "id FK"
    toyo_ban_code_name ||--o{ toyo_point : "ban FK"
    toyo_stud_info ||--o{ toyo_point : "stud_no FK"
    toyo_kind_name ||--o{ toyo_point : "kind FK"
    toyo_stud_info ||--o{ toyo_point_payment : "stud_no FK"
```

---

## 검증 요약표

| 구분 | 내용 | 조치 |
|---|---|---|
| 테이블 커버리지 | 원본 56개 중 실사용 34개 + md5enc, 100% 일치 | 변경 없음 |
| PK/FK 전제 | 원본에 PK/FK/INDEX 전무 → ERD는 역설계 결과 | 상단 각주 추가 |
| `toyo_code_name` | 20개+ 컬럼의 소프트 참조 마스터인데 고립 노드 | 주석으로 관계 명시 |
| `toyo_stud_code_name` | 코드 미사용 (0건) | ⚠️ 플래그, 유지여부 확인 |
| `toyo_stud_dream_support_grade` | 코드 미사용 (0건) | ⚠️ 플래그, 유지여부 확인 |
| `toyo_stud_score_hist` | 코드 미사용 (0건) | ⚠️ 플래그, 유지여부 확인 |
| `toyo_stud_dream_course` / `_year_course` | 완전 동일 구조 중복, 둘 다 미사용 | ⚠️ 통합/삭제 검토 |
| `md5enc` | 하드코딩 관리자 인증 게이트, 원본 PK 없음 | 특수목적 주석 추가 |
| `dream_kind_1/2/3` 반복 컬럼 | 1NF 위반 (비정규화) | 비고 추가, FK 표현 불가 사유 명시 |
| `_ENC` 컬럼 암호화 방식 | `AES_ENCRYPT` + DB 루트 비번 재사용 | 별도 문서에 pgcrypto 전환 계획 필요 (ERD 범위 밖) |





## 3-2. DDL — 재검증 결과

> 첨부된 `3-2. DDL(기존).md`를 `toyo테이블스키마DB_덤프.sql`(원본 컬럼 정의) 및 `phpcssjs소스.zip`(실제 WHERE/UPDATE 쿼리)과 전수 대조했다. **테이블 34개 전체의 컬럼명·타입·길이·NOT NULL은 프로그램으로 diff한 결과 전부 정확했다.** 문제는 컬럼 단위가 아니라 ①일부 테이블의 **PK 구성**, ②전체 FK에 일괄 적용된 **CASCADE 정책**, ③업무 테이블이 아닌 **`md5enc` 테이블 포함** 3가지였다. 아래에 근거와 함께 정리하고, 하단에 수정본 전체를 첨부한다.

---

### 검증 결과 1 — 제거 대상: `md5enc` 테이블

기존 문서는 "제외: 백업/임시/pack/날짜suffix 테이블, MySQL 시스템 테이블"이라고 명시했지만 `md5enc`가 그대로 포함되어 있었다. 이 테이블은 `SEQ, USERID, PASSWD(32자리)`만 있는 독립 테이블로, `TOYO_ID_INFO`(실제 로그인 계정)와 어떤 FK로도 연결되지 않고 `phpcssjs소스.zip` 256개 파일 어디에서도 참조되지 않는다. MD5 해시 연습용으로 만들어졌다가 방치된 것으로 보이는 **업무 무관 테이블**이므로 스키마에서 제외했다.

---

### 검증 결과 2 — PK 구성 오류 2건 (코드로 직접 확인)

| 테이블 | 기존 문서 PK | 실제 코드 근거 | 수정 |
|---|---|---|---|
| `toyo_reg_date_poss` | `(seq, poss_date)` | `banRegDatePossModifyProc.php` 80행: `WHERE SEQ = '$SEQ'` — **SEQ 단독**으로 행을 특정 | `(seq)` |
| `toyo_stud_score_hist` | `(seq, gubun, enroll_date, ban, stud_no, subject)` | `seq`를 `GENERATED BY DEFAULT AS IDENTITY`(자동 증가 서로게이트 키)로 선언해 놓고 정작 PK는 6개 컬럼 전부를 묶었다 — 서로게이트 키를 쓰는 의미가 없어짐. 원본 트리거(`TOYO_STUD_SCORE_TRI_INSERT`)도 `SEQ`에만 값을 맡기고 나머지로 유일성을 판단하지 않았다 | `(seq)` |

---

### 검증 결과 3 — PK에서 `ban` 제거 권고 (6개 테이블)

`toyo_stud_chul`, `toyo_stud_field_attend`, `toyo_stud_score`, `toyo_stud_bible_memory`, `toyo_stud_memory`, `toyo_stud_dream` 6개 테이블은 PK가 `(enroll_date, ban, stud_no, ...)`로 되어 있다. 그런데 **같은 패턴의 `toyo_point` 테이블만 유일하게 PK가 `(enroll_date, kind, stud_no)`로 `ban`이 빠져 있다** — `banStudPointEventModifyProc.php` 246행에서 `WHERE ENROLL_DATE=? AND KIND=? AND STUD_NO=?`로 직접 확인된다.

학생은 특정 날짜에 반이 하나뿐이므로 `ban`은 `(enroll_date, stud_no)`에 함수적으로 종속된 값이다 — PK에 넣어도 오류는 아니지만, **더 넓은 키일수록 "같은 날 같은 학생이 다른 반으로 중복 입력되는" 실수를 걸러내지 못한다**(좁은 키가 더 엄격한 제약이다). 코드로 실측된 `toyo_point`의 패턴을 기준으로 나머지 6개도 `ban`을 PK에서 빼고 일반 컬럼(+FK)으로 내렸다.

> ⚠️ 예외: `toyo_stud_dream_course`/`toyo_stud_dream_year_course`의 PK에 `dream_kind`가 들어간 것은 그대로 두었다. 두 테이블은 `phpcssjs소스.zip` 256개 파일 어디서도 참조되지 않는(0건) 미사용 테이블이라 실사용 쿼리로 검증할 방법이 없다 — 임의로 고치지 않고 원안을 유지했다.

---

### 검증 결과 4 (가장 중요) — FK `ON DELETE CASCADE` 전체 통일은 위험하다

기존 문서는 36개 FK 전부를 예외 없이 `CASCADE`로 통일했다. 이건 **이미 이 프로젝트의 3-3 SQLAlchemy 모델 예시에서 스스로 세운 원칙과 어긋난다** — 그 예시는 `user_id`(소유자 참조)는 `CASCADE`, `category_id`(마스터/코드 참조)는 `RESTRICT`로 명확히 구분했다. 이번 DDL은 그 구분을 지키지 않고 전부 CASCADE로 밀었다.

**실제로 얼마나 위험한지 연쇄를 따라가 보면:**

```mermaid
flowchart TD
    A["DELETE FROM toyo_ban_code_name<br/>WHERE ban='003' (반 코드 실수로 삭제)"] --> B["toyo_stud_info<br/>ban='003'인 학생 전원 CASCADE 삭제"]
    B --> C["그 학생들의<br/>toyo_stud_score 전부 CASCADE 삭제"]
    B --> D["그 학생들의<br/>toyo_stud_chul(출석) 전부 CASCADE 삭제"]
    B --> E["그 학생들의<br/>toyo_stud_dream/memory/bible_memory<br/>전부 CASCADE 삭제"]
    B --> F["그 학생들의<br/>toyo_point/point_payment 전부 CASCADE 삭제"]

    style A fill:#FBE1E1,stroke:#C0392B
    style B fill:#FBE1E1,stroke:#C0392B
    style C fill:#FCEFE3,stroke:#D8964C
    style D fill:#FCEFE3,stroke:#D8964C
    style E fill:#FCEFE3,stroke:#D8964C
    style F fill:#FCEFE3,stroke:#D8964C
```

반 코드(`toyo_ban_code_name`) 하나를 잘못 지우면 **그 반 학생 전원의 출석·성적·포인트·진로 기록이 통째로 사라진다.** 실제로 기존 PHP 코드에서 "코드성 마스터"는 하드 `DELETE`가 아니라 `USE_YN='N'`(사용안함) 소프트 삭제로 운영되고 있었다(`banCodeNameModify.php`, `banBibleContestCodeModify.php` 등에서 확인) — 즉 원래 운영 방식 자체가 "코드 마스터는 지우지 않는다"였는데, 신규 DDL이 오히려 "지우면 다 같이 지워진다(CASCADE)"로 더 위험하게 만든 셈이다.

**수정 원칙** (§6 영속화 설계의 FK 위반 처리 원칙과도 일치):

| 참조 대상 | 정책 | 이유 |
|---|---|---|
| `toyo_stud_info.stud_no` (학생 소유 트랜잭션 데이터: 출석/성적/드림/암송/포인트 등) | **CASCADE** | 학생 삭제 시 그 학생의 종속 기록도 함께 정리되는 것이 정상 |
| `toyo_ban_code_name.ban`, `toyo_dream_kind.dream_kind`, `toyo_stud_code_name.subject`, `toyo_kind_name.kind`, `toyo_teacher_chul_code_name(teacher_kind,ban)` (코드성 마스터) | **RESTRICT** | 실수로 코드 하나 지웠다가 대량 연쇄 삭제되는 사고 방지. 삭제하려면 먼저 소속 데이터를 정리하라고 막아야 함 |
| `toyo_id_info.id` ← `toyo_id_info_hist` (로그인 이력) | **RESTRICT** | 시스템 접근 감사 목적 이력은 계정이 남아있는 한 임의로 사라지면 안 됨 |
| `toyo_team_game_score` ← `toyo_team_game_score_rows` (헤더-상세) | **CASCADE** | 상세 행은 헤더에 종속된 데이터, 헤더 삭제 시 함께 정리되는 것이 정상 |

---

### 검증 결과 5 — "미확정 FK 후보"에 대한 재검증

기존 문서가 "확인 필요"로 남겨둔 4개 항목을 실제로 확인했다.

| 항목 | 기존 문서 | 재검증 결과 |
|---|---|---|
| `toyo_team_score_plus.ban VARCHAR(20)` vs `ban_code_name.ban VARCHAR(3)` 길이 불일치 | 확인 필요 | **원본 덤프에서도 실제로 VARCHAR(20)로 선언되어 있음**(레거시 데이터 품질 문제, DDL 작성 실수 아님). 값 자체는 `001`~`009`처럼 3자리 컨벤션을 따르므로 신규 스키마에서는 `VARCHAR(3)`로 좁히고 FK(RESTRICT)를 정상 연결했다 |
| `team_game_score`/`_rows`/`team_score_plus`의 `kind VARCHAR(20)` vs `kind_name.kind VARCHAR(2)` | 확인 필요 | **연결하지 않는 것이 맞다.** `toyo_kind_name`은 포인트 종류 코드(2자리)이고, 팀게임의 `KIND`는 "게임 종류"를 나타내는 자유 문자열로 자릿수부터 다르다 — 컬럼명이 같을 뿐 서로 다른 도메인이다. FK를 억지로 연결하면 오히려 잘못된 제약이 된다 |
| `dream_kind_1/2/3` → `toyo_dream_kind` | 확인 필요 | 컬럼명·값 형식(VARCHAR(3))이 `dream_kind`와 동일해 같은 도메인임이 명확하다. `toyo_stud_new_info`, `toyo_stud_2hakgi_new_info`, `toyo_stud_dream` 3개 테이블에 각 3개씩 FK(RESTRICT) 9개를 추가했다 |
| `toyo_stud_score_hist → toyo_stud_score` 복합 FK | 확인 필요 | **추가하지 않는 것이 맞다.** 이력 테이블은 원본(라이브) 레코드와 생명주기가 달라야 한다 — 원본 성적이 수정/삭제되어도 이력은 그대로 남아있어야 감사 로그로서 의미가 있다. 원본 문서의 "미적용"은 사실 올바른 판단이었다 |

---

### 수정 반영 완료된 DDL 전체

```sql
-- ============================================
-- 토요하자 DB DDL (PostgreSQL 16) — 재검증/수정본
-- 기준: 운영 서버 SQL 덤프(toyo테이블스키마.sql) + phpcssjs소스.zip 실사 코드 교차검증
-- 제외: 백업/임시/pack/날짜suffix 테이블, MySQL 시스템 테이블, md5enc(비업무 테스트 테이블)
-- 정책: REG_DATE/MOD_DATE는 TIMESTAMP로 통일. FK는 참조 대상에 따라
--       CASCADE(학생 소유 트랜잭션 데이터) / RESTRICT(코드성 마스터, 감사이력) 분리 적용(§ 하단 표 참고)
-- ============================================

CREATE TABLE toyo_ban_code_name (
    ban VARCHAR(3),
    ban_name VARCHAR(100),
    ban_hp VARCHAR(100),
    ban_hp_enc BYTEA,
    use_yn VARCHAR(1),
    reg_date TIMESTAMP,
    reg_id VARCHAR(30),
    mod_date TIMESTAMP,
    mod_id VARCHAR(30),
    CONSTRAINT pk_toyo_ban_code_name PRIMARY KEY (ban)
);
CREATE TABLE toyo_ban_menu_name (
    menu VARCHAR(2),
    menu_name VARCHAR(100),
    src_name VARCHAR(100),
    order_by VARCHAR(2),
    mobile_order_by VARCHAR(2),
    level VARCHAR(1),
    group_no VARCHAR(2),
    use_yn VARCHAR(1),
    mobile_use_yn VARCHAR(1),
    menu_code VARCHAR(2),
    reg_date TIMESTAMP,
    reg_id VARCHAR(30),
    mod_date TIMESTAMP,
    mod_id VARCHAR(30),
    go_but_yn VARCHAR(1),
    go_but_nm VARCHAR(20),
    go_but_order_by VARCHAR(2),
    mobile_menu_name VARCHAR(100),
    mobile_but_yn VARCHAR(1),
    mobile_but_nm VARCHAR(20),
    mobile_but_order_by VARCHAR(2),
    CONSTRAINT pk_toyo_ban_menu_name PRIMARY KEY (menu)
);
CREATE TABLE toyo_bible_contest (
    contest_code VARCHAR(3),
    contest_rank VARCHAR(3),
    contest_point VARCHAR(3),
    use_yn VARCHAR(1),
    reg_date TIMESTAMP,
    reg_id VARCHAR(30),
    mod_date TIMESTAMP,
    mod_id VARCHAR(30),
    CONSTRAINT pk_toyo_bible_contest PRIMARY KEY (contest_code)
);
CREATE TABLE toyo_code_name (
    opt VARCHAR(20),
    code VARCHAR(6),
    code_name VARCHAR(100),
    kind_name VARCHAR(200),
    contents VARCHAR(4000),
    use_yn VARCHAR(1),
    reg_date TIMESTAMP,
    reg_id VARCHAR(30),
    mod_date TIMESTAMP,
    mod_id VARCHAR(30),
    CONSTRAINT pk_toyo_code_name PRIMARY KEY (opt, code)
);
CREATE TABLE toyo_dream_kind (
    dream_kind VARCHAR(3),
    dream_kind_name VARCHAR(100),
    grade VARCHAR(10),
    year_course VARCHAR(1),
    year VARCHAR(4),
    quarter VARCHAR(1),
    use_yn VARCHAR(1),
    reg_date TIMESTAMP,
    reg_id VARCHAR(30),
    mod_date TIMESTAMP,
    mod_id VARCHAR(30),
    CONSTRAINT pk_toyo_dream_kind PRIMARY KEY (dream_kind)
);
CREATE TABLE toyo_kind_name (
    kind VARCHAR(2),
    kind_name VARCHAR(100),
    use_yn VARCHAR(1),
    reg_date TIMESTAMP,
    reg_id VARCHAR(30),
    mod_date TIMESTAMP,
    mod_id VARCHAR(30),
    CONSTRAINT pk_toyo_kind_name PRIMARY KEY (kind)
);
CREATE TABLE toyo_stud_code_name (
    subject VARCHAR(3),
    subject_name VARCHAR(100),
    reg_date TIMESTAMP,
    reg_id VARCHAR(30),
    mod_date TIMESTAMP,
    mod_id VARCHAR(30),
    CONSTRAINT pk_toyo_stud_code_name PRIMARY KEY (subject)
);
CREATE TABLE toyo_stud_dream_support_grade (
    dream_kind VARCHAR(3),
    support_grade VARCHAR(6),
    use_yn VARCHAR(1),
    reg_date TIMESTAMP,
    reg_id VARCHAR(30),
    mod_date TIMESTAMP,
    mod_id VARCHAR(30),
    CONSTRAINT pk_toyo_stud_dream_support_grade PRIMARY KEY (dream_kind)
);
CREATE TABLE toyo_stud_field_attend_teacher (
    teacher_no VARCHAR(5),
    teacher_name VARCHAR(100),
    sex VARCHAR(1),
    hp VARCHAR(11),
    field_attend_kind VARCHAR(2),
    field_attend_nausea VARCHAR(2),
    field_attend_bus VARCHAR(2),
    teacher_kind VARCHAR(2),
    field_attend_insurance VARCHAR(2),
    use_yn VARCHAR(1),
    reg_date TIMESTAMP,
    reg_id VARCHAR(30),
    mod_date TIMESTAMP,
    mod_id VARCHAR(30),
    reason VARCHAR(200),
    CONSTRAINT pk_toyo_stud_field_attend_teacher PRIMARY KEY (teacher_no)
);
CREATE TABLE toyo_teacher_chul_code_name (
    teacher_kind VARCHAR(2),
    ban VARCHAR(3),
    ban_name VARCHAR(100),
    use_yn VARCHAR(1),
    reg_date TIMESTAMP,
    reg_id VARCHAR(30),
    mod_date TIMESTAMP,
    mod_id VARCHAR(30),
    CONSTRAINT pk_toyo_teacher_chul_code_name PRIMARY KEY (teacher_kind, ban)
);
CREATE TABLE toyo_id_info (
    id VARCHAR(20),
    passwd VARCHAR(64) NOT NULL,
    k_name VARCHAR(64) NOT NULL,
    use_yn VARCHAR(1),
    ssn VARCHAR(4),
    token VARCHAR(200),
    auth VARCHAR(2),
    login_first_time TIMESTAMP,
    login_last_time TIMESTAMP,
    reg_date TIMESTAMP,
    reg_id VARCHAR(30),
    mod_date TIMESTAMP,
    mod_id VARCHAR(30),
    id_img_path VARCHAR(200),
    id_img_name VARCHAR(200),
    group_code VARCHAR(2),
    teacher_hp_no_enc BYTEA,
    CONSTRAINT pk_toyo_id_info PRIMARY KEY (id)
);
CREATE TABLE toyo_id_info_hist (
    id VARCHAR(20),
    enroll_date VARCHAR(8),
    mac_address VARCHAR(100),
    reg_date TIMESTAMP,
    reg_id VARCHAR(30),
    mod_date TIMESTAMP,
    mod_id VARCHAR(30),
    CONSTRAINT pk_toyo_id_info_hist PRIMARY KEY (id, enroll_date)
);
CREATE TABLE toyo_stud_info (
    stud_no VARCHAR(5),
    ban VARCHAR(3),
    stud_name VARCHAR(100),
    grade VARCHAR(1),
    team VARCHAR(20),
    sex VARCHAR(1),
    one_year_yn VARCHAR(1),
    dream_kind VARCHAR(3),
    parents_no_hp_enc BYTEA,
    use_yn VARCHAR(1),
    reg_date TIMESTAMP,
    reg_id VARCHAR(30),
    mod_date TIMESTAMP,
    mod_id VARCHAR(30),
    attend_yn VARCHAR(1),
    stud_img_path VARCHAR(200),
    stud_img_name VARCHAR(200),
    parents_name VARCHAR(20),
    CONSTRAINT pk_toyo_stud_info PRIMARY KEY (stud_no)
);
CREATE TABLE toyo_stud_2hakgi_info (
    stud_no VARCHAR(5),
    ban VARCHAR(3),
    stud_name VARCHAR(100),
    grade VARCHAR(1),
    team VARCHAR(20),
    rereg_kind VARCHAR(2),
    reason VARCHAR(200),
    enroll_date VARCHAR(8),
    reg_date TIMESTAMP,
    reg_id VARCHAR(30),
    mod_date TIMESTAMP,
    mod_id VARCHAR(30),
    CONSTRAINT pk_toyo_stud_2hakgi_info PRIMARY KEY (stud_no)
);
CREATE TABLE toyo_stud_2hakgi_new_info (
    stud_no VARCHAR(5),
    stud_name VARCHAR(100),
    sex VARCHAR(1),
    grade VARCHAR(1),
    parent_name VARCHAR(20),
    parent_hp VARCHAR(11),
    request_teacher_name VARCHAR(20),
    request_method VARCHAR(100),
    church_reg_status VARCHAR(3),
    etc VARCHAR(400),
    reg_fee_kind VARCHAR(2),
    progress_status VARCHAR(3),
    enroll_date VARCHAR(8),
    reg_date TIMESTAMP,
    reg_id VARCHAR(30),
    mod_date TIMESTAMP,
    mod_id VARCHAR(30),
    dream_kind_1 VARCHAR(3),
    dream_kind_2 VARCHAR(3),
    dream_kind_3 VARCHAR(3),
    CONSTRAINT pk_toyo_stud_2hakgi_new_info PRIMARY KEY (stud_no)
);
CREATE TABLE toyo_stud_new_info (
    stud_no VARCHAR(5),
    stud_name VARCHAR(100),
    sex VARCHAR(1),
    grade VARCHAR(1),
    parent_name VARCHAR(20),
    parent_hp VARCHAR(11),
    request_teacher_name VARCHAR(20),
    request_method VARCHAR(100),
    church_reg_status VARCHAR(3),
    etc VARCHAR(400),
    reg_fee_kind VARCHAR(2),
    progress_status VARCHAR(3),
    enroll_date VARCHAR(8),
    reg_date TIMESTAMP,
    reg_id VARCHAR(30),
    mod_date TIMESTAMP,
    mod_id VARCHAR(30),
    dream_kind_1 VARCHAR(3),
    dream_kind_2 VARCHAR(3),
    dream_kind_3 VARCHAR(3),
    CONSTRAINT pk_toyo_stud_new_info PRIMARY KEY (stud_no)
);
CREATE TABLE toyo_stud_reg_fee (
    stud_no VARCHAR(5),
    reg_fee_kind VARCHAR(2),
    reason VARCHAR(200),
    new_yn VARCHAR(1),
    year VARCHAR(4),
    quarter VARCHAR(1),
    enroll_date VARCHAR(8),
    reg_date TIMESTAMP,
    reg_id VARCHAR(30),
    mod_date TIMESTAMP,
    mod_id VARCHAR(30),
    CONSTRAINT pk_toyo_stud_reg_fee PRIMARY KEY (stud_no)
);
CREATE TABLE toyo_stud_field_attend (
    enroll_date VARCHAR(8),
    ban VARCHAR(3),
    stud_no VARCHAR(5),
    field_attend_kind VARCHAR(2),
    reason VARCHAR(200),
    field_attend_nausea VARCHAR(2),
    field_attend_bus VARCHAR(2),
    field_attend_insurance VARCHAR(2) NOT NULL,
    confirm_yn VARCHAR(1),
    reg_date TIMESTAMP,
    reg_id VARCHAR(30),
    mod_date TIMESTAMP,
    mod_id VARCHAR(30),
    CONSTRAINT pk_toyo_stud_field_attend PRIMARY KEY (enroll_date, stud_no)
);
CREATE TABLE toyo_stud_bible_memory (
    enroll_date VARCHAR(8),
    ban VARCHAR(3),
    stud_no VARCHAR(5),
    degree_no VARCHAR(2),
    pass_no VARCHAR(2),
    reg_date TIMESTAMP,
    reg_id VARCHAR(30),
    mod_date TIMESTAMP,
    mod_id VARCHAR(30),
    present VARCHAR(3),
    bible_chul VARCHAR(2),
    CONSTRAINT pk_toyo_stud_bible_memory PRIMARY KEY (enroll_date, stud_no)
);
CREATE TABLE toyo_stud_chul (
    enroll_date VARCHAR(8),
    ban VARCHAR(3),
    stud_no VARCHAR(5),
    chul_kind VARCHAR(2),
    reason VARCHAR(200),
    reg_date TIMESTAMP,
    reg_id VARCHAR(30),
    mod_date TIMESTAMP,
    mod_id VARCHAR(30),
    CONSTRAINT pk_toyo_stud_chul PRIMARY KEY (enroll_date, stud_no)
);
CREATE TABLE toyo_stud_dream (
    enroll_date VARCHAR(8),
    ban VARCHAR(3),
    stud_no VARCHAR(5),
    dream_kind_1 VARCHAR(3),
    dream_kind_2 VARCHAR(3),
    dream_kind_3 VARCHAR(3),
    use_yn VARCHAR(1),
    reg_date TIMESTAMP,
    reg_id VARCHAR(30),
    mod_date TIMESTAMP,
    mod_id VARCHAR(30),
    CONSTRAINT pk_toyo_stud_dream PRIMARY KEY (enroll_date, stud_no)
);
CREATE TABLE toyo_stud_dream_course (
    stud_no VARCHAR(5),
    year VARCHAR(4),
    quarter VARCHAR(1),
    dream_kind VARCHAR(3),
    use_yn VARCHAR(1),
    reg_date TIMESTAMP,
    reg_id VARCHAR(30),
    mod_date TIMESTAMP,
    mod_id VARCHAR(30),
    CONSTRAINT pk_toyo_stud_dream_course PRIMARY KEY (stud_no, year, quarter, dream_kind)
);
CREATE TABLE toyo_stud_dream_year_course (
    stud_no VARCHAR(5),
    year VARCHAR(4),
    quarter VARCHAR(1),
    dream_kind VARCHAR(3),
    use_yn VARCHAR(1),
    reg_date TIMESTAMP,
    reg_id VARCHAR(30),
    mod_date TIMESTAMP,
    mod_id VARCHAR(30),
    CONSTRAINT pk_toyo_stud_dream_year_course PRIMARY KEY (stud_no, year, quarter, dream_kind)
);
CREATE TABLE toyo_stud_memory (
    enroll_date VARCHAR(8),
    ban VARCHAR(3),
    stud_no VARCHAR(5),
    memory_kind_1 VARCHAR(3),
    memory_kind_2 VARCHAR(3),
    memory_kind_3 VARCHAR(3),
    reg_date TIMESTAMP,
    reg_id VARCHAR(30),
    mod_date TIMESTAMP,
    mod_id VARCHAR(30),
    CONSTRAINT pk_toyo_stud_memory PRIMARY KEY (enroll_date, stud_no)
);
CREATE TABLE toyo_stud_score (
    enroll_date VARCHAR(8),
    ban VARCHAR(3),
    stud_no VARCHAR(5),
    subject VARCHAR(3),
    score INTEGER,
    reg_date TIMESTAMP,
    reg_id VARCHAR(30),
    mod_date TIMESTAMP,
    mod_id VARCHAR(30),
    CONSTRAINT pk_toyo_stud_score PRIMARY KEY (enroll_date, stud_no, subject)
);
CREATE TABLE toyo_stud_score_hist (
    seq INTEGER GENERATED BY DEFAULT AS IDENTITY,
    gubun VARCHAR(1),
    enroll_date VARCHAR(8),
    ban VARCHAR(3),
    stud_no VARCHAR(5),
    subject VARCHAR(3),
    score INTEGER,
    reg_date TIMESTAMP,
    reg_id VARCHAR(30),
    mod_date TIMESTAMP,
    mod_id VARCHAR(30),
    CONSTRAINT pk_toyo_stud_score_hist PRIMARY KEY (seq)
);
CREATE TABLE toyo_teacher_chul (
    enroll_date VARCHAR(8),
    teacher_kind VARCHAR(2),
    ban VARCHAR(3),
    chul_yn VARCHAR(1),
    reason VARCHAR(200),
    reg_date TIMESTAMP,
    reg_id VARCHAR(30),
    mod_date TIMESTAMP,
    mod_id VARCHAR(30),
    CONSTRAINT pk_toyo_teacher_chul PRIMARY KEY (enroll_date, teacher_kind, ban)
);
CREATE TABLE toyo_team_game_score (
    enroll_date VARCHAR(8),
    kind VARCHAR(20),
    team VARCHAR(20),
    score INTEGER,
    display_yn VARCHAR(100),
    reg_date TIMESTAMP,
    reg_id VARCHAR(30),
    mod_date TIMESTAMP,
    mod_id VARCHAR(30),
    CONSTRAINT pk_toyo_team_game_score PRIMARY KEY (enroll_date, kind, team)
);
CREATE TABLE toyo_team_game_score_rows (
    enroll_date VARCHAR(8),
    kind VARCHAR(20),
    team VARCHAR(20),
    seq INTEGER,
    score INTEGER,
    reg_date TIMESTAMP,
    reg_id VARCHAR(30),
    mod_date TIMESTAMP,
    mod_id VARCHAR(30),
    CONSTRAINT pk_toyo_team_game_score_rows PRIMARY KEY (enroll_date, kind, team, seq)
);
CREATE TABLE toyo_team_score_plus (
    enroll_date VARCHAR(8),
    kind VARCHAR(20),
    ban VARCHAR(3),
    team VARCHAR(20),
    score INTEGER,
    reg_date TIMESTAMP,
    reg_id VARCHAR(30),
    mod_date TIMESTAMP,
    mod_id VARCHAR(30),
    CONSTRAINT pk_toyo_team_score_plus PRIMARY KEY (enroll_date, kind, ban, team)
);
CREATE TABLE toyo_point (
    enroll_date VARCHAR(8),
    kind VARCHAR(2),
    stud_no VARCHAR(5),
    point VARCHAR(3),
    etc VARCHAR(400),
    ban VARCHAR(3),
    team VARCHAR(20),
    top_team_kor VARCHAR(400),
    chul_kind VARCHAR(2),
    point_reg_kind VARCHAR(2),
    point_event_kind VARCHAR(2),
    reg_date TIMESTAMP,
    reg_id VARCHAR(30),
    mod_date TIMESTAMP,
    mod_id VARCHAR(30),
    CONSTRAINT pk_toyo_point PRIMARY KEY (enroll_date, kind, stud_no)
);
CREATE TABLE toyo_point_payment (
    enroll_date VARCHAR(8),
    stud_no VARCHAR(5),
    point VARCHAR(3),
    etc VARCHAR(400),
    reg_date TIMESTAMP,
    reg_id VARCHAR(30),
    mod_date TIMESTAMP,
    mod_id VARCHAR(30),
    CONSTRAINT pk_toyo_point_payment PRIMARY KEY (enroll_date, stud_no)
);
CREATE TABLE toyo_reg_date_poss (
    seq VARCHAR(3),
    poss_date VARCHAR(8),
    use_yn VARCHAR(1),
    reg_date TIMESTAMP,
    reg_id VARCHAR(30),
    mod_date TIMESTAMP,
    mod_id VARCHAR(30),
    CONSTRAINT pk_toyo_reg_date_poss PRIMARY KEY (seq)
);
CREATE TABLE toyo_notice_info (
    notice_no VARCHAR(5),
    title VARCHAR(200) NOT NULL,
    contents VARCHAR(4000) NOT NULL,
    notice_start_date VARCHAR(8),
    notice_end_date VARCHAR(8),
    use_yn VARCHAR(1),
    reg_date TIMESTAMP,
    reg_id VARCHAR(30),
    mod_date TIMESTAMP,
    mod_id VARCHAR(30),
    CONSTRAINT pk_toyo_notice_info PRIMARY KEY (notice_no)
);

-- ============================================
-- Foreign Key 제약
-- 원칙: stud_no(학생 소유 트랜잭션 데이터) 참조 = ON DELETE CASCADE
--       코드성 마스터(ban/dream_kind/subject/kind/teacher_kind+ban) 참조 = ON DELETE RESTRICT
--       계정 접근감사 이력(id_info_hist) = ON DELETE RESTRICT (계정 삭제와 무관하게 이력 보존)
-- ============================================

-- [CASCADE] 학생(stud_no) 소유 트랜잭션 데이터 — 학생 삭제 시 함께 삭제
ALTER TABLE toyo_stud_2hakgi_info ADD CONSTRAINT fk_toyo_stud_2hakgi_info_stud_no FOREIGN KEY (stud_no) REFERENCES toyo_stud_info (stud_no) ON DELETE CASCADE;
ALTER TABLE toyo_stud_2hakgi_new_info ADD CONSTRAINT fk_toyo_stud_2hakgi_new_info_stud_no FOREIGN KEY (stud_no) REFERENCES toyo_stud_info (stud_no) ON DELETE CASCADE;
ALTER TABLE toyo_stud_new_info ADD CONSTRAINT fk_toyo_stud_new_info_stud_no FOREIGN KEY (stud_no) REFERENCES toyo_stud_info (stud_no) ON DELETE CASCADE;
ALTER TABLE toyo_stud_reg_fee ADD CONSTRAINT fk_toyo_stud_reg_fee_stud_no FOREIGN KEY (stud_no) REFERENCES toyo_stud_info (stud_no) ON DELETE CASCADE;
ALTER TABLE toyo_stud_field_attend ADD CONSTRAINT fk_toyo_stud_field_attend_stud_no FOREIGN KEY (stud_no) REFERENCES toyo_stud_info (stud_no) ON DELETE CASCADE;
ALTER TABLE toyo_stud_bible_memory ADD CONSTRAINT fk_toyo_stud_bible_memory_stud_no FOREIGN KEY (stud_no) REFERENCES toyo_stud_info (stud_no) ON DELETE CASCADE;
ALTER TABLE toyo_stud_chul ADD CONSTRAINT fk_toyo_stud_chul_stud_no FOREIGN KEY (stud_no) REFERENCES toyo_stud_info (stud_no) ON DELETE CASCADE;
ALTER TABLE toyo_stud_dream ADD CONSTRAINT fk_toyo_stud_dream_stud_no FOREIGN KEY (stud_no) REFERENCES toyo_stud_info (stud_no) ON DELETE CASCADE;
ALTER TABLE toyo_stud_dream_course ADD CONSTRAINT fk_toyo_stud_dream_course_stud_no FOREIGN KEY (stud_no) REFERENCES toyo_stud_info (stud_no) ON DELETE CASCADE;
ALTER TABLE toyo_stud_dream_year_course ADD CONSTRAINT fk_toyo_stud_dream_year_course_stud_no FOREIGN KEY (stud_no) REFERENCES toyo_stud_info (stud_no) ON DELETE CASCADE;
ALTER TABLE toyo_stud_memory ADD CONSTRAINT fk_toyo_stud_memory_stud_no FOREIGN KEY (stud_no) REFERENCES toyo_stud_info (stud_no) ON DELETE CASCADE;
ALTER TABLE toyo_stud_score ADD CONSTRAINT fk_toyo_stud_score_stud_no FOREIGN KEY (stud_no) REFERENCES toyo_stud_info (stud_no) ON DELETE CASCADE;
ALTER TABLE toyo_stud_score_hist ADD CONSTRAINT fk_toyo_stud_score_hist_stud_no FOREIGN KEY (stud_no) REFERENCES toyo_stud_info (stud_no) ON DELETE CASCADE;
ALTER TABLE toyo_point ADD CONSTRAINT fk_toyo_point_stud_no FOREIGN KEY (stud_no) REFERENCES toyo_stud_info (stud_no) ON DELETE CASCADE;
ALTER TABLE toyo_point_payment ADD CONSTRAINT fk_toyo_point_payment_stud_no FOREIGN KEY (stud_no) REFERENCES toyo_stud_info (stud_no) ON DELETE CASCADE;

-- [CASCADE] 상세 행 — 헤더(팀게임 점수) 소유, 헤더 삭제 시 상세도 함께 삭제
ALTER TABLE toyo_team_game_score_rows ADD CONSTRAINT fk_toyo_team_game_score_rows_header FOREIGN KEY (enroll_date, kind, team) REFERENCES toyo_team_game_score (enroll_date, kind, team) ON DELETE CASCADE;

-- [RESTRICT] 코드성 마스터(ban) 참조 — 소속 데이터가 있으면 코드 삭제 자체를 차단
ALTER TABLE toyo_stud_info ADD CONSTRAINT fk_toyo_stud_info_ban FOREIGN KEY (ban) REFERENCES toyo_ban_code_name (ban) ON DELETE RESTRICT;
ALTER TABLE toyo_stud_2hakgi_info ADD CONSTRAINT fk_toyo_stud_2hakgi_info_ban FOREIGN KEY (ban) REFERENCES toyo_ban_code_name (ban) ON DELETE RESTRICT;
ALTER TABLE toyo_stud_field_attend ADD CONSTRAINT fk_toyo_stud_field_attend_ban FOREIGN KEY (ban) REFERENCES toyo_ban_code_name (ban) ON DELETE RESTRICT;
ALTER TABLE toyo_stud_bible_memory ADD CONSTRAINT fk_toyo_stud_bible_memory_ban FOREIGN KEY (ban) REFERENCES toyo_ban_code_name (ban) ON DELETE RESTRICT;
ALTER TABLE toyo_stud_chul ADD CONSTRAINT fk_toyo_stud_chul_ban FOREIGN KEY (ban) REFERENCES toyo_ban_code_name (ban) ON DELETE RESTRICT;
ALTER TABLE toyo_stud_dream ADD CONSTRAINT fk_toyo_stud_dream_ban FOREIGN KEY (ban) REFERENCES toyo_ban_code_name (ban) ON DELETE RESTRICT;
ALTER TABLE toyo_stud_memory ADD CONSTRAINT fk_toyo_stud_memory_ban FOREIGN KEY (ban) REFERENCES toyo_ban_code_name (ban) ON DELETE RESTRICT;
ALTER TABLE toyo_stud_score ADD CONSTRAINT fk_toyo_stud_score_ban FOREIGN KEY (ban) REFERENCES toyo_ban_code_name (ban) ON DELETE RESTRICT;
ALTER TABLE toyo_stud_score_hist ADD CONSTRAINT fk_toyo_stud_score_hist_ban FOREIGN KEY (ban) REFERENCES toyo_ban_code_name (ban) ON DELETE RESTRICT;
ALTER TABLE toyo_teacher_chul ADD CONSTRAINT fk_toyo_teacher_chul_ban FOREIGN KEY (ban) REFERENCES toyo_ban_code_name (ban) ON DELETE RESTRICT;
ALTER TABLE toyo_teacher_chul_code_name ADD CONSTRAINT fk_toyo_teacher_chul_code_name_ban FOREIGN KEY (ban) REFERENCES toyo_ban_code_name (ban) ON DELETE RESTRICT;
ALTER TABLE toyo_point ADD CONSTRAINT fk_toyo_point_ban FOREIGN KEY (ban) REFERENCES toyo_ban_code_name (ban) ON DELETE RESTRICT;
ALTER TABLE toyo_team_score_plus ADD CONSTRAINT fk_toyo_team_score_plus_ban FOREIGN KEY (ban) REFERENCES toyo_ban_code_name (ban) ON DELETE RESTRICT;

-- [RESTRICT] 코드성 마스터(dream_kind) 참조
ALTER TABLE toyo_stud_info ADD CONSTRAINT fk_toyo_stud_info_dream_kind FOREIGN KEY (dream_kind) REFERENCES toyo_dream_kind (dream_kind) ON DELETE RESTRICT;
ALTER TABLE toyo_stud_dream_course ADD CONSTRAINT fk_toyo_stud_dream_course_dream_kind FOREIGN KEY (dream_kind) REFERENCES toyo_dream_kind (dream_kind) ON DELETE RESTRICT;
ALTER TABLE toyo_stud_dream_year_course ADD CONSTRAINT fk_toyo_stud_dream_year_course_dream_kind FOREIGN KEY (dream_kind) REFERENCES toyo_dream_kind (dream_kind) ON DELETE RESTRICT;
ALTER TABLE toyo_stud_dream_support_grade ADD CONSTRAINT fk_toyo_stud_dream_support_grade_dream_kind FOREIGN KEY (dream_kind) REFERENCES toyo_dream_kind (dream_kind) ON DELETE RESTRICT;
ALTER TABLE toyo_stud_new_info ADD CONSTRAINT fk_toyo_stud_new_info_dream_kind_1 FOREIGN KEY (dream_kind_1) REFERENCES toyo_dream_kind (dream_kind) ON DELETE RESTRICT;
ALTER TABLE toyo_stud_new_info ADD CONSTRAINT fk_toyo_stud_new_info_dream_kind_2 FOREIGN KEY (dream_kind_2) REFERENCES toyo_dream_kind (dream_kind) ON DELETE RESTRICT;
ALTER TABLE toyo_stud_new_info ADD CONSTRAINT fk_toyo_stud_new_info_dream_kind_3 FOREIGN KEY (dream_kind_3) REFERENCES toyo_dream_kind (dream_kind) ON DELETE RESTRICT;
ALTER TABLE toyo_stud_2hakgi_new_info ADD CONSTRAINT fk_toyo_stud_2hakgi_new_info_dream_kind_1 FOREIGN KEY (dream_kind_1) REFERENCES toyo_dream_kind (dream_kind) ON DELETE RESTRICT;
ALTER TABLE toyo_stud_2hakgi_new_info ADD CONSTRAINT fk_toyo_stud_2hakgi_new_info_dream_kind_2 FOREIGN KEY (dream_kind_2) REFERENCES toyo_dream_kind (dream_kind) ON DELETE RESTRICT;
ALTER TABLE toyo_stud_2hakgi_new_info ADD CONSTRAINT fk_toyo_stud_2hakgi_new_info_dream_kind_3 FOREIGN KEY (dream_kind_3) REFERENCES toyo_dream_kind (dream_kind) ON DELETE RESTRICT;
ALTER TABLE toyo_stud_dream ADD CONSTRAINT fk_toyo_stud_dream_dream_kind_1 FOREIGN KEY (dream_kind_1) REFERENCES toyo_dream_kind (dream_kind) ON DELETE RESTRICT;
ALTER TABLE toyo_stud_dream ADD CONSTRAINT fk_toyo_stud_dream_dream_kind_2 FOREIGN KEY (dream_kind_2) REFERENCES toyo_dream_kind (dream_kind) ON DELETE RESTRICT;
ALTER TABLE toyo_stud_dream ADD CONSTRAINT fk_toyo_stud_dream_dream_kind_3 FOREIGN KEY (dream_kind_3) REFERENCES toyo_dream_kind (dream_kind) ON DELETE RESTRICT;

-- [RESTRICT] 코드성 마스터(subject/kind) 참조
ALTER TABLE toyo_stud_score ADD CONSTRAINT fk_toyo_stud_score_subject FOREIGN KEY (subject) REFERENCES toyo_stud_code_name (subject) ON DELETE RESTRICT;
ALTER TABLE toyo_stud_score_hist ADD CONSTRAINT fk_toyo_stud_score_hist_subject FOREIGN KEY (subject) REFERENCES toyo_stud_code_name (subject) ON DELETE RESTRICT;
ALTER TABLE toyo_point ADD CONSTRAINT fk_toyo_point_kind FOREIGN KEY (kind) REFERENCES toyo_kind_name (kind) ON DELETE RESTRICT;

-- [RESTRICT] 복합 코드 마스터(teacher_kind, ban) 참조
ALTER TABLE toyo_teacher_chul ADD CONSTRAINT fk_toyo_teacher_chul_teacher_kind_ban FOREIGN KEY (teacher_kind, ban) REFERENCES toyo_teacher_chul_code_name (teacher_kind, ban) ON DELETE RESTRICT;

-- [RESTRICT] 계정 접근감사 이력 — 계정이 존재하는 한 로그인 이력은 보존(계정 삭제 전 이력부터 정리해야 함)
ALTER TABLE toyo_id_info_hist ADD CONSTRAINT fk_toyo_id_info_hist_id FOREIGN KEY (id) REFERENCES toyo_id_info (id) ON DELETE RESTRICT;

```



### 3-3. SQLAlchemy 모델 (최종 통합본)

이 문서는 아래 두 파일을 하나로 합친 것이다.
- `3-3. SQLAlchemy 모델 (예시)(기존).md` → 엔진/세션 부트스트랩 부분만 채택 (`database.py`)
- `3-3. SQLAlchemy 모델 (예시)(신규).md` → 레거시 코드/스키마 대조 검증을 마친 모델 (`models.py`)

**바이브코딩 사용법**: 아래 코드블록 2개를 각각 프로젝트 루트에 `database.py`, `models.py`로 그대로 저장하면 된다. AI 코딩 툴에 "이 문서 기준으로 FastAPI 프로젝트 스캐폴딩 해줘" 라고 넘겨도 파일 경계(`# --- file: xxx.py ---`)를 그대로 인식해서 분리 생성할 수 있게 주석으로 파일 경로를 명시해 두었다.

**의존성**: `pip install "sqlalchemy>=2.0" "psycopg[binary]"` (psycopg2 아님, psycopg3)

---

#### `database.py` — 엔진 / 세션 부트스트랩

```python
# --- file: database.py ---
"""
SQLAlchemy 2.0 엔진 / 세션 부트스트랩

- DB: PostgreSQL 16 (Docker, pg-lab)
- 드라이버: psycopg 3.x (psycopg2 아님) -> "postgresql+psycopg://" 스킴 사용
- models.py 는 여기서 정의한 Base를 그대로 import 해서 사용한다.
"""
import os

from sqlalchemy import create_engine
from sqlalchemy.orm import DeclarativeBase, sessionmaker


class Base(DeclarativeBase):
    pass


# 운영 환경에서는 비밀번호를 코드에 두지 말고 환경변수(.env 등)로 분리할 것.
DATABASE_URL = os.environ.get(
    "DATABASE_URL",
    "postgresql+psycopg://postgres:postgres@localhost:5432/toyo",
)

engine = create_engine(DATABASE_URL, pool_pre_ping=True, echo=False)
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)


def get_db():
    """FastAPI Depends용 세션 제너레이터"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
```

---

#### `models.py` — 검증판 v2 (레거시 PHP 소스 + 스키마 덤프 대조 검증 완료)

```python
# --- file: models.py ---
"""
신규 toyo 프로젝트 SQLAlchemy 모델 (PostgreSQL 16 / psycopg3 / SQLAlchemy 2.0) - 검증판 v2

레거시 PHP+MySQL(MyISAM) 스키마(toyo테이블스키마.sql)를 그대로 이식한 것이 아니라,
새 프로젝트에 맞게 재설계했다. 아래 항목은 레거시 PHP 소스(phpcssjs소스.zip)와
스키마 덤프(toyo테이블스키마DB_덤프.sql)를 실제로 대조 검증하여 확정한 내용이다.

구분          | 레거시(참고용)                       | 신규
-------------|-------------------------------------|--------------------------------
계정         | toyo_id_info                         | Account
세션/로그인  | toyo_id_info.TOKEN, 로그인 이력       | LoginSession
반(class)    | toyo_ban_code_name                    | ClassRoom
학생         | toyo_stud_info                        | Student
반 배정 이력 | toyo_stud_info_pack / *_2hakgi_info 등 | Enrollment (신규)
출석         | toyo_stud_chul                         | Attendance
성적         | toyo_stud_score                        | Score

설계 변경 포인트
    1. 복합 자연키(ENROLL_DATE+BAN+STUD_NO 등) 대신 정수 서러게이트 PK(id) + UniqueConstraint 사용.
    2. varchar(8) 날짜 문자열 -> Date, varchar(1) Y/N -> Boolean, 코드성 컬럼 -> Enum.
    3. 비밀번호는 pwdlib(Argon2) 해시 문자열만 저장.

[치명적 수정 - "기존" 버전의 추정치를 실코드 근거로 교체]
1. Subject enum: bible/attitude/etc(추정) -> 001~005 실제 코드로 교체
   (근거: banScoreModify.php, banScoreRegProc.php)
2. Score.score CHECK(0~100) 제거: 004(암송점수)는 50점 단위로 상한 없이 누적됨
   (근거: MEMORY_VALUE maxlength=4, UI 경고문 "0/50/100/150/200점~")
3. AttendanceStatus에 15=코로나결석 추가 누락분 반영
   (근거: banScoreRegProc.php 등 다수 파일에서 CHUL_KIND==='15' 분기 확인)
4. AccountRole: ADMIN/TEACHER 2종 -> 실제 AUTH 7종 코드로 확장
   (근거: banUserInfoList.php, banOrganChartSelect.php의 AUTH select box)

[구조적 추가]
5. Enrollment(연도/학기별 반 배정 이력) 엔티티 신설
   - 레거시가 *_pack, *_2hakgi_info, 날짜 붙은 *_backup 테이블로 어설프게 흉내내던
     "학생의 반/학년 소속은 학기마다 바뀐다"는 이력 요구사항을 정식으로 모델링.
   - Attendance/Score는 student_id가 아닌 enrollment_id를 참조하여, 과거 시점의
     반 정보가 현재 반 소속으로 왜곡되지 않도록 함.
6. Student.legacy_stud_no 추가: 레거시 STUD_NO(자연키) 보존. 마이그레이션 매핑,
   과도기 병행 운영, 기존 문서/엑셀 참조용으로 반드시 필요.
7. LoginSession: 토큰을 평문이 아닌 해시로 저장(token_hash). 원문은 응답에만 실어 전달.

[범위 외 - 별도 설계 필요, 이 파일에는 미포함]
toyo_point(포인트), toyo_stud_dream*(진로), toyo_bible_contest(성경대회),
toyo_notice_info(공지), toyo_stud_reg_fee(등록비), toyo_stud_field_attend*(수련회 출결),
toyo_team_game_score*(팀게임점수), toyo_teacher_chul(교사출결), 메뉴별 ACL(GROUP_NO/LEVEL).
"""
import enum
import hashlib
import secrets
from datetime import date, datetime

from sqlalchemy import (
    CheckConstraint,
    Date,
    DateTime,
    ForeignKey,
    Integer,
    String,
    UniqueConstraint,
    func,
)
from sqlalchemy import Enum as SAEnum
from sqlalchemy.orm import Mapped, mapped_column, relationship

from database import Base


# ======================================================================
# 공통 Enum
# ======================================================================

class AccountRole(str, enum.Enum):
    """계정 권한 (레거시 toyo_id_info.AUTH 대체)

    레거시 banUserInfoList.php / banOrganChartSelect.php select box 기준 실제 코드값.
    enum value는 마이그레이션 호환을 위해 원본 코드값을 그대로 사용한다.
    주의: 코드 '3','4'는 관측된 소스에서 사용례를 찾지 못했다 -> 실운영 데이터로 재확인 필요.
    """
    ASSISTANT_TEACHER = "0"   # 보조교사
    DREAM_TEACHER = "1"       # 꿈땅교사
    GAME_DIRECTOR = "2"       # 게임디렉터
    HOMEROOM_TEACHER = "5"    # 담임/임원 교사
    TEAM_LEADER = "6"         # (불티/티엔티)팀장
    STAFF = "7"               # 교역자/부장/행정
    SYSTEM_ADMIN = "8"        # 전산팀


class Sex(str, enum.Enum):
    """성별 (레거시 SEX 컬럼 대체)"""
    MALE = "M"
    FEMALE = "F"


class AttendanceStatus(str, enum.Enum):
    """출석 상태 (레거시 toyo_stud_chul.CHUL_KIND 코드 대체)

    레거시 실코드 기준(banScoreRegProc.php 외 다수):
        11=출석, 12=결석, 13=지각, 14=조퇴, 15=코로나결석
    """
    PRESENT = "11"
    ABSENT = "12"
    LATE = "13"
    EARLY_LEAVE = "14"
    COVID_ABSENT = "15"


class Subject(str, enum.Enum):
    """성적 항목 (레거시 toyo_stud_score.SUBJECT 대체)

    레거시 실코드(banScoreModify.php 내 CODE hidden input 기준):
        001=정시출석(0/50), 002=단복착용(0/50), 003=핸드북지참(0/50),
        004=암송점수(50점 단위, 상한 없음), 005=출석점수(CHUL_KIND 파생, 0/50/100)
    과목별로 점수 유효 범위가 다르므로 DB CHECK로 강제하지 않고
    서비스 레이어에서 subject별 검증한다 (SUBJECT_SCORE_RULES 참고).
    """
    ON_TIME_ATTEND = "001"   # 정시출석
    UNIFORM = "002"          # 단복착용
    HANDBOOK = "003"         # 핸드북지참
    MEMORY = "004"           # 암송점수
    ATTEND_SCORE = "005"     # 출석점수(CHUL_KIND 파생값 저장용)


# 서비스 레이어에서 사용할 과목별 점수 검증 규칙(참고용 상수, DB 제약 아님)
SUBJECT_SCORE_RULES = {
    Subject.ON_TIME_ATTEND: {"step": 50, "min": 0, "max": 50},
    Subject.UNIFORM: {"step": 50, "min": 0, "max": 50},
    Subject.HANDBOOK: {"step": 50, "min": 0, "max": 50},
    Subject.MEMORY: {"step": 50, "min": 0, "max": None},       # 상한 없음(레거시 UI 경고문 기준)
    Subject.ATTEND_SCORE: {"step": 50, "min": 0, "max": 100},
}


# ======================================================================
# 계정 / 세션
# ======================================================================

class Account(Base):
    """교사/관리자 로그인 계정 (레거시 toyo_id_info 대체)"""
    __tablename__ = "accounts"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    username: Mapped[str] = mapped_column(String(50), unique=True, nullable=False)
    password_hash: Mapped[str] = mapped_column(String(255), nullable=False)  # pwdlib(Argon2) 해시
    name: Mapped[str] = mapped_column(String(64), nullable=False)
    role: Mapped[AccountRole] = mapped_column(
        SAEnum(AccountRole, name="account_role"), nullable=False
    )
    # 레거시 STUD_NO와 동일한 이유로 보존: 과도기 병행 운영 및 데이터 매핑용
    legacy_id: Mapped[str | None] = mapped_column(String(20), unique=True)
    is_active: Mapped[bool] = mapped_column(default=True, nullable=False)
    last_login_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False
    )

    sessions: Mapped[list["LoginSession"]] = relationship(back_populates="account", cascade="all, delete-orphan")


class LoginSession(Base):
    """로그인 세션 (레거시 toyo_id_info.TOKEN / 로그인 이력 대체)

    변경: 토큰 원문이 아니라 해시(token_hash)를 저장한다. 원문 토큰은 로그인 응답에만
    한 번 실어 전달하고, 이후 검증은 들어온 토큰을 해시해서 비교한다.
    (레거시는 TOKEN 컬럼에 평문 저장 -> DB 유출 시 세션 탈취 위험. 신규에서는 개선)

    주의: SQLAlchemy의 DB 세션(sqlalchemy.orm.Session)과 이름이 겹치므로
    임포트 충돌 방지를 위해 클래스명은 LoginSession으로 둔다. 테이블명은 "sessions" 유지.
    """
    __tablename__ = "sessions"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    token_hash: Mapped[str] = mapped_column(String(64), unique=True, nullable=False)
    account_id: Mapped[int] = mapped_column(ForeignKey("accounts.id", ondelete="CASCADE"), nullable=False)
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )

    account: Mapped["Account"] = relationship(back_populates="sessions")

    @staticmethod
    def issue_token() -> tuple[str, str]:
        """(원문 토큰, 저장용 해시) 튜플 반환. 원문은 클라이언트에만 전달."""
        raw = secrets.token_hex(32)
        return raw, hashlib.sha256(raw.encode()).hexdigest()


# ======================================================================
# 반 / 학생 / 학기 배정 이력
# ======================================================================

class ClassRoom(Base):
    """반(class) 마스터 (레거시 toyo_ban_code_name 대체)"""
    __tablename__ = "classes"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    code: Mapped[str] = mapped_column(String(3), unique=True, nullable=False)  # 레거시 BAN 코드 하위호환용
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    phone: Mapped[str | None] = mapped_column(String(20))
    is_active: Mapped[bool] = mapped_column(default=True, nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False
    )

    enrollments: Mapped[list["Enrollment"]] = relationship(back_populates="class_room")


class Student(Base):
    """학생 기본 정보 (레거시 toyo_stud_info 대체)

    변경: class_id/grade/team을 이 테이블에서 직접 관리하지 않는다.
    "현재 반/학년/팀"은 Enrollment 중 최신(is_active=True) 레코드로 조회하고,
    출결/성적 등 이력 데이터는 반드시 Enrollment를 통해 당시 시점의 반 정보를 참조한다.
    (레거시가 연도별 pack/backup 테이블로 흉내내던 이력 요구사항의 정식 대체)
    """
    __tablename__ = "students"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    legacy_stud_no: Mapped[str | None] = mapped_column(String(5), unique=True)  # 레거시 STUD_NO 보존
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    sex: Mapped[Sex | None] = mapped_column(SAEnum(Sex, name="sex"))
    parent_name: Mapped[str | None] = mapped_column(String(20))
    parent_phone_enc: Mapped[bytes | None]  # 앱 레벨 암호화(예: Fernet) 저장
    is_active: Mapped[bool] = mapped_column(default=True, nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False
    )

    enrollments: Mapped[list["Enrollment"]] = relationship(back_populates="student", cascade="all, delete-orphan")


class Enrollment(Base):
    """연도/학기별 반 배정 이력 (신규 - 레거시에 없던 정식 이력 모델)

    레거시는 toyo_stud_info_pack / toyo_stud_2hakgi_info / toyo_stud_chul0403_backup
    같은 테이블을 매 학기 복제해서 과거 반/학년 정보를 어설프게 보존했다.
    이 테이블이 그 요구사항을 정식으로 대체한다.
    """
    __tablename__ = "enrollments"
    __table_args__ = (
        UniqueConstraint("student_id", "school_year", "semester", name="uq_enrollment_student_period"),
    )

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    student_id: Mapped[int] = mapped_column(ForeignKey("students.id", ondelete="CASCADE"), nullable=False)
    class_room_id: Mapped[int | None] = mapped_column(ForeignKey("classes.id"))
    school_year: Mapped[int] = mapped_column(Integer, nullable=False)
    semester: Mapped[int] = mapped_column(Integer, nullable=False)  # 1 또는 2 (레거시 2hakgi 개념)
    grade: Mapped[int | None]  # 학년 1~6 (레거시 GRADE varchar(1) '초1'~'초6' 확인됨)
    team: Mapped[str | None] = mapped_column(String(20))
    is_active: Mapped[bool] = mapped_column(default=True, nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )

    student: Mapped["Student"] = relationship(back_populates="enrollments")
    class_room: Mapped["ClassRoom | None"] = relationship(back_populates="enrollments")
    attendances: Mapped[list["Attendance"]] = relationship(back_populates="enrollment")
    scores: Mapped[list["Score"]] = relationship(back_populates="enrollment")


# ======================================================================
# 출석 / 성적
# ======================================================================

class Attendance(Base):
    """학생 출석 (레거시 toyo_stud_chul 대체)

    enrollment_id를 참조하여 "그 당시" 반 정보를 그대로 보존한다
    (레거시 TOYO_STUD_CHUL.BAN이 담당하던 역할).
    """
    __tablename__ = "attendances"
    __table_args__ = (
        UniqueConstraint("enrollment_id", "enroll_date", name="uq_attendance_enrollment_date"),
    )

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    enrollment_id: Mapped[int] = mapped_column(ForeignKey("enrollments.id", ondelete="CASCADE"), nullable=False)
    enroll_date: Mapped[date] = mapped_column(Date, nullable=False)
    status: Mapped[AttendanceStatus] = mapped_column(
        SAEnum(AttendanceStatus, name="attendance_status"), nullable=False
    )
    reason: Mapped[str | None] = mapped_column(String(200))
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False
    )

    enrollment: Mapped["Enrollment"] = relationship(back_populates="attendances")


class Score(Base):
    """학생 성적 (레거시 toyo_stud_score 대체)

    변경: 전역 CHECK(0~100) 제거. 004(암송점수)는 상한 없이 50점 단위로 누적되므로
    DB 제약이 아닌 서비스 레이어(SUBJECT_SCORE_RULES)에서 과목별로 검증한다.
    음수 등 명백히 잘못된 값만 DB에서 걸러낸다.
    """
    __tablename__ = "scores"
    __table_args__ = (
        UniqueConstraint("enrollment_id", "enroll_date", "subject", name="uq_score_enrollment_date_subject"),
        CheckConstraint("score >= 0", name="ck_score_non_negative"),
    )

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    enrollment_id: Mapped[int] = mapped_column(ForeignKey("enrollments.id", ondelete="CASCADE"), nullable=False)
    enroll_date: Mapped[date] = mapped_column(Date, nullable=False)
    subject: Mapped[Subject] = mapped_column(SAEnum(Subject, name="subject"), nullable=False)
    score: Mapped[int] = mapped_column(nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False
    )

    enrollment: Mapped["Enrollment"] = relationship(back_populates="scores")
```

---

#### 다음 단계 (바이브코딩 프롬프트로 바로 쓸 수 있는 체크리스트)
1. `database.py`, `models.py` 저장 후 `alembic init alembic` → `alembic revision --autogenerate -m "init"` 으로 마이그레이션 생성
2. 서비스 레이어에서 `SUBJECT_SCORE_RULES` 기준으로 `Score` 입력값 검증하는 validator 함수 작성 (DB CHECK로는 안 걸러짐에 유의)
3. `Enrollment` 생성/전학/진급 처리 서비스 함수 (`promote_student(student_id, new_school_year, ...)`) 설계
4. 범위 외로 남겨둔 도메인(포인트/진로/성경대회/공지/등록비/수련회출결/팀게임점수/교사출결, 메뉴 ACL) 중 우선순위 높은 것부터 추가 모델링 요청




# 3-4. 설계 결정 근거 (toyo 프로젝트) — 재검증판

> 원본 `3-4. 설계 결정 근거 (toyo 프로젝트)(기존).md`를 (1) 실제 레거시 스키마(`toyo테이블스키마DB_덤프.sql`), (2) PHP 소스(`phpcssjs소스.zip`), (3) TRD(`바이드코딩시_시스템구조문서_.md`, §1 기술스택) 3개 문서 교차 검증 후 수정한 버전입니다.
> 표 아래 "재검증 노트"에 항목별 근거(파일명·쿼리 인용)를 남겼습니다.

## 수정된 결정 근거 표

| 결정 | 근거 | 검증 상태 |
|---|---|---|
| PK를 복합 자연키(`ENROLL_DATE+BAN+STUD_NO`)가 아닌 `id`(surrogate key)로 | 레거시는 날짜+반+학번 조합을 PK로 썼는데, 여러 컬럼을 매번 조인/외래키에 실어야 해 무겁고 관리가 어려움. 대리키로 단순화하고, 중복 방지는 `UniqueConstraint`로 별도 유지 | ✅ 원본 유지 (실제 레거시 PK와 일치 확인) |
| `UNIQUE (student_id, enroll_date)` / `(student_id, enroll_date, subject)` | 같은 학생이 같은 날짜에 출석/성적이 중복 등록되는 것을 DB 레벨에서 방지 | ✅ 원본 유지. 단, 아래 "반(class) 스냅샷" 항목과 세트로 봐야 함 |
| **출석·성적 등 이력성 테이블에는 등록 시점의 반(BAN)/팀(TEAM) 값을 스냅샷 컬럼으로 그대로 보존한다** (student 테이블 현재값 조인 금지) | 레거시에서 학생의 `BAN`/`TEAM`은 **가변값**이다(`banStudBanTeamInfoModifyProc.php`가 실제로 `UPDATE TOYO_STUD_INFO SET BAN=..., TEAM=...` 실행). 반면 반 이동 시 과거 `TOYO_STUD_CHUL`/`TOYO_STUD_SCORE`/`TOYO_STUD_BIBLE_MEMORY`/`TOYO_POINT` 등 이력 데이터의 BAN을 소급 수정하는 로직은 코드 전체에서 발견되지 않음. 즉 레거시 설계자는 "그 시점의 반"을 의도적으로 각 이력 레코드의 PK에 포함시켜 남겨둔 것 — student 현재값을 조인해서 쓰면 반 이동 이력이 있는 학생의 과거 출석/성적/포인트 기록이 전부 **최신 반으로 잘못 표시**된다 | ❌ **원본 결정 오류 — 반대로 수정 필요.** 원본은 "TOYO_STUD_INFO.BAN만 쓰이고 있어 불필요"라고 되어 있었으나 이는 사실과 다름. 유일성 제약(UNIQUE)에는 BAN을 넣을 필요 없지만, **일반 컬럼으로는 반드시 유지**해야 함 |
| 학번(`STUD_NO`) 대신 `id`를 PK로 사용 | (근거 정정) `STUD_NO`는 이름과 무관하게 `LPAD(MAX(STUD_NO)+1,5,0)` 방식으로 채번되는 5자리 순번이라, 동명이인 문제는 레거시에서도 이미 발생하지 않음. 진짜 문제는 **`MAX+1` 채번 방식 자체의 동시성 결함**(신입반 등록 시즌에 여러 창구에서 동시 등록 시 중복/누락 가능)과, 학번을 FK로 여러 이력 테이블에 그대로 흩뿌려 써서 나중에 학번 정책이 바뀌면 마이그레이션 비용이 커진다는 점. `id` surrogate key + `STUD_NO`는 표시/출력용 비즈니스 코드로 분리하고, 채번은 DB 시퀀스/`SELECT ... FOR UPDATE` 등 동시성 안전한 방식으로 대체 필요 | ❌ **근거 오류 — 근거 문구 교체 필요.** "동명이인 해소"는 실제 이유가 아님. 결정 자체(surrogate key 도입)는 유지해도 되지만 사유가 잘못 기재됨 |
| 세션을 `Session` 별도 테이블로 분리(`TOYO_ID_INFO.TOKEN` 통합 컬럼 대신) | 레거시는 계정당 `TOKEN varchar(200)` 단일 컬럼만 가지고 있어, 사실상 **동시 로그인 1세션만 허용**(재로그인 시 이전 토큰 무효화)되는 구조였음. 이를 1:N 세션 테이블로 바꾸면 다중 기기 로그인이 허용되는 것으로, **레거시의 기존 제약을 완화하는 신규 요구사항 추가**에 해당함 | ⚠️ 결정은 합리적이나, "기존 요구사항 보존"이 아니라 "신규 기능 추가"임을 명시 필요 — 실제로 다중기기 로그인이 필요한 요건인지(교사 1인 1기기 원칙이 의도된 정책이었을 수 있음) 기획 측 재확인 권장 |
| 코드값(`CHUL_KIND` 등)을 범용 코드 테이블(`toyo_code_name`) 대신 Python/DB `Enum`으로 고정 | (근거 정정) 레거시도 이미 `TOYO_CODE_NAME(OPT='CHUL_KIND')` 코드 테이블로 관리 중이었고, 실사용 코드값은 **11=출석, 12=결석, 13=지각, 14=조퇴 + 15=코로나/온라인 결석 처리(COVID)**까지 5개다(`banChulManageList.php`에서 `CHUL_KIND='15'` COVID 케이스 확인). 즉 "확정된 닫힌 집합"이라는 전제 자체가 사실이 아니며, 이 코드는 **과거에 실제로 한 번 늘어난 이력**이 있다 | ❌ **근거 오류 — 코드값 누락 및 전제 오류.** (1) Enum에 `15(COVID/온라인)`를 반드시 포함해야 함 (2) "닫힌 집합"이 아니라 "종종 변경될 수 있는 집합"임을 인정하고, Enum 고정 시에는 향후 코드 추가마다 마이그레이션(스키마 변경+배포)이 필요하다는 트레이드오프를 근거란에 명시하거나, 레거시처럼 관리용 코드 테이블 + DB `CHECK` 제약 병행을 대안으로 검토 |
| `varchar(8)`/`varchar(14)` 날짜·일시 문자열 대신 `Date`/`DateTime` 타입 | (범위 확장) 레거시에는 `ENROLL_DATE` 같은 `varchar(8)`(YYYYMMDD) 뿐 아니라, 거의 모든 테이블의 `REG_DATE`/`MOD_DATE`가 `varchar(14)`(YYYYMMDDHHMMSS) 문자열로 저장되어 있음(`toyo_stud_chul`, `toyo_stud_score`, `toyo_code_name` 등 전 테이블 공통). 문자열 정렬/비교 오류, 날짜 연산·인덱스 활용 불가 문제는 둘 다 동일하게 발생 | ⚠️ 원본은 `varchar(8)`만 언급 — `varchar(14)` 일시 컬럼까지 범위를 넓혀 `Date` 뿐 아니라 `DateTime` 타입 결정도 함께 명시 필요 |
| 비밀번호는 `pwdlib`(Argon2) 해시만 저장 | 레거시 `PASSWD`는 `MD5('$PASSWD')`로 저장되는 약한 단방향 해시(`loginFormProc.php` 확인). Argon2로 교체는 타당. **TRD 교차검증**: TRD §1 기술스택에 `pwdlib[argon2] 0.3.0`이 이미 동일하게 명시되어 있어 두 문서 간 결정이 일치함(불일치 없음) | ✅ 원본 유지, TRD와도 일치. 단, **마이그레이션 전략은 두 문서 어디에도 없음** — MD5는 되돌릴 수 없으므로 기존 계정의 비밀번호를 Argon2로 "변환"할 수 없음. 최초 로그인 시 임시 비밀번호 발급 또는 강제 재설정 절차를 별도 결정 항목으로 3-4·TRD 양쪽에 추가 필요 |
| **(신규 추가) 개인정보(보호자/반/교사 휴대폰번호)는 애플리케이션 레벨 암호화 컬럼으로 저장** | 레거시에 `TOYO_STUD_INFO.PARENTS_NO_HP_ENC`, `TOYO_BAN_CODE_NAME.BAN_HP_ENC`, `TOYO_ID_INFO.TEACHER_HP_NO_ENC` 3개 컬럼이 `blob` 타입으로 존재하며, 실제로 `AES_ENCRYPT(값, 'dlsejr00**')`로 암호화되어 있음(`banStudInfoNewRegModifyProc.php`, `banTeacherInfoModifyProc.php` 등에서 확인) — **암호화 키가 DB root 비밀번호와 동일한 문자열로 하드코딩**되어 있어 사실상 무의미한 암호화 상태. **TRD 교차검증**: TRD §1에 이미 `cryptography` 패키지가 이 3개 컬럼(`parents_no_hp_enc`/`ban_hp_enc`/`teacher_hp_no_enc`)의 암호화 대체용으로 추가되어 있어, 신규 스택 쪽에서는 이미 인지·반영된 항목임. 다만 **정작 설계 결정 근거를 남기는 이 문서(3-4)에는 누락**되어 있어, "왜 이 3개 컬럼을 암호화하는지/키 관리를 어떻게 하는지"에 대한 데이터 모델 레벨 근거가 비어 있음 | 🆕 원본 표에 없던 항목 — TRD와 일관되게 반드시 추가 필요. 키 관리 방안(환경변수/KMS 등, 레거시처럼 코드에 하드코딩 금지)을 근거란에 구체적으로 명시할 것 |

## 재검증 노트 (근거 인용)

- **BAN 스냅샷 이슈**: `banStudBanTeamInfoModifyProc.php`
  ```
  UPDATE TOYO_STUD_INFO SET BAN='$BAN', TEAM='$TEAM', MOD_DATE=NOW(), MOD_ID='MODIFY' WHERE STUD_NO='$STUD_NO'
  ```
  이 화면(반/팀 재편성)이 존재하고, 레거시 PK 정의가 `toyo_stud_chul(ENROLL_DATE,BAN,STUD_NO)`, `toyo_stud_score(ENROLL_DATE,BAN,STUD_NO,SUBJECT)`, `toyo_stud_bible_memory(ENROLL_DATE,BAN,STUD_NO)`, `toyo_point(ENROLL_DATE,KIND,STUD_NO)` 등으로 반 이동 이후에도 과거 BAN 이력 UPDATE 로직이 코드 전체에 없다는 점이 반 스냅샷 보존이 필요한 근거입니다.
- **STUD_NO 채번**: `banStudInfoNewRegProc.php`
  ```
  select LPAD(MAX(STUD_NO)+1,5,0) STUD_NO_MAX from TOYO_STUD_INFO
  ```
- **CHUL_KIND 코드값**: `banChulModify.php`(11/12/13/14 라디오 옵션), `banChulManageList.php`(`CHUL_KIND='15'` → `COVID` 컬럼), `banStudPointDetailList.php`(`TOYO_CODE_NAME WHERE OPT='CHUL_KIND'`로 코드명 조회하는 기존 코드 테이블 존재 확인)
- **세션 토큰**: `toyo_id_info.TOKEN varchar(200)` — 계정당 1개 컬럼(1:1), `loginFormProc.php`에서 로그인 시 새 토큰을 매번 재발급
- **비밀번호**: `loginFormProc.php`
  ```
  WHERE ID = '$ID' AND PASSWD = MD5('$PASSWD')
  ```
- **개인정보 암호화 흔적**: `toyo_stud_info.PARENTS_NO_HP_ENC blob`, `toyo_ban_code_name.BAN_HP_ENC blob`, `toyo_id_info.TEACHER_HP_NO_ENC blob`. 실제 암복호화는 `banStudInfoNewRegModifyProc.php`
  ```
  PARENTS_NO_HP_ENC = HEX(AES_ENCRYPT('$PARENTS_NO_HP_ENC', 'dlsejr00**'))
  ```
  형태로 이루어지며, 키 `'dlsejr00**'`는 `appdata.php`/`dbconfig.php`의 DB root 비밀번호와 동일 — 키 하드코딩 및 재사용 문제
- **TRD 교차검증**: `바이드코딩시_시스템구조문서_.md` §1에서 `pwdlib[argon2] 0.3.0`(비밀번호)과 `cryptography`(3개 `_enc` 컬럼 암호화)를 이미 기술스택으로 확정해 둔 상태 — 3-4 문서의 수정 방향과 상충 없이 일치함. 단, 3-4 문서에는 이 결정의 "데이터 모델 관점 근거"가 없었으므로 이번에 추가함

## 아직 미확정 항목 (원본과 동일하게 유지)

> `Subject`(성적 과목) enum의 실제 코드값은 아직 확정되지 않아 이 표에는 포함하지 않았습니다. 참고로 레거시 쿼리 주석에는 `SUBJECT='001'`, `SUBJECT='005'` 등 3자리 숫자코드 사용 흔적이 남아있어(`banChulRegProc.php` 등), 코드값 확정 시 참고 자료로 활용 가능합니다.
> 코드값이 확정되면 "코드값을 Enum으로 고정" 행에 함께 반영할 수 있습니다.



## 4. 모듈/함수 설계

### 4-1. 디렉터리 구조 (toyo 프로젝트, 재검증본)

```
toyo/
├── main.py                    # FastAPI 앱 생성, 라우터 등록만 담당
├── database.py                # engine, SessionLocal, Base, get_db
├── config.py                  # 환경설정 (Pydantic Settings, .env 로드)
├── security.py                # Argon2 해싱, 세션 토큰 검증 등 도메인 횡단 보안 유틸
├── encryption.py               # (추가) cryptography 기반 개인정보 컬럼 암복호화 — security.py와 관심사가 달라 분리
├── deps.py                    # get_current_account, require_admin 등 공통 Depends
│
├── domains/
│   ├── auth/                  # 계정 · 세션 · 로그인이력 (3개 테이블)
│   │   ├── models.py           # toyo_id_info, toyo_id_info_hist, md5enc
│   │   ├── schemas.py
│   │   ├── crud.py
│   │   ├── service.py          # 로그인/로그아웃 비즈니스 로직(해싱, 세션 발급/만료)
│   │   └── router.py
│   │
│   ├── code_tables/            # (이름 변경) 기준정보 — 반/희망분야/과목/교사출결코드 등 (8개 테이블)
│   │   ├── models.py           # toyo_ban_code_name, toyo_dream_kind, toyo_kind_name, toyo_stud_code_name,
│   │   │                        #   toyo_teacher_chul_code_name, toyo_code_name, toyo_ban_menu_name, toyo_reg_date_poss
│   │   ├── schemas.py
│   │   ├── crud.py
│   │   └── router.py           # 관리자 전용(수정/삭제), 조회는 전체 교사 허용
│   │
│   ├── students/               # 학생 관리 (5개 테이블)
│   │   ├── models.py           # toyo_stud_info, toyo_stud_2hakgi_info, toyo_stud_2hakgi_new_info,
│   │   │                        #   toyo_stud_new_info, toyo_stud_reg_fee
│   │   ├── schemas.py
│   │   ├── crud.py
│   │   └── router.py
│   │
│   ├── attendance/              # 출결 관리 — 학생/교사 모두 (4개 테이블)
│   │   ├── models.py           # toyo_stud_chul, toyo_stud_field_attend, toyo_stud_field_attend_teacher, toyo_teacher_chul
│   │   ├── schemas.py
│   │   ├── crud.py
│   │   └── router.py
│   │
│   ├── scores/                  # 성적 · 게임점수 관리 (5개 테이블)
│   │   ├── models.py           # toyo_stud_score, toyo_stud_score_hist, toyo_team_game_score,
│   │   │                        #   toyo_team_game_score_rows, toyo_team_score_plus
│   │   ├── schemas.py
│   │   ├── crud.py
│   │   └── router.py
│   │
│   ├── dreams/                  # (신규 추가) 희망분야/진로 관리 (4개 테이블)
│   │   ├── models.py           # toyo_stud_dream, toyo_stud_dream_course, toyo_stud_dream_year_course,
│   │   │                        #   toyo_stud_dream_support_grade
│   │   ├── schemas.py
│   │   ├── crud.py
│   │   └── router.py
│   │
│   └── activities/               # (신규 추가) 포인트/암송/공지 등 부가 활동 (6개 테이블)
│       ├── models.py           # toyo_notice_info, toyo_point, toyo_point_payment,
│       │                        #   toyo_bible_contest, toyo_stud_bible_memory, toyo_stud_memory
│       ├── schemas.py
│       ├── crud.py
│       └── router.py
│
├── admin/                        # (신규 추가) 특정 테이블을 소유하지 않는 횡단 관리자 기능
│   └── router.py                 # 하드 삭제(각 도메인 crud의 hard_delete_* 호출), 기준정보 CRUD 진입점
│
├── alembic/                       # (신규 추가) 35개 테이블 스키마 마이그레이션 이력
│   ├── versions/
│   └── env.py
├── alembic.ini
│
├── seeds/                          # (신규 추가) 기준정보(코드 테이블) 8개 초기 데이터
│   └── code_tables_seed.py
│
├── static/
│   ├── index.html                 # 일반 교사 화면
│   ├── admin.html                  # (신규 추가) SCR-901 관리자 전용 화면
│   ├── app.js
│   └── uploads/                    # (신규 추가) 학생/교사 사진 저장 위치(로컬 저장 시)
│
├── tests/
├── requirements.txt
├── docker-compose.yml               # PostgreSQL 16
├── .env                             # DB 접속 정보, SECRET_KEY, ENCRYPTION_KEY 등(git 제외)
└── README.md
```

파일 분리 기준(원본과 동일하게 유지): 업무(도메인) 단위로 모듈을 분리한다. 같은 업무 변경 시 함께 바뀌는 코드(model+schema+crud+router)를 한 폴더에 모은다.

### 재검증 결과 — 수정/추가한 부분

| 항목 | 원본 | 재검증본 | 근거 |
|---|---|---|---|
| **테이블 수 오기** | "6개 테이블" | **35개 테이블** | 3-1(ERD)·12(체크리스트) 등 이후 문서 전부 35개로 확정. 원본 표기가 명백한 오기 |
| **`classes`(반) 도메인 → `code_tables`(기준정보)로 통합** | `classes/`에 반(ban)만 별도 도메인화 | 반(`toyo_ban_code_name`)을 포함한 기준정보 8개 테이블을 `code_tables/` 하나로 통합 | 반은 "코드-이름 매핑"이라는 점에서 희망분야(`dream_kind`)·과목(`stud_code_name`)·교사출결코드 등 나머지 7개 기준정보 테이블과 CRUD 패턴이 동일하다. 반만 떼어 별도 도메인화하면 나머지 7개가 어느 도메인에도 속하지 못하는 문제가 생긴다 |
| **`dreams`(희망분야) 도메인 신규 추가** | 없음 | 4개 테이블 추가 | 원본에서 완전히 누락. 8·9·13번 문서에서 이미 희망분야 등록 흐름을 다뤘는데 디렉터리 구조엔 반영 안 됨 |
| **`activities`(포인트/암송/공지) 도메인 신규 추가** | 없음 | 6개 테이블 추가 | 4-3번(함수 명세표) 부록에서 암송자등록/암송자PPT/암송발표자검색 함수를 이미 설계했는데, 이 함수들이 담길 도메인 자체가 원본 구조에 없었다 |
| **`admin/` 신규 추가** | 없음 | 횡단 관리자 라우터 추가 | 9·13번 문서에서 결정한 "하드 삭제는 관리자 전용, 403 검증" 기능이 들어갈 위치가 원본에 없었다 |
| **`alembic/`, `seeds/` 신규 추가** | 없음 | 추가 | 1·1-1·11번 문서에서 이미 결정된 마이그레이션/기준정보 시드 요구사항이 이 구조에는 반영 안 되어 있었다 |
| **`encryption.py` 신규 추가** | 없음 | `security.py`와 분리해 추가 | 1번 문서에서 결정한 `cryptography` 기반 암호화가 들어갈 파일이 없었다. Argon2 해싱(인증)과 개인정보 암호화(보호)는 서로 다른 관심사이므로 분리 |
| **`static/admin.html`, `static/uploads/` 신규 추가** | `static/{index.html, app.js}`만 | 관리자 화면 + 사진 업로드 저장 경로 추가 | 2·13번 문서에서 이미 결정된 관리자 화면 분리, 사진 업로드 기능이 반영 안 되어 있었다 |

원본의 핵심 설계 판단(도메인별 model+schema+crud+router 묶음, `security.py`↔`auth/service.py` 분리 근거, 레거시 화면 분리 관행을 참고한 도메인 경계 설정)은 타당하므로 그대로 유지했다. 다만 **반영 범위가 전체 35개 테이블의 절반에도 못 미쳤던 것**이 가장 큰 문제였다.



# 4-2. 용어 주의 — "세션" 이중 의미 (toyo 프로젝트, 재검증본)

toyo 프로젝트에서도 "세션"은 두 가지 서로 다른 개념을 가리켜서 헷갈리기 쉽다는 취지 자체는 유효하다. 다만 원본 문서가 근거로 든 **별도의 `sessions` 테이블/`LoginSession` 모델은 toyo에 존재하지 않는다** — contact-manager 구조가 그대로 남아있던 오류이므로 아래와 같이 정정한다.

- **SQLAlchemy DB 세션** (`Session`, 요청 단위 파이썬 ↔ DB 연결) — `database.py`의
  `SessionLocal`이 매 요청마다 만들어내는 그 세션이다. (원본과 동일, 정정 없음)
- **로그인 세션(토큰)** — toyo는 별도 `sessions` 테이블이 없고, **`toyo_id_info` 테이블 자체의 `token`/`login_last_time` 컬럼**으로 로그인 상태를 관리한다(레거시 `loginFormProc.php`의 `UPDATE TOYO_ID_INFO SET TOKEN=...`을 그대로 계승, §8 참고). 즉 로그인 세션은 **별도 모델이 아니라 `ToyoIdInfo` 모델의 필드 일부**다.

**정정 사항**

| 원본 | 재검증본 |
|---|---|
| `sessions` 테이블(별도 존재) | 존재하지 않음 — `toyo_id_info.token`이 그 역할 |
| `LoginSession` 모델 클래스 신설 | 불필요 — `ToyoIdInfo` 모델(§4-3)에 이미 `token` 필드가 있음 |
| 클래스명 충돌 우려 대상 | `LoginSession` vs `Session`이 아니라, **변수명 `session`을 로그인 상태를 가리키는 용도로 쓰지 말 것** — 실제 충돌은 클래스가 아니라 관용적으로 쓰는 변수명 수준에서 발생한다 |

그래도 이름 충돌을 조심해야 하는 지점은 남아있다. `db: Session` (SQLAlchemy DB 세션 타입힌트)과, 쿠키에 담기는 로그인 토큰을 가리키는 변수를 똑같이 `session`이라고 부르면 코드 리뷰·디버깅 시 헷갈린다. 그래서 명명 규칙만 다음과 같이 정한다.

```python
from sqlalchemy.orm import Session   # SQLAlchemy DB 세션 — 함수 인자 타입힌트로만 사용

def get_current_teacher(
    session_id: str | None,  # 쿠키에 담긴 로그인 토큰 문자열 (toyo_id_info.token 값)
    db: Session,              # SQLAlchemy DB 세션
) -> ToyoIdInfo:
    ...
```

- 로그인 토큰을 가리킬 때는 항상 `session_id`(쿠키 이름) 또는 `token`(컬럼명과 동일)이라고만 부르고, `session`이라는 단독 변수명은 SQLAlchemy DB 세션(`db`)에만 쓴다.
- 별도 모델 클래스를 만들 필요가 없으므로 `LoginSession` 관련 네이밍 규칙 자체가 toyo에는 해당 사항 없음.





### 4-3. 함수 명세표 (toyo 프로젝트)

> ⚠️ **레거시에는 대응할 함수가 없음 (중요한 전제 차이)**: 레거시 PHP 256개 파일을 전수 확인한 결과, 서버 측 재사용 함수가 하나도 없는 순수 procedural 구조였다(화면 1개 = SQL+로직+출력이 한 파일에 뒤섞인 구조). 따라서 아래 함수들은 레거시를 그대로 옮긴 것이 아니라, 8·9·11·12·13번 문서에서 확정한 업무 규칙(반 기반 접근 제어, 소프트 삭제 기본/하드 삭제 CASCADE, 성적 upsert, 채번 동시성 등)을 근거로 **신규로 설계**한 것이다.

| 함수/객체 | 위치 | 입력 | 출력/효과 |
|---|---|---|---|
| get_db() | database.py | — | 요청 단위 DB 세션 제공(yield), 종료 시 자동 close |
| 35개 테이블 모델(`ToyoStudInfo` 등) | models/*.py | — | 테이블 정의(Mapped 문법), 도메인별 7개 파일로 분리(§11) |
| LoginIn / StudentCreate / StudentUpdate / AttendanceCreate / ScoreBatchCreate / DreamCreate 등 | schemas/*.py | — | 입출력 양식+검증 규칙 |
| hash_password(원문) | security.py | 원문 | bcrypt/argon2 해시 |
| verify_password(원문, 해시) | security.py | 입력값, 저장 해시 | True/False |
| create_session_token() | security.py | — | 랜덤 세션 토큰 생성 |
| authenticate_teacher(db, id, passwd) | crud/auth.py | 로그인 입력 | 성공 시 `toyo_id_info` row(`use_yn='Y'` 조건 포함), 실패 시 None |
| create_login_session(db, id, mac_address) | crud/auth.py | id, 클라이언트 정보 | `toyo_id_info` 토큰 갱신 + `toyo_id_info_hist` UPSERT(`ON CONFLICT(id, enroll_date) DO UPDATE`) → 토큰 반환 |
| get_current_teacher(session_id, db) | routers/auth.py | 쿠키 session_id | 교사 정보(`id`, `ban`, `is_admin`) 반환 또는 401 raise |
| require_admin(teacher) | routers/auth.py | get_current_teacher 결과 | `is_admin`이 아니면 403 raise (관리자 전용 라우터 의존성) |
| logout(db, session_id) | crud/auth.py | session_id | 세션 토큰 무효화 |
| get_active_notices(db) | crud/etc.py | — | `toyo_notice_info` 중 게시기간 내(`use_yn='Y'` AND 오늘 BETWEEN 시작~종료) 목록 |
| **generate_stud_no(db)** | crud/student.py | — | `SELECT MAX(stud_no) FOR UPDATE` 기반 원자적 채번(5자리 zero-pad), 동시 등록 시 경쟁 조건 방지 |
| **student_duplicate_exists(db, name, grade, sex, exclude_stud_no=None)** | crud/student.py | 이름/학년/성별+제외id | 동일 조건 `use_yn='Y'` 학생 존재 여부(bool), 수정 시 자기 자신 제외 |
| list_students(db, ban, name=None, include_inactive=False) | crud/student.py | 반+검색조건 | 해당 반 학생 목록(기본은 `use_yn='Y'`만) |
| get_student_in_my_ban(db, ban, stud_no) | crud/student.py | 반+대상 stud_no | `WHERE stud_no=? AND ban=?` → Student 또는 None(담당 반 아니면 404 처리용) |
| create_student(db, data) | crud/student.py | StudentCreate | `parents_no_hp` 암호화 + generate_stud_no + INSERT + COMMIT |
| update_student(db, stud_no, data) | crud/student.py | 대상+수정데이터 | UPDATE + COMMIT |
| soft_delete_student(db, stud_no) | crud/student.py | 대상 stud_no | `use_yn='N'` UPDATE (기본 삭제 경로) |
| **hard_delete_student(db, stud_no)** | crud/student.py (관리자 전용) | 대상 stud_no | 물리 DELETE → `ON DELETE CASCADE`로 성적/출결/희망분야 등 종속 레코드 자동 삭제 |
| count_dependent_records(db, stud_no) | crud/student.py | 대상 stud_no | 하드 삭제 confirm 다이얼로그용 종속 레코드 건수(성적/출결/희망분야 등) 사전 집계 |
| create_attendance(db, ban, stud_no, data) | crud/attendance.py | 반+학생+출결데이터 | `toyo_stud_chul` UPSERT(`ON CONFLICT DO UPDATE`) |
| list_attendance(db, ban, enroll_date) | crud/attendance.py | 반+일자 | 해당 반/일자 출결 목록 |
| **upsert_score(db, enroll_date, ban, stud_no, scores: dict)** | crud/score.py | 반+학생+5개 항목 점수 | `toyo_stud_score` 5행 `ON CONFLICT (enroll_date, ban, stud_no, subject) DO UPDATE` 일괄 처리(단일 트랜잭션) |
| list_scores(db, ban, stud_no=None, enroll_date=None) | crud/score.py | 검색조건 | 성적 목록 |
| **dream_duplicate_exists(db, stud_no, dream_kind, exclude_id=None)** | crud/dream.py | 학생+희망분야+제외id | 동일 학생·동일 희망분야 중복 여부(bool), 수정 시 자기 자신 제외 |
| create_dream(db, data) | crud/dream.py | DreamCreate | INSERT + COMMIT |
| list_code_table(db, table_name) | crud/code_tables.py | 테이블 구분(반/희망분야/과목 등) | 기준정보 목록(드롭다운 채우기용, 8개 테이블 공통 함수) |
| 라우터 함수(약 20개) | routers/*.py | HTTP 요청 | 세션확인→(관리자 라우터는 권한확인)→형식검증→crud호출→상태코드 결정 |

### 4-3-부록. 기본 사용 메뉴 함수 (첨부 메뉴 이미지 기준)

첨부하신 메뉴(학생 출결등록/암송자등록/암송자PPT/학생 출결현황/교사출석등록/교사출결현황/암송발표자검색/학생점수현황/교사생일(월)) 중, 위 표에 아직 없던 것만 함수로 추가한다.

| 함수/객체 | 위치 | 입력 | 출력/효과 |
|---|---|---|---|
| **create_bible_memory(db, ban, stud_no, data)** | crud/etc.py | 반+학생+암송데이터 | `toyo_stud_bible_memory` INSERT/UPSERT — "암송자등록" 메뉴 대응 |
| **list_bible_memory_for_ppt(db, enroll_date, kind)** | crud/etc.py | 일자+구분 | `toyo_stud_bible_memory` + `toyo_stud_info` JOIN, PPT 발표 순서대로 정렬된 목록 — "암송자PPT" 메뉴 대응(읽기 전용, 화면 출력용이라 별도 등록 로직 없음) |
| **search_bible_memory_presenters(db, ban=None, enroll_date=None, name=None)** | crud/etc.py | 검색조건(선택) | 조건에 맞는 암송 발표자 목록 검색 — "암송발표자검색" 메뉴 대응 |
| **get_student_attendance_status(db, ban, enroll_date)** | crud/attendance.py | 반+일자 | 해당 반/일자 학생 전체의 출결 등록 여부·상태를 집계해 반환(등록 자체는 `create_attendance`가 담당, 이 함수는 조회 전용) — "학생 출결현황" 메뉴 대응 |
| **create_teacher_attendance(db, teacher_no, ban, data)** | crud/attendance.py | 교사+반+출결데이터 | `toyo_teacher_chul` INSERT/UPSERT — "교사출석등록" 메뉴 대응 |
| **get_teacher_attendance_status(db, enroll_date)** | crud/attendance.py | 일자 | 해당 일자 전체 교사 출결 현황 집계 — "교사출결현황" 메뉴 대응 |
| **get_student_score_status(db, ban, enroll_date)** | crud/score.py | 반+일자 | 해당 반/일자 학생 전체의 성적 등록 여부·현황 집계(등록 자체는 `upsert_score`가 담당) — "학생점수현황" 메뉴 대응 |
| **list_teachers_by_birth_month(db, month)** | crud/auth.py | 월(1~12) | `toyo_id_info.ssn`(4자리 MMDD)에서 앞 2자리를 월로 파싱해 해당 월 생일 교사 목록 반환 — "교사생일(월)" 메뉴 대응 |

> `ssn` 컬럼은 4자리(MMDD로 추정)만 저장하는 레거시 관행이라, 실제 값 포맷(월/일 순서인지, 두 자리씩인지)은 운영 데이터로 재확인이 필요하다. 확인 전에는 `list_teachers_by_birth_month`의 파싱 로직을 확정하지 말 것을 권장한다.

**레거시 대비 신규로 반드시 넣어야 하는 "숨은 버그 방지" 포인트 2가지**

1. **`student_duplicate_exists`/`dream_duplicate_exists`에 `exclude_stud_no`/`exclude_id` 파라미터 필수**: contact-manager 예시와 동일한 함정이다. 이 파라미터 없이 구현하면 "학생 A의 팀 정보만 수정하려고 이름/학년/성별을 그대로 다시 전송했는데 409가 뜨는" 버그가 그대로 재현된다.
2. **`generate_stud_no`는 반드시 DB 레벨 잠금(`FOR UPDATE`) 또는 `SEQUENCE`로 구현**: 레거시(`MAX(stud_no)+1`)를 함수 이름만 바꿔 그대로 옮기면, 동시 등록 시 같은 `stud_no`가 발급되는 레거시의 실제 결함을 신규 시스템에 그대로 이식하게 된다.



## 5. 인증 설계

> toyo 프로젝트(교사용 학생관리 시스템) 신규 인증 설계다. 기준 문서(`5.인증설계(기존설계).md`)의 구조와 기술 방향(세션 쿠키 + Argon2 + DB 세션 테이블)을 그대로 따르되, 아래 두 산출물을 근거로 toyo 도메인에 맞게 재작성했다.
> - `toyo테이블스키마DB_덤프.sql` — 기존 `TOYO_ID_INFO` 테이블 구조(교사/관리자 계정)
> - `phpcssjs소스.zip` — 기존 로그인 구현(`loginFormProc.php`, `logoutFormProc.php`, `menuSelect.php` 등) 실사 코드

### 5-1. 방식 선정 — 세션 쿠키 vs JWT

| 비교 항목 | 세션 쿠키(채택) | JWT(미채택, 향후 확장) |
|---|---|---|
| 추가 라이브러리 | 0개(secrets 표준) | PyJWT 등 별도 필요 |
| 화면 코드 복잡도 | 쿠키 자동 보관/첨부 | 저장+헤더 첨부 코드 필요 |
| 실무 사용처 | 전통 웹 프레임워크 기본 방식 | 모바일/MSA 간 통신 |
| 로그인 상태 확인 | sessions SELECT로 직접 확인 | 토큰 자체 서명 검증 |
| 로그아웃 | 행 삭제=즉시 무효화 | 만료 전 유효(블랙리스트 별도 필요) |
| 채택 여부 | 채택(기본 인증) | 심화 과정 이관 |

> ⚠️ **기존(PHP) 방식과의 결정적 차이**: 기존 시스템도 `session_start()` 기반 세션 쿠키였지만, "행 삭제=즉시 무효화"가 **표에만 있고 실제로 구현되지 않았다.** `logoutFormProc.php`는 세션 값을 빈 문자열로 초기화만 할 뿐 세션 자체를 파기하지 않았고, 토큰도 `TOYO_ID_INFO.TOKEN` 컬럼(사용자당 1개)에 저장해 "삭제"가 아닌 "덮어쓰기"로만 관리됐다. 신규 설계는 세션을 **별도 테이블의 행**으로 분리해 `DELETE` = 즉시 무효화를 코드 구조로 보장한다(5-3 참고).

toyo는 교사·관리자만 로그인하는 폐쇄형 백오피스이며 외부 API·모바일 연동 계획이 없다. 세션 쿠키만으로 충분하고, JWT의 무상태·크로스도메인 이점이 실익으로 이어지지 않는다.

---

### 5-2. 비밀번호 해싱

```python
# security.py
from pwdlib import PasswordHash

password_hash = PasswordHash.recommended()  # Argon2

def hash_password(plain: str) -> str:
    return password_hash.hash(plain)

def verify_password(plain: str, hashed: str) -> bool:
    return password_hash.verify(plain, hashed)
```

원칙: 비밀번호는 어떤 경우에도 원문 저장하지 않는다. `password_hash` 컬럼은 `UserOut` 응답 스키마에 절대 포함하지 않는다.

> ⚠️ **기존(PHP) 방식과의 차이**: 기존 `TOYO_ID_INFO.PASSWD`는 `MD5(비밀번호)`(무솔트)로 저장됐고, 검증도 `WHERE PASSWD = MD5('$PASSWD')` 형태로 DB에서 직접 비교했다(SQL 문자열 결합 — 인젝션 여지 포함). Argon2는 이 두 문제(약한 해시, DB단 평문 결합)를 모두 제거한다.

**레거시 계정 마이그레이션(지연 재해시)** — 기존 교사 계정을 일괄 초기화하면 운영 혼선이 크므로, 로그인 시점에 자동 전환한다.

```python
import hashlib

def verify_and_upgrade(plain: str, stored: str, user_id: str, db: Session) -> bool:
    if len(stored) == 32:  # 레거시 MD5 해시(32자리 hex)로 판단
        if hashlib.md5(plain.encode()).hexdigest() != stored:
            return False
        # 검증 성공 시 즉시 Argon2로 교체
        db.execute(
            update(models.User)
            .where(models.User.id == user_id)
            .values(password_hash=hash_password(plain))
        )
        db.commit()
        return True
    return verify_password(plain, stored)
```

사용자는 비밀번호를 다시 입력할 필요 없이, 다음 로그인 시점부터 자동으로 안전한 해시로 전환된다.

---

### 5-3. 세션 발급/검증 흐름

```mermaid
sequenceDiagram
    autonumber
    actor U as 교사/관리자
    participant B as 브라우저
    participant API as FastAPI
    participant DB as login_sessions 테이블

    rect rgb(234,241,251)
    Note over U,DB: 로그인 성공 시점
    U->>API: POST /auth/login (id, password)
    API->>API: verify_and_upgrade() 통과
    API->>API: secrets.token_hex(32) → 세션ID 생성
    API->>DB: INSERT {session_id, user_id}
    API->>API: users.login_last_time 갱신
    API-->>B: Set-Cookie: session_id=토큰, HttpOnly, SameSite=Lax
    end

    rect rgb(252,239,227)
    Note over U,DB: 이후의 모든 보호 API 요청 (예: 성적 등록)
    B->>API: 쿠키 자동 첨부하여 요청
    API->>DB: SELECT WHERE session_id=?
    alt 존재함
        DB-->>API: user_id 반환
        API->>API: users에서 auth_level 조회 후 권한 검사
        API->>API: 정상 로직 진행
    else 존재하지 않음
        API-->>B: 401
    end
    end

    rect rgb(228,245,233)
    Note over U,DB: 로그아웃
    U->>API: POST /auth/logout
    API->>DB: DELETE WHERE session_id=?
    API-->>B: delete_cookie 응답
    Note over B,DB: 동일 쿠키로 재요청해도<br/>DB에 행이 없으므로 401
    end
```

> 💡 기존 시스템은 로그인 이력을 `TOYO_ID_INFO_HIST`에 **날짜 단위 1건**으로만 남겼다(같은 날 재로그인은 upsert로 덮어써 이력이 소실됨). `login_sessions`는 로그인마다 독립된 행이므로, 필요 시 이 테이블을 그대로 로그인 이력 조회에도 활용할 수 있다(별도 이력 테이블 불필요).

---

### 5-4. get_current_user 상세

| 단계 | 확인 | 실패 시 |
|---|---|---|
| ① | 쿠키 존재 | 401 |
| ② | login_sessions 행 존재 여부 | 401(위조/로그아웃된 세션) |
| ③ | 세션 행의 user_id로 users 조회 | (정상 흐름에서 미발생, FK 보장) |
| ④ | User 객체 반환 | — |

```python
def get_current_user(
    session_id: str | None = Cookie(default=None),
    db: Session = Depends(get_db),
) -> models.User:
    if session_id is None:
        raise HTTPException(401, "로그인이 필요합니다")
    session = db.get(models.LoginSession, session_id)
    if session is None:
        raise HTTPException(401, "로그인이 필요합니다")
    return db.get(models.User, session.user_id)
```

toyo는 `AUTH`(권한 레벨 0~8) 기반 기능 접근 제어가 실제 업무 요구사항이므로, `get_current_user` 위에 권한 레벨 검사 의존성을 한 단계 더 둔다.

```python
def require_auth_level(min_level: int):
    def checker(user: models.User = Depends(get_current_user)) -> models.User:
        if user.auth_level < min_level:
            raise HTTPException(403, "권한이 없습니다")
        return user
    return checker

# 보호 라우터 적용 — 예: 반별 성적 등록(교사 이상만 가능)
def add_score(data: ScoreCreate,
              user: models.User = Depends(require_auth_level(1)),
              db: Session = Depends(get_db)):
    ...
```

> ⚠️ **기존(PHP) 방식과의 결정적 차이**: 기존 시스템은 로그인 여부·권한 확인이 `menuSelect.php`(메뉴 목록을 그리는 화면)에만 존재했고, 실제 쓰기를 수행하는 `banScoreModifyProc.php` 등 `~Proc.php` 파일들은 세션 검사를 전혀 하지 않았다. `$_SESSION[ID]`는 감사 기록(수정자) 값으로만 읽혔을 뿐이다. 즉 URL을 직접 알면 **로그인하지 않고도 데이터 수정이 가능**했다. 신규 설계는 이 문제를 "화면에서 숨기는 것"이 아니라 **모든 쓰기 라우터에 `require_auth_level`(또는 최소 `get_current_user`) 의존성을 코드 리뷰 필수 항목으로 강제**하는 것으로 구조적으로 차단한다.

`AUTH` 값은 기존 `TOYO_ID_INFO.AUTH`(문자열)를 정수로 정규화해 이관한다.

| auth_level | 레거시 라벨 |
|---|---|
| 0 | 보조교사 |
| 1 | 꿈땅교사 |
| 2 | 게임디렉터 |
| 5 | (담임/임원)교사 |
| 6 | (불티/티엔티)팀장 |
| 7 | 교역자/부장/행정 |
| 8 | 전산팀(최고 권한) |

(값 사이 공백(3, 4)은 향후 확장 여지로 그대로 유지한다. `GROUP_CODE`는 권한이 아닌 소속 조직 구분 값이므로 `auth_level`과 혼용하지 않는다.)

---

### 5-5. 보안 고려사항

| 항목 | 규칙 | 근거 |
|---|---|---|
| 쿠키 HttpOnly | 설정 | JS의 쿠키 접근 차단, XSS 세션 탈취 방지 |
| **쿠키 SameSite** | `Lax` 이상 설정 | 타 사이트에서 발생한 요청에 쿠키가 자동 첨부되는 것을 막아 CSRF 위험 완화 |
| 로그인 실패 응답 | 동일 문구로 통일 | 계정 열거(enumeration) 공격 방지 |
| 타인 데이터 접근 | 403 아닌 404 | 데이터 존재 자체 비노출. 조회 조건에 user_id 포함 시 자연 구현 |
| 비밀번호 저장 | Argon2 해시만(레거시 MD5는 5-2 방식으로 순차 폐기) | DB 유출 시에도 원문 비노출 |
| **쓰기 라우터 인증 강제(신규 추가)** | 모든 POST/PUT/DELETE 라우터에 `get_current_user`(또는 `require_auth_level`) 의존성 필수 | 기존 시스템의 최대 결함(§5-4 경고) 재발 방지. 라우터 등록 시 의존성 누락을 코드 리뷰/린트로 점검 |
| DB 접속 계정 | 애플리케이션 전용 최소권한 계정, 자격증명은 환경변수로 분리 | 기존 `mysqli('...', 'root', '평문비번', ...)` 형태의 하드코딩 재발 방지 |

```python
response.set_cookie(
    "session_id", token,
    httponly=True,
    samesite="lax",   # 기본 CSRF 완화
    # secure=True,     # HTTPS 배포 시 활성화. 로컬 HTTP 환경에서는 미설정.
)
```

> 💡 기존 시스템은 쿠키 속성을 아무것도 지정하지 않았다(`HttpOnly`조차 없음). 위 설정은 "이미 있던 걸 강화"가 아니라 **처음으로 도입**하는 항목이다.


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




## 7. 유효성 검사 기술 명세

> toyo 프로젝트 신규 유효성 검사 명세다. 기준 문서(`7.유효성검사기술명세(기존).md`)의 구조(규칙표 → Pydantic 스키마 → 검증 2계층)를 그대로 따르되, 규칙 자체는 toyo의 실제 DB 컬럼 정의(`toyo테이블스키마DB_덤프.sql`)와 기존 화면의 JS/PHP 검증 코드(`phpcssjs소스.zip`)를 그대로 근거로 삼았다. 임의로 만든 규칙은 없다.

### 7-1. 규칙표

| 대상 | 규칙 | 통과 예 | 실패 예(→422) |
|---|---|---|---|
| 교사 ID | `^\d{7}$` | 0101234 | 12345(6자리), abc1234 |
| 교사 비밀번호 | 4~20자 | pass1234 | abc |
| 학생 이름 | 공백 제거 후 2~20자 | 김민준 | ㅁ, (빈 값), 공백만 입력 |
| 학년(GRADE) | `^[1-6]$` (초1~초6) | 3 | 0, 7 |
| 성별(SEX) | `^[MF]$` | M | 남, 1 |
| 반(BAN) | `^\d{3}$` | 003 | 3, A03 |
| 학부모 휴대폰 | `^01[016789]\d{7,8}$` (11자리 숫자) | 01012345678 | 010-1234-5678, 021234567 |
| 학부모 이름 | 1~20자 | 김철수 | (빈 값), 21자 이상 |

> ⚠️ **기존(PHP) 방식과의 차이 — 학부모 휴대폰**: 기존 JS는 `document.form['PARENTS_NO_HP_ENC[]'].value.replace(/\s/g,"").length != 11` 로 **자릿수만** 검사했다. `"01012345678"`뿐 아니라 `"99912345678"`처럼 010/011로 시작하지 않는 11자리 숫자도 그대로 통과되어 저장(AES 암호화)됐다. 신규 설계는 자릿수 대신 실제 이동통신 국번(010/011/016~019) 접두 정규식으로 강화한다.
>
> ⚠️ **기존(PHP) 방식과의 차이 — 교사 비밀번호**: 기존 `loginForm.php`는 `PASSWD.value.length == ""`(빈 값 여부)만 검사했다. 최소 길이·최대 길이(폼상 `maxlength=10`) 외 별도 복잡도 규칙이 없었다. 신규 설계에서 최소 길이 규칙을 명시적으로 도입한다.

---

### 7-2. Pydantic 스키마

```python
class TeacherLoginIn(BaseModel):
    id: str = Field(pattern=r"^\d{7}$")
    password: str = Field(min_length=4, max_length=20)

class StudentCreate(BaseModel):
    ban: str = Field(pattern=r"^\d{3}$")
    stud_name: str = Field(min_length=2, max_length=20)
    grade: str = Field(pattern=r"^[1-6]$")
    sex: str = Field(pattern=r"^[MF]$")
    parents_no_hp: str = Field(pattern=r"^01[016789]\d{7,8}$")
    parents_name: str = Field(min_length=1, max_length=20)

class StudentUpdate(BaseModel):
    ban: str | None = Field(default=None, pattern=r"^\d{3}$")
    stud_name: str | None = Field(default=None, min_length=2, max_length=20)
    grade: str | None = Field(default=None, pattern=r"^[1-6]$")
    sex: str | None = Field(default=None, pattern=r"^[MF]$")
    parents_no_hp: str | None = Field(default=None, pattern=r"^01[016789]\d{7,8}$")
    parents_name: str | None = Field(default=None, min_length=1, max_length=20)
```

> ⚠️ **crud.py 중복 확인 함수 — `exclude_id` 반영 (기존 시스템의 실제 중복확인 쿼리를 그대로 이식)**:
>
> 기존 `banStudInfoNewRegModifyProc.php`는 `STUD_NAME + GRADE + SEX + USE_YN='Y'` 조합이 같고 `STUD_NO`만 다른 행이 있는지를 검사했다(동명이인이라도 학년·성별까지 같으면 중복으로 간주). 신규 설계는 이 로직을 코드로 그대로 옮기되, `exclude_id`(자기 자신 제외) 패턴으로 등록/수정 양쪽에 재사용한다.
>
> ```python
> # crud.py
> def student_dup_exists(
>     db: Session, stud_name: str, grade: str, sex: str, exclude_stud_no: str | None = None
> ) -> bool:
>     stmt = select(models.Student).where(
>         models.Student.stud_name == stud_name,
>         models.Student.grade == grade,
>         models.Student.sex == sex,
>         models.Student.use_yn == "Y",
>     )
>     if exclude_stud_no is not None:
>         stmt = stmt.where(models.Student.stud_no != exclude_stud_no)
>     return db.scalar(stmt) is not None
>
> # routers/students.py — 신규 등록(exclude 없이 호출)
> if crud.student_dup_exists(db, data.stud_name, data.grade, data.sex):
>     raise HTTPException(409, "동일 학년·성별에 이미 등록된 이름입니다")
>
> # routers/students.py — 정보 수정(자기 자신을 exclude)
> if crud.student_dup_exists(db, data.stud_name, data.grade, data.sex, exclude_stud_no=student.stud_no):
>     raise HTTPException(409, "동일 학년·성별에 이미 등록된 이름입니다")
> ```

> ⚠️ **기존(PHP) 방식과의 차이 — 학생번호(STUD_NO) 채번**: 기존 시스템은 `SELECT LPAD(MAX(STUD_NO)+1,5,0)`로 다음 번호를 계산한 뒤 별도 INSERT를 실행했다(`banStudInfoNewRegProc.php`). 두 교사가 신규 등록을 동시에 제출하면 같은 `STUD_NO`를 계산해 충돌할 수 있는 **MAX+1 경쟁 조건**이다. 신규 설계는 `stud_no`를 진짜 `AUTO_INCREMENT`(또는 `SEQUENCE`) 컬럼으로 선언해 DB가 값을 발급하게 하고, 애플리케이션은 값을 계산하지 않는다.

---

### 7-3. 검증 2계층 구조

| 계층 | 판단 기준 | 처리 주체 | 실패 |
|---|---|---|---|
| ① 형식 검증 | 입력 단독 판단 가능 | Pydantic 자동 | 422 |
| ② 데이터 검증 | DB 조회 필요 | crud.py 코드 | 404/409 |

```mermaid
flowchart LR
    Req["요청"] --> P1["① Pydantic<br/>형식 검증"]
    P1 -- "실패" --> R1["422"]
    P1 -- "통과" --> P2["② crud.py<br/>데이터 검증<br/>(student_dup_exists 등)"]
    P2 -- "실패" --> R2["404/409"]
    P2 -- "통과" --> OK["정상 처리"]

    style R1 fill:#FBE1E1,stroke:#C0392B
    style R2 fill:#FCEFE3,stroke:#D8964C
    style OK fill:#E4F5E9,stroke:#2E8B57
```

> 💡 기존 시스템에는 이 2계층 구분이 없었다. `banStudInfoNewRegModifyProc.php`는 형식 검증(빈 값 여부 등)과 데이터 검증(중복 확인 쿼리)이 같은 파일, 같은 흐름 안에 섞여 있었고 실패 시 응답도 `alert()` + `history.go(-1)` 하나뿐이라 422와 409를 구분할 방법이 없었다. 신규 설계는 실패 원인에 따라 상태코드를 분리해, 화면단이 "입력을 고쳐야 하는지(422)" "이미 존재해서 안 되는지(409)"를 구분해 안내할 수 있게 한다.









## 8. 단계별 워크플로우 (toyo 프로젝트)

> 아래 흐름은 레거시 PHP 소스(`loginFormProc.php`, `banStudInfoNewRegProc.php`, `banScoreRegProc.php` 등)를 실제로 분석해서, 그 안에 담긴 **업무 로직**을 신규 FastAPI/SQLAlchemy(PostgreSQL 16) 구조에 맞춰 재설계한 것입니다. 레거시의 구현 방식(문자열 조합 SQL, 세션 처리 등)을 그대로 옮기는 게 아니라, 레거시가 지키던 **업무 규칙**만 추출해 정확한 흐름으로 재구성했습니다.

### 8-1. 공통 처리 파이프라인

```mermaid
flowchart LR
    A["fetch"] --> B["① 세션확인<br/>401"] --> C["② 형식검증<br/>422"] --> D["③ 데이터검증/중복확인<br/>404/409"] --> E["④ 처리+커밋"] --> F["⑤ JSON응답"]

    style B fill:#FBE1E1,stroke:#C0392B
    style C fill:#FBE1E1,stroke:#C0392B
    style D fill:#FCEFE3,stroke:#D8964C
    style F fill:#E4F5E9,stroke:#2E8B57
```

①은 인증 필수 API(관리자/교사 로그인 이후)에만, ③은 본문 있는 요청(POST/PATCH)에만 적용. 어느 단계든 실패 시 이후 단계 미실행, 즉시 오류 응답.

**레거시 → 신규 전환 시 반드시 보강해야 할 지점 (20년차 설계자 관점)**

| 레거시 방식 | 문제 | 신규 설계 |
|---|---|---|
| `$_SESSION[TOKEN]`을 PHP 세션에 저장, 별도 만료 로직 없음 | 세션 하이재킹/무기한 로그인 위험 | FastAPI 세션 쿠키 + 서버측 만료(TTL) 관리 |
| 비밀번호 `MD5('$PASSWD')` | MD5는 크랙 가능한 해시, 솔트 없음 | `bcrypt`/`argon2`로 재해싱, 최초 로그인 시 마이그레이션 |
| `AES_ENCRYPT(컬럼, 'dlsejr00**')` — 암호화 키가 소스코드에 하드코딩 | 키 유출 시 전체 개인정보(`parents_no_hp_enc`, `ban_hp_enc`) 노출 | 키는 환경변수/시크릿 매니저로 분리, 애플리케이션 레벨 암호화로 전환 |
| SQL을 문자열로 직접 조합(`'$_POST[ID]'`) | SQL Injection 위험 | SQLAlchemy 파라미터 바인딩으로 원천 차단 |

---

### 8-2. 시퀀스 — 로그인 (레거시 `loginFormProc.php` 기준)

```mermaid
sequenceDiagram
    autonumber
    actor U as 사용자(교사/관리자)
    participant R as 라우터
    participant C as crud.login
    participant DB as PostgreSQL

    U->>R: POST /auth/login (id, passwd)
    R->>DB: SELECT toyo_id_info WHERE id=? AND passwd=hash(?) AND use_yn='Y'
    alt 일치하는 계정 없음
        DB-->>R: 없음
        R-->>U: 401 (정확한 아이디를 입력해 주세요)
    else 인증 성공
        DB-->>R: id, k_name, auth
        R->>C: login(id)
        C->>C: 세션 토큰 생성
        C->>DB: UPDATE toyo_id_info SET token=?, login_last_time=now(), mod_date=now()
        C->>DB: INSERT toyo_id_info_hist (id, enroll_date=오늘, mac_address, reg_date) <br/>ON CONFLICT(id, enroll_date) DO UPDATE
        C->>DB: COMMIT
        DB-->>C: 완료
        C-->>R: 세션 정보
        R-->>U: 200 OK + 세션 쿠키 발급
    end
```

레거시는 로그인 성공 시 `TOYO_NOTICE_INFO`에서 게시기간 중인 공지를 조회해 `alert()`로 띄우는 로직도 포함되어 있었으나, 이는 UI 관심사이므로 신규 설계에서는 `GET /notices/active`로 별도 분리한다.

---

### 8-3. 시퀀스 — 학생 신규 등록 (레거시 `banStudInfoNewRegProc.php` 기준, 대표)

```mermaid
flowchart TD
    A["POST /students"] --> B{"① 세션 쿠키 유효?"}
    B -- "No" --> R1["401"]
    B -- "Yes" --> C{"② Pydantic 형식<br/>검증 통과?"}
    C -- "No" --> R2["422"]
    C -- "Yes" --> D{"③ 동일 이름+학년+성별<br/>use_yn='Y' 학생 존재?"}
    D -- "Yes" --> R3["409<br/>'동일한 학생정보가 존재합니다'"]
    D -- "No" --> E["④ stud_no 채번<br/>(MAX(stud_no)+1, 5자리 zero-pad)"]
    E --> F["⑤ parents_no_hp 암호화 + INSERT + COMMIT"]
    F --> R4["201 Created + 학생 JSON"]

    style R1 fill:#FBE1E1,stroke:#C0392B
    style R2 fill:#FBE1E1,stroke:#C0392B
    style R3 fill:#FCEFE3,stroke:#D8964C
    style R4 fill:#E4F5E9,stroke:#2E8B57
```

**레거시 로직 중 신규 설계에서 반드시 고쳐야 하는 부분**

- `stud_no`를 `SELECT MAX(stud_no)+1`로 채번 — 동시에 두 명이 등록하면 같은 번호가 발급되는 **경쟁 조건(race condition)**이 있다. 신규 설계에서는 PostgreSQL `SEQUENCE` 또는 `SELECT ... FOR UPDATE`로 채번을 원자적으로 처리해야 한다.
- 중복 검사가 "이름+학년+성별" 3개 조합만 보는데, 동명이인이 흔한 경우 오탐(false positive)이 날 수 있다 — 정책을 그대로 유지할지, 생년월일 등을 추가할지는 별도 확인이 필요하다.

---

### 8-4. 시퀀스 — 점수/출결 등록 및 삭제 정책 (엣지 케이스)

```mermaid
flowchart TD
    A["POST /scores"] --> B{"① 세션 확인"}
    B -- "No" --> R1["401"]
    B -- "Yes" --> C{"② 내 반(ban) 학생?"}
    C -- "No" --> R2["404"]
    C -- "Yes" --> D["③ toyo_stud_score 5건<br/>(고정출석/복장/교재/암송/출결점수)<br/>+ toyo_stud_chul 1건 UPSERT"]
    D --> R3["201 Created"]

    style R1 fill:#FBE1E1,stroke:#C0392B
    style R2 fill:#FBE1E1,stroke:#C0392B
    style R3 fill:#E4F5E9,stroke:#2E8B57
```

레거시는 `toyo_stud_score`(PK: `enroll_date`+`ban`+`stud_no`+`subject`)에 동일 건을 두 번 등록하면 **PK 충돌로 실패**한다(재등록/수정 처리가 없었다). 신규 설계에서는 `INSERT ... ON CONFLICT (enroll_date, ban, stud_no, subject) DO UPDATE`로 바꿔서, 담당 교사가 점수를 실수로 다시 등록해도 덮어쓰기가 되도록 하는 것을 권장한다.

**삭제(DELETE) 정책 — 레거시와 신규 스키마의 근본적 차이**

레거시 PHP 소스 전체(약 280개 파일)를 확인한 결과, `toyo_*` 테이블에 대한 실제 `DELETE FROM` 구문은 **단 한 건도 없었다**. 모든 "삭제"는 `USE_YN = 'N'`으로 갱신하는 **소프트 삭제**만 사용했고, 물리적 레코드 삭제는 발생한 적이 없다.

반면 신규 스키마는 결정하신 대로 **전체 FK가 `ON DELETE CASCADE`**로 되어 있다. 이는 레거시에는 없던 물리 삭제 기능을 신규 시스템에 새로 추가하는 것이므로, 아래 원칙을 명시해 둘 필요가 있다.

| 삭제 유형 | 적용 대상 | 동작 |
|---|---|---|
| **소프트 삭제 (기본, 레거시와 동일)** | 학생/반/교사 등 대부분의 일반 CRUD | `use_yn`을 `'N'`으로 UPDATE, 물리 레코드는 유지 |
| **하드 삭제 (신규 추가 기능, 관리자 전용)** | 데이터 정리가 필요한 관리자 작업 | 실제 `DELETE` 실행 → `ON DELETE CASCADE`로 자식 레코드까지 DB 레벨에서 연쇄 삭제됨 |

하드 삭제 API는 `toyo_stud_info` 같은 상위 테이블 하나만 지워도 `toyo_stud_score`, `toyo_stud_chul`, `toyo_stud_dream` 등 다수 테이블이 연쇄로 사라지므로, **관리자 권한 확인 + 삭제 전 확인(confirm) 절차**를 반드시 넣는 것을 권장한다. RESTRICT처럼 애플리케이션이 사전에 자식 건수를 세어 409로 막는 방식은 이번 CASCADE 정책상 적용하지 않는다.





## 9. 에러/예외 처리 전략 (toyo 프로젝트)

> 8번 문서와 마찬가지로, 레거시 PHP의 `alert()` 기반 오류 처리(HTTP 상태 코드 없이 클라이언트 스크립트로만 안내)를 FastAPI의 표준 상태 코드 체계로 재설계한 것입니다. toyo 프로젝트는 contact-manager 예시와 달리 **① 전체 FK가 CASCADE로 통일**되어 있고 **② 레거시가 소프트 삭제(`use_yn`) 중심**이었다는 두 가지 특징이 상태 코드 설계에 직접 반영됩니다.

### 9-1. 상태 코드 매트릭스

| 코드 | 의미 | 발생 상황 (toyo 기준) |
|---|---|---|
| 401 | 인증 필요/실패 | 세션 없음·무효, 로그인 아이디/비밀번호 불일치 |
| 403 | 권한 없음 | 일반 교사(`AUTH`)가 관리자 전용 기능(하드 삭제, 반 배정 변경 등) 호출 |
| 404 | 대상 없음 | 없는 `stud_no`/`ban`/`id`, 담당 반이 아닌 학생·반 데이터 접근 (`ban` 필터로 자연 구현) |
| 409 | 규칙 충돌 | 동일 학생 중복 등록(이름+학년+성별), 동일 `enroll_date+ban+stud_no+subject` 점수 재등록, 로그인 계정 `use_yn='N'`(비활성 계정) |
| 422 | 형식 위반 | Pydantic 규칙 위반(자동) |
| 500 | 서버 오류 | 발생 금지(예외 처리 누락 신호) |

레거시에는 없던 **403**을 새로 추가했다. 레거시는 `AUTH` 컬럼(권한 구분)이 있었음에도 실제로는 화면 메뉴만 숨기고 서버단 권한 검증은 하지 않았는데, 이는 URL을 직접 호출하면 권한 없이도 처리가 되는 구조적 결함이었다. 신규 설계에서는 반드시 서버 측에서 `AUTH`를 검증해 403을 반환해야 한다.

### 9-2. 원칙

- **소프트 삭제가 기본, 하드 삭제는 예외**: 일반 CRUD의 "삭제"는 `use_yn='N'` UPDATE이며 404/409를 발생시키지 않는다(존재만 확인하면 됨). 관리자 전용 하드 삭제(`DELETE`)만 403/404 검증 후 실행하고, CASCADE로 자식 레코드가 함께 사라지므로 **사전 count 확인 후 409로 막는 로직 자체가 없다** — 이 점이 contact-manager(카테고리 RESTRICT) 예시와 가장 크게 다른 부분이다.
- **담당 반 외 데이터는 403이 아닌 404로 응답**: 존재 여부 비노출 원칙은 그대로 유지하되, "내 반인가"의 판단 기준은 `user_id`가 아니라 **교사·반 배정 관계(`ban`)**다.
- **동시 등록으로 인한 PK 충돌은 409로 변환**: 레거시는 `toyo_stud_score` 중복 INSERT 시 DB 예외(500)가 그대로 나던 구조였다. 신규 설계에서는 `IntegrityError`를 잡아 409로 감싸거나, `INSERT ... ON CONFLICT DO UPDATE`로 애초에 충돌 자체를 없앤다(8-4 참고).
- 오류 응답은 `{"detail": "..."}`로 통일.

### 9-3. 코드 패턴

```python
# 1) 담당 반 소속 학생 조회 — 존재 여부 비노출(404)
student = crud.get_student_in_my_ban(db, teacher.ban, stud_no)
if student is None:
    raise HTTPException(status_code=404, detail="해당 학생 정보가 없습니다")

# 2) 관리자 전용 기능 — 403
if not teacher.is_admin:
    raise HTTPException(status_code=403, detail="관리자만 사용할 수 있는 기능입니다")

# 3) 신규 학생 등록 시 중복 검사(이름+학년+성별, use_yn='Y') — 409
if crud.student_duplicate_exists(db, name=data.stud_name, grade=data.grade, sex=data.sex):
    raise HTTPException(
        status_code=409,
        detail="동일한 학생 정보가 이미 존재합니다(이름/학년/성별 중복). 기존 학생 정보를 확인해 주세요.",
    )

# 4) 로그인 시 계정 상태 확인 — 401 vs 409
account = crud.get_id_info(db, data.id, hash_password(data.passwd))
if account is None:
    raise HTTPException(status_code=401, detail="아이디 또는 비밀번호가 올바르지 않습니다")
if account.use_yn != "Y":
    raise HTTPException(status_code=409, detail="비활성화된 계정입니다. 관리자에게 문의해 주세요")

# 5) 점수 등록 — PK(enroll_date, ban, stud_no, subject) 충돌은 업데이트로 흡수 (409 없음)
crud.upsert_score(
    db,
    enroll_date=data.enroll_date, ban=teacher.ban, stud_no=data.stud_no,
    subject=data.subject, score=data.score,
)  # 내부적으로 INSERT ... ON CONFLICT (enroll_date, ban, stud_no, subject) DO UPDATE

# 6) 하드 삭제(관리자 전용) — CASCADE로 자식 레코드까지 함께 삭제됨을 명확히 안내
if not teacher.is_admin:
    raise HTTPException(status_code=403, detail="하드 삭제는 관리자만 실행할 수 있습니다")
student = crud.get_student(db, stud_no)
if student is None:
    raise HTTPException(status_code=404, detail="해당 학생 정보가 없습니다")
crud.hard_delete_student(db, stud_no)  # ON DELETE CASCADE로 성적/출결/희망분야 등 종속 레코드 자동 삭제
```






## 10. 테스트 시나리오 (toyo 프로젝트)

### 문서 작성 기준 안내
첨부해주신 예시 문서는 **자체 PRD의 AC-01~17**과 1:1 대응된 문서였습니다. toyo 프로젝트는 이번 대화 시점까지 별도의 PRD/AC 목록이 작성되어 있지 않아, 같은 형식을 유지하되 **AC 항목 자체를 실제 PHP 소스코드 검증(AS-IS 코드 리딩)을 통해 확보한 사실만으로 새로 정의**했습니다. 추측이나 일반적인 REST API 관례(401/409/422 등)를 적용하지 않고, toyo가 실제로 동작하는 방식(레거시 procedural PHP + `mysql_*`/`mysqli`, alert()+리다이렉트 기반 UX)을 그대로 반영했습니다.

각 AC 항목에는 근거가 된 소스파일을 표기했습니다. 이 표는 이후 정식 PRD 작성 시 AC 원본으로 그대로 승격시켜 사용하시면 됩니다.

1차 검증(로그인/학생등록/출석/코드관리)에 이어, 가장 기본적으로 사용하는 9개 메뉴(학생출결등록/암송자등록/암송자PPT/학생출결현황/교사출석등록/교사출결현황/암송발표자현황/학생점수현황/교사생일(월))를 2차로 검증해 AC-14~22, TC-21~33을 추가했습니다. 이 과정에서 **3개 화면에 걸쳐 반복되는 동일한 회귀 버그 패턴**을 발견해 별도로 강조했습니다.

> ⚠️ **핵심 발견 — "당일 등록 제한" 로직이 상시 무력화된 코드 패턴**
> `학생출결등록`(`banChulRegProc.php`), `암송자등록`(`banMemoryRegProc.php`), `학생점수등록`(`banScoreRegProc.php`) 3개 화면 전부 아래와 같은 동일한 형태의 코드를 가지고 있습니다.
> ```php
> if ($poss_yn === "N" && 1===2) {   // 항상 거짓 → 아래 안내/차단 블록은 절대 실행되지 않음
>     echo "...당일만 등록 가능합니다...";
> } else {
>     // 실제 등록 처리
> }
> ```
> `TOYO_REG_DATE_POSS`를 조회해 `$poss_yn`을 정상적으로 계산하지만, 마지막에 `&& 1===2`(또는 `1==2`)라는 항상 거짓인 조건이 붙어 있어 **차단 로직 자체가 죽은 코드**입니다. 실제로는 토요하자 진행일이 아니어도 세 화면 모두 상시 등록이 가능합니다. 반면 같은 계열인 `필드체험학습 등록`(`banChulRegAllProc.php`)은 조건이 `&& 1===1`로 되어 있어 **정상적으로 차단**됩니다 — 즉 화면마다 제한 여부가 들쭉날쭉합니다. 개발/디버그 중 임시로 넣었다가 되돌리지 못한 코드로 추정되며, 가장 많이 쓰이는 메뉴들에 걸쳐 있어 우선순위 높은 회귀 확인 대상입니다.

### AC(인수기준) 목록 — 코드 검증 기반 신규 도출

| AC | 내용 | 근거 파일 |
|---|---|---|
| AC-01 | ID+비밀번호(MD5) 일치 & USE_YN='Y' 인 계정만 로그인 성공, 64자리 랜덤 TOKEN 발급 후 세션(`TOKEN/ID/K_NAME/AUTH`) 저장 | `loginFormProc.php` |
| AC-02 | 로그인 실패(아이디/비번 불일치, 또는 USE_YN≠'Y') 시 동일 문구로 안내 후 입력 화면 유지 (계정 존재 여부 미노출) | `loginFormProc.php` |
| AC-03 | 로그인 성공 시 `TOYO_ID_INFO_HIST`에 (ID, 당일 ENROLL_DATE) 기준 접속이력 upsert (`ON DUPLICATE KEY UPDATE`로 MAC/시간 갱신) | `loginFormProc.php` |
| AC-04 | 세션ID 없음 / 세션TOKEN 없음 / DB TOKEN 없음 / 세션TOKEN≠DB TOKEN — 4가지 상황을 각각 다른 문구로 안내하고 로그인 화면으로 강제 이동 | `dbconfig.php` |
| AC-05 | 학생 신규등록 시 STUD_NO는 `LPAD(MAX(STUD_NO)+1,5,0)`로 자동 채번 (5자리, 예: 00001) | `banStudInfoNewRegProc.php` |
| AC-06 | 학생 신규등록 시 (이름+학년+성별) 조합이 USE_YN='Y'인 기존 학생과 동일하면 등록 차단(안내 후 이전 화면 복귀), 다르면 정상 등록 | `banStudInfoNewRegProc.php` |
| AC-07 | 학생 보호자 연락처는 `AES_ENCRYPT(값,'dlsejr00**')` 후 HEX 인코딩하여 저장 (평문 미저장) | `banStudInfoNewRegProc.php` |
| AC-08 | 야외체험학습(출석) 등록/전체등록은 `TOYO_REG_DATE_POSS`에 **당일 날짜**가 USE_YN='Y'로 등록되어 있어야만 허용, 아니면 안내 후 차단 | `banChulRegAllProc.php` |
| AC-09 | 공통코드(TOYO_CODE_NAME) 수정은 별도 검증/중복확인 없이 OPT+CODE 매칭 시 즉시 UPDATE (실패/미존재 여부와 무관하게 항상 "성공" 안내 노출) | `banCodeNameModifyProc.php` |
| AC-10 | 메뉴 노출은 `$_SESSION['AUTH']`(숫자 문자열) 값과 메뉴별 `LEVEL`을 비교해 결정 (AUTH≥LEVEL일 때만 노출) | `topMenuInclude.php`, `menuSelect.php` |
| AC-11 | 반(BAN) 코드가 담긴 화면은 세션 기준이 아닌 **폼/URL 파라미터(`$_POST[BAN]` 등)** 로 조회 대상을 결정 — 로그인한 교사가 자신이 담당하지 않는 BAN 값을 임의로 넘겨도 서버 측에서 별도 소유권 검증을 하지 않음 | `banChulRegAllProc.php` 외 다수 `ban*List/Modify*.php` |
| AC-12 | 로그아웃 시 세션 파기 후 이후 보호된 화면 접근은 AC-04 기준으로 재차단 | `logoutFormProc.php`, `dbconfig.php` |
| AC-13 | 대부분의 등록/수정 쿼리는 `$_POST` 값을 이스케이프 없이 문자열로 직접 결합 (`mysql_query`/`mysqli->query`) — 특수문자·SQL 예약어 입력 시 쿼리 오류 또는 비정상 동작 가능 | `banCodeNameModifyProc.php`, `banStudInfoNewRegProc.php` 등 |
| AC-14 | 학생출결등록: 폼 진입 시 오늘 이미 등록된 반이면 "정보수정 버튼을 눌러주세요" 안내(클라이언트 JS `DUPCHK`) 후 목록으로 이동 | `banChulReg.php` |
| AC-15 | 학생출결등록: CHUL_KIND가 결석/조퇴/지각(12/13/14)이면 사유(REASON) 입력이 **클라이언트 JS에서만** 필수이며, 서버(`banChulRegProc.php`)는 REASON 값을 검증 없이 그대로 저장 → 빈 사유로도 서버 직접 호출 시 저장됨 | `banChulReg.php`(클라이언트), `banChulRegProc.php`(서버) |
| AC-16 | 학생출결등록: `TOYO_REG_DATE_POSS` 기반 당일 제한 검사 코드가 있으나 `1===2` 조건으로 항상 비활성화되어 실제로는 날짜 제한이 동작하지 않음(상단 핵심 발견 참고) | `banChulRegProc.php` |
| AC-17 | 암송자등록: MEMORY_KIND_1/2/3 세 개를 한 행에 저장, 당일 제한 검사 코드가 동일하게 `1===2`로 비활성화되어 상시 등록 가능 | `banMemoryRegProc.php` |
| AC-18 | 학생점수등록: 당일 제한 검사 코드가 동일하게 `1==2`로 비활성화되어 상시 등록 가능 (학생점수현황 화면의 "점수등록" 버튼과 연결) | `banScoreRegProc.php` |
| AC-19 | 교사출석등록: 동일 (ENROLL_DATE,TEACHER_KIND,BAN) 중복 여부를 조회는 하지만(`$total`) 그 결과로 분기 처리하지 않아 **중복 체크가 사실상 없음**. ENROLL_DATE는 사용자 입력이 아니라 서버가 `ADDDATE(CURDATE(), 7-DAYOFWEEK(CURDATE()))`(돌아오는 토요일)로 자동 계산해서 저장 | `banTeacherRegProc.php` |
| AC-20 | 교사출석등록: PK(ENROLL_DATE,TEACHER_KIND,BAN) 중복 INSERT 시 DB 에러가 나더라도 `$mysqli->query()` 반환값을 검사하지 않아 화면엔 항상 "정상 처리" 메시지만 노출됨(에러 무시) | `banTeacherRegProc.php` |
| AC-21 | 교사생일(월): `TOYO_ID_INFO.SSN`(4자리, 생년월일 MMDD로 사용 — 실제 주민번호 아님)을 기준으로 월별 목록 필터링, `AUTH < 9` 조건으로 최고관리자 계정은 목록에서 제외 | `banTeacherBirthList.php` |
| AC-22 | 학생점수현황/암송자PPT/암송발표자현황/학생출결현황/교사출결현황 등 조회 화면도 기존 AC-11과 동일하게 세션이 아닌 `$_POST[BAN]` 파라미터로 조회 범위가 결정됨(IDOR 패턴 적용 범위 확장) | `banScoreList.php`, `banStudScoreAverageList.php`, `banMemoryManagePPT.php`, `banBibleMemoryStatisticsList.php`, `banChulManageList.php`, `banStudChulStatisticsList.php`, `banTeacherChulStatisticsList.php` |

---

### 테스트 시나리오

계정 2개(교사A=AUTH 낮음, 관리자B=AUTH="9")로 검증하며, 예시 문서의 A/B 대조 패턴을 그대로 적용했습니다.

| TC | 입력/행위 | 기대 결과 | 대응 AC |
|---|---|---|---|
| TC-01 | 등록된 ID + 올바른 비밀번호로 로그인 | 공지사항 팝업(있을 경우) 후 메뉴 화면 이동, 세션에 TOKEN/ID/K_NAME/AUTH 저장 | AC-01 |
| TC-02 | 존재하지 않는 ID로 로그인 | "정확한 아이디를 입력해 주세요" 안내, 입력화면 유지(계정 존재여부 비노출) | AC-02 |
| TC-03 | 존재하는 ID + 틀린 비밀번호로 로그인 | TC-02와 동일한 문구로 안내(사유 구분 없음) | AC-02 |
| TC-04 | USE_YN='N'으로 비활성화된 ID로 로그인 | 로그인 실패 처리(활성 계정과 동일 문구) | AC-02 |
| TC-05 | 로그인 성공 직후 `TOYO_ID_INFO_HIST` 확인 | (ID, 당일 ENROLL_DATE) 행이 없으면 INSERT, 있으면 MAC/시간만 UPDATE(행 중복 생성 안 됨) | AC-03 |
| TC-06 | 로그인하지 않은 상태로 `banChulManageList.php` 등 보호 화면 직접 접속 | "로그인이 필요합니다(세션아이디 없음)" 안내 후 로그인 화면 이동 | AC-04 |
| TC-07 | 세션은 있으나 서버 재기동 등으로 DB TOKEN이 비어있는 상태에서 접근 | "(DB 토큰 없음)" 문구로 안내 후 로그인 화면 이동 | AC-04 |
| TC-08 | 다른 브라우저(B)에서 같은 계정으로 재로그인 후, 기존 브라우저(A)에서 계속 사용 | A의 세션TOKEN과 DB TOKEN 불일치로 "(DB토큰값과 다름)" 안내 후 A는 강제 로그아웃 | AC-04 |
| TC-09 | 학생 신규등록(성별/학년/이름 신규 조합) | STUD_NO가 `기존 최대값+1`(5자리)로 자동 채번되어 등록, 목록에 반영 | AC-05 |
| TC-10 | 이미 등록된 학생과 이름/학년/성별이 모두 동일한 학생 재등록 시도 | "동일한 학생정보가 존재합니다" 안내 후 등록 차단, 신규 행 미생성 | AC-06 |
| TC-11 | 이름은 같지만 학년 또는 성별이 다른 학생 등록 | 중복으로 판단하지 않고 정상 등록(신규 STUD_NO 채번) | AC-06 |
| TC-12 | 학생 등록 후 DB의 `PARENTS_NO_HP_ENC` 컬럼 직접 조회 | 평문 전화번호가 아닌 AES 암호화 HEX 값으로 저장되어 있음(원문 미노출) | AC-07 |
| TC-13 | 당일 날짜가 `TOYO_REG_DATE_POSS`에 등록되지 않은 상태에서 출석부 전체등록 시도 | "토요하자 진행 당일만 등록 가능합니다" 안내, 미등록 | AC-08 |
| TC-14 | 당일 날짜가 등록가능일로 지정된 상태에서 동일 시나리오 재시도 | 정상 등록 처리 | AC-08 |
| TC-15 | 존재하지 않는 OPT/CODE 조합으로 코드 수정 요청(강제로 폼 조작) | 실제로는 UPDATE 대상 행이 없어 아무 것도 바뀌지 않지만, 화면은 "정상 수정되었습니다" 성공 안내를 그대로 노출 (검증 로직 부재 확인용 회귀 케이스) | AC-09 |
| TC-16 | AUTH="9"(관리자) 계정으로 로그인 후 전체 메뉴 노출 확인 | LEVEL 제한과 무관하게 모든 메뉴 노출 | AC-10 |
| TC-17 | AUTH 낮은 일반 교사 계정으로 로그인 후 메뉴 목록 확인 | 자신의 AUTH 값보다 LEVEL이 높은 메뉴는 화면에 노출되지 않음 | AC-10 |
| TC-18 | 일반 교사(A, 담당 BAN="101")로 로그인 후, 브라우저에서 폼 파라미터의 BAN 값을 다른 반("102")으로 조작하여 조회/등록 요청 전송 | 서버가 BAN 소유권을 검증하지 않아 타 반(102) 데이터가 그대로 조회/등록됨 — **AS-IS 취약점 재현 확인용 케이스**, 신규 설계 시 반드시 세션 기반 소유권 검증 추가 필요 | AC-11 |
| TC-19 | 로그아웃 실행 후 뒤로가기(브라우저 캐시)로 직전 보호 화면 재접근 | 캐시된 화면이 잠깐 보이더라도, 해당 화면의 실제 데이터 조회/등록 액션은 AC-04 기준으로 재차단됨 | AC-12 |
| TC-20 | 학생명/코드명 등 텍스트 입력란에 `'`(작은따옴표) 또는 `--`, `;` 등 SQL 특수문자 입력 후 등록/수정 | 현재 구조상 입력값이 그대로 쿼리에 결합되어 쿼리 오류 또는 비정상 데이터 저장 가능성 있음 — **SQL 인젝션 리스크 회귀 확인용 케이스**, 신규 설계 시 반드시 Prepared Statement 적용 필요 | AC-13 |
| TC-21 | 이미 오늘 출결이 등록된 반으로 학생출결등록 화면 재진입 | "OO에 등록한 출결정보가 있습니다. 정보수정 버튼을 눌러주세요" 안내 후 `banChulList.php`로 이동, 등록 폼 미노출 | AC-14 |
| TC-22 | 화면(JS)에서 결석(12)을 선택하고 사유를 비운 채 제출 시도 | 클라이언트에서 "결석/조퇴/지각시 사유는 필수입력입니다" alert로 제출 차단 | AC-15 |
| TC-23 | 브라우저 개발자도구 등으로 JS 검증을 우회하여 REASON 빈 값으로 `banChulRegProc.php`에 직접 POST | 서버 측 차단 없이 REASON이 빈 값(`''`)인 채로 그대로 `TOYO_STUD_CHUL`에 저장됨 — **AS-IS 결함 재현 케이스** | AC-15 |
| TC-24 | `TOYO_REG_DATE_POSS`에 오늘 날짜가 없는 상태에서 학생출결등록 제출 | 코드상 차단 문구가 존재하지만 실제로는 안내 없이 정상 등록됨(제한 미작동 확인) | AC-16 |
| TC-25 | 동일하게 `TOYO_REG_DATE_POSS`에 오늘 날짜가 없는 상태에서 암송자등록 제출 | TC-24와 동일하게 제한 없이 정상 등록됨 | AC-17 |
| TC-26 | 동일하게 `TOYO_REG_DATE_POSS`에 오늘 날짜가 없는 상태에서 학생점수등록 제출 | TC-24와 동일하게 제한 없이 정상 등록됨 | AC-18 |
| TC-27 | (대조군) 동일 조건에서 필드체험학습 등록(`banChulRegAllProc.php`) 제출 | 이 화면은 조건식이 살아있어 정상적으로 "당일만 등록 가능합니다" 안내로 차단됨 — 위 3개 화면과의 동작 불일치 확인용 | AC-16~18 |
| TC-28 | 동일 (교사구분, 반) 조합으로 교사출석등록을 연속 2회 제출 | 1차는 정상 등록되지만, 2차는 PK 중복으로 DB 단에서 실패함에도 화면엔 "정상적으로 등록되었습니다"로 동일하게 노출(사용자는 실패 여부를 알 수 없음) | AC-19, AC-20 |
| TC-29 | 화요일 등 평일에 교사출석등록 제출 | ENROLL_DATE 입력값과 무관하게 항상 "이번 주 돌아오는 토요일" 날짜로 저장됨 | AC-19 |
| TC-30 | 교사생일(월) 화면에서 "3월" 선택 | SSN 앞 2자리가 '03'인 활성 계정만 노출, 목록에 AUTH=9 계정은 포함되지 않음 | AC-21 |
| TC-31 | 교사생일(월) 화면에서 "전체(ALL)" 선택 | 월 필터 없이 AUTH<9인 전체 활성 계정이 SSN 오름차순으로 노출 | AC-21 |
| TC-32 | 교사A(담당 BAN="101")로 로그인 후 학생점수현황 화면에서 BAN 파라미터를 "102"로 조작 | 자신이 담당하지 않는 반(102)의 학생 점수 데이터가 그대로 조회됨 | AC-22 |
| TC-33 | 동일한 BAN 파라미터 조작을 암송자PPT / 학생출결현황 / 교사출결현황 화면에 각각 적용 | 세 화면 모두 소유권 검증 없이 타 반 데이터가 노출됨(AC-11과 동일 패턴 재확인) | AC-22 |

### 참고 — 이 문서의 한계 및 다음 단계 제안
- TC-16~20, TC-23~29는 **정상 기능 검증이 아니라 AS-IS 시스템의 구조적 취약점(권한 우회, SQL 인젝션, 비활성화된 검증, 무시된 에러, 방치된 중복확인)을 재현하는 회귀 테스트**입니다. 운영 중인 시스템이므로 실제 운영 DB가 아닌 테스트 DB에서만 수행해 주세요.
- 256개 화면 중 현재까지 로그인/학생등록/출석/코드관리 4개 핵심 흐름 + 가장 많이 쓰이는 9개 메뉴(학생출결등록/암송자등록/암송자PPT/학생출결현황/교사출석등록/교사출결현황/암송발표자현황/학생점수현황/교사생일(월))를 코드로 직접 검증했습니다. 재등록·꿈땅(진로)·포인트 등 나머지 도메인도 동일한 방식(코드 리딩 → AC 도출 → TC 작성)으로 이어서 확장해 드릴 수 있습니다.
- 위 발견 사항들은 신규(TO-BE) 설계 시 다음을 반드시 반영해야 합니다: ① 당일 등록 제한 로직을 화면마다 각각 두지 말고 공통 함수/미들웨어로 일원화, ② 서버 측 필수값 검증 추가(클라이언트 JS만으로 끝내지 않기), ③ DB 쿼리 실행 결과(성공/실패)를 반드시 확인 후 사용자에게 정확한 결과 안내, ④ 소유권(담당 반) 검증을 세션 기준으로 서버에서 강제, ⑤ Prepared Statement 적용으로 SQL 인젝션 리스크 제거.
- 이 AC 목록을 정식 PRD 문서의 "인수 기준" 섹션으로 그대로 옮겨서 6종 문서 세트(PRD/TRD/기능명세서/화면정의서 등)의 시작점으로 사용하시길 권장합니다.









## 11. 디렉터리 구조 및 실행 (toyo 프로젝트)

> contact-manager 예시는 테이블 2개짜리 소규모 구조라 `models.py` 파일 하나로 충분했지만, toyo는 실사용 테이블이 35개이고 도메인이 뚜렷하게 나뉘어 있다(회원/기준정보/학생/출결/성적/희망분야/포인트 등). 20년차 설계자 관점에서, 이 규모에서 단일 파일 구조를 유지하면 파일당 수천 줄이 되어 유지보수가 불가능해지므로 **도메인별 패키지 분리**가 필수다. 또한 운영 DB를 이관하는 프로젝트이므로 `alembic` 마이그레이션 이력 관리를 처음부터 넣는다(신규 프로젝트라고 스키마를 코드로만 관리하면, 이후 배포 환경마다 스키마가 어긋나는 사고가 반드시 발생한다).

```
toyo_app/
├── main.py                      # FastAPI 앱 진입점, 라우터 등록
├── config.py                    # .env 로드 (DATABASE_URL, SECRET_KEY, AES_ENC_KEY 등)
├── database.py                  # SQLAlchemy engine/session, Base
├── security.py                  # 비밀번호 해시(bcrypt), 세션 토큰 발급/검증
│
├── models/                      # 도메인별 SQLAlchemy 모델 (35개 테이블)
│   ├── __init__.py              # 전체 모델을 재노출 (Base.metadata가 다 인식하도록)
│   ├── code_tables.py           # toyo_ban_code_name, toyo_dream_kind, toyo_kind_name,
│   │                             #   toyo_stud_code_name, toyo_teacher_chul_code_name,
│   │                             #   toyo_code_name, toyo_ban_menu_name, toyo_reg_date_poss (기준정보 8개)
│   ├── auth.py                  # toyo_id_info, toyo_id_info_hist, md5enc (계정/인증 3개)
│   ├── student.py                # toyo_stud_info, toyo_stud_2hakgi_info, toyo_stud_2hakgi_new_info,
│   │                             #   toyo_stud_new_info, toyo_stud_reg_fee (학생 기본정보 5개)
│   ├── attendance.py             # toyo_stud_chul, toyo_stud_field_attend, toyo_stud_field_attend_teacher,
│   │                             #   toyo_teacher_chul (출결 4개)
│   ├── score.py                  # toyo_stud_score, toyo_stud_score_hist, toyo_team_game_score,
│   │                             #   toyo_team_game_score_rows, toyo_team_score_plus (성적/게임점수 5개)
│   ├── dream.py                  # toyo_stud_dream, toyo_stud_dream_course, toyo_stud_dream_year_course,
│   │                             #   toyo_stud_dream_support_grade (희망분야 4개)
│   └── etc.py                    # toyo_notice_info, toyo_point, toyo_point_payment,
│                                 #   toyo_bible_contest, toyo_stud_bible_memory, toyo_stud_memory (기타 6개)
│
├── schemas/                     # Pydantic 스키마 — models/ 와 1:1 대응하는 동일 구조
│   ├── __init__.py
│   ├── code_tables.py / auth.py / student.py / attendance.py / score.py / dream.py / etc.py
│
├── crud/                        # DB 접근 로직 — models/ 와 1:1 대응
│   ├── __init__.py
│   ├── code_tables.py / auth.py / student.py / attendance.py / score.py / dream.py / etc.py
│
├── routers/                     # API 엔드포인트
│   ├── __init__.py
│   ├── auth.py                  # 로그인/로그아웃
│   ├── students.py               # 학생 등록/조회/수정, 소프트 삭제
│   ├── attendance.py             # 출결 등록
│   ├── scores.py                  # 성적/게임점수 등록
│   ├── dreams.py                  # 희망분야 등록
│   └── admin.py                   # 관리자 전용 — 하드 삭제, 기준정보(code_tables) 관리
│
├── alembic/                      # DB 마이그레이션 이력 (운영 스키마 이관 프로젝트이므로 필수)
│   ├── versions/
│   └── env.py
├── alembic.ini
│
├── seeds/                        # 기준정보(코드) 테이블 초기 데이터
│   └── code_tables_seed.py       # toyo_ban_code_name, toyo_dream_kind 등 — 없으면 FK 위반으로
│                                 #   학생/성적 등록 자체가 불가능하므로 최초 배포 시 반드시 선행
│
├── tests/
│   ├── conftest.py
│   └── test_*.py
│
├── static/                       # 관리자용 웹 UI(있는 경우)
├── requirements.txt
├── docker-compose.yml             # PostgreSQL 16
├── .env                            # DATABASE_URL, SECRET_KEY, AES_ENC_KEY 등(git 제외)
└── README.md
```

**contact-manager와 다른 점 (설계 근거)**

| 구분 | contact-manager | toyo |
|---|---|---|
| 테이블 수 | 2개 | 35개 |
| 모델 파일 구조 | `models.py` 단일 파일 | 도메인별 패키지(`models/`) 분리 |
| 스키마 관리 | 코드(`create_all`)로 충분 | `alembic` 마이그레이션 이력 필수(운영 이관 프로젝트) |
| 초기 데이터 | 불필요 | 기준정보(코드 테이블) 시드 데이터 없으면 FK 위반으로 등록 자체가 불가능 |
| 삭제 정책 | RESTRICT 예외 있음 | 전체 CASCADE, 소프트 삭제(`use_yn`) 기본 |

```
# 실행 절차
1) docker compose up -d                          # PostgreSQL 16 컨테이너 기동
2) python -m venv venv && source venv/bin/activate
3) pip install -r requirements.txt
4) alembic upgrade head                           # 35개 테이블 스키마 생성/이관
5) python -m seeds.code_tables_seed                # 기준정보(반/희망분야/과목 등 코드 테이블) 시드
6) uvicorn main:app --reload                       # http://127.0.0.1:8000
7) http://127.0.0.1:8000/docs                      # Swagger UI 검증
```

**주의 (20년차 설계자 관점)**

- **테이블 생성 순서**: 부모(기준정보) → 자식(학생/성적/출결) 순으로 마이그레이션이 실행되어야 FK 제약이 걸린다. `alembic autogenerate`가 이 순서를 스스로 보장하지 않는 경우가 있으므로, 최초 마이그레이션 리비전 작성 후 반드시 `alembic upgrade head`가 에러 없이 끝까지 도는지 빈 DB에서 검증한다.
- **기준정보 시드 누락 위험**: `toyo_ban_code_name`(반), `toyo_dream_kind`(희망분야), `toyo_stud_code_name`(과목) 등 8개 기준정보 테이블은 애플리케이션 코드가 아니라 **실 운영 데이터**이므로, 운영 SQL 덤프에서 해당 테이블의 데이터만 별도로 뽑아 `seeds/`로 이관해야 한다. 비워둔 채 배포하면 학생 등록 시 첫 요청부터 FK 위반으로 실패한다.




## 12. 구현 체크리스트 (toyo 프로젝트)

- [ ] Docker PostgreSQL 16 실행 확인
- [ ] venv + requirements.txt 설치
- [ ] `alembic upgrade head`로 35개 테이블 생성 확인(`psql \dt`, 제외 대상인 백업/임시/pack 테이블은 생성되지 않았는지도 확인)
- [ ] get_db() 세션 개설/종료 정상 동작
- [ ] **기준정보(코드) 테이블 8개 시드 데이터 적재 확인** — `toyo_ban_code_name`, `toyo_dream_kind`, `toyo_kind_name`, `toyo_stud_code_name`, `toyo_teacher_chul_code_name`, `toyo_code_name`, `toyo_ban_menu_name`, `toyo_reg_date_poss` (비어있으면 이후 모든 FK 검증이 실패함)
- [ ] 전체 FK 36개에 `ON DELETE CASCADE` 적용 확인(`information_schema.referential_constraints`로 일괄 조회)
- [ ] 비밀번호 bcrypt/argon2 해시 저장 확인(레거시 MD5 원문 그대로 저장 금지)
- [ ] `parents_no_hp`, `ban_hp` 등 개인정보 암호화 컬럼의 암호화 키가 `.env`/시크릿 매니저에서만 로드되는지 확인(소스코드 하드코딩 금지)
- [ ] 로그인 성공 시 Set-Cookie(HttpOnly + SameSite=Lax) 포함 확인
- [ ] `get_current_user`가 인증 API(로그인) 제외 전체 API를 보호하는지 확인
- [ ] **AUTH(권한) 기반 403 확인** — 일반 교사 계정으로 관리자 전용 API(하드 삭제, 기준정보 관리) 호출 시 403
- [ ] 로그아웃 후 동일 쿠키 401 확인
- [ ] `stud_no` 채번이 동시 요청에서도 중복되지 않는지 확인(SEQUENCE 또는 `SELECT ... FOR UPDATE` 동시성 테스트)
- [ ] 학생 등록 시 이름+학년+성별 중복 검사 409 확인
- [ ] **담당 반(`ban`)이 아닌 학생/출결/성적 데이터 접근 시 404 확인**(존재 여부 비노출, `user_id` 대신 `ban` 필터로 구현)
- [ ] 성적 등록 시 동일 `(enroll_date, ban, stud_no, subject)` 재등록이 500이 아닌 정상 업데이트로 처리되는지 확인(`ON CONFLICT DO UPDATE`)
- [ ] 출결 등록 시 `toyo_stud_chul` 저장 및 `toyo_stud_score`의 출결점수(CHUL_CODE) 반영 확인
- [ ] **소프트 삭제(`use_yn='N'`) 동작 확인** — 목록/조회 API에서 제외되는지, 데이터는 물리적으로 남아있는지
- [ ] **하드 삭제(관리자 전용) CASCADE 확인** — 상위 테이블(예: `toyo_stud_info`) 삭제 시 `toyo_stud_score`/`toyo_stud_chul`/`toyo_stud_dream` 등 종속 레코드가 함께 삭제되는지, 그리고 일반 교사 권한으로는 403으로 차단되는지
- [ ] 계정 2개(교사 A/B, 담당 반이 다른 경우) 데이터 격리 테스트(목록·검색·직접 `stud_no` 접근)
- [ ] 학생명/전화번호/날짜 형식 검증 422 확인
- [ ] 전 오류 응답 `{"detail": "..."}` 통일 확인
- [ ] 어떤 요청에도 500 미발생 확인(특히 레거시에서 500이 나던 지점 — 성적 재등록, DB 접속 실패 등 재현 테스트)
- [ ] `reg_date`/`mod_date` 컬럼이 `TIMESTAMP` 타입으로 정상 저장·조회되는지 확인(레거시 `varchar(14)` 문자열 포맷과 혼동 없는지)
- [ ] `toyo_team_score_plus.ban`/`toyo_team_game_score.kind` 등 FK 미적용으로 남겨둔 컬럼의 실제 값 범위를 운영 데이터로 검증(뒤늦게 FK 추가 여부 결정)
- [ ] 정적/관리자 화면 연동 후 로그인~학생 등록~출결/성적 등록 전체 흐름 브라우저 동작 확인
- [ ] `/docs`에서 전체 API 실행 가능 확인
- [ ] UTF-8 한글 입출력 확인(학생명, 학부모명 등 한글 데이터 다수)






## 13. 화면(UI) 설계 상세 — 프론트엔드 구현용 (toyo 프로젝트)

본 장은 레거시 화면(`banStudInfoNewRegList.php`, `banScoreReg.php`, `banChulReg.php` 등)의 실제 동작을 TRD 관점에서 재구성한 프론트엔드 구현 명세다. contact-manager는 로그인한 "본인" 소유 데이터만 다뤘지만, toyo는 교사가 **자신이 담당하는 반(`ban`)의 학생들**을 다루는 구조이므로 화면 전반에 "반 선택"이 1차 필터로 들어간다.

### 13-1. SCR-002 학생 관리 화면 레이아웃 요약

- 상단: 서비스명, 로그인한 교사명(`k_name`), 담당 반 표시, [로그아웃]
- 좌측: 학생 등록 폼(이름/성별/학년/팀/출결여부/1년차여부/학부모연락처) + [등록]/[취소], 반 선택 드롭다운(관리자만 다른 반 조회 가능), 학생 검색창 + [검색/전체], 학생 목록(총건수 표시, 사용중지(`use_yn='N'`) 학생은 회색 처리로 구분 표시)
- 우측: 선택한 학생의 상세 탭 — [출결 등록] / [성적 등록] / [희망분야 등록]
- 하단: SCR-900 공통 메시지 영역

> ⚠️ **행 [삭제]는 기본적으로 소프트 삭제(`use_yn='N'`)만 노출**: 레거시가 물리 삭제 없이 소프트 삭제만 써왔던 관행을 그대로 유지한다. 물리 삭제(하드 삭제)는 일반 교사 화면에는 아예 노출하지 않고, SCR-900과 별도의 **관리자 전용 화면(SCR-901)**에서만 제공한다(§9 CASCADE 정책 참고).

### 13-2. 학생 영역 — 구성 요소/동작

| 요소 | 동작 | 호출 API | 성공 시 반응 |
|---|---|---|---|
| 등록 폼+[등록] | 항목 입력 후 클릭 | POST /students | 폼 초기화+목록 재조회 |
| 반 선택 드롭다운 | 목록 선택 | (GET /code-tables/ban으로 사전 채움) | 학생 목록 해당 반으로 필터링 |
| 검색창+[검색] | 이름 입력 후 클릭 | GET /students?ban=&name= (부분일치) | 목록 교체, 총건수 갱신 |
| [전체] | 클릭 | GET /students?ban= | 반 전체 목록 복귀 |
| 행의 [수정] | 클릭 | (호출 없음) | 폼에 값 채움+편집모드([등록]→[저장], [취소] 노출) |
| 편집모드 [저장] | 클릭 | PATCH /students/{stud_no} | 편집모드 해제+재조회 |
| 편집모드 [취소] | 클릭 | (호출 없음) | 폼 초기화+편집모드 해제 |
| 행의 [사용중지] | 클릭→confirm | PATCH /students/{stud_no} (use_yn='N') | 재조회, 목록에서 회색 처리 |
| [로그아웃] | 클릭 | POST /auth/logout | SCR-001 전환 |

반을 드롭다운(select)으로 강제하는 이유: 애초에 본인이 담당하는 반만 선택 가능하게 하는 UI 제약 설계다. 단, API 직접 호출 경로가 있으므로 서버 측 `ban` 소유권 검증은 반드시 유지한다(§9, 담당 반 외 접근 시 404).

### 13-3. 출결/성적 등록 영역

| 요소 | 동작 | 호출 API | 성공 | 실패 |
|---|---|---|---|---|
| 출결 등록 폼(출결종류/사유)+[등록] | 학생 선택 후 클릭 | POST /attendance | 목록+해당 학생 상세 갱신 | 422 형식 오류 |
| 성적 등록 폼(고정출석/복장/교재/암송 점수)+[등록] | 학생 선택 후 클릭 | POST /scores | 목록 갱신, 재등록 시에도 값 덮어쓰기(에러 없음) | 422 형식 오류 |
| 희망분야 등록 폼+[등록] | 학생 선택 후 클릭 | POST /dreams | 목록 갱신 | 409 이미 등록된 희망분야(중복) |
| [사진 업로드] | 학생/교사 사진 파일 선택 후 클릭 | POST /students/{stud_no}/photo (multipart/form-data) | 업로드한 사진으로 목록/상세 썸네일 갱신 | 422 파일 형식/크기 오류 |

레거시(`banScoreRegProc.php`)는 성적을 5개 항목(고정출석·복장·교재·암송·출결점수)으로 나눠 한 번에 등록했는데, 이 묶음 처리 방식은 그대로 유지하고 API 한 번(`POST /scores`)에서 서버가 내부적으로 5개 행을 처리하도록 한다(화면에서 5번 호출하지 않음).

### 13-4. SCR-901 관리자 전용 — 기준정보/하드 삭제 화면

- 반/희망분야/과목 등 기준정보(코드 테이블) CRUD
- 학생·성적·출결 데이터 **물리 삭제**(하드 삭제) — 삭제 전 "이 학생을 삭제하면 관련 성적/출결/희망분야 N건이 함께 삭제됩니다"라는 CASCADE 영향 범위를 반드시 confirm 다이얼로그에 표시
- 일반 교사 계정으로 이 화면 진입 시 403 → 로그인 화면 또는 접근 거부 안내로 리다이렉트

### 13-5. SCR-900 공통 메시지/오류 표시 규칙

| 상황 | 화면 동작 |
|---|---|
| 401(로그인 시도 자체 제외) | 세션 만료로 간주 → 로그인 화면 전환 |
| 403 | "권한이 없습니다" 고정 문구 표시(관리자 전용 기능 노출 자체를 UI에서 막는 것이 1차, 403은 최종 방어선) |
| 404/409/422 | `detail`을 그대로 표시(문구 재생성 없음) |
| 성공(200/201/204) | 안내 1~2초 노출 후 소멸 |
| 422 detail이 배열 | 첫 항목 `msg`만 표시 |
| 사진 업로드 실패(형식/용량 초과) | 422 detail을 그대로 표시, 업로드 폼은 초기화하지 않고 파일 재선택만 유도 |

---
