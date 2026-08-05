\set ON_ERROR_STOP on
\echo '=== 1) INSERT 테스트: toyo_stud_info ==='
INSERT INTO toyo_stud_info (stud_no, ban, stud_name, grade, team, use_yn, reg_date, reg_id)
VALUES ('00001', '001', '홍길동', '3', 'RED', 'Y', to_char(now(),'YYYYMMDDHH24MISS'), 'TEST');

\echo '=== 2) PK 중복 INSERT 실패 테스트 (에러가 나야 정상) ==='
DO $$
BEGIN
  BEGIN
    INSERT INTO toyo_stud_info (stud_no, ban, stud_name) VALUES ('00001', '002', '중복학생');
    RAISE EXCEPTION 'PK 제약이 동작하지 않음(중복 삽입 성공) - 실패';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'PK 제약 정상 동작 확인 (unique_violation 발생)';
  END;
END $$;

\echo '=== 3) SELECT 테스트 ==='
SELECT stud_no, stud_name, ban, team FROM toyo_stud_info WHERE stud_no = '00001';

\echo '=== 4) UPDATE 테스트 ==='
UPDATE toyo_stud_info SET team = 'BLUE' WHERE stud_no = '00001';
SELECT stud_no, team FROM toyo_stud_info WHERE stud_no = '00001';

\echo '=== 5) 인덱스(STUD_SCORE, STUD_CHUL) 존재 확인 ==='
SELECT indexname, indexdef FROM pg_indexes WHERE tablename = 'toyo_stud_info';

\echo '=== 6) UNIQUE INDEX 동작 테스트: toyo_stud_field_attend ==='
INSERT INTO toyo_stud_field_attend (enroll_date, ban, stud_no, field_attend_kind)
VALUES ('20260801', '001', '00001', '01');

DO $$
BEGIN
  BEGIN
    INSERT INTO toyo_stud_field_attend (enroll_date, ban, stud_no, field_attend_kind)
    VALUES ('20260801', '001', '00001', '02');
    RAISE EXCEPTION 'UNIQUE INDEX가 동작하지 않음 - 실패';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'UNIQUE INDEX 정상 동작 확인';
  END;
END $$;

\echo '=== 7) IDENTITY(AUTO_INCREMENT 대체) 컬럼 테스트: toyo_stud_score_hist ==='
INSERT INTO toyo_stud_score_hist (gubun, enroll_date, ban, stud_no, subject, score)
VALUES ('1', '20260801', '001', '00001', 'A01', 90);
INSERT INTO toyo_stud_score_hist (gubun, enroll_date, ban, stud_no, subject, score)
VALUES ('1', '20260801', '001', '00002', 'A01', 85);
SELECT seq, stud_no, score FROM toyo_stud_score_hist ORDER BY seq;

\echo '=== 8) DELETE 테스트 ==='
DELETE FROM toyo_stud_field_attend WHERE stud_no = '00001';
SELECT count(*) AS remaining FROM toyo_stud_field_attend WHERE stud_no='00001';

\echo '=== 9) ALTER TABLE ADD COLUMN 테스트 ==='
ALTER TABLE toyo_stud_info ADD COLUMN test_col VARCHAR(10);
SELECT column_name FROM information_schema.columns WHERE table_name='toyo_stud_info' AND column_name='test_col';

\echo '=== 10) ALTER TABLE DROP COLUMN 테스트 ==='
ALTER TABLE toyo_stud_info DROP COLUMN test_col;
SELECT column_name FROM information_schema.columns WHERE table_name='toyo_stud_info' AND column_name='test_col';

\echo '=== 11) BYTEA 컬럼(구 blob) 테스트: toyo_ban_code_name ==='
INSERT INTO toyo_ban_code_name (ban, ban_name, ban_hp_enc) VALUES ('999', '테스트반', '\xDEADBEEF');
SELECT ban, ban_name, encode(ban_hp_enc,'hex') AS hp_enc_hex FROM toyo_ban_code_name WHERE ban='999';

\echo '=== 12) DROP TABLE 테스트(임시 테이블) ==='
CREATE TABLE zz_drop_test (id INT PRIMARY KEY);
DROP TABLE zz_drop_test;
SELECT count(*) FROM information_schema.tables WHERE table_name='zz_drop_test';

\echo '=== 정리: 테스트 데이터 삭제 ==='
DELETE FROM toyo_stud_info WHERE stud_no='00001';
DELETE FROM toyo_stud_score_hist WHERE stud_no IN ('00001','00002');
DELETE FROM toyo_ban_code_name WHERE ban='999';

\echo '=== 모든 테스트 통과 ==='
