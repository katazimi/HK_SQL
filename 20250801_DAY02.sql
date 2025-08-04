-- 2025.08.01 MARIADB_DAY02

USE sqlDB;

-- 테이블 확인용
SELCET * FROM buyTbl; 
SELCET * FROM userTbl;

-- WHERE 조건절
SELECT * FROM userTbl WHERE name='김경호';

-- 관계연산자 =, <, >, <>, !=, not, or, and
SELECT userID, name FROM userTbl WHERE birthYear>=1970 AND height>=182;
SELECT userID, name FROM userTbl WHERE birthYear>=1970 OR height>=182;

-- BETWEEN
SELECT name, height FROM userTbl WHERE height>=180 AND height<=183;
SELECT name, height FROM userTbl WHERE height BETWEEN 180 AND 183;

-- 지역이 경남, 전남, 경북인 사람의 정보 조회
SELECT name, addr FROM userTbl WHERE addr = '경남' OR addr = '전남' OR addr = '경북';
SELECT name, addr FROM userTbl WHERE addr IN ('경남','전남','경북');

-- LIKE 연산자 
SELECT name, addr FROM userTbl WHERE addr LIKE '경_';
SELECT name, height FROM userTbl WHERE name LIKE '김%';
SELECT name, height FROM userTbl WHERE name LIKE '_종신';


-- 연습문제-1 ------------------------------------------------------------------------------------------
USE scott;
-- Q1) 사원테이블에서 사원번호가 '7844' 인 사원의 사원번호, 이름, 월급을 출력하자.
SELECT EMPNO, ENAME, SAL FROM EMP WHERE EMPNO = 7844;
-- Q2) 사원테이블에서 'SMITH'의 사원번호, 이름, 월급을 출력하자.
SELECT EMPNO, ENAME, SAL FROM EMP WHERE ENAME = 'SMITH';
-- Q3) 사원테이블에서 입사일이 1980년 12월 17일인 사원의 모든 데이터를 출력하자.
SELECT * FROM EMP WHERE HIREDATE = '1980-12-17';
-- Q4) 1980년도에서 1982년도 사이에 입사한 사원의 이름과 입사일을 출력하자.
SELECT ENAME, HIREDATE FROM EMP WHERE HIREDATE BETWEEN '1980-01-01' AND '1982-12-31';
-- Q5) 월급이 2000 이하인 사원의 이름과 월급을 출력하자.
SELECT ENAME, SAL FROM EMP WHERE SAL <= 2000;
-- Q6) 월급이 1000에서 2000 사이인 사원의 이름과 월급을 출력하자.
SELECT ENAME, SAL FROM EMP WHERE SAL BETWEEN 1000 AND 2000;
-- Q7) 사원번호가 7369, 7499, 7521인 사원들의 이름과 월급을 출력하자.
SELECT ENAME, SAL FROM EMP WHERE EMPNO IN(7369,7499,7521);


-- 서브쿼리 : 쿼리 내부에 쿼리를 작성
SELECT name, height FROM userTbl WHERE height > 177;
SELECT name, height FROM userTbl WHERE height > (SELECT height FROM userTbl WHERE name = '김경호');

SELECT name, height FROM userTbl WHERE height>ALL(SELECT height FROM userTbl WHERE addr='경남');
SELECT name, height FROM userTbl WHERE height IN (SELECT height FROM userTbl WHERE addr='경남');

-- 인라인 뷰로 활용
SELECT * FROM (SELECT userID, price FROM buyTbl) AS a;


-- 연습문제-2
-- 01. 부서번호가 10번인 사원들과 
-- 같은 월급을 받는 사원의 이름과 월급을 출력하자.
SELECT ENAME, SAL FROM EMP WHERE SAL IN (SELECT SAL FROM EMP WHERE DEPTNO = 10);

-- 02. 직업이 'CLERK'인 사원과 같은 부서에서 근무하는 사원의 
-- 이름과 월급, 부서번호를 출력하자.
SELECT ENAME, SAL, DEPTNO FROM EMP WHERE DEPTNO IN (SELECT DEPTNO FROM EMP WHERE JOB = 'CLERK');

-- 03. 'CHICAGO'에서 근무하는 사원들과 같은 부서에서 근무하는 
-- 사원의 이름과 월급을 출력하자.
SELECT ENAME, SAL FROM EMP WHERE DEPTNO IN (SELECT DEPTNO FROM DEPT WHERE LOC = 'CHICAGO');

-- 04. 부하직원이 있는 사원의 사원번호와 이름을 출력하자. 
-- 자기 자신이 다른 사원의 관리자인 사원)
SELECT EMPNO, ENAME FROM EMP WHERE EMPNO IN (SELECT MGR FROM EMP WHERE MGR IS NOT NULL);

-- 05. 부하직원이 없는 사원의 사원번호와 이름을 출력하자.
SELECT EMPNO, ENAME FROM EMP WHERE EMPNO != ALL (SELECT DISTINCT NVL(MGR,0) FROM EMP);

-- 06. 'KING'에게 보고하는 사원의 이름과 월급을 출력하자. 
-- (관리자가 'KING'인 사원)
SELECT ENAME, SAL FROM EMP WHERE MGR = (SELECT EMPNO FROM EMP WHERE ENAME = 'KING');

-- 07. 20번 부서의 사원 중 가장 많은 월급을 받는 사원보다 
-- 더 많은 월급을 받는 사원들의 이름과 월급을 출력하자.
SELECT ENAME, SAL FROM EMP WHERE SAL > (SELECT MAX(SAL) FROM EMP WHERE DEPTNO = 20);

-- 08. 직업이 'SALESMAN' 인 사원중 가장 큰 월급을 받는 사원보다 
-- 더 많은 월급을 받는 사원들의 이름과 월급을 출력하자.
-- 단, MAX함수를 사용하지 말자.(ANY, ALL 연산자)
SELECT ENAME, SAL FROM EMP WHERE SAL > ALL (SELECT SAL FROM EMP WHERE JOB = 'SALESMAN');


-- 문제-3
-- 01. 'SMITH'보다 월급을 많이 받는 사원들의 
-- 이름과 월급을 출력하자.
SELECT ENAME, SAL FROM EMP WHERE SAL > (SELECT SAL FROM EMP WHERE ENAME = 'SMITH');

-- 02. 10번 부서의 사원들과 같은 월급을 받는 사원들의 
-- 이름, 월급, 부서번호를 출력하자.
SELECT ENAME, SAL, DEPTNO FROM EMP WHERE SAL IN (SELECT SAL FROM EMP WHERE DEPTNO = 10);

-- 03. 'BLAKE'가 근무하는 부서의 위치(LOC)를 출력하자.
SELECT LOC FROM DEPT WHERE DEPTNO = (SELECT DEPTNO FROM EMP WHERE ENAME = 'BLAKE');

-- 04. 총 사원의 평균월급보다 더 많은 월급을 받는 사원들의 사원번호, 이름, 월급을 출력하되, 월급이 높은 사람 순으로 출력하자.
SELECT EMPNO, ENAME, SAL FROM EMP WHERE SAL > (SELECT AVG(SAL) FROM EMP) ORDER BY SAL DESC;


-- 05. 이름에 'T'를 포함하고 있는 사원들의 이름을 출력하자.
SELECT ENAME FROM EMP WHERE ENAME LIKE '%T%';

-- 06. 20번 부서에 있는 사원들 중 
-- 가장 많은 월급을 받는 사원보다 
-- 많은 월급을 받는 사원들의 이름, 부서번호, 월급을 출력하자.
SELECT ENAME, DEPTNO, SAL FROM EMP WHERE SAL > ALL (SELECT SAL FROM EMP WHERE DEPTNO = 20);

-- 07. 'DALLAS'에서 근무하고 있는 사원과 
-- 같은 부서에서 일하는 사원의 이름, 부서번호, 직업을 출력하자.
SELECT ENAME, DEPTNO, JOB FROM EMP WHERE DEPTNO = (SELECT DEPTNO FROM DEPT WHERE LOC = 'DALLAS');


-- 08. 이름에 'S'가 들어가는 사원과 동일한 부서에서 근무하는 사원 중, 
-- 자신의 급여가 평균 급여보다 많은 사원들의 
-- 사원번호, 이름, 급여를 출력하자.
SELECT EMPNO, ENAME, SAL FROM EMP WHERE DEPTNO IN (SELECT DEPTNO FROM EMP WHERE ENAME LIKE '%S%');

-- 09. 사원번호가 7369 인 사원과 같은 직업이고, 
-- 월급이 7876보다 많은 사원의 
-- 이름과 직업을 출력하자.
SELECT ENAME, JOB FROM EMP WHERE JOB = (SELECT JOB FROM EMP WHERE EMPNO = 7369) AND SAL > (SELECT SAL FROM EMP WHERE EMPNO = 7876);










