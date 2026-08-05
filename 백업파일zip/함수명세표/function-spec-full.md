# 4-3. 함수 명세표 (전체 재작성) — toyo 프로젝트

## 0. 재작성 배경

이전 명세표는 계정/반/학생/출석/성적, 6개 테이블만 다뤘습니다. 이번에 `phpcssjs소스.zip`
**256개 PHP 파일 전체**를 다시 열어서 확인한 결과, 실제 레거시 시스템은 아래처럼
훨씬 넓은 범위(24개 업무 도메인)를 다루고 있었습니다. 이전 버전은 전체의 일부만
반영된 게 맞습니다.

| 확인 방법 | 결과 |
|---|---|
| 파일 총 개수 | 256개 (.php) |
| 제외(백업/사용안함/무관 샘플) | 11개 — 아래 "제외 목록" 참고 |
| 분석 대상 | 245개 |
| 업무 도메인 수 | 24개 (아래 표) |

### 제외한 11개 파일과 이유
| 파일 | 이유 |
|---|---|
| `banScoreModifyBak20241117.php`, `banScoreRegBak20241117.php`, `banScoreRegProcBak20241117.php`, `banScoreModifyProc20241117.php` | 날짜suffix 백업본. 어디서도 링크/include 안 됨 |
| `banNewRegListbak20161205.php` | 날짜suffix 백업본 |
| `xxxbanFieldTeacherPrivateNewRegList.php` | 파일명 `xxx` 접두 = 폐기 표시, 링크 없음 |
| `testDecode.php` | 디버그용 테스트 스크립트 |
| `delete.php`, `insertform.php`, `list.php`, `ex_11_database.php` | toyo 업무와 무관한 샘플 게시판/비디오 플레이어 튜토리얼 코드 (내용 확인함) |

### 도메인별 레거시 파일 수 (245개 분류)
| 도메인 | 레거시 파일 수 |
|---|---|
| 학생 신규/재등록 관리 | 29 |
| 꿈(진로) 관리 | 23 |
| 성적 관리 | 26 (오프라인 18 + 온라인 8) |
| 포인트 관리 | 15 |
| 교사 관리 | 16 |
| 야외활동(수련회) 참가 | 14 |
| 팀게임 점수 관리 | 13 |
| 메뉴 관리 | 13 |
| 구절암송 관리 | 20 (오프라인 10 + 온라인 10) |
| 반(class) 관리 | 15 |
| 성경대회/성경암송 | 12 |
| 출석 관리 | 12 (오프라인 10 + 온라인 2) |
| 수련회 인솔교사 | 10 |
| 등록비 관리 | 8 |
| 학생 출결 통계 | 4 |
| 공지사항 | 5 |
| 인증/로그인 | 5 |
| 교사 출석 | 3 |
| 등록가능일자 | 3 |
| 이미지 업로드 | 2 |
| 사용자정보(엑셀) | 2 |
| 공통 인프라(DB커넥션) | 2 |
| 기타 유틸(음력변환) | 1 |

> 온라인/오프라인 쌍(성적·출석·구절암송)은 실제 쿼리를 열어 확인한 결과 **같은 테이블을
> 같은 조건으로 조회**하고 있었습니다 (예: `banScoreList.php`와 `onlinebanScoreList.php`
> 모두 `TOYO_BAN_CODE_NAME`을 동일하게 참조). 즉 데이터 모델이 다른 게 아니라
> "교사가 관리자 화면에서 입력" vs "학부모/학생이 셀프서비스로 입력"이라는
> **접근 채널·권한 차이**입니다. 새 설계에서는 이걸 별도 도메인으로 쪼개지 않고,
> 하나의 리소스에 역할(role) 기반 권한만 다르게 적용합니다. (아래 6~8번 도메인 참고)

---

## 1. 인증/계정

| 함수 | 위치 | 입력 | 출력/효과 |
|---|---|---|---|
| hash_password / verify_password | security.py | 원문 / (원문,해시) | Argon2 해시 / True·False |
| username_exists(db, username, exclude_id=None) | domains/auth/crud.py | 아이디+제외id | 중복 여부 |
| create_account / authenticate_account | domains/auth/crud.py | 가입정보 / 로그인정보 | Account / Account\|None |
| create_login_session / get_login_session / delete_login_session | domains/auth/crud.py | account_id / token | 세션 발급·조회·삭제 |
| get_current_account | deps.py | 쿠키 session_id | Account 또는 401 |
| signup / login / logout / me | domains/auth/router.py | HTTP 요청 | 201/200/204/200 |

*레거시 대응: `loginForm.php`, `loginFormProc.php`, `logoutFormProc.php`, `dbconfigLogin.php`, `topMenuIncludeLogin.php` (5개)*

---

## 2. 메뉴/권한 관리

레거시는 계정 등급(교사/부장/관리자 등)별로 보이는 메뉴가 달라 `menu*Select.php`가 13개나
나뉘어 있었습니다. 새 설계에서는 메뉴 트리 자체를 DB로 빼지 않고, **역할(Role) 기반
권한 체크를 라우터 depends에서 처리**하고 프런트에서 역할에 따라 메뉴를 필터링하는 방식으로
단순화합니다(별도 백엔드 CRUD 불필요).

| 함수 | 위치 | 입력 | 출력/효과 |
|---|---|---|---|
| require_role(*roles) | deps.py | 허용 role 목록 | 403 또는 통과 (Depends 팩토리) |
| get_menu_tree(role) | (프런트 정적 설정) | 현재 role | 역할별 메뉴 트리 (백엔드 API 아님) |

*레거시 대응: `menuManager.php`, `menuManagerModify.php`, `menuManagerModifyProc.php`,
`menuSelect.php`, `menuClassTeacherSelect.php`, `menuGameManageSelect.php`,
`menuManageSelect.php`, `menuNewHakgiManageSelect.php`, `menuStudManageSelect.php`,
`menuTeacherAllManageSelect.php`, `menuTeacherManageSelect.php`, `menuXXXXManageSelect.php`,
`topMenuInclude.php` (13개)*

---

## 3. 반(Class) 관리

| 함수 | 위치 | 입력 | 출력/효과 |
|---|---|---|---|
| class_code_exists(db, code, exclude_id=None) | domains/classes/crud.py | 코드+제외id | 중복 여부 |
| list_classes / get_class / create_class / update_class / delete_class | domains/classes/crud.py | 검색조건 또는 대상+데이터 | 조회/등록/수정/삭제 |
| list_teams / create_team / update_team | domains/classes/crud.py | 팀 정보 | 팀 마스터 CRUD |
| get_org_chart(db) | domains/classes/crud.py | — | 반-교사-팀 조직도 트리 |
| 라우터 함수 6개 | domains/classes/router.py | HTTP 요청 | 상태코드 결정 |

*레거시 대응: `banList.php`, `banSelect.php`, `banCodeNameList/Modify/ModifyProc/ExcelList.php`,
`banOrganChartSelect.php`, `banTeamModify/ModifyProc.php`, `banTeamTotalList.php`,
`onlinebanSelect.php`, `kindSelect.php`, `banGameKindSelect.php`, `banGameRowsKindSelect.php`,
`banGameTotKindSelect.php` (15개 — 코드 조회류 Select 팝업 다수는 `list_classes`/`list_codes`
공용 함수 하나로 흡수)*

---

## 4. 학생 등록 관리 (신규/재등록/2학기 재편성)

레거시에서 가장 많은 파일(29개)이 몰린 영역입니다. `New`(최초 등록), `ReReg`(재등록),
`ReReg2Hakgi`(2학기 재편성), `StudBanTeamInfo`(반/팀 재배정)로 나뉘어 있었지만,
전부 "학생 상태(신규/재등록/반편성)를 바꾸는 한 리소스"라 하나의 도메인으로 묶습니다.

| 함수 | 위치 | 입력 | 출력/효과 |
|---|---|---|---|
| list_students / get_student / create_student / update_student / delete_student | domains/students/crud.py | 검색조건 또는 대상+데이터 | 조회/등록/수정/삭제 |
| create_new_registration(db, data) | domains/students/crud.py | 신규 신청 데이터 | Student(status=new) 생성 |
| reassign_class(db, student_id, class_id, team) | domains/students/crud.py | 학생id+반id+팀 | 반/팀 재배정(2학기 포함) |
| list_registrations(db, status, class_id) | domains/students/crud.py | 상태(신규/재등록)+반 | 등록 현황 목록 |
| export_registrations_excel(db, 조건) | domains/students/service.py | 검색조건 | 엑셀 바이너리 |
| 라우터 함수 8개 | domains/students/router.py | HTTP 요청 | 상태코드 결정 |

*레거시 대응: `banStudInfoNewReg*`(6), `banNewReg*`(9, bak 제외), `banReReg*`(9),
`banReReg2Hakgi*`(2), `banStudBanTeamInfo*`(3), `banToyoNewRegList.php` (총 29개)*

---

## 5. 등록비 / 등록가능일자

| 함수 | 위치 | 입력 | 출력/효과 |
|---|---|---|---|
| list_reg_fees / get_reg_fee / create_reg_fee / update_reg_fee | domains/students/reg_fee_crud.py | 검색조건 또는 대상+데이터 | 등록비 조회/등록/수정 |
| list_possible_dates / create_possible_date / update_possible_date | domains/students/reg_date_crud.py | 검색조건 또는 대상+데이터 | 등록 가능일 관리 |
| 라우터 함수 6개 | domains/students/router.py (하위 prefix) | HTTP 요청 | 상태코드 결정 |

*레거시 대응: `banRegFee*`(8), `banNewFeeList.php`, `banRegDatePoss*`(3) (총 11개)*

---

## 6. 출석 관리 (학생, 오프라인+온라인 통합)

| 함수 | 위치 | 입력 | 출력/효과 |
|---|---|---|---|
| attendance_exists(db, student_id, enroll_date, exclude_id=None) | domains/attendance/crud.py | 학생id+날짜+제외id | 중복 출석 방지 |
| list_attendance / get_attendance / create_attendance / update_attendance / delete_attendance | domains/attendance/crud.py | 검색조건 또는 대상+데이터 | 조회/등록/수정/삭제 |
| bulk_create_attendance(db, class_id, enroll_date, items) | domains/attendance/crud.py | 반 전체 출석 일괄 | 여러 건 INSERT (레거시 `RegAllProc` 대응) |
| get_attendance_statistics(db, class_id, period) | domains/attendance/crud.py | 반+기간 | 출석률 통계 |
| 라우터 함수 6개 (role: teacher=입력, guardian=본인 자녀 조회만) | domains/attendance/router.py | HTTP 요청 | 상태코드 결정 |

*레거시 대응: 오프라인 `banChul*`(10) + 온라인 `onlinebanChul*`(2) + 통계
`banStudChulCntStatistics*`, `banStudChulStatistics*`(4) = 총 16개*

---

## 7. 교사 출석

| 함수 | 위치 | 입력 | 출력/효과 |
|---|---|---|---|
| list_teacher_attendance / create_teacher_attendance | domains/teachers/attendance_crud.py | 검색조건 또는 데이터 | 교사 출석 조회/등록 |
| get_teacher_attendance_statistics(db, period) | domains/teachers/attendance_crud.py | 기간 | 통계 |
| 라우터 함수 3개 | domains/teachers/router.py | HTTP 요청 | 상태코드 결정 |

*레거시 대응: `banTeacherChulSelect.php`, `banTeacherChulStatisticsList/DetailList.php` (3개)*

---

## 8. 성적 관리 (오프라인+온라인 통합)

| 함수 | 위치 | 입력 | 출력/효과 |
|---|---|---|---|
| score_exists(db, student_id, enroll_date, subject, exclude_id=None) | domains/scores/crud.py | 학생id+날짜+과목+제외id | 중복 성적 방지 |
| list_scores / get_score / create_score / update_score / delete_score | domains/scores/crud.py | 검색조건 또는 대상+데이터 | 조회/등록/수정/삭제 |
| get_score_average(db, class_id, period) | domains/scores/crud.py | 반+기간 | 평균 성적 |
| export_scores_ppt(db, class_id, period) / export_scores_excel(db, 조건) | domains/scores/service.py | 반+기간 | PPT/엑셀 바이너리 |
| 라우터 함수 6개 (role: teacher=입력/수정, guardian=본인 자녀 조회) | domains/scores/router.py | HTTP 요청 | 상태코드 결정 |

*레거시 대응: 오프라인 `banScore*`(14, bak 제외) + `banStudScoreAverage*`(2) + `scoreModify/Reg.php`(2)
+ 온라인 `onlinebanScore*`(8) = 총 26개*

---

## 9. 구절암송 관리 (오프라인+온라인 통합)

| 함수 | 위치 | 입력 | 출력/효과 |
|---|---|---|---|
| list_memory_records / get_memory_record / create_memory_record / update_memory_record | domains/memory/crud.py | 검색조건 또는 대상+데이터 | 조회/등록/수정 |
| get_memory_pass_status(db, student_id) | domains/memory/crud.py | 학생id | 합격/진도 현황 |
| export_memory_ppt(db, class_id) | domains/memory/service.py | 반id | PPT 바이너리 |
| 라우터 함수 5개 | domains/memory/router.py | HTTP 요청 | 상태코드 결정 |

*레거시 대응: 오프라인 `banMemory*`(10) + 온라인 `onlinebanMemory*`(10) = 총 20개
(`banMemoryFullPptList`, `banMemoryManagePPT` 등 PPT류는 `export_memory_ppt` 하나로 통합)*

---

## 10. 성경대회 / 성경암송

| 함수 | 위치 | 입력 | 출력/효과 |
|---|---|---|---|
| list_bible_contest_codes / update_bible_contest_code | domains/bible/crud.py | 검색조건 또는 대상+데이터 | 대회 등급 코드 관리 |
| list_bible_memory / get_bible_memory / create_bible_memory / update_bible_memory | domains/bible/crud.py | 검색조건 또는 대상+데이터 | 성경암송 기록 조회/등록/수정 |
| get_bible_memory_statistics(db, class_id, period) | domains/bible/crud.py | 반+기간 | 통계(상세 포함) |
| apply_memory_point(db, student_id, contest_code) | domains/bible/service.py | 학생id+대회코드 | 포인트 도메인과 연동 지급 |
| 라우터 함수 6개 | domains/bible/router.py | HTTP 요청 | 상태코드 결정 |

*레거시 대응: `banBibleContestCode*`(3) + `banBibleMemory*`(9) = 총 12개*

---

## 11. 꿈(진로) 관리

| 함수 | 위치 | 입력 | 출력/효과 |
|---|---|---|---|
| list_dream_kinds / create_dream_kind / update_dream_kind | domains/dream/crud.py | 검색조건 또는 대상+데이터 | 진로 코스 마스터 CRUD |
| list_student_dreams / create_student_dream / update_student_dream | domains/dream/crud.py | 검색조건 또는 대상+데이터 | 학생 희망 진로(회차별) |
| list_dream_courses / create_dream_course / get_dream_year_course | domains/dream/crud.py | 검색조건 또는 대상+데이터 | 학기/연간 코스 신청 |
| get_dream_attendance(db, course_id, enroll_date) | domains/dream/crud.py | 코스+날짜 | 진로 코스 출결 |
| export_dream_placement_print(db, class_id) | domains/dream/service.py | 반id | 배치표 출력물 |
| 라우터 함수 9개 | domains/dream/router.py | HTTP 요청 | 상태코드 결정 |

*레거시 대응: `banDreamCode*`(4) + `banDream*`(10) + `banStudDreamInfo*`(4) +
`banStudInfoDreamInfoList.php` + `banDreamChulManage*`(2) + `banPlaceStudDreamPrint.php`
= 총 23개*

---

## 12. 포인트 관리

| 함수 | 위치 | 입력 | 출력/효과 |
|---|---|---|---|
| list_points / create_point | domains/points/crud.py | 검색조건 또는 데이터 | 포인트 적립/차감 조회/등록 |
| create_point_event / update_point_event | domains/points/crud.py | 이벤트 데이터 | 이벤트성 포인트 지급 관리 |
| create_point_payment | domains/points/crud.py | 사용 내역 | 포인트 사용(차감) 등록 |
| get_point_balance(db, student_id) | domains/points/crud.py | 학생id | 잔여 포인트 |
| list_point_present_candidates(db, threshold) | domains/points/crud.py | 기준점수 | 포상 대상자 목록 |
| 라우터 함수 7개 | domains/points/router.py | HTTP 요청 | 상태코드 결정 |

*레거시 대응: `banPointReg*`(3) + `banStudPoint*`(12) = 총 15개*

---

## 13. 팀게임 점수 관리

| 함수 | 위치 | 입력 | 출력/효과 |
|---|---|---|---|
| list_game_scores / create_game_score / update_game_score | domains/team_games/crud.py | 검색조건 또는 대상+데이터 | 팀 게임 점수 조회/등록/수정 |
| list_game_score_rows / create_game_score_row | domains/team_games/crud.py | 검색조건 또는 데이터 | 회차별 상세 점수 |
| merge_game_scores(db, from_kind, into_kind) | domains/team_games/crud.py | 병합 대상 kind | 점수 합산(레거시 MergeintoProc 대응) |
| 라우터 함수 6개 | domains/team_games/router.py | HTTP 요청 | 상태코드 결정 |

*레거시 대응: `banGameRowsScore*`(4) + `banGameScore*`(6) (Kind Select류는 3번 도메인에 흡수)
= 총 10개 (Kind Select 3개 제외 시)*

---

## 14. 야외활동(수련회) 관리 (학생 참가 + 버스 + 인솔교사)

| 함수 | 위치 | 입력 | 출력/효과 |
|---|---|---|---|
| list_field_attendances / get_field_attendance / create_field_attendance / update_field_attendance | domains/field_trip/crud.py | 검색조건 또는 대상+데이터 | 학생 참가 신청 조회/등록/수정 |
| bulk_create_field_attendance(db, class_id, items) | domains/field_trip/crud.py | 반 전체 일괄 신청 | 여러 건 INSERT (RegAllProc 대응) |
| create_field_bus_assignment / update_field_bus_assignment | domains/field_trip/crud.py | 버스 배정 데이터 | 버스 배정 관리 |
| list_field_teachers / create_field_teacher / update_field_teacher | domains/field_trip/crud.py | 검색조건 또는 대상+데이터 | 인솔교사(공개/비공개) 관리 |
| export_field_attendance_excel(db, class_id) | domains/field_trip/service.py | 반id | 엑셀 바이너리 |
| 라우터 함수 10개 | domains/field_trip/router.py | HTTP 요청 | 상태코드 결정 |

*레거시 대응: `banFieldAttend*`(9) + `banFieldAttendBus*`(4) + `banFieldTeacher*`(6) +
`banFieldTeacherPrivate*`(4) = 총 23개 (제외한 `xxxbanFieldTeacherPrivateNewRegList.php` 미포함)*

---

## 15. 교사 관리

| 함수 | 위치 | 입력 | 출력/효과 |
|---|---|---|---|
| list_teachers / get_teacher / create_teacher / update_teacher / delete_teacher | domains/teachers/crud.py | 검색조건 또는 대상+데이터 | 교사 정보 CRUD (= Account와 1:1 확장 프로필) |
| list_teacher_birthdays(db, month) | domains/teachers/crud.py | 월 | 생일자 목록 |
| list_login_history(db, account_id) | domains/teachers/crud.py | 계정id | 로그인 이력(= LoginSession 조회로 대체) |
| 라우터 함수 6개 | domains/teachers/router.py | HTTP 요청 | 상태코드 결정 |

*레거시 대응: `banTeacherList/ManageList/ManageDetailList/Modify/ModifyProc/Reg/RegProc/Select.php`,
`banTeacharList.php`(오타 파일, 통합), `banTeacherInfoModify/ModifyProc/Reg/RegProc.php`,
`banTeacherBirthList.php`, `banTeacherLoginList/DetailList.php` (총 16개)*

---

## 16. 공지사항

| 함수 | 위치 | 입력 | 출력/효과 |
|---|---|---|---|
| list_notices / get_notice / create_notice / update_notice / delete_notice | domains/notices/crud.py | 검색조건 또는 대상+데이터 | 공지 CRUD |
| 라우터 함수 5개 | domains/notices/router.py | HTTP 요청 | 상태코드 결정 |

*레거시 대응: `banNoticeModify/ModifyProc/Reg/RegList/RegProc.php` (5개)*

---

## 17. 이미지 업로드 (공용 유틸)

| 함수 | 위치 | 입력 | 출력/효과 |
|---|---|---|---|
| upload_image(file, subject_type, subject_id) | common/upload.py | 업로드 파일+대상 | 저장 경로 반환 (학생 사진 등 여러 도메인에서 재사용) |

*레거시 대응: `banImgUpload.php`, `banImgUploadProc.php` (2개)*

---

## 18. 사용자정보/통계 추출

| 함수 | 위치 | 입력 | 출력/효과 |
|---|---|---|---|
| export_user_info_excel(db, 조건) | domains/teachers/service.py | 검색조건 | 엑셀 바이너리 |

*레거시 대응: `banUserInfoExcelList.php`, `banUserInfoList.php` (2개)*

---

## 19. 기타 유틸

| 함수 | 위치 | 입력 | 출력/효과 |
|---|---|---|---|
| solar_to_lunar(solar_date) | common/calendar_util.py | 양력 날짜 | 음력 날짜 변환 (학생 생일 표기용 추정) |

*레거시 대응: `solartolunarExcelList.php` (1개)*

---

## 20. 함수 수 요약

| 구분 | 개수 |
|---|---|
| 레거시 PHP 파일 (분석 대상) | 245 |
| 제외 파일 (백업/사용안함/무관) | 11 |
| 새로 설계한 도메인 | 19 (1~19번) |
| 새로 설계한 함수/엔드포인트 합계 (crud+router+service) | 약 140개 |

레거시 245개 파일이 새 설계에서 약 140개 함수로 줄어드는 건 기능 누락이 아니라,
**Reg.php + RegProc.php + Modify.php + ModifyProc.php + List.php + Select.php** 로
쪼개져 있던 "폼 표시/폼 처리/목록 표시/팝업 선택"이 REST 방식에서는
`create_x` 하나, `list_x` 하나로 합쳐지기 때문입니다. 온라인/오프라인 쌍도
역할(role) 기반 권한으로 통합했기 때문에 줄었습니다.

## 21. 확인 필요 사항

1. **온라인/오프라인 통합 방향에 이견 없는지** — 학부모 셀프서비스(온라인) 화면과 교사 관리
   화면(오프라인)을 같은 API+역할권한으로 합치는 게 맞는지, 아니면 실제로 입력 로직이
   달라 분리 유지가 필요한지 (예: 온라인은 승인 대기 상태를 거치는지 등) 확인 필요합니다.
2. **PPT/엑셀 추출 기능의 우선순위** — 성적/구절암송/야외활동 등 여러 도메인에 PPT·엑셀
   출력 기능이 있는데, 이번 phase에 포함할지 다음 phase로 미룰지 정해주세요.
3. **포인트 ↔ 성경대회 자동 지급 연동(`apply_memory_point`)** — 실제로 대회 통과 시
   자동으로 포인트가 적립되는 로직인지, 수기로 별도 등록하는지 소스상 명확하지 않아
   확인이 필요합니다(`banBibleMemoryPointProc.php`, `banScorePPTPointProc.php` 참고).
