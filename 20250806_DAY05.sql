-- 2025.08.06 MARIADB_DAY05

-- 윈도우 함수
-- 순위 함수
SELECT ROW_NUMBER() OVER(ORDER BY height DESC) '키큰순위', NAME, addr, height FROM userTbl;
SELECT ROW_NUMBER() OVER(PARTITION BY addr ORDER BY height DESC, NAME ASC) '키큰순위', NAME, addr, height FROM userTbl;
SELECT DENSE_RANK() OVER(ORDER BY height DESC) '키큰 순위', NAME, addr, height FROM userTbl;
SELECT RANK() OVER(ORDER BY height DESC) '키큰 순위', NAME, addr, height FROM userTbl;

SELECT NTILE(4) OVER(ORDER BY height DESC) '키큰순위', NAME, addr, height FROM userTbl;

-- PIVOT
CREATE TABLE pivotTest (uname CHAR(3), season CHAR(2), amount INT);
INSERT INTO pivotTest VALUES('김범수','겨울',10),('윤종신','여름',15),('김범수','가을',25),('김범수','봄',3),('김범수','봄',37),('윤종신','겨울',40),('김범수','여름',14),('김범수','겨울',22),('윤종신','여름',64);
SELECT * FROM pivotTest;

SELECT uname, SUM(IF(season='봄',amount,0)) AS '봄', 
			  SUM(IF(season='여름',amount,0)) AS '여름', 
			  SUM(IF(season='가을',amount,0)) AS '가을', 
			    SUM(IF(season='겨울',amount,0)) AS '겨울',
			    SUM(amount) AS '합계' FROM pivotTest GROUP BY uname;
			    
-- JSON DATA
SELECT JSON_OBJECT('name',NAME,'height',height) AS 'JSON 값' FROM userTbl WHERE height >= 180;

-- 연습문제1
-- 1.사원 테이블에서 각 사원에 급여(SAL)가 높은 순서대로 상위 5명을 아래 예제처럼 출력하세요?
SELECT * FROM (SELECT ROW_NUMBER() OVER(ORDER BY SAL DESC) AS 급여순위, EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO FROM EMP) AS RANK
WHERE 급여순위 < 6;

-- 2. 사원 테이블에서 각 사원에 급여(SAL)가 높은 순서대로 순위를 부여 했을 때 6등~10등인 사람을 순위대로 아래 예제처럼 출력하세요?
SELECT * FROM (SELECT ROW_NUMBER() OVER(ORDER BY SAL DESC) AS 급여순위, EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO FROM EMP) AS RANK
WHERE 급여순위 BETWEEN 6 AND 10;

-- 3.SALGRADE 테이블 데이터 세로 정보를 가로로 아래 예제처럼 출력하세요?
SELECT MAX(IF(GRADE = 1,CONCAT(LOSAL,'~',HISAL),null)) AS 'GRADE_1',
	   MAX(IF(GRADE=2,CONCAT(LOSAL,'~',HISAL),null)) AS 'GRADE_2',
	    MAX(IF(GRADE=3, CONCAT(LOSAL,'~',HISAL),null)) AS 'GRADE_3',
	    MAX(IF(GRADE=4, CONCAT(LOSAL,'~',HISAL),null)) AS 'GRADE_4',
	    MAX(IF (GRADE=5, CONCAT(LOSAL,'~',HISAL),null)) AS 'GRADE_5' FROM SALGRADE;
	    
SELECT MAX(CASE WHEN GRADE = 1 THEN CONCAT(LOSAL,'~',HISAL) END) AS 'GRADE_1',
	   MAX(CASE WHEN GRADE = 2 THEN CONCAT(LOSAL,'~',HISAL) END) AS 'GRADE_2',
	   MAX(CASE WHEN GRADE = 3 THEN CONCAT(LOSAL,'~',HISAL) END) AS 'GRADE_3',
	   MAX(CASE WHEN GRADE = 4 THEN CONCAT(LOSAL,'~',HISAL) END) AS 'GRADE_4',
	   MAX(CASE WHEN GRADE = 5 THEN CONCAT(LOSAL,'~',HISAL) END) AS 'GRADE_5'
FROM SALGRADE;
-- 4. 사원 테이블에서 직업이 ‘SALESMAN’ 사원 중에 급여(SAL) 낮은 순서대로 순위(RANK)를 아래 예제처럼 출력하세요?
SELECT * FROM (SELECT ENAME,SAL, ROW_NUMBER() OVER(ORDER BY SAL ASC) AS RANK FROM EMP WHERE JOB = 'SALESMAN') AS RANK;

-- 5.사원 테이블에서 직업이 ‘SALESMAN’ 사원 중에 급여(SAL) 낮은 순서대로 순위(RANK)를 아래 예제처럼 출력하세요?
SELECT * FROM (SELECT ENAME,SAL, RANK() OVER(ORDER BY SAL ASC) AS RANK FROM EMP WHERE JOB = 'SALESMAN') AS RANK;

-- 6.사원 테이블에서 직업이 ‘SALESMAN’ 사원 중에 급여(SAL) 낮은 순서대로 순위(RANK)를 아래 예제처럼 출력하세요?
SELECT * FROM (SELECT ENAME,SAL, DENSE_RANK() OVER(ORDER BY SAL ASC) AS RANK FROM EMP WHERE JOB = 'SALESMAN') AS RANK;

-- 조인
SELECT u.userID, name, prodName, addr, amount FROM buyTbl b JOIN userTbl u ON b.userID = u.userID WHERE b.userID = 'JYP';

SELECT u.userID, name, prodName, addr, amount FROM buyTbl b, userTbl u WHERE b.userID = u.userID  AND b.userID = 'JYP';

SELECT DISTINCT u.userID, name, addr, CONCAT(mobile1, mobile2) FROM buyTbl b INNER JOIN userTbl u ON b.userID = u.userID ORDER BY u.userID;

CREATE TABLE stdTBL (stdNAME VARCHAR(10) NOT NULL PRIMARY KEY, addr CHAR(4) NOT NULL);
CREATE TABLE clubTBL (clubName VARCHAR(10) NOT NULL PRIMARY KEY, roomNo CHAR(4) NOT NULL);
CREATE TABLE stdclubTBL (num INT AUTO_INCREMENT NOT NULL PRIMARY KEY, stdName VARCHAR(10) NOT NULL, clubName VARCHAR(10) NOT NULL, FOREIGN KEY(stdName) REFERENCES stdTBL(stdNAME), FOREIGN KEY(clubName) REFERENCES clubTBL(clubName));

INSERT INTO stdTBL VALUES(N'김범수',N'경남'),(N'성식경',N'서울'),(N'조용필',N'경기'),(N'은지원',N'경북'),(N'바비킴',N'서울');
INSERT INTO clubTBL VALUES(N'수영',N'101호'),(N'바둑',N'102호'),(N'축구',N'103호'),(N'봉사',N'104호');
INSERT INTO stdclubTBL VALUES(NULL,N'김범수',N'바둑'),(NULL,N'김범수',N'축구'),(NULL,N'조용필',N'축구'),(NULL,N'은지원',N'축구'),(NULL,N'은지원',N'봉사'),(NULL,N'바비킴',N'봉사');

SELECT S.stdNAME, S.addr, C.clubName FROM stdTBL S JOIN stdclubTBL SC ON S.stdNAME = SC.stdName INNER JOIN clubTBL C ON SC.clubName = C.clubName ORDER BY S.stdNAME;

SELECT C.clubName, C.roomNo, S.stdNAME, S.addr FROM stdTBL S INNER JOIN stdclubTBL SC ON SC.stdName = S.stdNAME 
INNER JOIN clubTBL C ON SC.clubName = C.clubName ORDER BY C.clubName;

-- 외부조인
SELECT u.userID, u.name, b.prodName, u.addr FROM userTBL u LEFT OUTER JOIN buyTBL b ON u.userID = b.userID;

SELECT C.clubName, C.roomNo, S.stdNAME, S.addr FROM stdTBL S LEFT OUTER JOIN stdclubTBL SC ON SC.stdName = S.stdNAME LEFT OUTER JOIN clubTBL C ON SC.clubName = C.clubName ORDER BY C.clubName;

SELECT C.clubName, C.roomNo, S.stdNAME, S.addr FROM stdTBL S LEFT OUTER JOIN stdclubTBL SC ON SC.stdName = S.stdNAME RIGHT OUTER JOIN clubTBL C ON SC.clubName = C.clubName ;

SELECT S.stdNAME, S.addr, C.clubName, C.roomNo FROM stdTBL S LEFT OUTER JOIN stdclubTBL SC ON SC.stdName = S.stdNAME LEFT OUTER JOIN clubTBL C ON SC.clubName = C.clubName UNION SELECT S.stdNAME, S.addr, C.clubName, C.roomNo FROM stdTBL S LEFT OUTER JOIN stdclubTBL SC ON SC.stdName = S.stdNAME RIGHT OUTER JOIN clubTBL C ON SC.clubName = C.clubName;

-- 연습문제2
-- Q1) 사원테이블과 부서테이블에서 사원들의 이름, 부서번호, 부서이름을 출력하자.
SELECT E.ENAME, E.DEPTNO, D.DNAME FROM EMP E JOIN DEPT D ON E.DEPTNO = D.DEPTNO;

-- Q2) 사원테이블과 부서테이블에서 'DALLAS'에서 근무하는 사원의 이름, 직위, 부서번호, 부서이름을 출력하자.
SELECT E.ENAME, E.JOB ,E.DEPTNO, D.DNAME FROM EMP E JOIN DEPT D ON E.DEPTNO = D.DEPTNO WHERE D.LOC = 'DALLAS';

-- Q3) 사원테이블과 부서테이블에서 이름에 'A'가 들어가는 사원들의 이름과 부서이름을 출력하자.
SELECT E.ENAME, D.DNAME FROM EMP E JOIN DEPT D ON E.DEPTNO = D.DEPTNO WHERE E.ENAME LIKE '%A%';

-- Q4) 사원테이블과 부서테이블에서 사원이름과 그 사원이 속한 부서의 부서명, 월급을 출력하자. 단 월급이 3000 이상인 사원들을 출력하자.
SELECT E.ENAME, D.DNAME, E.SAL FROM EMP E JOIN DEPT D ON E.DEPTNO = D.DEPTNO WHERE E.SAL >= 3000;

-- Q5) 사원테이블과 부서테이블에서 직업이 'SALESMAN'인 사원들의 직업과 사원이름, 속한 부서이름을 출력하자.
SELECT E.JOB, E.ENAME, D.DNAME FROM EMP E JOIN DEPT D ON E.DEPTNO = D.DEPTNO WHERE E.JOB = 'SALESMAN';

-- Q6) 사원테이블과 급여테이블(SALGRADE)에서 커미션이 책정된 사원들의 사원번호, 이름, 연봉, 연봉+커미션, 급여등급을 출력하자. 단, 각각의 컬럼명을 '사원번호', '사원이름', '연봉', '실급여', '급여등급'으로 출력하자.
SELECT E.EMPNO AS '사원번호', E.ENAME AS '사원이름', E.SAL AS '연봉', E.SAL+NVL(E.COMM,0) AS '실급여', S.GRADE AS '급여등급' FROM EMP E JOIN SALGRADE S ON E.SAL BETWEEN S.LOSAL AND S.HISAL;

-- Q7) 사원테이블과 부서테이블, 급여테이블에서 부서번호가 10번인 사원들의 부서번호, 부서이름, 사원이름, 월급, 급여등급을 출력하자.
SELECT E.DEPTNO, D.DNAME, E.ENAME, E.SAL, S.GRADE FROM EMP E JOIN DEPT D ON E.DEPTNO = D.DEPTNO JOIN SALGRADE S ON E.SAL BETWEEN S.LOSAL AND S.HISAL WHERE E.DEPTNO = 10;

-- Q8) 사원테이블과 부서테이블, 급여테이블에서 부서번호가 10번이거나 20번인 사원들의 부서번호, 부서이름, 사원이름, 월급, 급여등급을 출력하자. 단, 부서번호가 낮은 순으로(오름차순), 월급이 높은 순으로(내림차순) 출력하자.
SELECT E.DEPTNO, D.DNAME, E.ENAME, E.SAL, S.GRADE FROM EMP E JOIN DEPT D ON E.DEPTNO = D.DEPTNO JOIN SALGRADE S ON E.SAL BETWEEN S.LOSAL AND S.HISAL WHERE E.DEPTNO = 10 OR E.DEPTNO = 20 ORDER BY SAL DESC;

-- Q9) 사원테이블에서 사원번호와 사원이름, 그리고 그 사원을 관리하는 관리자의 사원번호와 사원이름을 출력하자 단, 각각의 컬렴명을 '사원번호', '사원이름', '관리자번호', '관리자이름'으로 출력하자.
SELECT E1.EMPNO AS '사원번호', E1.ENAME AS '사원이름', E2.EMPNO AS '관리자번호', E2.ENAME AS '관리자이름'  FROM EMP E1 JOIN EMP E2 ON E1.MGR = E2.EMPNO;

-- Q10) 사원테이블과 부서테이블에서 해당 부서의 모든 사원에 대한 부서이름, 위치, 사원 수 및 평균 급여를 출력하자.
-- 단, 각각의 컬럼명을 DNAME, LOC, NUMBER OF PEOPLE, SALARY 로 출력하자.
SELECT D.DNAME AS 'DNAME', D.LOC AS 'LOC', COUNT(*) AS 'NUMBER OF PEOPLE', AVG(E.SAL) AS 'SALARY' FROM EMP E JOIN DEPT D ON E.DEPTNO = D.DEPTNO GROUP BY D.DNAME;












