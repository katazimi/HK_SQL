-- 2025.08.05 MARIADB_DAY04

-- 사용자 생성 및 권한 부여
-- CREATE USER id@'ip주소' IDENTIFIED BY '패스워드' 
CREATE USER director@'%' IDENTIFIED BY 'director';
GRANT ALL ON *.*  TO director@'%' WITH GRANT OPTION;

CREATE USER ceo@'%' IDENTIFIED BY 'ceo';
GRANT SELECT ON *.* TO ceo@'%';

CREATE USER staff@'%' IDENTIFIED BY 'staff';
GRANT SELECT,INSERT,UPDATE,DELETE ON scott.* TO staff@'%';

-- 권한 제거
REVOKE UPDATE ON scott.* FROM staff@'%';
REVOKE DELETE ON scott.* FROM staff@'%';

-- 모든 권한 제거
REVOKE ALL PRIVILEGES ON scott.* FROM staff@'%';

-- DML 사용법
CREATE TABLE testTBL1(id INT, userName char(3), age INT);

-- insert문
INSERT INTO testTBL1(id, userName) VALUES(2,'설현');
SELECT * FROM testTBL1;
INSERT INTO testTBL1(id, userName, age) VALUES(3,'초아',26);
INSERT INTO testTBL1(id, userName,age) VALUES(1,'홍길동',100);

CREATE TABLE testTBL2(id INT AUTO_INCREMENT PRIMARY KEY, userName CHAR(3), age INT);

INSERT INTO testTBL2 VALUES(null, '지민',25);
INSERT INTO testTBL2 VALUES(null, '유나',22);
INSERT INTO testTBL2 VALUES(null, '유경',21);
SELECT * FROM testTBL2;

SELECT LAST_INSERT_ID();

ALTER TABLE testTBL2 AUTO_INCREMENT = 100;
INSERT INTO testTBL2 VALUES(null, '찬미',23);
SET @@AUTO_INCREMENT_INCREMENT = 3;

INSERT INTO testTBL2 VALUES(null,'영수',28),(null, '철수', 28),(null, '고수', 28),(null, '삼수', 28);

INSERT INTO testTBL2 SELECT * FROM test;

-- update문
UPDATE testTBL2 SET userName = '수정', age='50' WHERE id = 102;

-- delete문 : 행단위로 삭제
DELETE FROM testTBL2 WHERE id=3;
DELETE FROM testTBL2 WHERE userName='찬미';

-- 비재귀적 CTE
WITH abc(userID, total) AS (SELECT userID, SUM(price*amount) FROM buyTbl GROUP BY userID) SELECT * FROM abc ORDER BY total DESC;

-- 9.연습문제 내장함수의 활용
-- Q1) 사원 테이블에서 사원이름을 첫글자는 대문자로, 나머지는 소문자로 출력하자.
SELECT EMPNO,CONCAT(SUBSTRING(ENAME,1,1), LOWER(SUBSTRING(ENAME,2))) AS 'NAME' FROM EMP;

-- Q2) 사원테이블에서 사원이름을 출력하고,
--    이름의 두번째 글자부터 네번째 글자도 출력하자.
SELECT ENAME, SUBSTRING(ENAME,2,2) FROM EMP;

-- Q3) 사원테이블에서 각 사원 이름의 철자 개수를 출력하자.
SELECT EMPNO, LENGTH(ENAME) FROM EMP;

-- Q4) 사원테이블에서 각 사원 이름의 앞 글자 하나와 마지막 글자 하나만 출력하되,
-- 소문자로 출력하라.
SELECT EMPNO, CONCAT(LOWER(SUBSTRING(ENAME,1,1)), LOWER(SUBSTRING(ENAME, LENGTH(ENAME)))) FROM EMP;

-- Q5) 3456.78을 소수점 첫번째 자리에서 반올림해서 출력하자.
SELECT ROUND(3456.78);

-- Q6) 사원테이블에서 사원이름과 근무일수(고용일 ~ 현재 날짜)를 출력하자.
SELECT ENAME, CONCAT(HIREDATE, ' ~ ', DATE(NOW())) AS '근무일수' FROM EMP;

-- Q7) 위 문제에서 근무일수를 '00년 00개월 00일' 형식으로 출력하자. (한달을 30일로 계산)
-- 예)
--  ENAME  |  근무일수
--  -------------------------------
--  KING     |  00년 00개월 00일

SELECT ENAME, CONCAT(FLOOR(DATEDIFF(DATE(NOW()),HIREDATE)/365), '년 ', FLOOR(DATEDIFF(DATE(NOW()),HIREDATE)%365/30), '개월 ', DATEDIFF(DATE(NOW()),HIREDATE)%30, '일') AS '근무일수' FROM EMP;


-- 연습문제 - 2
CREATE TABLE EMP_2 (SELECT * FROM EMP);

-- 1.   사원(EMP이름)테이블에서 직업(JOB)이 ‘SALESMAN’ 인 사원 급여(SAL)에 400 더하는 수정(UPDATE) 구문을 구하세요?
UPDATE EMP_2 SET SAL = SAL+400 WHERE JOB = 'SALESMAN';

-- 2.   사원(EMP이름)테이블에서 급여(SAL)가 사원 평균급여 보다 높은 사원을 대상으로 고용일자(HIREDATE)를 1년 더하는 수정(UPDATE) 구문을 구하세요?
UPDATE EMP_2 SET HIREDATE = ADDDATE(HIREDATE, INTERVAL 1 YEAR) WHERE SAL > (SELECT AVG(SAL) FROM EMP_2);

-- 3.   사원(EMP이름)테이블에서 전체 사원을 대상으로 COMM 컬럼에 100 을 더하고 직업(JOB)이 ‘CLERK’ 인 사원은 현 급여에서 2배, ‘MANAGER’ 인 직업을 가진 사원은 현 급여에서 3배, 이외 직업을 가진 사원은 현 급여에서 4배를 더하는 수정(UPDATE) 구문을 구하세요?
UPDATE EMP_2 SET COMM = COMM+100, SAL = CASE WHEN JOB = 'CLERK' THEN SAL*2 WHEN JOB = 'MANAGER' THEN SAL*3 ELSE SAL*4 END;

-- 4.   사원(EMP이름)테이블에서 이름(ENAME)이 ‘M’으로 시작하는 사원 삭제(DELETE) 구문을 구하세요?
DELETE FROM EMP_2 WHERE SUBSTRING(ENAME,1,1) = 'M';
	
-- 5.   사원(EMP이름)테이블에서 급여(SAL)가 사원 평균급여 보다 높은 사원 삭제(DELETE) 구문을 구하세요?
DELETE FROM EMP_2 WHERE SAL > (SELECT AVG(SAL) FROM EMP_2);
