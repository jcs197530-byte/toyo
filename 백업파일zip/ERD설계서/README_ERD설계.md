# 토요하자 DB ERD — Mermaid 설계 문서

## 1. 방식
`toyohaja_postgresql16_schema.sql`의 테이블 29개는 **명시적 FK 제약(REFERENCES)이 하나도 없는** 구조입니다
(MySQL 원본부터 애플리케이션 레벨에서만 정합성을 관리하는 전형적인 레거시 설계). 요청하신 대로
**"PK 컬럼명이 다른 테이블의 컬럼명과 일치하면 관계로 매칭"** 하는 방식으로 관계를 역추론했습니다.

### 매칭 규칙
1. 각 테이블의 PK를 확인해 **단일 컬럼 PK를 가진 "마스터(기준) 테이블"** 을 식별
2. 다른 모든 테이블을 훑어 그 컬럼명과 **완전히 동일한 이름의 컬럼**을 가진 테이블을 찾음 → 관계로 연결
3. 자식 테이블의 PK가 그 컬럼 단독이면 `1:1(optional)`, 아니면 `1:N` 으로 카디널리티 결정
4. 복합키 마스터(예: `high_school_teacher_chul_code_name(teacher_kind, ban)`)는 그 두 컬럼을 모두 가진
   하위 테이블에 한해 별도로 수동 검증 후 연결 (합계-이력형 3쌍: 아래 참고)

### ⚠️ 자동 매칭만으로는 부족했던 부분 (직접 수동 검증)
`stud_no`는 학생 마스터(`toyo_stud_info`) 외에도 `toyo_stud_reg_fee`, `toyo_stud_2hakgi_new_info`,
`toyo_stud_new_info`, `toyo_stud_2hakgi_info` 4개 테이블에서 **각각 단독 PK**로 쓰이고 있어서,
기계적으로 "PK 일치"만 적용하면 이 5개 테이블이 서로 마스터라고 착각하며 관계가 5×5로 얽히는
스파게티 구조가 나옵니다. **20년차 관점에서 판단**해 `toyo_stud_info` 만을 학생 마스터로 지정하고
나머지 4개는 학생의 1:1 확장(신청/회비/재등록) 테이블로 처리했습니다.

또한 순수 컬럼명 일치만으로는 의미 없는 관계도 걸러졌습니다. 예를 들어
`toyo_stud_field_attend`, `toyo_stud_score`, `toyo_stud_chul` 등은 모두 `(enroll_date, ban, stud_no)`
조합을 PK로 쓰지만, 이들은 서로 참조 관계가 아니라 **각자 독립적으로 `ban`/`stud_no` 마스터만
참조**하는 형제 테이블이라 서로 연결하지 않았습니다. 반면 아래 3쌍은 "합계-이력/디테일" 관계가
명확해 별도로 연결했습니다.

| 마스터(합계) | 디테일/이력 | 근거 |
|---|---|---|
| `toyo_team_game_score` | `toyo_team_game_score_rows` | rows가 score의 PK에 `seq`만 추가한 디테일 |
| `toyo_stud_score` | `toyo_stud_score_hist` | hist가 score의 PK에 `seq, gubun`을 추가한 이력 |
| `high_school_teacher_chul_code_name` | `toyo_teacher_chul` | 코드마스터(teacher_kind+ban) → 출석기록 |

## 2. 마스터(기준) 테이블 6개
| 테이블 | PK | 의미 |
|---|---|---|
| `toyo_stud_info` | stud_no | 학생 마스터 |
| `toyo_ban_code_name` | ban | 반 코드 |
| `toyo_dream_kind` | dream_kind | 꿈땅종류 코드 |
| `toyo_kind_name` | kind | 게임종류 코드 |
| `toyo_stud_code_name` | subject | 과목 코드 |
| `toyo_id_info` | id | 로그인 계정 |

이 6개 테이블에서 총 32개의 1:N/1:1 관계 + 위 3개의 복합키 관계 = **총 35개 관계선**이 생성되었습니다.

## 3. 관계선이 없는 독립 테이블
아래 테이블은 다른 어떤 테이블과도 컬럼명이 겹치는 PK가 없어 독립 엔터티로 남았습니다
(실제로도 애플리케이션 메뉴/공통코드성 테이블이라 정상입니다):
`toyo_stud_field_attend_teacher`, `toyo_code_name`, `toyo_reg_date_poss`, `toyo_ban_menu_name`, `md5enc`

## 4. 검증 (내부 테스트)
- **실제 Mermaid 파서(`mermaid` npm 패키지, v11)** 를 Node.js에서 직접 구동해
  `mermaid.parse()`로 문법을 검증 → `PARSE OK` 확인 (Claude가 직접 임의로 판단한 것이 아니라
  Mermaid 공식 라이브러리가 실제로 파싱에 성공한 결과입니다)
- 29개 엔터티 블록의 중괄호 짝, 컬럼 수, PK/FK 표기를 스크립트로 교차 검증
- 관계선 35개 전부 "실제로 존재하는 두 테이블 + 실제로 존재하는 컬럼명"만 참조하도록 프로그램적으로 생성 (오타/유령 테이블 참조 불가능한 구조)
- `toyohaja_erd_preview.html`을 열면 브라우저에서 Mermaid.js(CDN)로 바로 렌더링되어 시각적으로도 확인 가능

## 5. 파일
- `toyohaja_erd.mmd` — 순수 Mermaid 소스 (바이브코딩 프롬프트에 그대로 첨부하시면 됩니다)
- `toyohaja_erd_preview.html` — 더블클릭해서 브라우저로 열면 바로 렌더링되는 미리보기
