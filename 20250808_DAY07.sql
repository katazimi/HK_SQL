-- 2025.08.08 MARIADB_DAY07

-- 인덱스 사용
-- 종류: 클러스터형 인덱스, 보조인덱스
-- 1. 인덱스 자동 생성하기
CREATE TABLE tbl1(a INT PRIMARY KEY, b INT, c INT);

-- 인덱스 조회하기
SHOW INDEX FROM tbl1;

-- 2. primary key, unique 여러 제약조건 설정
CREATE TABLE tbl2 (a INT PRIMARY KEY, b INT UNIQUE, c INT UNIQUE, d INT);

SHOW INDEX FROM tbl2;
-- 결과 확인 : Non_unique 모두 0 -> unique 인덱스임
--			 Key_name: primary 인것이 클러스터형 인덱스
--			 보조인덱스는 테이블 당 여러개 생성 가능

-- 3. unique 제약조건만 지정한 경우
CREATE TABLE tbl3 (a INT UNIQUE , b INT UNIQUE, c INT UNIQUE, d INT);
SHOW INDEX FROM tbl3;
-- 셋중에 클러스터형 인덱스의 역할X -> 모두 보조인덱스로 생성

-- 4. unique 제약조건 + NOT NULL
CREATE TABLE tbl4 (a INT UNIQUE NOT NULL, b INT UNIQUE, c INT UNIQUE, d INT);
SHOW INDEX FROM tbl4;
-- UNIQUE이면서 NOT NULL인 a 인덱스가 클러스터형 인덱스가 됨

-- 5. UNIQUE, NOT NULL 인 경우와 PRIMARY KEY인 경우
CREATE TABLE tbl5 (a INT UNIQUE NOT NULL, b INT UNIQUE NOT NULL, c INT UNIQUE, d INT PRIMARY KEY);
SHOW INDEX FROM tbl5;
-- PRIMARY KEY로 설정한 인덱스가 우선순위가 높다

-- 6. 클러스터형 인덱스는 행 데이터를 정렬한다.
CREATE TABLE usertblidx (SELECT userID, NAME, birthyear, addr FROM userTbl WHERE NAME IN ('이승기','김범수', '조용필', '성시경', '김경호'));
SELECT * FROM usertblidx;
ALTER TABLE usertblidx ADD CONSTRAINT pk_userID PRIMARY KEY (userID);
ALTER TABLE usertblidx DROP PRIMARY KEY;
ALTER TABLE usertblidx ADD CONSTRAINT pk_NAME PRIMARY KEY (NAME);


-- 인덱스를 생성하고 사용해보자
-- 1. 인덱스 이름 확인
SHOW TABLE STATUS LIKE 'userTbl';
CREATE INDEX idx_userTBL_addr ON userTbl (addr);
SHOW INDEX FROM userTbl;
ANALYZE TABLE userTbl;
SHOW TABLE STATUS LIKE 'userTbl';

-- 2. 보조 인덱스 생성
CREATE UNIQUE INDEX idx_userTBL_birthYear ON userTbl (birthyear); -- 1979가 중복이라 오류발생
CREATE UNIQUE INDEX idx_userTBL_name ON userTbl (NAME); -- 보조 인덱스 생성
INSERT INTO userTbl VALUES('GPS', '김범수', 1983, '미국', NULL, NULL, 162, NULL); -- 중복된값 입력 불가
CREATE INDEX idx_userTBL_name_birthYear ON userTbl (NAME, birthyear);
DROP INDEX idx_userTBL_name ON userTbl;
EXPLAIN SELECT * FROM userTbl WHERE NAME='윤종신' AND birthyear='1969';
SELECT * FROM userTbl WHERE name='윤종신' and birthYear='1969';
CREATE INDEX idx_userTbl_mobile1 ON userTbl (mobile1);
SELECT * FROM userTbl WHERE mobile1='011';
EXPLAIN SELECT * FROM userTbl WHERE mobile1='011';

-- 3. 인덱스를 삭제해보자
SHOW INDEX FROM userTbl;
DROP INDEX idx_userTBL_addr ON userTbl; -- ALTER TABLE userTbl DROP INDEX idx_userTBL_addr;
DROP INDEX idx_userTBL_name_birthYear ON userTbl;
DROP INDEX idx_userTBL_mobile1 ON userTbl;

ALTER TABLE userTbl DROP PRIMARY KEY;
SELECT table_name, constraint_name FROM information_schema.referential_constraints WHERE CONSTRAINT_SCHEMA = 'sqlDB';

ALTER TABLE buyTbl DROP FOREIGN KEY buytbl_ibfk_1;
ALTER TABLE userTbl DROP PRIMARY KEY;



-- index 성능 비교
-- 데이터 베이스 새로 생성
CREATE DATABASE indexDB;
SELECT COUNT(*) FROM employees.employees;

CREATE TABLE emp (SELECT * FROM employees.`employees` ORDER BY RAND());
CREATE TABLE emp_C (SELECT * FROM employees.`employees` ORDER BY RAND());
CREATE TABLE emp_Se (SELECT * FROM employees.`employees` ORDER BY RAND());

SELECT * FROM emp LIMIT 5;
SELECT * FROM emp_C LIMIT 5;
SELECT * FROM emp_Se LIMIT 5;

-- 인덱스가 존재하는지 확인
SHOW TABLE STATUS;

-- index 생성하기
ALTER TABLE emp_C ADD PRIMARY KEY (emp_no);
ALTER TABLE emp_Se ADD INDEX idx_emp_no (`emp_no`);

-- index 생성 확인
SHOW INDEX FROM emp;
SHOW INDEX FROM emp_C;
SHOW INDEX FROM emp_Se;

-- 조회
EXPLAIN SELECT * FROM emp WHERE emp_no < 11000;
EXPLAIN SELECT * FROM emp_C WHERE emp_no < 11000;
EXPLAIN SELECT * FROM emp_Se WHERE emp_no < 11000;

-- index를 강제로 실행 또는 실행 못하게 하려면 hint 사용
EXPLAIN SELECT * FROM emp_C USE INDEX(PRIMARY) WHERE emp_no < 11000;
EXPLAIN SELECT * FROM emp_C IGNORE INDEX(PRIMARY) WHERE emp_no < 11000;

-- index룰 사용 못하는 경우
EXPLAIN SELECT * FROM emp_Se WHERE emp_no < 400000;

-- 쿼리문을 잘못 만들 경우
EXPLAIN SELECT * FROM emp_C USE INDEX(PRIMARY) WHERE emp_no*1 = 11000;

-- 중복도가 높고, 종류가 적을 경우
ALTER TABLE emp ADD index idx_gender (gender);
ANALYZE TABLE emp;
SHOW INDEX FROM emp;
EXPLAIN SELECT * FROM emp WHERE gender = 'M';

-- 스토어드 프로그래밍 (프로시저)
DELIMITER $$
CREATE PROCEDURE userProc1(IN userName VARCHAR(10))
BEGIN 
	SELECT * FROM userTbl WHERE NAME = userName;
END $$
DELIMITER ;


CALL userProc1('조관우');

-- 매개변수 2개: 회원이 태어난 해 이후에 출생했으면서 키가 큰회원 조회
DELIMITER $$
CREATE PROCEDURE userProc2(IN userbirth INT, IN userheight INT)
BEGIN 
	SELECT * FROM userTbl WHERE birthYear > userbirth AND `height` > userheight;
END $$
DELIMITER ;

CALL userProc2(1970, 178);

-- 출력개변수 이용
DELIMITER $$
CREATE PROCEDURE userProc3(IN txtValue CHAR(10), OUT outValue INT)
BEGIN 
	INSERT INTO testTbl VALUES (NULL, txtValue);
	SELECT MAX(id) INTO outValue FROM testTbl;
END $$
DELIMITER ;

CREATE TABLE testTbl (id INT AUTO_INCREMENT PRIMARY KEY, txt CHAR(10));

SET @myValue='';
CALL userProc3('테스트 값', @myValue);


