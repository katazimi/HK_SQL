-- 2025.08.011 MARIADB_DAY08

-- 함수 사용하기
DROP FUNCTION if EXISTS userFunc;
DELIMITER $$
CREATE FUNCTION userFunc(VALUE1 INT, VALUE2 INT)
	RETURNS INT
BEGIN 
	RETURN VALUE1 + VALUE2;
END $$
DELIMITER ;

SELECT userFunc(100,200);


-- 커서 사용하기
-- 테이블에서 조회한 여러행의 결과를 한행씩 처리하기 위한 방식
-- 실행과정: SELECT 실행 -> 결과: 5개의 행이 조회 --> 한행씩 선택해서 처리
-- 커서 open -> 한개행 읽고 다음행 이동 -> 더 이상 행이 없으면 종료 -> 커서 닫기
DROP PROCEDURE if EXISTS cursorProc;
DELIMITER $$ 
CREATE PROCEDURE cursorProc() 
BEGIN
	DECLARE userHeight INT;
	DECLARE cnt INT DEFAULT 0;
	DECLARE totalHeight INT DEFAULT 0;
	
	DECLARE endOfRow BOOLEAN DEFAULT FALSE;
	
	DECLARE userCuror CURSOR FOR -- 커서 선언
		SELECT height FROM `userTbl`;
	
	DECLARE CONTINUE HANDLER -- 행의 끝이면 endRow 변수에 TRUE대입
		FOR NOT FOUND SET endOfRow = TRUE;
		
	OPEN userCuror; -- 커서 실행 준비
	
	cursor_loop:LOOP
	-- 커서에서 실행된 결과에서 한행씩 대입
		FETCH userCuror INTO userHeight;
		IF endOfRow THEN LEAVE cursor_loop;
		END IF;
		
		SET cnt = cnt+1;
		SET totalHeight = totalHeight+userHeight;
	END LOOP cursor_loop;
	
	SELECT CONCAT('고객 키의 평균 ==> ', (totalHeight/cnt));
	
	CLOSE userCuror;
END$$
DELIMITER ;

CALL cursorProc();

-- 트리거 사용하가ㅣ
-- insert, update, delete 등의 이벤트 실행시
-- 자동으로 처리해줄 쿼리 정의
CREATE TABLE IF NOT EXISTS testTbl (id INT, txt VARCHAR(10));
INSERT INTO testTbl VALUES(1,'이에스아이디');
INSERT INTO testTbl VALUES(2,'에프터스쿨');
INSERT INTO testTbl VALUES(3,'에이오에이');

DROP TRIGGER IF EXISTS testTrg;
DELIMITER //
CREATE TRIGGER testTrg
	AFTER DELETE ON testTbl FOR EACH ROW
BEGIN
	SET @msg = '가수 그룹이 삭제됨';
END //
DELIMITER ;


DROP TRIGGER IF EXISTS backUserTbl_UdateTrg
DELIMITER //
CREATE TRIGGER backUserTbl_UdateTrg
	ALTER UPDATE ON userTbl FOR EACH ROW
BEGIN
	INSERT INTO `backup_userTbl` VALUES (OLD.`userID`, OLD.`name`, OLD.`birthYear`, OLD.`addr`, OLD.`mobile1`, 
												OLD.`mobile2`, OLD.`height`, OLD.`mDate`, '수정', CURDATE(), CURRENT_USER());
END //
DELIMITER ;

DROP TRIGGER IF EXISTS backUserTbl_DeleteTrg;
DELIMITER //
CREATE TRIGGER backUserTbl_DeleteTrg
	AFTER DELETE ON userTbl FOR EACH ROW
BEGIN
	INSERT INTO `backup_userTbl` VALUES (OLD.`userID`, OLD.`name`, OLD.`birthYear`, OLD.`addr`, OLD.`mobile1`, 
												OLD.`mobile2`, OLD.`height`, OLD.`mDate`, '삭제', CURDATE(), CURRENT_USER());
END //
DELIMITER ;


UPDATE userTbl SET addr='몽고' WHERE userId='jkw';
DELETE FROM userTbl WHERE height >= 177;

-- insert trigger 사용
DROP TRIGGER IF EXISTS backUserTbl_InsertTrg;
DELIMITER //
CREATE TRIGGER backUserTbl_InsertTrg
	AFTER Insert ON userTbl FOR EACH ROW
BEGIN
	SIGNAL SQLSTATE '45000'
	SET MESSAGE_TEXT='데이터 입력을 시도했습니다. 귀하의 정보가 서버에 기록되었습니다.';
END //
DELIMITER ;

INSERT INTO userTbl VALUES('abc','에비씨',1977,'서울','011','12345678',181,'2018-12-25');

DROP TRIGGER backUserTbl_InsertTrg;

-- before 트리거 사용
DROP TRIGGER IF EXISTS backUserTbl_beforeInsertTrg;
DELIMITER //
CREATE TRIGGER backUserTbl_beforeInsertTrg
	BEFORE Insert ON userTbl FOR EACH ROW
BEGIN
	IF NEW.`birthYear` < 1900 THEN SET NEW.`birthYear`=0;
	ELSEIF NEW.birthYear > YEAR(CURDATE()) THEN SET NEW.`birthYear` = YEAR(CURDATE());
	END IF;
END //
DELIMITER ;

INSERT INTO userTbl VALUES('abc','에비씨',1800,'서울','011','12345678',181,'2018-12-25');


-- 중첩 트리거 사용
-- 1. 연습용 DB생성
DROP DATABASE IF EXISTS triggerDB;
CREATE DATABASE IF NOT EXISTS triggerDB;

USE triggerDB;
CREATE TABLE orderTbl (orderNO INT AUTO_INCREMENT PRIMARY KEY, 
						userID VARCHAR(5), prodName VARCHAR(5), orderamount INT);
CREATE TABLE prodTbl (prodName VARCHAR(5), account INT);
CREATE TABLE deliverTbl (deliverNo INT AUTO_INCREMENT PRIMARY KEY, prodName VARCHAR(5), account INT UNIQUE);

INSERT INTO prodTbl VALUES('사과',100);
INSERT INTO prodTbl VALUES('배',100);
INSERT INTO prodTbl VALUES('귤',100);

-- 2. 중첩 트리거 실습
DROP TRIGGER IF EXISTS orderTrg;
DELIMITER //
CREATE TRIGGER orderTrg
	AFTER Insert ON orderTbl FOR EACH ROW
BEGIN
	UPDATE prodTbl SET account = account - NEW.`orderamount` WHERE `prodName`=NEW.`prodName`;
END //
DELIMITER ;

DROP TRIGGER IF EXISTS prodTrg;
DELIMITER //
CREATE TRIGGER prodTrg
	AFTER UPDATE ON prodTbl FOR EACH ROW
BEGIN
	DECLARE orderAmount INT;
	SET orderAmount = OLD.`account` - NEW.account;
	INSERT INTO deliverTbl(prodName, account) VALUES(NEW.`prodName`, orderAmount);
END //
DELIMITER ;

INSERT INTO orderTbl VALUES (NULL,'JOHN','배',5);
SELECT * FROM orderTbl;
SELECT * FROM prodTbl;
SELECT * FROM deliverTbl;

ALTER TABLE deliverTbl CHANGE prodName productName VARCHAR(5);
INSERT INTO orderTbl VALUES(NULL, 'DANG','사과',9);
SELECT * FROM orderTbl;
SELECT * FROM prodTbl;
SELECT * FROM deliverTbl;


-- 실습 진행
-- 프로시저 만들기
-- 문제 1 — 특정 부서의 사원 목록 조회
-- 매개변수로 **부서번호(deptno)**를 입력받아 해당 부서 사원의 ename, job, sal을 출력하는 프로시저(getDept_emp()) 작성
-- 부서가 존재하지 않으면 "해당 부서가 없습니다." 메시지 출력
DELIMITER $$
CREATE PROCEDURE getDept_emp(IN deptno_2 INT)
BEGIN 
	IF deptno_2 IN (SELECT DEPTNO FROM EMP) THEN SELECT ENAME, JOB, `SAL` FROM EMP WHERE DEPTNO = deptno_2;
	ELSE SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='해당 부서가 없습니다.';
	END IF;
END $$
DELIMITER ;

CALL getDept_emp(30);

-- 문제 2 — 급여 인상
-- 매개변수로 **사원번호(empno)**와 **인상액(amount)**을 받아 해당 사원의 급여(sal)를 증가시키는 프로시저(increase_salary()) 작성
-- 인상 후 변경된 급여를 출력(update로 급여를 변경시킨 후)
-- 사원번호가 존재하지 않으면 "사원을 찾을 수 없습니다." 메시지 출력
DELIMITER $$
CREATE PROCEDURE increase_salary(IN empno_2 INT, IN amount INT)
BEGIN 
	IF empno_2 IN (SELECT EMPNO FROM EMP) THEN UPDATE EMP SET SAL = SAL + amount WHERE EMPNO = empno_2;
	ELSE SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='사원을 찾을 수 없습니다.';
	END IF;
END $$
DELIMITER ;

CALL increase_salary(7369,200);


-- 문제 3 — 부서별 평균 급여 계산
-- 매개변수 없이 실행하면, 각 부서별 평균 급여를 계산하여 부서번호, 평균급여를 출력하는 프로시저 작성
-- 평균 급여는 소수점 2자리까지 표시
DELIMITER $$
CREATE PROCEDURE average_salary()
BEGIN 
	SELECT DEPTNO, TRUNCATE(AVG(SAL),2) FROM EMP GROUP BY DEPTNO;
END $$
DELIMITER ;

CALL average_salary();


-- 문제 4 — 급여 등급 조회
-- 매개변수로 **사원번호(empno)**를 입력받아 해당 사원의 급여 등급(salgrade)을 조회하는 프로시저 작성
-- emp → salgrade 테이블을 조인하여 등급을 찾음
-- 사원이 없으면 "사원 없음" 메시지 출력
DELIMITER $$
CREATE PROCEDURE grade_salary(IN empno_2 INT)
BEGIN 
	IF empno_2 IN (SELECT EMPNO FROM EMP) THEN SELECT E.`EMPNO`, S.`GRADE` FROM EMP E JOIN SALGRADE S ON E.SAL BETWEEN S.`LOSAL` AND S.`HISAL` WHERE E.`EMPNO` = empno_2;
	ELSE SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='사원을 찾을 수 없습니다.';
	END IF;
END $$
DELIMITER ;

CALL grade_salary(7269);


-- 문제 5 — 특정 직책(Job) 사원의 급여 일괄 인상
-- 매개변수로 **직책(job)**과 **인상률(percent)**을 입력받아 해당 직책 사원들의 급여를 모두 일괄 인상하는 프로시저 작성
-- 변경된 사원 수와 총 급여 변동액을 출력
-- 해당 직책이 없으면 "해당 직책의 사원이 없습니다." 메시지 출력
DELIMITER $$
CREATE PROCEDURE acrossTheBoard_increase(IN job_2 VARCHAR(9), IN percent INT)
BEGIN 
	IF job_2 IN (SELECT JOB FROM EMP) THEN UPDATE EMP SET SAL = SAL+SAL*(percent/100) WHERE JOB=job_2;
	ELSE SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='해당 직책의 사원이 없습니다.';
	END IF;
END $$
DELIMITER ;

CALL acrossTheBoard_increase('MANAGER',10);


-- 트리거 만들기 ---------------------------------------
-- 문제 1 — 급여 변경 이력 기록
--  설명: EMP 테이블에서 사원의 급여(SAL)가 변경될 때만, 변경 전·후 급여를 로그 테이블에 저장하는 트리거를 작성하시오.
-- 조건 : 변경 전 급여와 변경 후 급여가 다른 경우만 기록,  변경 일자와 변경한 사용자도 함께 기록
CREATE TABLE EMP_LOG (SELECT * FROM EMP WHERE 1=2);
ALTER TABLE EMP_LOG ADD COLUMN modType CHAR(2), ADD COLUMN modDate DATE, ADD COLUMN modUser VARCHAR(256);

DROP TRIGGER IF EXISTS EMP_updateSALTrg;
DELIMITER //
CREATE TRIGGER EMP_updateSALTrg	
AFTER UPDATE ON EMP FOR EACH ROW
BEGIN
	IF NEW.SAL <> OLD.SAL THEN INSERT INTO EMP_LOG VALUES (OLD.`EMPNO`, OLD.`ENAME`, OLD.`JOB`, OLD.`MGR`, OLD.`HIREDATE`, OLD.`SAL`,NEW.`SAL`, OLD.`COMM`, OLD.`DEPTNO`, '수정', CURDATE(), CURRENT_USER());
	END IF;
END //
DELIMITER ;

UPDATE EMP SET SAL = 800 WHERE EMPNO=7369;


-- 문제 2 — 신규 사원 등록 시 입사일 자동 설정
--  설명: EMP 테이블에 새로운 사원이 INSERT 될 때, HIREDATE가 NULL이면 자동으로 SYSDATE를 설정하는 트리거를 작성하시오.
-- 조건: HIREDATE가 NULL이 아닌 경우는 기존 값 유지,  BEFORE INSERT 트리거로 구현
DROP TRIGGER IF EXISTS EMP_insertTrg;
DELIMITER //
CREATE TRIGGER EMP_insertTrg
BEFORE INSERT ON EMP FOR EACH ROW
BEGIN 
	IF NEW.`HIREDATE` IS NULL THEN SET NEW.`HIREDATE` = SYSDATE();
	END IF;
END //
DELIMITER ;

INSERT INTO EMP VALUES(7901, 'KANG', 'CLERK', NULL, NULL,800,NULL,20);

-- 문제 3 — 부서 삭제 시 사원 이력 백업
--  설명: DEPT 테이블에서 부서가 삭제될 때, 해당 부서 소속 사원들을 EMP_BACKUP 테이블로 백업한 뒤, 사원 데이터를 EMP에서 삭제하는 트리거를
-- 작성하시오.
-- 조건: 부서 삭제 전에 백업 수행, BEFORE DELETE ON DEPT 에서 FOR EACH ROW 사용
DROP TRIGGER IF EXISTS DEPT_deleteTrg;
DELIMITER //
CREATE TRIGGER DEPT_deleteTrg
BEFORE DELETE ON DEPT FOR EACH ROW
BEGIN 
	INSERT INTO EMP_LOG (EMPNO,ENAME,JOB,MGR,HIREDATE,SAL,COMM,DEPTNO,modType, modDate, modUser) SELECT EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO, '수정', CURDATE(), CURRENT_USER() FROM EMP WHERE DEPTNO = OLD.DEPTNO;
	DELETE FROM EMP WHERE DEPTNO = OLD.`DEPTNO`;
END //
DELIMITER ;

INSERT INTO DEPT VALUES(50,'A','SEOUL');
INSERT INTO EMP VALUES(7901, 'KANG', 'CLERK', NULL, NULL,800,NULL,50);
DELETE FROM DEPT WHERE DEPTNO = 50;

-- 문제 4 — 사원 직책 변경 시 로그 기록
--  설명: EMP 테이블에서 사원의 JOB이 변경될 때, 이전 직책과 새 직책을 JOB_CHANGE_LOG에 저장하는 트리거를 작성하시오.
-- 조건: 변경 전 직책과 변경 후 직책이 다를 경우만 기록
--          변경한 사용자, 변경 일자 기록
CREATE TABLE JOB_CHANGE_LOG (SELECT * FROM EMP WHERE 1=2);
ALTER TABLE JOB_CHANGE_LOG ADD COLUMN NEW_JOB VARCHAR(9), ADD COLUMN modType CHAR(2), ADD COLUMN modDate DATE, ADD COLUMN modUser VARCHAR(256);

DROP TRIGGER IF EXISTS EMP_updateJobTrg;
DELIMITER //
CREATE TRIGGER EMP_updateJobTrg
AFTER UPDATE ON EMP FOR EACH ROW
BEGIN
	IF NEW.JOB <> OLD.JOB THEN INSERT INTO JOB_CHANGE_LOG VALUES (OLD.`EMPNO`, OLD.`ENAME`, OLD.`JOB`, NEW.`JOB`, OLD.`MGR`, OLD.`HIREDATE`, OLD.`SAL`, OLD.`COMM`, OLD.`DEPTNO`, '수정', CURDATE(), CURRENT_USER());
	END IF;
END //
DELIMITER ;

UPDATE EMP SET JOB = 'CLERK' WHERE EMPNO=7369;

-- 문제 5 — 부서별 급여 총합 검증
--  설명: EMP 테이블에서 사원의 급여(SAL)가 변경될 때, 해당 부서의 급여 총합이 50,000을 초과하면 변경을 막는 트리거를 작성하시오.
-- 조건:  BEFORE INSERT 와 UPDATE 트리거 2개 필요
--            부서별 급여 총합 계산 후 조건 위반 시  SIGNAL SQLSTATE '45000' 로 에러 발생 트랜잭션 롤백

DROP TRIGGER IF EXISTS SAL_SUM_Trg1;
DELIMITER //
CREATE TRIGGER SAL_SUM_Trg1
	BEFORE Insert ON EMP FOR EACH ROW
BEGIN
	IF COALESCE((SELECT SUM(SAL) FROM EMP WHERE DEPTNO=NEW.`DEPTNO` GROUP BY `DEPTNO`),0) + NEW.`SAL` > 50000 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='부서 급여 총합이 50,000을 초과하였습니다.';
	END IF;
END //
DELIMITER ;

DROP TRIGGER IF EXISTS SAL_SUM_Trg2;
DELIMITER //
CREATE TRIGGER SAL_SUM_Trg2
	BEFORE UPDATE ON EMP FOR EACH ROW
BEGIN
	IF COALESCE((SELECT SUM(SAL) FROM EMP WHERE DEPTNO=NEW.`DEPTNO` GROUP BY `DEPTNO`),0) + NEW.`SAL` > 50000 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='부서 급여 총합이 50,000을 초과하였습니다.';
	END IF;END //
DELIMITER ;

INSERT INTO EMP VALUES(7901, 'KANG', 'CLERK', NULL, NULL,50000,NULL,10);
UPDATE EMP SET SAL=50000 WHERE EMPNO=7369;













