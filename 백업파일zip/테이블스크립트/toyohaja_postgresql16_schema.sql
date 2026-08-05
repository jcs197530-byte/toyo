-- ============================================================
-- 토요하자 DB PostgreSQL 16 스키마 (MySQL/PHP 원본에서 변환)
-- 원본: 토요하자스크립트NEW202608012100.sql (MySQL DDL 변경이력 재구성)
-- ============================================================

CREATE TABLE toyo_stud_field_attend (
    enroll_date VARCHAR(8),
    ban VARCHAR(3),
    stud_no VARCHAR(5),
    field_attend_kind VARCHAR(2),
    reason VARCHAR(200),
    field_attend_nausea VARCHAR(2),
    field_attend_bus VARCHAR(2),
    field_attend_insurance VARCHAR(2),
    confirm_yn VARCHAR(1),
    reg_date VARCHAR(14),
    reg_id VARCHAR(30),
    mod_date VARCHAR(14),
    mod_id VARCHAR(30),
    CONSTRAINT pk_toyo_stud_field_attend PRIMARY KEY (enroll_date, ban, stud_no)
);
CREATE UNIQUE INDEX unique_toyo_stud_field_attend ON toyo_stud_field_attend (enroll_date, ban, stud_no);

CREATE TABLE toyo_ban_menu_name (
    menu VARCHAR(2),
    menu_name VARCHAR(100),
    src_name VARCHAR(100),
    order_by VARCHAR(2),
    level VARCHAR(1),
    group_no VARCHAR(2),
    use_yn VARCHAR(1),
    menu_code VARCHAR(2),
    reg_date VARCHAR(14),
    reg_id VARCHAR(30),
    mod_date VARCHAR(14),
    mod_id VARCHAR(30),
    go_but_yn VARCHAR(1),
    go_but_nm VARCHAR(20),
    go_but_order_by VARCHAR(2),
    mobile_menu_name VARCHAR(100),
    mobile_use_yn VARCHAR(1),
    mobile_order_by VARCHAR(2),
    mobile_but_yn VARCHAR(1),
    mobile_but_nm VARCHAR(20),
    mobile_but_order_by VARCHAR(2),
    CONSTRAINT pk_toyo_ban_menu_name PRIMARY KEY (menu)
);
CREATE INDEX toyo_ban_menu_name_ix01 ON toyo_ban_menu_name (menu, menu_name, src_name, level, group_no, go_but_nm);

CREATE TABLE toyo_id_info_hist (
    id VARCHAR(20) NOT NULL,
    enroll_date VARCHAR(8),
    mac_address VARCHAR(100),
    reg_date TIMESTAMP,
    reg_id VARCHAR(30),
    mod_date TIMESTAMP,
    mod_id VARCHAR(30),
    CONSTRAINT pk_toyo_id_info_hist PRIMARY KEY (id, enroll_date)
);
CREATE INDEX toyo_id_info_hist_ix01 ON toyo_id_info_hist (id, enroll_date);

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
    CONSTRAINT pk_toyo_stud_bible_memory PRIMARY KEY (enroll_date, ban, stud_no)
);

CREATE TABLE toyo_code_name (
    opt VARCHAR(20),
    code VARCHAR(6),
    code_name VARCHAR(100),
    use_yn VARCHAR(1),
    reg_date VARCHAR(14),
    reg_id VARCHAR(30),
    mod_date VARCHAR(14),
    mod_id VARCHAR(30),
    contents VARCHAR(4000),
    kind_name VARCHAR(200),
    detail_code VARCHAR(2),
    CONSTRAINT pk_toyo_code_name PRIMARY KEY (opt, code)
);

CREATE TABLE toyo_id_info (
    id VARCHAR(20) NOT NULL,
    passwd VARCHAR(64) NOT NULL,
    k_name VARCHAR(64) NOT NULL,
    use_yn VARCHAR(1),
    token VARCHAR(200),
    auth VARCHAR(2),
    login_first_time TIMESTAMP,
    login_last_time TIMESTAMP,
    reg_date TIMESTAMP,
    reg_id VARCHAR(30),
    mod_date TIMESTAMP,
    mod_id VARCHAR(30),
    parents_name VARCHAR(20),
    ssn VARCHAR(4),
    id_img_path VARCHAR(200),
    id_img_name VARCHAR(200),
    group_code VARCHAR(2),
    CONSTRAINT pk_toyo_id_info PRIMARY KEY (id)
);
CREATE INDEX toyo_id_info_ix01 ON toyo_id_info (id, k_name);

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

CREATE TABLE toyo_stud_reg_fee (
    stud_no VARCHAR(5),
    reg_fee_kind VARCHAR(2),
    reason VARCHAR(200),
    new_yn VARCHAR(1),
    year VARCHAR(4),
    quarter VARCHAR(1),
    enroll_date VARCHAR(8),
    reg_date VARCHAR(14),
    reg_id VARCHAR(30),
    mod_date VARCHAR(14),
    mod_id VARCHAR(30),
    CONSTRAINT pk_toyo_stud_reg_fee PRIMARY KEY (stud_no)
);

CREATE TABLE toyo_stud_dream_year_course (
    stud_no VARCHAR(5),
    year VARCHAR(4),
    quarter VARCHAR(1),
    dream_kind VARCHAR(3),
    use_yn VARCHAR(1),
    reg_date VARCHAR(14),
    reg_id VARCHAR(30),
    mod_date VARCHAR(14),
    mod_id VARCHAR(30),
    CONSTRAINT pk_toyo_stud_dream_year_course PRIMARY KEY (stud_no, year, quarter, dream_kind)
);

CREATE TABLE toyo_stud_dream_course (
    stud_no VARCHAR(5),
    year VARCHAR(4),
    quarter VARCHAR(1),
    dream_kind VARCHAR(3),
    use_yn VARCHAR(1),
    reg_date VARCHAR(14),
    reg_id VARCHAR(30),
    mod_date VARCHAR(14),
    mod_id VARCHAR(30),
    CONSTRAINT pk_toyo_stud_dream_course PRIMARY KEY (stud_no, year, quarter, dream_kind)
);

CREATE TABLE md5enc (
    userid VARCHAR(20) NOT NULL,
    passwd VARCHAR(32) NOT NULL,
    use_yn VARCHAR(1),
    reg_date TIMESTAMP,
    reg_id VARCHAR(30),
    mod_date TIMESTAMP,
    mod_id VARCHAR(30),
    CONSTRAINT pk_md5enc PRIMARY KEY (userid)
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

CREATE TABLE toyo_stud_2hakgi_info (
    stud_no VARCHAR(5),
    ban VARCHAR(3),
    stud_name VARCHAR(100),
    grade VARCHAR(1),
    team VARCHAR(20),
    rereg_kind VARCHAR(2),
    reason VARCHAR(200),
    enroll_date VARCHAR(8),
    reg_date VARCHAR(14),
    reg_id VARCHAR(30),
    mod_date VARCHAR(14),
    mod_id VARCHAR(30),
    CONSTRAINT pk_toyo_stud_2hakgi_info PRIMARY KEY (stud_no)
);

CREATE TABLE toyo_stud_dream (
    enroll_date VARCHAR(8),
    ban VARCHAR(3),
    stud_no VARCHAR(5),
    dream_kind_1 VARCHAR(3),
    dream_kind_2 VARCHAR(3),
    dream_kind_3 VARCHAR(3),
    use_yn VARCHAR(1),
    reg_date VARCHAR(14),
    reg_id VARCHAR(30),
    mod_date VARCHAR(14),
    mod_id VARCHAR(30),
    CONSTRAINT pk_toyo_stud_dream PRIMARY KEY (enroll_date, ban, stud_no)
);

CREATE TABLE high_school_teacher_chul_code_name (
    teacher_kind VARCHAR(2),
    ban VARCHAR(3),
    ban_name VARCHAR(100),
    use_yn VARCHAR(1),
    reg_date VARCHAR(14),
    reg_id VARCHAR(30),
    mod_date VARCHAR(14),
    mod_id VARCHAR(30),
    CONSTRAINT pk_high_school_teacher_chul_code_name PRIMARY KEY (teacher_kind, ban)
);

CREATE TABLE toyo_teacher_chul (
    enroll_date VARCHAR(8),
    teacher_kind VARCHAR(2),
    ban VARCHAR(3),
    chul_yn VARCHAR(1),
    reason VARCHAR(200),
    reg_date VARCHAR(14),
    reg_id VARCHAR(30),
    mod_date VARCHAR(14),
    mod_id VARCHAR(30),
    CONSTRAINT pk_toyo_teacher_chul PRIMARY KEY (enroll_date, teacher_kind, ban)
);

CREATE TABLE toyo_stud_memory (
    enroll_date VARCHAR(8),
    ban VARCHAR(3),
    stud_no VARCHAR(5),
    memory_kind_1 VARCHAR(3),
    memory_kind_2 VARCHAR(3),
    memory_kind_3 VARCHAR(3),
    reg_date VARCHAR(14),
    reg_id VARCHAR(30),
    mod_date VARCHAR(14),
    mod_id VARCHAR(30),
    CONSTRAINT pk_toyo_stud_memory PRIMARY KEY (enroll_date, ban, stud_no)
);
CREATE INDEX stud_memory_ix01 ON toyo_stud_memory (ban, stud_no);

CREATE TABLE toyo_reg_date_poss (
    poss_date VARCHAR(8),
    use_yn VARCHAR(1),
    reg_date VARCHAR(14),
    reg_id VARCHAR(30),
    mod_date VARCHAR(14),
    mod_id VARCHAR(30),
    CONSTRAINT pk_toyo_reg_date_poss PRIMARY KEY (poss_date)
);

CREATE TABLE toyo_stud_chul (
    enroll_date VARCHAR(8),
    ban VARCHAR(3),
    stud_no VARCHAR(5),
    chul_kind VARCHAR(2),
    reason VARCHAR(200),
    reg_date VARCHAR(14),
    reg_id VARCHAR(30),
    mod_date VARCHAR(14),
    mod_id VARCHAR(30),
    CONSTRAINT pk_toyo_stud_chul PRIMARY KEY (enroll_date, ban, stud_no)
);
CREATE INDEX stud_chul_ix01 ON toyo_stud_chul (stud_no, chul_kind);

CREATE TABLE toyo_stud_score_hist (
    seq INTEGER GENERATED BY DEFAULT AS IDENTITY,
    gubun VARCHAR(1),
    enroll_date VARCHAR(8),
    ban VARCHAR(3),
    stud_no VARCHAR(5),
    subject VARCHAR(3),
    score INTEGER,
    reg_date VARCHAR(14),
    reg_id VARCHAR(30),
    mod_date VARCHAR(14),
    mod_id VARCHAR(30),
    CONSTRAINT pk_toyo_stud_score_hist PRIMARY KEY (seq, gubun, enroll_date, ban, stud_no, subject)
);

CREATE TABLE toyo_kind_name (
    kind VARCHAR(2),
    kind_name VARCHAR(100),
    use_yn VARCHAR(1),
    reg_date VARCHAR(14),
    reg_id VARCHAR(30),
    mod_date VARCHAR(14),
    mod_id VARCHAR(30),
    CONSTRAINT pk_toyo_kind_name PRIMARY KEY (kind)
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

CREATE TABLE toyo_team_game_score (
    enroll_date VARCHAR(8),
    kind VARCHAR(20),
    team VARCHAR(20),
    score INTEGER,
    reg_date VARCHAR(14),
    reg_id VARCHAR(30),
    mod_date VARCHAR(14),
    mod_id VARCHAR(30),
    CONSTRAINT pk_toyo_team_game_score PRIMARY KEY (enroll_date, kind, team)
);

CREATE TABLE toyo_ban_code_name (
    ban VARCHAR(3),
    ban_name VARCHAR(100),
    use_yn VARCHAR(1),
    reg_date VARCHAR(14),
    reg_id VARCHAR(30),
    mod_date VARCHAR(14),
    mod_id VARCHAR(30),
    ban_hp VARCHAR(100),
    ban_hp_enc BYTEA,
    CONSTRAINT pk_toyo_ban_code_name PRIMARY KEY (ban)
);

CREATE TABLE toyo_stud_code_name (
    subject VARCHAR(3),
    subject_name VARCHAR(100),
    reg_date VARCHAR(14),
    reg_id VARCHAR(30),
    mod_date VARCHAR(14),
    mod_id VARCHAR(30),
    CONSTRAINT pk_toyo_stud_code_name PRIMARY KEY (subject)
);

CREATE TABLE toyo_stud_score (
    enroll_date VARCHAR(8),
    ban VARCHAR(3),
    stud_no VARCHAR(5),
    subject VARCHAR(3),
    score INTEGER,
    reg_date VARCHAR(14),
    reg_id VARCHAR(30),
    mod_date VARCHAR(14),
    mod_id VARCHAR(30),
    CONSTRAINT pk_toyo_stud_score PRIMARY KEY (enroll_date, ban, stud_no, subject)
);
CREATE INDEX stud_score_ix01 ON toyo_stud_score (stud_no, enroll_date, ban);

-- NOTE: PARENTS_NO_HP_ENC 컬럼은 원본 스크립트에 CREATE/ALTER 정의가 없고 DML(UPDATE)에서만 사용되어 타입을 추정함
CREATE TABLE toyo_stud_info (
    stud_no VARCHAR(5),
    ban VARCHAR(3),
    stud_name VARCHAR(100),
    grade VARCHAR(1),
    team VARCHAR(20),
    attend_yn VARCHAR(1),
    sex VARCHAR(1),
    one_year_yn VARCHAR(1),
    use_yn VARCHAR(1),
    reg_date VARCHAR(14),
    reg_id VARCHAR(30),
    mod_date VARCHAR(14),
    mod_id VARCHAR(30),
    parents_name VARCHAR(20),
    stud_img_path VARCHAR(200),
    stud_img_name VARCHAR(200),
    dream_kind VARCHAR(3),
    parents_no_hp_enc VARCHAR(500),
    CONSTRAINT pk_toyo_stud_info PRIMARY KEY (stud_no)
);
CREATE INDEX stud_score ON toyo_stud_info (stud_no, team, ban);
CREATE INDEX stud_chul ON toyo_stud_info (stud_no, ban);

