-- phpMyAdmin SQL Dump
-- version 4.2.9.1
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: 26-08-01 23:16
-- 서버 버전: 5.5.28
-- PHP 버전: 5.4.8

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- 데이터베이스: `toyo`
--

-- --------------------------------------------------------

--
-- 테이블 구조 `columns_priv`
--

CREATE TABLE IF NOT EXISTS `columns_priv` (
  `Host` char(60) COLLATE utf8_bin NOT NULL DEFAULT '',
  `Db` char(64) COLLATE utf8_bin NOT NULL DEFAULT '',
  `User` char(16) COLLATE utf8_bin NOT NULL DEFAULT '',
  `Table_name` char(64) COLLATE utf8_bin NOT NULL DEFAULT '',
  `Column_name` char(64) COLLATE utf8_bin NOT NULL DEFAULT '',
  `Timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `Column_priv` set('Select','Insert','Update','References') CHARACTER SET utf8 NOT NULL DEFAULT ''
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Column privileges';

-- --------------------------------------------------------

--
-- 테이블 구조 `db`
--

CREATE TABLE IF NOT EXISTS `db` (
  `Host` char(60) COLLATE utf8_bin NOT NULL DEFAULT '',
  `Db` char(64) COLLATE utf8_bin NOT NULL DEFAULT '',
  `User` char(16) COLLATE utf8_bin NOT NULL DEFAULT '',
  `Select_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Insert_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Update_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Delete_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Create_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Drop_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Grant_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `References_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Index_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Alter_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Create_tmp_table_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Lock_tables_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Create_view_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Show_view_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Create_routine_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Alter_routine_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Execute_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Event_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Trigger_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N'
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Database privileges';

-- --------------------------------------------------------

--
-- 테이블 구조 `edu_buseo_code_name`
--
-- 사용중(#1286 - )

-- --------------------------------------------------------

--
-- 테이블 구조 `edu_buseo_detail_code_name`
--
-- 사용중(#1286 - )

-- --------------------------------------------------------

--
-- 테이블 구조 `event`
--

CREATE TABLE IF NOT EXISTS `event` (
  `db` char(64) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL DEFAULT '',
  `name` char(64) NOT NULL DEFAULT '',
  `body` longblob NOT NULL,
  `definer` char(77) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL DEFAULT '',
  `execute_at` datetime DEFAULT NULL,
  `interval_value` int(11) DEFAULT NULL,
  `interval_field` enum('YEAR','QUARTER','MONTH','DAY','HOUR','MINUTE','WEEK','SECOND','MICROSECOND','YEAR_MONTH','DAY_HOUR','DAY_MINUTE','DAY_SECOND','HOUR_MINUTE','HOUR_SECOND','MINUTE_SECOND','DAY_MICROSECOND','HOUR_MICROSECOND','MINUTE_MICROSECOND','SECOND_MICROSECOND') DEFAULT NULL,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `modified` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `last_executed` datetime DEFAULT NULL,
  `starts` datetime DEFAULT NULL,
  `ends` datetime DEFAULT NULL,
  `status` enum('ENABLED','DISABLED','SLAVESIDE_DISABLED') NOT NULL DEFAULT 'ENABLED',
  `on_completion` enum('DROP','PRESERVE') NOT NULL DEFAULT 'DROP',
  `sql_mode` set('REAL_AS_FLOAT','PIPES_AS_CONCAT','ANSI_QUOTES','IGNORE_SPACE','NOT_USED','ONLY_FULL_GROUP_BY','NO_UNSIGNED_SUBTRACTION','NO_DIR_IN_CREATE','POSTGRESQL','ORACLE','MSSQL','DB2','MAXDB','NO_KEY_OPTIONS','NO_TABLE_OPTIONS','NO_FIELD_OPTIONS','MYSQL323','MYSQL40','ANSI','NO_AUTO_VALUE_ON_ZERO','NO_BACKSLASH_ESCAPES','STRICT_TRANS_TABLES','STRICT_ALL_TABLES','NO_ZERO_IN_DATE','NO_ZERO_DATE','INVALID_DATES','ERROR_FOR_DIVISION_BY_ZERO','TRADITIONAL','NO_AUTO_CREATE_USER','HIGH_NOT_PRECEDENCE','NO_ENGINE_SUBSTITUTION','PAD_CHAR_TO_FULL_LENGTH') NOT NULL DEFAULT '',
  `comment` char(64) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL DEFAULT '',
  `originator` int(10) unsigned NOT NULL,
  `time_zone` char(64) CHARACTER SET latin1 NOT NULL DEFAULT 'SYSTEM',
  `character_set_client` char(32) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
  `collation_connection` char(32) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
  `db_collation` char(32) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
  `body_utf8` longblob
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='Events';

-- --------------------------------------------------------

--
-- 테이블 구조 `func`
--

CREATE TABLE IF NOT EXISTS `func` (
  `name` char(64) COLLATE utf8_bin NOT NULL DEFAULT '',
  `ret` tinyint(1) NOT NULL DEFAULT '0',
  `dl` char(128) COLLATE utf8_bin NOT NULL DEFAULT '',
  `type` enum('function','aggregate') CHARACTER SET utf8 NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='User defined functions';

-- --------------------------------------------------------

--
-- 테이블 구조 `general_log`
--

CREATE TABLE IF NOT EXISTS `general_log` (
  `event_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `user_host` mediumtext NOT NULL,
  `thread_id` int(11) NOT NULL,
  `server_id` int(10) unsigned NOT NULL,
  `command_type` varchar(64) NOT NULL,
  `argument` mediumtext NOT NULL
) ENGINE=CSV DEFAULT CHARSET=utf8 COMMENT='General log';

-- --------------------------------------------------------

--
-- 테이블 구조 `help_category`
--

CREATE TABLE IF NOT EXISTS `help_category` (
  `help_category_id` smallint(5) unsigned NOT NULL,
  `name` char(64) NOT NULL,
  `parent_category_id` smallint(5) unsigned DEFAULT NULL,
  `url` char(128) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='help categories';

-- --------------------------------------------------------

--
-- 테이블 구조 `help_keyword`
--

CREATE TABLE IF NOT EXISTS `help_keyword` (
  `help_keyword_id` int(10) unsigned NOT NULL,
  `name` char(64) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='help keywords';

-- --------------------------------------------------------

--
-- 테이블 구조 `help_relation`
--

CREATE TABLE IF NOT EXISTS `help_relation` (
  `help_topic_id` int(10) unsigned NOT NULL,
  `help_keyword_id` int(10) unsigned NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='keyword-topic relation';

-- --------------------------------------------------------

--
-- 테이블 구조 `help_topic`
--

CREATE TABLE IF NOT EXISTS `help_topic` (
  `help_topic_id` int(10) unsigned NOT NULL,
  `name` char(64) NOT NULL,
  `help_category_id` smallint(5) unsigned NOT NULL,
  `description` text NOT NULL,
  `example` text NOT NULL,
  `url` char(128) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='help topics';

-- --------------------------------------------------------

--
-- 테이블 구조 `host`
--

CREATE TABLE IF NOT EXISTS `host` (
  `Host` char(60) COLLATE utf8_bin NOT NULL DEFAULT '',
  `Db` char(64) COLLATE utf8_bin NOT NULL DEFAULT '',
  `Select_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Insert_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Update_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Delete_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Create_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Drop_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Grant_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `References_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Index_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Alter_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Create_tmp_table_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Lock_tables_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Create_view_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Show_view_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Create_routine_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Alter_routine_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Execute_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Trigger_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N'
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Host privileges;  Merged with database privileges';

-- --------------------------------------------------------

--
-- 테이블 구조 `innodb_index_stats`
--
-- 사용중(#1286 - )

-- --------------------------------------------------------

--
-- 테이블 구조 `innodb_table_stats`
--
-- 사용중(#1286 - )

-- --------------------------------------------------------

--
-- 테이블 구조 `just_test`
--

CREATE TABLE IF NOT EXISTS `just_test` (
`uid` int(11) NOT NULL,
  `var` varchar(255) NOT NULL DEFAULT ''
) ENGINE=MyISAM AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `md5enc`
--

CREATE TABLE IF NOT EXISTS `md5enc` (
`SEQ` int(10) unsigned NOT NULL,
  `USERID` varchar(20) NOT NULL,
  `PASSWD` varchar(32) NOT NULL,
  `USE_YN` varchar(1) DEFAULT NULL,
  `REG_DATE` datetime DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` datetime DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `ndb_binlog_index`
--

CREATE TABLE IF NOT EXISTS `ndb_binlog_index` (
  `Position` bigint(20) unsigned NOT NULL,
  `File` varchar(255) NOT NULL,
  `epoch` bigint(20) unsigned NOT NULL,
  `inserts` bigint(20) unsigned NOT NULL,
  `updates` bigint(20) unsigned NOT NULL,
  `deletes` bigint(20) unsigned NOT NULL,
  `schemaops` bigint(20) unsigned NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- 테이블 구조 `plugin`
--

CREATE TABLE IF NOT EXISTS `plugin` (
  `name` varchar(64) NOT NULL DEFAULT '',
  `dl` varchar(128) NOT NULL DEFAULT ''
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='MySQL plugins';

-- --------------------------------------------------------

--
-- 테이블 구조 `proc`
--

CREATE TABLE IF NOT EXISTS `proc` (
  `db` char(64) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL DEFAULT '',
  `name` char(64) NOT NULL DEFAULT '',
  `type` enum('FUNCTION','PROCEDURE') NOT NULL,
  `specific_name` char(64) NOT NULL DEFAULT '',
  `language` enum('SQL') NOT NULL DEFAULT 'SQL',
  `sql_data_access` enum('CONTAINS_SQL','NO_SQL','READS_SQL_DATA','MODIFIES_SQL_DATA') NOT NULL DEFAULT 'CONTAINS_SQL',
  `is_deterministic` enum('YES','NO') NOT NULL DEFAULT 'NO',
  `security_type` enum('INVOKER','DEFINER') NOT NULL DEFAULT 'DEFINER',
  `param_list` blob NOT NULL,
  `returns` longblob NOT NULL,
  `body` longblob NOT NULL,
  `definer` char(77) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL DEFAULT '',
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `modified` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `sql_mode` set('REAL_AS_FLOAT','PIPES_AS_CONCAT','ANSI_QUOTES','IGNORE_SPACE','NOT_USED','ONLY_FULL_GROUP_BY','NO_UNSIGNED_SUBTRACTION','NO_DIR_IN_CREATE','POSTGRESQL','ORACLE','MSSQL','DB2','MAXDB','NO_KEY_OPTIONS','NO_TABLE_OPTIONS','NO_FIELD_OPTIONS','MYSQL323','MYSQL40','ANSI','NO_AUTO_VALUE_ON_ZERO','NO_BACKSLASH_ESCAPES','STRICT_TRANS_TABLES','STRICT_ALL_TABLES','NO_ZERO_IN_DATE','NO_ZERO_DATE','INVALID_DATES','ERROR_FOR_DIVISION_BY_ZERO','TRADITIONAL','NO_AUTO_CREATE_USER','HIGH_NOT_PRECEDENCE','NO_ENGINE_SUBSTITUTION','PAD_CHAR_TO_FULL_LENGTH') NOT NULL DEFAULT '',
  `comment` text CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `character_set_client` char(32) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
  `collation_connection` char(32) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
  `db_collation` char(32) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
  `body_utf8` longblob
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='Stored Procedures';

-- --------------------------------------------------------

--
-- 테이블 구조 `procs_priv`
--

CREATE TABLE IF NOT EXISTS `procs_priv` (
  `Host` char(60) COLLATE utf8_bin NOT NULL DEFAULT '',
  `Db` char(64) COLLATE utf8_bin NOT NULL DEFAULT '',
  `User` char(16) COLLATE utf8_bin NOT NULL DEFAULT '',
  `Routine_name` char(64) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `Routine_type` enum('FUNCTION','PROCEDURE') COLLATE utf8_bin NOT NULL,
  `Grantor` char(77) COLLATE utf8_bin NOT NULL DEFAULT '',
  `Proc_priv` set('Execute','Alter Routine','Grant') CHARACTER SET utf8 NOT NULL DEFAULT '',
  `Timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Procedure privileges';

-- --------------------------------------------------------

--
-- 테이블 구조 `proxies_priv`
--

CREATE TABLE IF NOT EXISTS `proxies_priv` (
  `Host` char(60) COLLATE utf8_bin NOT NULL DEFAULT '',
  `User` char(16) COLLATE utf8_bin NOT NULL DEFAULT '',
  `Proxied_host` char(60) COLLATE utf8_bin NOT NULL DEFAULT '',
  `Proxied_user` char(16) COLLATE utf8_bin NOT NULL DEFAULT '',
  `With_grant` tinyint(1) NOT NULL DEFAULT '0',
  `Grantor` char(77) COLLATE utf8_bin NOT NULL DEFAULT '',
  `Timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='User proxy privileges';

-- --------------------------------------------------------

--
-- 테이블 구조 `sboard`
--

CREATE TABLE IF NOT EXISTS `sboard` (
  `bd_no` int(10) NOT NULL,
  `bd_name` varchar(20) NOT NULL,
  `bd_pwd` varchar(20) NOT NULL,
  `bd_cont` varchar(100) NOT NULL,
  `bd_regDate` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `servers`
--

CREATE TABLE IF NOT EXISTS `servers` (
  `Server_name` char(64) NOT NULL DEFAULT '',
  `Host` char(64) NOT NULL DEFAULT '',
  `Db` char(64) NOT NULL DEFAULT '',
  `Username` char(64) NOT NULL DEFAULT '',
  `Password` char(64) NOT NULL DEFAULT '',
  `Port` int(4) NOT NULL DEFAULT '0',
  `Socket` char(64) NOT NULL DEFAULT '',
  `Wrapper` char(64) NOT NULL DEFAULT '',
  `Owner` char(64) NOT NULL DEFAULT ''
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='MySQL Foreign Servers table';

-- --------------------------------------------------------

--
-- 테이블 구조 `slave_master_info`
--
-- 사용중(#1286 - )

-- --------------------------------------------------------

--
-- 테이블 구조 `slave_relay_log_info`
--
-- 사용중(#1286 - )

-- --------------------------------------------------------

--
-- 테이블 구조 `slave_worker_info`
--
-- 사용중(#1286 - )

-- --------------------------------------------------------

--
-- 테이블 구조 `slow_log`
--

CREATE TABLE IF NOT EXISTS `slow_log` (
  `start_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `user_host` mediumtext NOT NULL,
  `query_time` time NOT NULL,
  `lock_time` time NOT NULL,
  `rows_sent` int(11) NOT NULL,
  `rows_examined` int(11) NOT NULL,
  `db` varchar(512) NOT NULL,
  `last_insert_id` int(11) NOT NULL,
  `insert_id` int(11) NOT NULL,
  `server_id` int(10) unsigned NOT NULL,
  `sql_text` mediumtext NOT NULL
) ENGINE=CSV DEFAULT CHARSET=utf8 COMMENT='Slow log';

-- --------------------------------------------------------

--
-- 테이블 구조 `tables_priv`
--

CREATE TABLE IF NOT EXISTS `tables_priv` (
  `Host` char(60) COLLATE utf8_bin NOT NULL DEFAULT '',
  `Db` char(64) COLLATE utf8_bin NOT NULL DEFAULT '',
  `User` char(16) COLLATE utf8_bin NOT NULL DEFAULT '',
  `Table_name` char(64) COLLATE utf8_bin NOT NULL DEFAULT '',
  `Grantor` char(77) COLLATE utf8_bin NOT NULL DEFAULT '',
  `Timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `Table_priv` set('Select','Insert','Update','Delete','Create','Drop','Grant','References','Index','Alter','Create View','Show view','Trigger') CHARACTER SET utf8 NOT NULL DEFAULT '',
  `Column_priv` set('Select','Insert','Update','References') CHARACTER SET utf8 NOT NULL DEFAULT ''
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Table privileges';

-- --------------------------------------------------------

--
-- 테이블 구조 `test`
--
-- 사용중(#1286 - )

-- --------------------------------------------------------

--
-- 테이블 구조 `time_zone`
--

CREATE TABLE IF NOT EXISTS `time_zone` (
`Time_zone_id` int(10) unsigned NOT NULL,
  `Use_leap_seconds` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='Time zones';

-- --------------------------------------------------------

--
-- 테이블 구조 `time_zone_leap_second`
--

CREATE TABLE IF NOT EXISTS `time_zone_leap_second` (
  `Transition_time` bigint(20) NOT NULL,
  `Correction` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='Leap seconds information for time zones';

-- --------------------------------------------------------

--
-- 테이블 구조 `time_zone_name`
--

CREATE TABLE IF NOT EXISTS `time_zone_name` (
  `Name` char(64) NOT NULL,
  `Time_zone_id` int(10) unsigned NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='Time zone names';

-- --------------------------------------------------------

--
-- 테이블 구조 `time_zone_transition`
--

CREATE TABLE IF NOT EXISTS `time_zone_transition` (
  `Time_zone_id` int(10) unsigned NOT NULL,
  `Transition_time` bigint(20) NOT NULL,
  `Transition_type_id` int(10) unsigned NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='Time zone transitions';

-- --------------------------------------------------------

--
-- 테이블 구조 `time_zone_transition_type`
--

CREATE TABLE IF NOT EXISTS `time_zone_transition_type` (
  `Time_zone_id` int(10) unsigned NOT NULL,
  `Transition_type_id` int(10) unsigned NOT NULL,
  `Offset` int(11) NOT NULL DEFAULT '0',
  `Is_DST` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `Abbreviation` char(8) NOT NULL DEFAULT ''
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='Time zone transition types';

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_ban_code_name`
--

CREATE TABLE IF NOT EXISTS `toyo_ban_code_name` (
  `BAN` varchar(3) NOT NULL DEFAULT '',
  `BAN_NAME` varchar(100) DEFAULT NULL,
  `BAN_HP` varchar(100) DEFAULT NULL,
  `BAN_HP_ENC` blob,
  `USE_YN` varchar(1) DEFAULT NULL,
  `REG_DATE` varchar(14) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` varchar(14) DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_ban_menu_name`
--

CREATE TABLE IF NOT EXISTS `toyo_ban_menu_name` (
  `MENU` varchar(2) NOT NULL DEFAULT '',
  `MENU_NAME` varchar(100) DEFAULT NULL,
  `SRC_NAME` varchar(100) DEFAULT NULL,
  `ORDER_BY` varchar(2) DEFAULT NULL,
  `MOBILE_ORDER_BY` varchar(2) DEFAULT NULL,
  `LEVEL` varchar(1) DEFAULT NULL,
  `GROUP_NO` varchar(2) DEFAULT NULL,
  `USE_YN` varchar(1) DEFAULT NULL,
  `MOBILE_USE_YN` varchar(1) DEFAULT NULL,
  `MENU_CODE` varchar(2) DEFAULT NULL,
  `REG_DATE` varchar(14) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` varchar(14) DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL,
  `GO_BUT_YN` varchar(1) DEFAULT NULL,
  `GO_BUT_NM` varchar(20) DEFAULT NULL,
  `GO_BUT_ORDER_BY` varchar(2) DEFAULT NULL,
  `MOBILE_MENU_NAME` varchar(100) DEFAULT NULL,
  `MOBILE_BUT_YN` varchar(1) DEFAULT NULL,
  `MOBILE_BUT_NM` varchar(20) DEFAULT NULL,
  `MOBILE_BUT_ORDER_BY` varchar(2) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_bible_contest`
--

CREATE TABLE IF NOT EXISTS `toyo_bible_contest` (
  `CONTEST_CODE` varchar(3) NOT NULL DEFAULT '',
  `CONTEST_RANK` varchar(3) DEFAULT NULL,
  `CONTEST_POINT` varchar(3) DEFAULT NULL,
  `USE_YN` varchar(1) DEFAULT NULL,
  `REG_DATE` datetime DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` datetime DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_code_name`
--

CREATE TABLE IF NOT EXISTS `toyo_code_name` (
  `OPT` varchar(20) NOT NULL DEFAULT '',
  `CODE` varchar(6) NOT NULL DEFAULT '',
  `CODE_NAME` varchar(100) DEFAULT NULL,
  `KIND_NAME` varchar(200) DEFAULT NULL,
  `CONTENTS` varchar(4000) DEFAULT NULL,
  `USE_YN` varchar(1) DEFAULT NULL,
  `REG_DATE` varchar(14) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` varchar(14) DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_code_name_pack`
--

CREATE TABLE IF NOT EXISTS `toyo_code_name_pack` (
  `OPT` varchar(20) NOT NULL DEFAULT '',
  `CODE` varchar(6) NOT NULL DEFAULT '',
  `CODE_NAME` varchar(100) DEFAULT NULL,
  `USE_YN` varchar(1) DEFAULT NULL,
  `REG_DATE` varchar(14) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` varchar(14) DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_dream_kind`
--

CREATE TABLE IF NOT EXISTS `toyo_dream_kind` (
  `DREAM_KIND` varchar(3) NOT NULL DEFAULT '',
  `DREAM_KIND_NAME` varchar(100) DEFAULT NULL,
  `GRADE` varchar(10) DEFAULT NULL,
  `YEAR_COURSE` varchar(1) DEFAULT NULL,
  `YEAR` varchar(4) DEFAULT NULL,
  `QUARTER` varchar(1) DEFAULT NULL,
  `USE_YN` varchar(1) DEFAULT NULL,
  `REG_DATE` datetime DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` datetime DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_id_info`
--

CREATE TABLE IF NOT EXISTS `toyo_id_info` (
  `ID` varchar(20) NOT NULL,
  `PASSWD` varchar(64) NOT NULL,
  `K_NAME` varchar(64) NOT NULL,
  `USE_YN` varchar(1) DEFAULT NULL,
  `SSN` varchar(4) DEFAULT NULL,
  `TOKEN` varchar(200) DEFAULT NULL,
  `AUTH` varchar(2) DEFAULT NULL,
  `LOGIN_FIRST_TIME` datetime DEFAULT NULL,
  `LOGIN_LAST_TIME` datetime DEFAULT NULL,
  `REG_DATE` datetime DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` datetime DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL,
  `ID_IMG_PATH` varchar(200) DEFAULT NULL,
  `ID_IMG_NAME` varchar(200) DEFAULT NULL,
  `GROUP_CODE` varchar(2) DEFAULT NULL,
  `TEACHER_HP_NO_ENC` blob
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_id_info_hist`
--

CREATE TABLE IF NOT EXISTS `toyo_id_info_hist` (
  `ID` varchar(20) NOT NULL,
  `ENROLL_DATE` varchar(8) NOT NULL DEFAULT '',
  `MAC_ADDRESS` varchar(100) DEFAULT NULL,
  `REG_DATE` datetime DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` datetime DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_kind_name`
--

CREATE TABLE IF NOT EXISTS `toyo_kind_name` (
  `KIND` varchar(2) NOT NULL DEFAULT '',
  `KIND_NAME` varchar(100) DEFAULT NULL,
  `USE_YN` varchar(1) DEFAULT NULL,
  `REG_DATE` varchar(14) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` varchar(14) DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_kind_name_pack`
--

CREATE TABLE IF NOT EXISTS `toyo_kind_name_pack` (
  `KIND` varchar(2) NOT NULL DEFAULT '',
  `KIND_NAME` varchar(100) DEFAULT NULL,
  `USE_YN` varchar(1) DEFAULT NULL,
  `REG_DATE` varchar(14) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` varchar(14) DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_notice_info`
--

CREATE TABLE IF NOT EXISTS `toyo_notice_info` (
  `NOTICE_NO` varchar(5) NOT NULL,
  `TITLE` varchar(200) NOT NULL,
  `CONTENTS` varchar(4000) NOT NULL,
  `NOTICE_START_DATE` varchar(8) DEFAULT NULL,
  `NOTICE_END_DATE` varchar(8) DEFAULT NULL,
  `USE_YN` varchar(1) DEFAULT NULL,
  `REG_DATE` datetime DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` datetime DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_point`
--

CREATE TABLE IF NOT EXISTS `toyo_point` (
  `ENROLL_DATE` varchar(8) NOT NULL DEFAULT '',
  `KIND` varchar(2) NOT NULL DEFAULT '',
  `STUD_NO` varchar(5) NOT NULL DEFAULT '',
  `POINT` varchar(3) DEFAULT NULL,
  `ETC` varchar(400) DEFAULT NULL,
  `BAN` varchar(3) DEFAULT NULL,
  `TEAM` varchar(20) DEFAULT NULL,
  `TOP_TEAM_KOR` varchar(400) DEFAULT NULL,
  `CHUL_KIND` varchar(2) DEFAULT NULL,
  `POINT_REG_KIND` varchar(2) DEFAULT NULL,
  `POINT_EVENT_KIND` varchar(2) DEFAULT NULL,
  `REG_DATE` datetime DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` datetime DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_point_payment`
--

CREATE TABLE IF NOT EXISTS `toyo_point_payment` (
  `ENROLL_DATE` varchar(8) NOT NULL DEFAULT '',
  `STUD_NO` varchar(5) NOT NULL DEFAULT '',
  `POINT` varchar(3) DEFAULT NULL,
  `ETC` varchar(400) DEFAULT NULL,
  `REG_DATE` datetime DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` datetime DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_reg_date_poss`
--

CREATE TABLE IF NOT EXISTS `toyo_reg_date_poss` (
  `SEQ` varchar(3) NOT NULL DEFAULT '',
  `POSS_DATE` varchar(8) NOT NULL DEFAULT '',
  `USE_YN` varchar(1) DEFAULT NULL,
  `REG_DATE` datetime DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` datetime DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_stud_2hakgi_info`
--

CREATE TABLE IF NOT EXISTS `toyo_stud_2hakgi_info` (
  `STUD_NO` varchar(5) NOT NULL DEFAULT '',
  `BAN` varchar(3) DEFAULT NULL,
  `STUD_NAME` varchar(100) DEFAULT NULL,
  `GRADE` varchar(1) DEFAULT NULL,
  `TEAM` varchar(20) DEFAULT NULL,
  `REREG_KIND` varchar(2) DEFAULT NULL,
  `REASON` varchar(200) DEFAULT NULL,
  `ENROLL_DATE` varchar(8) DEFAULT NULL,
  `REG_DATE` varchar(14) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` varchar(14) DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_stud_2hakgi_new_info`
--

CREATE TABLE IF NOT EXISTS `toyo_stud_2hakgi_new_info` (
  `STUD_NO` varchar(5) NOT NULL DEFAULT '',
  `STUD_NAME` varchar(100) DEFAULT NULL,
  `SEX` varchar(1) DEFAULT NULL,
  `GRADE` varchar(1) DEFAULT NULL,
  `PARENT_NAME` varchar(20) DEFAULT NULL,
  `PARENT_HP` varchar(11) DEFAULT NULL,
  `REQUEST_TEACHER_NAME` varchar(20) DEFAULT NULL,
  `REQUEST_METHOD` varchar(100) DEFAULT NULL,
  `CHURCH_REG_STATUS` varchar(3) DEFAULT NULL,
  `ETC` varchar(400) DEFAULT NULL,
  `REG_FEE_KIND` varchar(2) DEFAULT NULL,
  `PROGRESS_STATUS` varchar(3) DEFAULT NULL,
  `ENROLL_DATE` varchar(8) DEFAULT NULL,
  `REG_DATE` datetime DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` datetime DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL,
  `DREAM_KIND_1` varchar(3) DEFAULT NULL,
  `DREAM_KIND_2` varchar(3) DEFAULT NULL,
  `DREAM_KIND_3` varchar(3) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_stud_bible_memory`
--

CREATE TABLE IF NOT EXISTS `toyo_stud_bible_memory` (
  `ENROLL_DATE` varchar(8) NOT NULL DEFAULT '',
  `BAN` varchar(3) NOT NULL DEFAULT '',
  `STUD_NO` varchar(5) NOT NULL DEFAULT '',
  `DEGREE_NO` varchar(2) DEFAULT NULL,
  `PASS_NO` varchar(2) DEFAULT NULL,
  `REG_DATE` datetime DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` datetime DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL,
  `PRESENT` varchar(3) DEFAULT NULL,
  `BIBLE_CHUL` varchar(2) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_stud_chul`
--

CREATE TABLE IF NOT EXISTS `toyo_stud_chul` (
  `ENROLL_DATE` varchar(8) NOT NULL DEFAULT '',
  `BAN` varchar(3) NOT NULL DEFAULT '',
  `STUD_NO` varchar(5) NOT NULL DEFAULT '',
  `CHUL_KIND` varchar(2) DEFAULT NULL,
  `REASON` varchar(200) DEFAULT NULL,
  `REG_DATE` varchar(14) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` varchar(14) DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_stud_chul0403`
--

CREATE TABLE IF NOT EXISTS `toyo_stud_chul0403` (
  `ENROLL_DATE` varchar(8) NOT NULL DEFAULT '',
  `BAN` varchar(3) NOT NULL DEFAULT '',
  `STUD_NO` varchar(5) NOT NULL DEFAULT '',
  `CHUL_KIND` varchar(2) DEFAULT NULL,
  `REASON` varchar(200) DEFAULT NULL,
  `REG_DATE` varchar(14) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` varchar(14) DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_stud_chul0409_backup`
--

CREATE TABLE IF NOT EXISTS `toyo_stud_chul0409_backup` (
  `ENROLL_DATE` varchar(8) NOT NULL DEFAULT '',
  `BAN` varchar(3) NOT NULL DEFAULT '',
  `STUD_NO` varchar(5) NOT NULL DEFAULT '',
  `CHUL_KIND` varchar(2) DEFAULT NULL,
  `REASON` varchar(200) DEFAULT NULL,
  `REG_DATE` varchar(14) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` varchar(14) DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_stud_chul0417_backup`
--

CREATE TABLE IF NOT EXISTS `toyo_stud_chul0417_backup` (
  `ENROLL_DATE` varchar(8) NOT NULL DEFAULT '',
  `BAN` varchar(3) NOT NULL DEFAULT '',
  `STUD_NO` varchar(5) NOT NULL DEFAULT '',
  `CHUL_KIND` varchar(2) DEFAULT NULL,
  `REASON` varchar(200) DEFAULT NULL,
  `REG_DATE` varchar(14) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` varchar(14) DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_stud_chul0421_backup`
--

CREATE TABLE IF NOT EXISTS `toyo_stud_chul0421_backup` (
  `ENROLL_DATE` varchar(8) NOT NULL DEFAULT '',
  `BAN` varchar(3) NOT NULL DEFAULT '',
  `STUD_NO` varchar(5) NOT NULL DEFAULT '',
  `CHUL_KIND` varchar(2) DEFAULT NULL,
  `REASON` varchar(200) DEFAULT NULL,
  `REG_DATE` varchar(14) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` varchar(14) DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_stud_chul0423_backup`
--

CREATE TABLE IF NOT EXISTS `toyo_stud_chul0423_backup` (
  `ENROLL_DATE` varchar(8) NOT NULL DEFAULT '',
  `BAN` varchar(3) NOT NULL DEFAULT '',
  `STUD_NO` varchar(5) NOT NULL DEFAULT '',
  `CHUL_KIND` varchar(2) DEFAULT NULL,
  `REASON` varchar(200) DEFAULT NULL,
  `REG_DATE` varchar(14) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` varchar(14) DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_stud_chul0501_backup`
--

CREATE TABLE IF NOT EXISTS `toyo_stud_chul0501_backup` (
  `ENROLL_DATE` varchar(8) NOT NULL DEFAULT '',
  `BAN` varchar(3) NOT NULL DEFAULT '',
  `STUD_NO` varchar(5) NOT NULL DEFAULT '',
  `CHUL_KIND` varchar(2) DEFAULT NULL,
  `REASON` varchar(200) DEFAULT NULL,
  `REG_DATE` varchar(14) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` varchar(14) DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_stud_chul0513_backup`
--

CREATE TABLE IF NOT EXISTS `toyo_stud_chul0513_backup` (
  `ENROLL_DATE` varchar(8) NOT NULL DEFAULT '',
  `BAN` varchar(3) NOT NULL DEFAULT '',
  `STUD_NO` varchar(5) NOT NULL DEFAULT '',
  `CHUL_KIND` varchar(2) DEFAULT NULL,
  `REASON` varchar(200) DEFAULT NULL,
  `REG_DATE` varchar(14) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` varchar(14) DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_stud_chul0516_backup`
--

CREATE TABLE IF NOT EXISTS `toyo_stud_chul0516_backup` (
  `ENROLL_DATE` varchar(8) NOT NULL DEFAULT '',
  `BAN` varchar(3) NOT NULL DEFAULT '',
  `STUD_NO` varchar(5) NOT NULL DEFAULT '',
  `CHUL_KIND` varchar(2) DEFAULT NULL,
  `REASON` varchar(200) DEFAULT NULL,
  `REG_DATE` varchar(14) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` varchar(14) DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_stud_chul0521_backup`
--

CREATE TABLE IF NOT EXISTS `toyo_stud_chul0521_backup` (
  `ENROLL_DATE` varchar(8) NOT NULL DEFAULT '',
  `BAN` varchar(3) NOT NULL DEFAULT '',
  `STUD_NO` varchar(5) NOT NULL DEFAULT '',
  `CHUL_KIND` varchar(2) DEFAULT NULL,
  `REASON` varchar(200) DEFAULT NULL,
  `REG_DATE` varchar(14) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` varchar(14) DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_stud_chul0526_backup`
--

CREATE TABLE IF NOT EXISTS `toyo_stud_chul0526_backup` (
  `ENROLL_DATE` varchar(8) NOT NULL DEFAULT '',
  `BAN` varchar(3) NOT NULL DEFAULT '',
  `STUD_NO` varchar(5) NOT NULL DEFAULT '',
  `CHUL_KIND` varchar(2) DEFAULT NULL,
  `REASON` varchar(200) DEFAULT NULL,
  `REG_DATE` varchar(14) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` varchar(14) DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_stud_chul20160330`
--

CREATE TABLE IF NOT EXISTS `toyo_stud_chul20160330` (
  `ENROLL_DATE` varchar(8) NOT NULL DEFAULT '',
  `BAN` varchar(3) NOT NULL DEFAULT '',
  `STUD_NO` varchar(5) NOT NULL DEFAULT '',
  `CHUL_KIND` varchar(2) DEFAULT NULL,
  `REASON` varchar(200) DEFAULT NULL,
  `REG_DATE` varchar(14) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` varchar(14) DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_stud_chul20160402`
--

CREATE TABLE IF NOT EXISTS `toyo_stud_chul20160402` (
  `ENROLL_DATE` varchar(8) NOT NULL DEFAULT '',
  `BAN` varchar(3) NOT NULL DEFAULT '',
  `STUD_NO` varchar(5) NOT NULL DEFAULT '',
  `CHUL_KIND` varchar(2) DEFAULT NULL,
  `REASON` varchar(200) DEFAULT NULL,
  `REG_DATE` varchar(14) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` varchar(14) DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_stud_code_name`
--

CREATE TABLE IF NOT EXISTS `toyo_stud_code_name` (
  `SUBJECT` varchar(3) NOT NULL DEFAULT '',
  `SUBJECT_NAME` varchar(100) DEFAULT NULL,
  `REG_DATE` varchar(14) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` varchar(14) DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_stud_code_name_pack`
--

CREATE TABLE IF NOT EXISTS `toyo_stud_code_name_pack` (
  `SUBJECT` varchar(3) NOT NULL DEFAULT '',
  `SUBJECT_NAME` varchar(100) DEFAULT NULL,
  `REG_DATE` varchar(14) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` varchar(14) DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_stud_dream`
--

CREATE TABLE IF NOT EXISTS `toyo_stud_dream` (
  `ENROLL_DATE` varchar(8) NOT NULL DEFAULT '',
  `BAN` varchar(3) NOT NULL DEFAULT '',
  `STUD_NO` varchar(5) NOT NULL DEFAULT '',
  `DREAM_KIND_1` varchar(3) DEFAULT NULL,
  `DREAM_KIND_2` varchar(3) DEFAULT NULL,
  `DREAM_KIND_3` varchar(3) DEFAULT NULL,
  `USE_YN` varchar(1) DEFAULT NULL,
  `REG_DATE` varchar(14) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` varchar(14) DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_stud_dream_course`
--

CREATE TABLE IF NOT EXISTS `toyo_stud_dream_course` (
  `STUD_NO` varchar(5) NOT NULL DEFAULT '',
  `YEAR` varchar(4) NOT NULL DEFAULT '',
  `QUARTER` varchar(1) NOT NULL DEFAULT '',
  `DREAM_KIND` varchar(3) NOT NULL DEFAULT '',
  `USE_YN` varchar(1) DEFAULT NULL,
  `REG_DATE` varchar(14) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` varchar(14) DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_stud_dream_support_grade`
--

CREATE TABLE IF NOT EXISTS `toyo_stud_dream_support_grade` (
  `DREAM_KIND` varchar(3) NOT NULL DEFAULT '',
  `SUPPORT_GRADE` varchar(6) DEFAULT NULL,
  `USE_YN` varchar(1) DEFAULT NULL,
  `REG_DATE` varchar(14) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` varchar(14) DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_stud_dream_year_course`
--

CREATE TABLE IF NOT EXISTS `toyo_stud_dream_year_course` (
  `STUD_NO` varchar(5) NOT NULL DEFAULT '',
  `YEAR` varchar(4) NOT NULL DEFAULT '',
  `QUARTER` varchar(1) NOT NULL DEFAULT '',
  `DREAM_KIND` varchar(3) NOT NULL DEFAULT '',
  `USE_YN` varchar(1) DEFAULT NULL,
  `REG_DATE` varchar(14) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` varchar(14) DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_stud_field_attend`
--

CREATE TABLE IF NOT EXISTS `toyo_stud_field_attend` (
  `ENROLL_DATE` varchar(8) NOT NULL DEFAULT '',
  `BAN` varchar(3) NOT NULL DEFAULT '',
  `STUD_NO` varchar(5) NOT NULL DEFAULT '',
  `FIELD_ATTEND_KIND` varchar(2) DEFAULT NULL,
  `REASON` varchar(200) DEFAULT NULL,
  `FIELD_ATTEND_NAUSEA` varchar(2) DEFAULT NULL,
  `FIELD_ATTEND_BUS` varchar(2) DEFAULT NULL,
  `FIELD_ATTEND_INSURANCE` varchar(2) CHARACTER SET utf8mb4 NOT NULL DEFAULT '',
  `CONFIRM_YN` varchar(1) DEFAULT NULL,
  `REG_DATE` varchar(14) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` varchar(14) DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_stud_field_attend0513_backup`
--

CREATE TABLE IF NOT EXISTS `toyo_stud_field_attend0513_backup` (
  `ENROLL_DATE` varchar(8) NOT NULL DEFAULT '',
  `BAN` varchar(3) NOT NULL DEFAULT '',
  `STUD_NO` varchar(5) NOT NULL DEFAULT '',
  `FIELD_ATTEND_KIND` varchar(2) DEFAULT NULL,
  `REASON` varchar(200) DEFAULT NULL,
  `REG_DATE` varchar(14) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` varchar(14) DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_stud_field_attend0516_backup`
--

CREATE TABLE IF NOT EXISTS `toyo_stud_field_attend0516_backup` (
  `ENROLL_DATE` varchar(8) NOT NULL DEFAULT '',
  `BAN` varchar(3) NOT NULL DEFAULT '',
  `STUD_NO` varchar(5) NOT NULL DEFAULT '',
  `FIELD_ATTEND_KIND` varchar(2) DEFAULT NULL,
  `REASON` varchar(200) DEFAULT NULL,
  `REG_DATE` varchar(14) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` varchar(14) DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_stud_field_attend_teacher`
--

CREATE TABLE IF NOT EXISTS `toyo_stud_field_attend_teacher` (
  `TEACHER_NO` varchar(5) NOT NULL DEFAULT '',
  `TEACHER_NAME` varchar(100) DEFAULT NULL,
  `SEX` varchar(1) DEFAULT NULL,
  `HP` varchar(11) DEFAULT NULL,
  `FIELD_ATTEND_KIND` varchar(2) DEFAULT NULL,
  `FIELD_ATTEND_NAUSEA` varchar(2) DEFAULT NULL,
  `FIELD_ATTEND_BUS` varchar(2) DEFAULT NULL,
  `TEACHER_KIND` varchar(2) DEFAULT NULL,
  `FIELD_ATTEND_INSURANCE` varchar(2) DEFAULT NULL,
  `USE_YN` varchar(1) DEFAULT NULL,
  `REG_DATE` datetime DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` datetime DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL,
  `REASON` varchar(200) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_stud_info`
--

CREATE TABLE IF NOT EXISTS `toyo_stud_info` (
  `STUD_NO` varchar(5) NOT NULL DEFAULT '',
  `BAN` varchar(3) DEFAULT NULL,
  `STUD_NAME` varchar(100) DEFAULT NULL,
  `GRADE` varchar(1) DEFAULT NULL,
  `TEAM` varchar(20) DEFAULT NULL,
  `SEX` varchar(1) DEFAULT NULL,
  `ONE_YEAR_YN` varchar(1) DEFAULT NULL,
  `DREAM_KIND` varchar(3) DEFAULT NULL,
  `PARENTS_NO_HP_ENC` blob,
  `USE_YN` varchar(1) DEFAULT NULL,
  `REG_DATE` varchar(14) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` varchar(14) DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL,
  `ATTEND_YN` varchar(1) DEFAULT NULL,
  `STUD_IMG_PATH` varchar(200) DEFAULT NULL,
  `STUD_IMG_NAME` varchar(200) DEFAULT NULL,
  `PARENTS_NAME` varchar(20) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_stud_info0628_backup`
--
-- 사용중(#1286 - )

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_stud_info_2017_grade`
--

CREATE TABLE IF NOT EXISTS `toyo_stud_info_2017_grade` (
  `STUD_NO` varchar(5) NOT NULL DEFAULT '',
  `BAN` varchar(3) DEFAULT NULL,
  `STUD_NAME` varchar(100) DEFAULT NULL,
  `GRADE` varchar(1) DEFAULT NULL,
  `TEAM` varchar(20) DEFAULT NULL,
  `USE_YN` varchar(1) DEFAULT NULL,
  `REG_DATE` varchar(14) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` varchar(14) DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_stud_info_pack`
--

CREATE TABLE IF NOT EXISTS `toyo_stud_info_pack` (
  `STUD_NO` varchar(5) NOT NULL DEFAULT '',
  `BAN` varchar(3) DEFAULT NULL,
  `STUD_NAME` varchar(100) DEFAULT NULL,
  `GRADE` varchar(1) DEFAULT NULL,
  `TEAM` varchar(20) DEFAULT NULL,
  `USE_YN` varchar(1) DEFAULT NULL,
  `REG_DATE` varchar(14) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` varchar(14) DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_stud_info_temp`
--

CREATE TABLE IF NOT EXISTS `toyo_stud_info_temp` (
  `BAN` varchar(3) NOT NULL DEFAULT '',
  `STUD_NAME` varchar(100) NOT NULL DEFAULT '',
  `PARENTS_NO_HP_ENC` blob
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_stud_memory`
--

CREATE TABLE IF NOT EXISTS `toyo_stud_memory` (
  `ENROLL_DATE` varchar(8) NOT NULL DEFAULT '',
  `BAN` varchar(3) NOT NULL DEFAULT '',
  `STUD_NO` varchar(5) NOT NULL DEFAULT '',
  `MEMORY_KIND_1` varchar(3) DEFAULT NULL,
  `MEMORY_KIND_2` varchar(3) DEFAULT NULL,
  `MEMORY_KIND_3` varchar(3) DEFAULT NULL,
  `REG_DATE` varchar(14) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` varchar(14) DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_stud_memory_pack`
--

CREATE TABLE IF NOT EXISTS `toyo_stud_memory_pack` (
  `ENROLL_DATE` varchar(8) NOT NULL DEFAULT '',
  `BAN` varchar(3) NOT NULL DEFAULT '',
  `STUD_NO` varchar(5) NOT NULL DEFAULT '',
  `MEMORY_KIND_1` varchar(3) DEFAULT NULL,
  `MEMORY_KIND_2` varchar(3) DEFAULT NULL,
  `MEMORY_KIND_3` varchar(3) DEFAULT NULL,
  `REG_DATE` varchar(14) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` varchar(14) DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_stud_new_info`
--

CREATE TABLE IF NOT EXISTS `toyo_stud_new_info` (
  `STUD_NO` varchar(5) NOT NULL DEFAULT '',
  `STUD_NAME` varchar(100) DEFAULT NULL,
  `SEX` varchar(1) DEFAULT NULL,
  `GRADE` varchar(1) DEFAULT NULL,
  `PARENT_NAME` varchar(20) DEFAULT NULL,
  `PARENT_HP` varchar(11) DEFAULT NULL,
  `REQUEST_TEACHER_NAME` varchar(20) DEFAULT NULL,
  `REQUEST_METHOD` varchar(100) DEFAULT NULL,
  `CHURCH_REG_STATUS` varchar(3) DEFAULT NULL,
  `ETC` varchar(400) DEFAULT NULL,
  `REG_FEE_KIND` varchar(2) DEFAULT NULL,
  `PROGRESS_STATUS` varchar(3) DEFAULT NULL,
  `ENROLL_DATE` varchar(8) DEFAULT NULL,
  `REG_DATE` datetime DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` datetime DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL,
  `DREAM_KIND_1` varchar(3) DEFAULT NULL,
  `DREAM_KIND_2` varchar(3) DEFAULT NULL,
  `DREAM_KIND_3` varchar(3) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_stud_reg_fee`
--

CREATE TABLE IF NOT EXISTS `toyo_stud_reg_fee` (
  `STUD_NO` varchar(5) NOT NULL DEFAULT '',
  `REG_FEE_KIND` varchar(2) DEFAULT NULL,
  `REASON` varchar(200) DEFAULT NULL,
  `NEW_YN` varchar(1) DEFAULT NULL,
  `YEAR` varchar(4) DEFAULT NULL,
  `QUARTER` varchar(1) DEFAULT NULL,
  `ENROLL_DATE` varchar(8) DEFAULT NULL,
  `REG_DATE` varchar(14) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` varchar(14) DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_stud_score`
--

CREATE TABLE IF NOT EXISTS `toyo_stud_score` (
  `ENROLL_DATE` varchar(8) NOT NULL DEFAULT '',
  `BAN` varchar(3) NOT NULL DEFAULT '',
  `STUD_NO` varchar(5) NOT NULL DEFAULT '',
  `SUBJECT` varchar(3) NOT NULL DEFAULT '',
  `SCORE` int(3) DEFAULT NULL,
  `REG_DATE` varchar(14) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` varchar(14) DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- 트리거 `toyo_stud_score`
--
DELIMITER //
CREATE TRIGGER `TOYO_STUD_SCORE_TRI_INSERT` AFTER INSERT ON `toyo_stud_score`
 FOR EACH ROW BEGIN

   INSERT INTO TOYO_STUD_SCORE_HIST
    (
      SEQ
    , GUBUN
    , ENROLL_DATE
    , BAN
    , STUD_NO
    , SUBJECT
    , SCORE
    , REG_DATE
    , REG_ID
    , MOD_DATE
    , MOD_ID    
    )
   VALUES
    (
	  NULL
    , 'I'
    , NEW.ENROLL_DATE
    , NEW.BAN
    , NEW.STUD_NO
    , NEW.SUBJECT
    , NEW.SCORE
    , NEW.REG_DATE
    , NEW.REG_ID
    , NEW.MOD_DATE
    , NEW.MOD_ID    
    );

END
//
DELIMITER ;
DELIMITER //
CREATE TRIGGER `TOYO_STUD_SCORE_TRI_UPDATE` AFTER UPDATE ON `toyo_stud_score`
 FOR EACH ROW BEGIN

   INSERT INTO TOYO_STUD_SCORE_HIST
    (
      SEQ
    , GUBUN
    , ENROLL_DATE
    , BAN
    , STUD_NO
    , SUBJECT
    , SCORE
    , REG_DATE
    , REG_ID
    , MOD_DATE
    , MOD_ID    
    )
   VALUES
    (
	  NULL
    , 'U'
    , NEW.ENROLL_DATE
    , NEW.BAN
    , NEW.STUD_NO
    , NEW.SUBJECT
    , NEW.SCORE
    , NEW.REG_DATE
    , NEW.REG_ID
    , NEW.MOD_DATE
    , NEW.MOD_ID    
    );

END
//
DELIMITER ;

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_stud_score_hist`
--

CREATE TABLE IF NOT EXISTS `toyo_stud_score_hist` (
`SEQ` int(9) NOT NULL,
  `GUBUN` varchar(1) NOT NULL DEFAULT '',
  `ENROLL_DATE` varchar(8) NOT NULL DEFAULT '',
  `BAN` varchar(3) NOT NULL DEFAULT '',
  `STUD_NO` varchar(5) NOT NULL DEFAULT '',
  `SUBJECT` varchar(3) NOT NULL DEFAULT '',
  `SCORE` int(3) DEFAULT NULL,
  `REG_DATE` varchar(14) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` varchar(14) DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL
) ENGINE=MyISAM AUTO_INCREMENT=153528 DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_stud_score_pack`
--

CREATE TABLE IF NOT EXISTS `toyo_stud_score_pack` (
  `ENROLL_DATE` varchar(8) NOT NULL DEFAULT '',
  `BAN` varchar(3) NOT NULL DEFAULT '',
  `STUD_NO` varchar(5) NOT NULL DEFAULT '',
  `SUBJECT` varchar(3) NOT NULL DEFAULT '',
  `SCORE` int(3) DEFAULT NULL,
  `REG_DATE` varchar(14) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` varchar(14) DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_teacher_chul`
--

CREATE TABLE IF NOT EXISTS `toyo_teacher_chul` (
  `ENROLL_DATE` varchar(8) NOT NULL DEFAULT '',
  `TEACHER_KIND` varchar(2) NOT NULL DEFAULT '',
  `BAN` varchar(3) NOT NULL DEFAULT '',
  `CHUL_YN` varchar(1) DEFAULT NULL,
  `REASON` varchar(200) DEFAULT NULL,
  `REG_DATE` varchar(14) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` varchar(14) DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_teacher_chul_code_name`
--

CREATE TABLE IF NOT EXISTS `toyo_teacher_chul_code_name` (
  `TEACHER_KIND` varchar(2) NOT NULL DEFAULT '',
  `BAN` varchar(3) NOT NULL DEFAULT '',
  `BAN_NAME` varchar(100) DEFAULT NULL,
  `USE_YN` varchar(1) DEFAULT NULL,
  `REG_DATE` varchar(14) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` varchar(14) DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_team_game_score`
--

CREATE TABLE IF NOT EXISTS `toyo_team_game_score` (
  `ENROLL_DATE` varchar(8) NOT NULL DEFAULT '',
  `KIND` varchar(20) NOT NULL DEFAULT '',
  `TEAM` varchar(20) NOT NULL DEFAULT '',
  `SCORE` int(4) DEFAULT NULL,
  `DISPLAY_YN` varchar(100) DEFAULT NULL,
  `REG_DATE` varchar(14) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` varchar(14) DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_team_game_score_rows`
--

CREATE TABLE IF NOT EXISTS `toyo_team_game_score_rows` (
  `ENROLL_DATE` varchar(8) NOT NULL DEFAULT '',
  `KIND` varchar(20) NOT NULL DEFAULT '',
  `TEAM` varchar(20) NOT NULL DEFAULT '',
  `SEQ` int(9) NOT NULL DEFAULT '0',
  `SCORE` int(4) DEFAULT NULL,
  `REG_DATE` datetime DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` datetime DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `toyo_team_score_plus`
--

CREATE TABLE IF NOT EXISTS `toyo_team_score_plus` (
  `ENROLL_DATE` varchar(8) NOT NULL DEFAULT '',
  `KIND` varchar(20) NOT NULL DEFAULT '',
  `BAN` varchar(20) NOT NULL DEFAULT '',
  `TEAM` varchar(20) NOT NULL DEFAULT '',
  `SCORE` int(4) DEFAULT NULL,
  `REG_DATE` datetime DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `MOD_DATE` datetime DEFAULT NULL,
  `MOD_ID` varchar(30) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 테이블 구조 `user`
--

CREATE TABLE IF NOT EXISTS `user` (
  `Host` char(60) COLLATE utf8_bin NOT NULL DEFAULT '',
  `User` char(16) COLLATE utf8_bin NOT NULL DEFAULT '',
  `Password` char(41) CHARACTER SET latin1 COLLATE latin1_bin NOT NULL DEFAULT '',
  `Select_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Insert_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Update_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Delete_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Create_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Drop_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Reload_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Shutdown_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Process_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `File_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Grant_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `References_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Index_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Alter_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Show_db_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Super_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Create_tmp_table_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Lock_tables_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Execute_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Repl_slave_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Repl_client_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Create_view_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Show_view_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Create_routine_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Alter_routine_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Create_user_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Event_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Trigger_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `Create_tablespace_priv` enum('N','Y') CHARACTER SET utf8 NOT NULL DEFAULT 'N',
  `ssl_type` enum('','ANY','X509','SPECIFIED') CHARACTER SET utf8 NOT NULL DEFAULT '',
  `ssl_cipher` blob NOT NULL,
  `x509_issuer` blob NOT NULL,
  `x509_subject` blob NOT NULL,
  `max_questions` int(11) unsigned NOT NULL DEFAULT '0',
  `max_updates` int(11) unsigned NOT NULL DEFAULT '0',
  `max_connections` int(11) unsigned NOT NULL DEFAULT '0',
  `max_user_connections` int(11) unsigned NOT NULL DEFAULT '0',
  `plugin` char(64) COLLATE utf8_bin DEFAULT '',
  `authentication_string` text COLLATE utf8_bin
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Users and global privileges';

--
-- 덤프된 테이블의 인덱스
--

--
-- 테이블의 인덱스 `columns_priv`
--
ALTER TABLE `columns_priv`
 ADD PRIMARY KEY (`Host`,`Db`,`User`,`Table_name`,`Column_name`);

--
-- 테이블의 인덱스 `db`
--
ALTER TABLE `db`
 ADD PRIMARY KEY (`Host`,`Db`,`User`), ADD KEY `User` (`User`);

--
-- 테이블의 인덱스 `event`
--
ALTER TABLE `event`
 ADD PRIMARY KEY (`db`,`name`);

--
-- 테이블의 인덱스 `func`
--
ALTER TABLE `func`
 ADD PRIMARY KEY (`name`);

--
-- 테이블의 인덱스 `help_category`
--
ALTER TABLE `help_category`
 ADD PRIMARY KEY (`help_category_id`), ADD UNIQUE KEY `name` (`name`);

--
-- 테이블의 인덱스 `help_keyword`
--
ALTER TABLE `help_keyword`
 ADD PRIMARY KEY (`help_keyword_id`), ADD UNIQUE KEY `name` (`name`);

--
-- 테이블의 인덱스 `help_relation`
--
ALTER TABLE `help_relation`
 ADD PRIMARY KEY (`help_keyword_id`,`help_topic_id`);

--
-- 테이블의 인덱스 `help_topic`
--
ALTER TABLE `help_topic`
 ADD PRIMARY KEY (`help_topic_id`), ADD UNIQUE KEY `name` (`name`);

--
-- 테이블의 인덱스 `host`
--
ALTER TABLE `host`
 ADD PRIMARY KEY (`Host`,`Db`);

--
-- 테이블의 인덱스 `just_test`
--
ALTER TABLE `just_test`
 ADD PRIMARY KEY (`uid`);

--
-- 테이블의 인덱스 `md5enc`
--
ALTER TABLE `md5enc`
 ADD PRIMARY KEY (`SEQ`);

--
-- 테이블의 인덱스 `ndb_binlog_index`
--
ALTER TABLE `ndb_binlog_index`
 ADD PRIMARY KEY (`epoch`);

--
-- 테이블의 인덱스 `plugin`
--
ALTER TABLE `plugin`
 ADD PRIMARY KEY (`name`);

--
-- 테이블의 인덱스 `proc`
--
ALTER TABLE `proc`
 ADD PRIMARY KEY (`db`,`name`,`type`);

--
-- 테이블의 인덱스 `procs_priv`
--
ALTER TABLE `procs_priv`
 ADD PRIMARY KEY (`Host`,`Db`,`User`,`Routine_name`,`Routine_type`), ADD KEY `Grantor` (`Grantor`);

--
-- 테이블의 인덱스 `proxies_priv`
--
ALTER TABLE `proxies_priv`
 ADD PRIMARY KEY (`Host`,`User`,`Proxied_host`,`Proxied_user`), ADD KEY `Grantor` (`Grantor`);

--
-- 테이블의 인덱스 `servers`
--
ALTER TABLE `servers`
 ADD PRIMARY KEY (`Server_name`);

--
-- 테이블의 인덱스 `tables_priv`
--
ALTER TABLE `tables_priv`
 ADD PRIMARY KEY (`Host`,`Db`,`User`,`Table_name`), ADD KEY `Grantor` (`Grantor`);

--
-- 테이블의 인덱스 `time_zone`
--
ALTER TABLE `time_zone`
 ADD PRIMARY KEY (`Time_zone_id`);

--
-- 테이블의 인덱스 `time_zone_leap_second`
--
ALTER TABLE `time_zone_leap_second`
 ADD PRIMARY KEY (`Transition_time`);

--
-- 테이블의 인덱스 `time_zone_name`
--
ALTER TABLE `time_zone_name`
 ADD PRIMARY KEY (`Name`);

--
-- 테이블의 인덱스 `time_zone_transition`
--
ALTER TABLE `time_zone_transition`
 ADD PRIMARY KEY (`Time_zone_id`,`Transition_time`);

--
-- 테이블의 인덱스 `time_zone_transition_type`
--
ALTER TABLE `time_zone_transition_type`
 ADD PRIMARY KEY (`Time_zone_id`,`Transition_type_id`);

--
-- 테이블의 인덱스 `toyo_ban_code_name`
--
ALTER TABLE `toyo_ban_code_name`
 ADD PRIMARY KEY (`BAN`);

--
-- 테이블의 인덱스 `toyo_ban_menu_name`
--
ALTER TABLE `toyo_ban_menu_name`
 ADD PRIMARY KEY (`MENU`), ADD KEY `TOYO_BAN_MENU_NAME_IX01` (`MENU`,`MENU_NAME`,`SRC_NAME`,`LEVEL`,`GROUP_NO`,`GO_BUT_NM`);

--
-- 테이블의 인덱스 `toyo_bible_contest`
--
ALTER TABLE `toyo_bible_contest`
 ADD PRIMARY KEY (`CONTEST_CODE`);

--
-- 테이블의 인덱스 `toyo_code_name`
--
ALTER TABLE `toyo_code_name`
 ADD PRIMARY KEY (`OPT`,`CODE`);

--
-- 테이블의 인덱스 `toyo_code_name_pack`
--
ALTER TABLE `toyo_code_name_pack`
 ADD PRIMARY KEY (`OPT`,`CODE`);

--
-- 테이블의 인덱스 `toyo_dream_kind`
--
ALTER TABLE `toyo_dream_kind`
 ADD PRIMARY KEY (`DREAM_KIND`);

--
-- 테이블의 인덱스 `toyo_id_info`
--
ALTER TABLE `toyo_id_info`
 ADD PRIMARY KEY (`ID`), ADD KEY `TOYO_ID_INFO_IX01` (`ID`,`K_NAME`);

--
-- 테이블의 인덱스 `toyo_id_info_hist`
--
ALTER TABLE `toyo_id_info_hist`
 ADD PRIMARY KEY (`ID`,`ENROLL_DATE`), ADD KEY `TOYO_ID_INFO_HIST_IX01` (`ID`,`ENROLL_DATE`);

--
-- 테이블의 인덱스 `toyo_kind_name`
--
ALTER TABLE `toyo_kind_name`
 ADD PRIMARY KEY (`KIND`);

--
-- 테이블의 인덱스 `toyo_kind_name_pack`
--
ALTER TABLE `toyo_kind_name_pack`
 ADD PRIMARY KEY (`KIND`);

--
-- 테이블의 인덱스 `toyo_notice_info`
--
ALTER TABLE `toyo_notice_info`
 ADD PRIMARY KEY (`NOTICE_NO`);

--
-- 테이블의 인덱스 `toyo_point`
--
ALTER TABLE `toyo_point`
 ADD PRIMARY KEY (`ENROLL_DATE`,`KIND`,`STUD_NO`);

--
-- 테이블의 인덱스 `toyo_point_payment`
--
ALTER TABLE `toyo_point_payment`
 ADD PRIMARY KEY (`ENROLL_DATE`,`STUD_NO`);

--
-- 테이블의 인덱스 `toyo_reg_date_poss`
--
ALTER TABLE `toyo_reg_date_poss`
 ADD PRIMARY KEY (`SEQ`,`POSS_DATE`);

--
-- 테이블의 인덱스 `toyo_stud_2hakgi_info`
--
ALTER TABLE `toyo_stud_2hakgi_info`
 ADD PRIMARY KEY (`STUD_NO`);

--
-- 테이블의 인덱스 `toyo_stud_2hakgi_new_info`
--
ALTER TABLE `toyo_stud_2hakgi_new_info`
 ADD PRIMARY KEY (`STUD_NO`);

--
-- 테이블의 인덱스 `toyo_stud_bible_memory`
--
ALTER TABLE `toyo_stud_bible_memory`
 ADD PRIMARY KEY (`ENROLL_DATE`,`BAN`,`STUD_NO`);

--
-- 테이블의 인덱스 `toyo_stud_chul`
--
ALTER TABLE `toyo_stud_chul`
 ADD PRIMARY KEY (`ENROLL_DATE`,`BAN`,`STUD_NO`), ADD KEY `STUD_CHUL_IX01` (`STUD_NO`,`CHUL_KIND`), ADD KEY `STUD_CHUL_IX02` (`STUD_NO`,`CHUL_KIND`,`REASON`);

--
-- 테이블의 인덱스 `toyo_stud_chul20160330`
--
ALTER TABLE `toyo_stud_chul20160330`
 ADD PRIMARY KEY (`ENROLL_DATE`,`BAN`,`STUD_NO`);

--
-- 테이블의 인덱스 `toyo_stud_code_name`
--
ALTER TABLE `toyo_stud_code_name`
 ADD PRIMARY KEY (`SUBJECT`);

--
-- 테이블의 인덱스 `toyo_stud_code_name_pack`
--
ALTER TABLE `toyo_stud_code_name_pack`
 ADD PRIMARY KEY (`SUBJECT`);

--
-- 테이블의 인덱스 `toyo_stud_dream`
--
ALTER TABLE `toyo_stud_dream`
 ADD PRIMARY KEY (`ENROLL_DATE`,`BAN`,`STUD_NO`);

--
-- 테이블의 인덱스 `toyo_stud_dream_course`
--
ALTER TABLE `toyo_stud_dream_course`
 ADD PRIMARY KEY (`STUD_NO`,`YEAR`,`QUARTER`,`DREAM_KIND`);

--
-- 테이블의 인덱스 `toyo_stud_dream_support_grade`
--
ALTER TABLE `toyo_stud_dream_support_grade`
 ADD PRIMARY KEY (`DREAM_KIND`);

--
-- 테이블의 인덱스 `toyo_stud_dream_year_course`
--
ALTER TABLE `toyo_stud_dream_year_course`
 ADD PRIMARY KEY (`STUD_NO`,`YEAR`,`QUARTER`,`DREAM_KIND`);

--
-- 테이블의 인덱스 `toyo_stud_field_attend`
--
ALTER TABLE `toyo_stud_field_attend`
 ADD UNIQUE KEY `UNIQUE_TOYO_STUD_FIELD_ATTEND` (`ENROLL_DATE`,`BAN`,`STUD_NO`);

--
-- 테이블의 인덱스 `toyo_stud_field_attend_teacher`
--
ALTER TABLE `toyo_stud_field_attend_teacher`
 ADD PRIMARY KEY (`TEACHER_NO`);

--
-- 테이블의 인덱스 `toyo_stud_info`
--
ALTER TABLE `toyo_stud_info`
 ADD PRIMARY KEY (`STUD_NO`), ADD KEY `STUD_SCORE` (`STUD_NO`,`TEAM`,`BAN`), ADD KEY `STUD_CHUL` (`STUD_NO`,`BAN`);

--
-- 테이블의 인덱스 `toyo_stud_info_temp`
--
ALTER TABLE `toyo_stud_info_temp`
 ADD PRIMARY KEY (`BAN`,`STUD_NAME`);

--
-- 테이블의 인덱스 `toyo_stud_memory`
--
ALTER TABLE `toyo_stud_memory`
 ADD PRIMARY KEY (`ENROLL_DATE`,`BAN`,`STUD_NO`), ADD KEY `STUD_MEMORY_IX01` (`BAN`,`STUD_NO`);

--
-- 테이블의 인덱스 `toyo_stud_memory_pack`
--
ALTER TABLE `toyo_stud_memory_pack`
 ADD PRIMARY KEY (`ENROLL_DATE`,`BAN`,`STUD_NO`);

--
-- 테이블의 인덱스 `toyo_stud_new_info`
--
ALTER TABLE `toyo_stud_new_info`
 ADD PRIMARY KEY (`STUD_NO`);

--
-- 테이블의 인덱스 `toyo_stud_reg_fee`
--
ALTER TABLE `toyo_stud_reg_fee`
 ADD PRIMARY KEY (`STUD_NO`);

--
-- 테이블의 인덱스 `toyo_stud_score`
--
ALTER TABLE `toyo_stud_score`
 ADD PRIMARY KEY (`ENROLL_DATE`,`BAN`,`STUD_NO`,`SUBJECT`), ADD KEY `STUD_SCORE_IX01` (`STUD_NO`,`ENROLL_DATE`,`BAN`);

--
-- 테이블의 인덱스 `toyo_stud_score_hist`
--
ALTER TABLE `toyo_stud_score_hist`
 ADD PRIMARY KEY (`SEQ`,`GUBUN`,`ENROLL_DATE`,`BAN`,`STUD_NO`,`SUBJECT`);

--
-- 테이블의 인덱스 `toyo_stud_score_pack`
--
ALTER TABLE `toyo_stud_score_pack`
 ADD PRIMARY KEY (`ENROLL_DATE`,`BAN`,`STUD_NO`,`SUBJECT`);

--
-- 테이블의 인덱스 `toyo_teacher_chul`
--
ALTER TABLE `toyo_teacher_chul`
 ADD PRIMARY KEY (`ENROLL_DATE`,`TEACHER_KIND`,`BAN`);

--
-- 테이블의 인덱스 `toyo_teacher_chul_code_name`
--
ALTER TABLE `toyo_teacher_chul_code_name`
 ADD PRIMARY KEY (`TEACHER_KIND`,`BAN`);

--
-- 테이블의 인덱스 `toyo_team_game_score`
--
ALTER TABLE `toyo_team_game_score`
 ADD PRIMARY KEY (`ENROLL_DATE`,`KIND`,`TEAM`);

--
-- 테이블의 인덱스 `toyo_team_game_score_rows`
--
ALTER TABLE `toyo_team_game_score_rows`
 ADD PRIMARY KEY (`ENROLL_DATE`,`KIND`,`TEAM`,`SEQ`);

--
-- 테이블의 인덱스 `toyo_team_score_plus`
--
ALTER TABLE `toyo_team_score_plus`
 ADD PRIMARY KEY (`ENROLL_DATE`,`KIND`,`BAN`,`TEAM`);

--
-- 테이블의 인덱스 `user`
--
ALTER TABLE `user`
 ADD PRIMARY KEY (`Host`,`User`);

--
-- 덤프된 테이블의 AUTO_INCREMENT
--

--
-- 테이블의 AUTO_INCREMENT `just_test`
--
ALTER TABLE `just_test`
MODIFY `uid` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=7;
--
-- 테이블의 AUTO_INCREMENT `md5enc`
--
ALTER TABLE `md5enc`
MODIFY `SEQ` int(10) unsigned NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=4;
--
-- 테이블의 AUTO_INCREMENT `time_zone`
--
ALTER TABLE `time_zone`
MODIFY `Time_zone_id` int(10) unsigned NOT NULL AUTO_INCREMENT;
--
-- 테이블의 AUTO_INCREMENT `toyo_stud_score_hist`
--
ALTER TABLE `toyo_stud_score_hist`
MODIFY `SEQ` int(9) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=153528;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
