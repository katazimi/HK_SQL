-- 2025.07.31 Day01

-- Q1) 사원 테이블(EMP)의 모든 데이터를 출력하자.
SELECT * FROM EMP;
-- Q2) 사원 테이블에서 사원의 이름(ENAME), 사원의 번호(EMPNO), 월급(SAL)을 출력하자.
SELECT ENAME, EMPNO, SAL FROM EMP;
-- Q3) 사원 테이블에서 사원의 이름과 연봉을 출력하자.
SELECT ENAME, SAL FROM EMP;
-- Q4) 사원의 이름, 입사일(HIREDATE), 부서번호(DEPTNO)를 출력하자.
SELECT ENAME, HIREDATE, DEPTNO FROM EMP;
-- Q5) 사원의 이름과, 사원을 관리하고있는 관리자(MGR)를 출력하자.
SELECT ENAME, MGR FROM EMP;
-- Q6) 부서 테이블(DEPT)의 모든 데이터를 출력하자.
SELECT * FROM DEPT;
-- Q7) 부서 테이블의 구조를 보자
DESC DEPT;
-- Q8) 사원 테이블에서 사원의 이름, 월급, 커미션(COMM)을 출력하자.
SELECT ENAME, SAL, COMM FROM EMP;
-- Q9) 사원 테이블의 모든 데이터를 "OO님이 0000-00-00에 입사를 하고 OO의 월급을 받습니다." 형식인 하나의 컬럼으로 출력하자.
SELECT CONCAT(ENAME, '님이 ', HIREDATE, '에 입사를 하고 ', SAL, '의 월급을 받습니다.') FROM EMP;