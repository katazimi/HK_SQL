-- 2025.08.07 MARIADB_DAY06

-- procedure 작성법
DELIMITER $$
CREATE PROCEDURE ifProc()
BEGIN 
	DECLARE var1 INT;
	SET var1 = 100;
	
	IF var1 = 100 THEN SELECT '100입니다.';
	ELSE SELECT '100이 아닙니다.';
	END IF;
END $$
DELIMITER ;

CALL ifProc();

DELIMITER $$
CREATE PROCEDURE ifProc2()
BEGIN 
	DECLARE hireDATE DATE;
	DECLARE curDATE DATE;
	DECLARE days INT;
	
	SELECT hire_date INTO hireDate FROM employees WHERE emp_no = 10001;
	
	SET curDATE = CURRENT_DATE();
	SET days = DATEDIFF(curDATE,hireDATE);
	
	IF (days/365) >= 5 THEN SELECT CONCAT('입사한지 ', days,'일이나 지났습니다. 축하합니다!'); 
	ELSE SELECT '입사한지 ' + days + '일 밖에 안되었네요. 열심히 일하세요';
	END IF;
END $$
DELIMITER ;

CALL ifProc2();

SELECT U.userID, U.name,SUM(price*amount) AS '총구매액' FROM buyTbl B RIGHT OUTER JOIN userTbl U ON B.userID=U.userID GROUP BY U.userID, U.name ORDER BY SUM(price*amount) DESC;

SELECT 
    U.userID, 
    U.name, 
    SUM(price * amount) AS '총구매액',
    CASE
        WHEN SUM(price * amount) >= 1500 THEN '최우수고객'
        WHEN SUM(price * amount) >= 1000 THEN '우수고객'
        WHEN SUM(price * amount) >= 1 THEN '일반고객'
        ELSE '유령고객'
    END AS '고객등급'
FROM buyTbl B 
RIGHT OUTER JOIN userTbl U 
    ON B.userID = U.userID 
GROUP BY U.userID, U.name 
ORDER BY SUM(price * amount) DESC;

-- 테이블과 뷰------------------------------------------------------------------------------------------------------------------
CREATE DATABASE tableDB;
CREATE TABLE userTbl (SELECT * FROM sqldb.userTbl);
CREATE TABLE buyTbl (SELECT * FROM sqldb.buyTbl);

CREATE TABLE `userTbl2` (
  `userID` char(8) NOT NULL,
  `name` varchar(10) NOT NULL,
  `birthYear` int(11) NOT NULL,
  `addr` char(2) NOT NULL,
  `mobile1` char(3) DEFAULT NULL,
  `mobile2` char(8) DEFAULT NULL,
  `height` smallint(6) DEFAULT NULL,
  `mDate` date DEFAULT NULL,
  CONSTRAINT PRIMARY KEY pk_userTbl_userID (userID),
  CONSTRAINT UNIQUE unique_userTbl_name(NAME)
); 

CREATE TABLE `buyTbl2` (
  `num` int(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
  `userID` char(8) NOT NULL,
  `prodName` char(6) NOT NULL,
  `groupName` char(4) DEFAULT NULL,
  `price` int(11) NOT NULL,
  `amount` smallint(6) NOT NULL,
  CONSTRAINT FOREIGN KEY FK_buyTbl_userID (userID) REFERENCES userTbl2(userID)
);

-- step1
CREATE TABLE `userTbl3` (
  `userID` char(8),
  `name` varchar(10),
  `birthYear` int,
  `addr` nchar(2),
  `mobile1` char(3),
  `mobile2` char(8),
  `height` smallint,
  `mDate` date
); 

CREATE TABLE `buyTbl3` (
  `num` int(11) AUTO_INCREMENT PRIMARY KEY,
  `userID` char(8),
  `prodName` nchar(6),
  `groupName` nchar(4),
  `price` int,
  `amount` smallint
);

-- step2
INSERT INTO userTbl3 VALUES('LSG',N'이승기',1987,N'서울','011','11111111',182,'2008-8-8');
INSERT INTO userTbl3 VALUES('KBS',N'김범수',NULL,N'경남','011','22222222',173,'2012-4-4');
INSERT INTO userTbl3 VALUES('KKH',N'김경호',1871,N'전남','019','33333333',177,'2007-7-7');
INSERT INTO userTbl3 VALUES('JYP',N'조용필',1950,N'경기','011','44444444',166,'2009-4-4');

INSERT INTO buyTbl3 VALUES(NULL, 'KBS', N'운동화', NULL, 30, 2);
INSERT INTO buyTbl3 VALUES(NULL, 'KBS', N'노트북', N'전자', 1000, 1);
INSERT INTO buyTbl3 VALUES(NULL, 'JYP', N'모니터', N'전자', 200, 1);
INSERT INTO buyTbl3 VALUES(NULL, 'BBK', N'모니터', N'전자', 200, 5);

-- step3
ALTER TABLE userTbl3 ADD CONSTRAINT PK_userTbl3_userID PRIMARY KEY (userID);

-- step4
ALTER TABLE buyTbl3 ADD CONSTRAINT FK_userTbl3_buyTbl3 FOREIGN KEY (userID) REFERENCES userTbl3 (userID);

-- step5
SET check_constraint_checks = 0;
ALTER TABLE userTbl3 ADD CONSTRAINT CK_birthYear CHECK ( (birthYear >= 1900 AND birthYear <= 2000) AND (birthYear IS NOT NULL) );
SET check_constraint_checks = 1;

-- step6
INSERT INTO userTbl3 VALUES('SSK',N'성시경',1979,N'서울',NULL,NULL,186,'2013-12-12');
INSERT INTO userTbl3 VALUES('LJB',N'임재범',1963,N'서울','016','66666666',182,'2009-9-9');
INSERT INTO userTbl3 VALUES('YJS',N'윤종신',1969,N'경남',NULL,NULL,170,'2005-5-5');
INSERT INTO userTbl3 VALUES('EJW',N'은지원',1972,N'경북','011','88888888',174,'2014-3-3');
INSERT INTO userTbl3 VALUES('JKW',N'조관우',1965,N'경기','018','99999999',172,'2010-10-10');
INSERT INTO userTbl3 VALUES('BBK',N'바비킴',1973,N'서울','010','00000000',176,'2013-5-5');

-- step7
UPDATE userTbl3 SET userID = 'VVK' WHERE userID='BBK';

-- step8
SELECT B.userID, U.name, B.prodName, U.addr, CONCAT(U.`mobile1`,U.`mobile2`) AS '연락처' FROM buyTbl3 B LEFT OUTER JOIN userTbl3 U ON B.userID = U.userID;


-- 연습문제
-- Q1 
SELECT E.first_name, YEAR(E.hire_date) AS hire_year, (SELECT AVG(E2.salary) FROM employees E2 WHERE YEAR(E2.hire_date) = YEAR(E.hire_date)) AS avg_salary_same_year FROM employees E JOIN jobs J ON E.job_id = J.job_id WHERE J.job_title = 'Sales Manager' GROUP BY YEAR(E.hire_date);

-- Q2
SELECT L.`city`, ROUND(AVG(E.`salary`)), COUNT(*)  FROM employees E JOIN departments D ON E.`department_id` = D.`department_id` JOIN locations L ON D.`location_id` = L.`location_id` GROUP BY L.city HAVING COUNT(*) < 10;

-- Q3
SELECT E.`employee_id`, CONCAT(e.`first_name`, ' ', e.`last_name`) FROM employees E JOIN job_history JH ON E.`employee_id` = JH.`employee_id` JOIN jobs J ON JH.`job_id` = J.`job_id` WHERE J.`job_title` = 'Public Accountant';

-- Q4
SELECT E.`employee_id`, E.`salary`, E.`manager_id`, E2.`salary` FROM employees E JOIN employees E2 ON E.`manager_id` = E2.`employee_id` WHERE E.`salary` > E2.`salary`;

-- Q5
SELECT E.`hire_date`, E.`employee_id`, E.`first_name`, E.`last_name`, NVL(D.`department_name`, '<Not Assigned>') FROM employees E LEFT OUTER JOIN departments D ON E.`department_id` = D.`department_id` WHERE YEAR(E.`hire_date`) BETWEEN 1998 AND 1999;

-- Q6
SELECT E.`first_name`, E.`last_name`, E.`salary` FROM employees E JOIN jobs J ON E.`job_id` = J.`job_id` WHERE J.`job_title` = 'Sales Representative' AND E.`salary` BETWEEN 9000 AND 10000;

-- Q7
SELECT E.`last_name`, D.`department_name`, E.`salary` FROM employees E JOIN departments D ON E.`department_id` = D.`department_id` WHERE E.`salary` IN (SELECT MIN(salary) FROM employees GROUP BY `department_id`) ORDER BY D.`department_name` , E.`last_name`;

-- Q8
SELECT * FROM (SELECT last_name, first_name, salary, RANK() OVER(ORDER BY salary DESC) AS RANK1 FROM employees) AS sub WHERE RANK1 BETWEEN 6 AND 10;

-- Q9
SELECT E.`last_name`, NVL((SELECT last_name FROM employees WHERE `employee_id` = D.`manager_id`),'<없음>'), D.`department_name` FROM employees E JOIN departments D ON E.`department_id` = D.`department_id` JOIN locations L ON D.`location_id` = L.`location_id` WHERE L.`city` = 'Seattle';

-- Q10
SELECT J.`job_title`, SUM(E.`salary`) FROM employees E JOIN jobs J ON E.`job_id` = J.`job_id` GROUP BY J.`job_id` HAVING SUM(E.`salary`) > 30000 ORDER BY SUM(E.`salary`) DESC;

-- Q11
SELECT E.`employee_id`, E.`first_name`, J.`job_title`, D.`department_name` FROM employees E JOIN jobs J ON E.`job_id` = J.`job_id` JOIN departments D ON E.`department_id` = D.`department_id` JOIN locations L ON D.`location_id` = L.`location_id` WHERE L.`city` = 'Seattle' ORDER BY E.`employee_id`;

-- Q12
SELECT E1.`first_name`, E1.`hire_date`, NVL(E1.`manager_id`, '(NULL)'), NVL(E2.`first_name`, '(NULL)') FROM employees E1 LEFT OUTER JOIN employees E2 ON E2.`employee_id` = E1.`manager_id` WHERE YEAR(E1.`hire_date`) BETWEEN 1987 AND 1995;

-- Q13
SELECT E.`first_name`, E.`salary`, D.`department_name` FROM employees E JOIN departments D ON E.`department_id` = D.`department_id` WHERE D.`department_name` = 'Sales' AND E.`salary` < (SELECT AVG(salary) FROM employees WHERE `department_id` = 100 GROUP BY `department_id`);

-- Q14
SELECT CONCAT(MONTH(`hire_date`),'월') AS 'HIRE_DATE', COUNT(*) FROM employees GROUP BY MONTH(`hire_date`);

-- Q15
SELECT D.`department_name`, MAX(E.`salary`), MIN(E.`salary`), AVG(E.`salary`) FROM employees E JOIN departments D ON E.`department_id` = D.`department_id` GROUP BY D.`department_name` HAVING AVG(E.`salary`) > (SELECT AVG(salary) FROM employees WHERE `department_id` = (SELECT `department_id` FROM departments WHERE `department_name` = 'IT')) AND AVG(E.`salary`) < (SELECT AVG(salary) FROM employees WHERE `department_id` = (SELECT `department_id` FROM departments WHERE `department_name` = 'Sales')); 

-- Q16
SELECT D.`department_name`, CASE WHEN COUNT(E.`employee_id`) != 0 THEN COUNT(E.`employee_id`) ELSE '<신생부서>' END AS '현황' FROM departments D LEFT OUTER JOIN employees E ON D.`department_id` = E.`department_id` GROUP BY D.`department_name` HAVING COUNT(E.`employee_id`) < 2 ORDER BY D.`department_name` DESC;

-- Q17
SELECT D.`department_name`, MONTH(E.`hire_date`), COUNT(*) FROM employees E JOIN departments D ON E.`department_id` = D.`department_id` GROUP BY D.`department_name`,MONTH(E.`hire_date`) ORDER BY D.`department_name` ;

-- Q18
SELECT C.`country_name`, L.`city`, COUNT(E.`employee_id`) FROM employees E JOIN departments D ON E.`department_id` = D.`department_id` JOIN locations L ON D.`location_id` = L.`location_id` JOIN countries C ON L.`country_id` = C.`country_id` GROUP BY C.`country_name`, L.`city`;

-- Q19
SELECT D.`department_name`, E.`employee_id`, E.`first_name`,MAX(E.`salary`) AS 'SALARY', (SELECT AVG(salary) FROM employees WHERE `department_id` = D.`department_id` GROUP BY `department_id`) AS 'AVG_SALARY' FROM employees E JOIN departments D ON E.`department_id` = D.`department_id` GROUP BY D.`department_name` ORDER BY E.`employee_id`;

-- Q20
SELECT NVL(TRUNCATE(commission_pct,1),'<커미션 없음>') AS 'COMMISION', COUNT(*) FROM employees GROUP BY TRUNCATE(commission_pct,1);

-- Q21
SELECT * FROM (SELECT D.`department_name`, E.`first_name`, E.`salary`, E.`commission_pct`,ROW_NUMBER() OVER(ORDER BY E.`commission_pct` DESC) AS 'RANK' FROM employees E JOIN departments D ON E.`department_id` = D.`department_id`) AS sub HAVING RANK <5;


