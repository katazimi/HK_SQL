-- 2025.08.04 MARIADB_DAY03
use sqlDB;

CREATE TABLE buyTbl2 (SELECT * from buyTbl);

SELECT * FROM buyTbl2;

CREATE TABLE buyTbl3 (SELECT num, userId, prodname FROM buyTbl);

DROP TABLE buyTbl3; -- 테이블 삭제 -> DROP사용

-- 집계함수
SELECT userId, SUM(amount) AS '합계' FROM buyTbl GROUP BY userId;

SELECT userId AS '사용자 아이디', SUM(price * amount) AS '총 구매액' FROM buyTbl GROUP BY userId;

SELECT name, MAX(height), MIN(height) FROM userTbl GROUP BY name;

SELECT name,height FROM userTbl WHERE height = (SELECT MAX(height) FROM userTbl) or height = (SELECT MIN(height) FROM userTbl);

SELECT COUNT(*) FROM userTbl;

SELECT COUNT(mobile1) FROM userTbl; -- NULL 값은 제외하고 갯수를 집계함

-- HAVING 절 : 집계함수 관련 조건 정의
-- WHERE 절에서는 사용할 수 없음
SELECT userId AS '사용자', SUM(price * amount) AS '총 구매액' FROM buyTbl GROUP BY userId HAVING SUM(price * amount) > 1000 ORDER BY SUM(price * amount);

-- ROLLUP : 중간집계
SELECT num, groupName, SUM(price*amount) AS '비용' FROM buyTbl GROUP BY groupName, num WITH ROLLUP;
SELECT num, groupName, SUM(price*amount) AS '비용' FROM buyTbl GROUP BY groupName WITH ROLLUP;

-- 문제1 - 집계함수, orderby ----------------------------------------------------------------------------
-- Q1) 사원테이블에서 사원 이름과 월급을 구하되, 월급을 내림차순으로 출력하자.
SELECT ENAME, SAL FROM EMP ORDER BY SAL DESC;

-- Q2) 사원테이블에서 직업별 평균 월급을 출력하되 컬럼 ALIAS를 '평균' 으로 하고, 평균 월급이 높은 순으로 정렬하자.
SELECT JOB, AVG(SAL) AS '평균 임금' FROM EMP GROUP BY JOB ORDER BY AVG(SAL) DESC;

-- Q3) 사원테이블에서 직업별 총 월급을 구하고, 총 월급이 5000 이상인 것만 출력하자.
SELECT JOB, SUM(SAL) AS '총 월급' FROM EMP GROUP BY JOB HAVING SUM(SAL) > 5000;

-- Q4) 사원테이블에서 부서별 월급의 합을 구하고, 그 총합이 1000 이상인 것만 출력하자.
SELECT DEPTNO, SUM(SAL) AS '총 월급' FROM EMP GROUP BY DEPTNO HAVING SUM(SAL) > 1000;


-- 문제2 - 테이블 생성 및 복사 ----------------------------------------------------------------------------
-- Q1) SIZE가 10인 문자형 컬럼 ID와 PW를 가진 TEST 테이블을 생성해보자
CREATE TABLE TEST (ID VARCHAR(10), PW VARCHAR(10));

-- Q2) 사원 테이블(EMP)의 모든 구조와 데이터를 TEST01로 복사하여 생성해보자.
CREATE TABLE TEST01(SELECT * FROM EMP);

-- Q3) 사원 테이블에서 사원의 번호와 이름을 TEST02로 복사하여 생성해보자.
CREATE TABLE TEST02(SELECT EMPNO, ENAME FROM EMP);

-- Q4) 사원 테이블에서 사원의 번호와 이름을 TEST03으로 복사하여 생성해보자.
-- 단, 컬럼명을 M1, M2로 변경하면서 복사하자.
CREATE TABLE TEST03(SELECT EMPNO AS M1, ENAME AS M2 FROM EMP);

-- Q5) 사원 테이블의 구조만 TEST04로 복사하여 생성해보자.
CREATE TABLE TEST04 LIKE EMP;
DROP TABLE TEST04;
CREATE TABLE TEST04(SELECT * FROM EMP WHERE 1=2);

-- Q6) 부서 테이블(DEPT) 의 구조만 TEST05로 복사하여 생성해보자.
CREATE TABLE TEST05 LIKE DEPT;
DROP TABLE TEST05;
CREATE TABLE TEST05(SELECT * FROM DEPT WHERE 1=2);

-- 문제3 - group by, 집계함수 ---------------------------------------------------------------------------
-- Q1) 사원테이블에서 평균 월급을 출력하자.
SELECT AVG(SAL) FROM EMP;

-- Q2) 사원테이블에서 부서번호가 10인 부서에 근무하고 있는 사원들의 부서번호와 평균 월급을 출력하자.
SELECT DEPTNO, AVG(SAL) FROM EMP WHERE DEPTNO = 10 GROUP BY DEPTNO;

-- Q3) 사원테이블에서 직업이 'SALESMAN'인 사원들의 평균 월급을 출력하자.
SELECT JOB, AVG(SAL) FROM EMP GROUP BY JOB HAVING JOB = 'SALESMAN';

-- Q4) 사원테이블에서 부서별 평균 월급을 출력하자.
SELECT DEPTNO, AVG(SAL) FROM EMP GROUP BY DEPTNO;

-- Q5) 사원테이블에서 직업별 평균 월급을 출력하자.
SELECT JOB, AVG(SAL) FROM EMP GROUP BY JOB;

-- Q6) 사원 테이블에서 평균 커미션(COMM)을 출력하자.
SELECT AVG(COMM) FROM EMP; -- NULL 처리X
SELECT AVG(NVL(COMM,0)) FROM EMP; -- NULL => 0으로 계산

-- Q7) 사원테이블에서 10번 부서의 최대 월급을 출력하자.
SELECT DEPTNO, MAX(SAL) FROM EMP WHERE DEPTNO = 10 GROUP BY DEPTNO;

-- Q8) 사원테이블에서 부서별 최대 월급을 출력하자.
SELECT DEPTNO, MAX(SAL) FROM EMP GROUP BY DEPTNO;

-- Q9) 사원테이블에서 직업별 최대 월급을 출력하자.
SELECT JOB, MAX(SAL) FROM EMP GROUP BY JOB;

-- Q10) 사원테이블에서 직업이 'SALESMAN'인 사원들 중 최대월급을 출력하자.
SELECT JOB, MAX(SAL) FROM EMP WHERE JOB = 'SALESMAN' GROUP BY JOB;

-- 문제 4 - group by , having, 집계함수 -------------------------------------------------------------------
-- Q1) 사원 테이블에서 부서별 최대 월급을 출력하자.
SELECT DEPTNO, MAX(SAL) FROM EMP GROUP BY DEPTNO;

-- Q2) 사원테이블에서 직업별 최소 월급을 구하되, 직업이 'CLERK' 인 것만 출력하자.
SELECT JOB, MIN(SAL) FROM EMP GROUP BY JOB HAVING JOB = 'CLERK';

-- Q3) 사원테이블에서 커미션이 책정된 사원은 모두 몇 명인지 출력하자.
SELECT COUNT(COMM) FROM EMP;

-- Q4) 사원테이블에서 직업이 'SALESMAN'이고 월급이 1000 이상인 사원의 이름과 월급을 출력하자.
SELECT ENAME, SAL FROM EMP WHERE JOB = 'SALESMAN' AND SAL >= 1000;

-- Q5) 사원테이블에서 부서별 평균 월급을 출력하되, 평균 월급이 2000보다 큰 부서의 부서번호와 평균 월급을 출력하자.
SELECT DEPTNO, AVG(SAL) FROM EMP GROUP BY DEPTNO HAVING AVG(SAL)>2000;

-- Q6) 사원테이블에서 직업이 'MANAGER' 인 사원을 출력하되, 월급이 높은 순으로 이름, 직업, 월급을 출력하자.(내림차순)
SELECT ENAME, JOB, SAL FROM EMP WHERE JOB='MANAGER' ORDER BY SAL DESC;

-- Q7) 사원테이블에서 각 직업별 총 월급을 출력하되 월급이 낮은 순으로 출력하자.(오름차순)
SELECT JOB, SUM(SAL) FROM EMP GROUP BY JOB ORDER BY SUM(SAL);

-- Q8) 사원테이블에서 직업별 총 월급을 출력하되, 직업이 'MANAGER'인 사원들은 제외하고, 총 월급이 5000보다 큰 직업만 출력하자.
SELECT JOB, SUM(SAL) FROM EMP WHERE JOB != 'MANAGER' GROUP BY JOB HAVING SUM(SAL)>5000;

-- Q9) 사원테이블에서 직업별 최대 월급을 출력하되, 직업이 'CLERK' 인 사원들은 제외하고, 총 월급이 2000 이상인 직업과 최대월급을 오름차순으로 정렬하여 출력하자.
SELECT JOB, MAX(SAL) FROM EMP WHERE JOB != 'CLERK' GROUP BY JOB HAVING MAX(SAL) >= 2000 ORDER BY MAX(SAL);

-- Q10) 사원테이블에서 부서별 총 월급을 출력하되, 30번 부서를 제외하고, 총 월급이 8000 이상인 부서를 총 월급이 높은 순으로 출력하자.(내림차순)
SELECT DEPTNO, SUM(SAL) FROM EMP WHERE DEPTNO != 30 GROUP BY DEPTNO HAVING SUM(SAL)>=8000 ORDER BY SUM(SAL) DESC;

-- 11) 사원테이블에서 부서별 평균 월급을 출력하되, 커미션이 책정된 사원만 구하고, 평균 월급이 1000 달러 이상인 부서만 구하고, 평균 월급이 높은 순으로 출력하자.(내림차순)
SELECT DEPTNO, AVG(SAL) FROM EMP WHERE COMM IS NOT NULL GROUP BY DEPTNO HAVING AVG(SAL)>=1000 ORDER BY AVG(SAL) DESC;
