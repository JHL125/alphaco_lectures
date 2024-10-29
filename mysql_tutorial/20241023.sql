-- SQL 순서
-- FROM => WHERE => GROUP BY => SELECT => DISTINCT => ORDER BY

-- GROUP BY vs DISTINCT 비교
-- 테이블명 : orders 
USE classicmodels;
SELECT 
	status
FROM 
	orders
GROUP BY 
	status
;

-- DISTINCT 
SELECT 
	DISTINCT status
FROM 
	orders
;

-- GROUP BY : COUNT()
SELECT 
	status
    , COUNT(*)
FROM 
	orders
GROUP BY 
	status
;

-- 테이블명 : orderdetails
SELECT * FROM orderdetails;

SELECT 
	orderNumber
    , quantityOrdered * priceEach AS 매출액
FROM
	orderdetails
;

-- 주문번호당, 총매출액, 평균매출액을 구하세요 (~23분)
SELECT 
	orderNumber
    , SUM(quantityOrdered * priceEach) AS 총매출액
    , AVG(quantityOrdered * priceEach) AS 평균매출액
    , stddev_samp(quantityOrdered * priceEach) AS 표준편차
    , var_samp(quantityOrdered * priceEach) AS 분산
FROM
	orderdetails
GROUP BY 
	orderNumber
;

-- productCode, orderLineNumber 당 집계함수
-- 주문번호당, 총매출액, 평균매출액을 구하세요 (~23분)
SELECT 
	productCode
    , orderLineNumber
    , SUM(quantityOrdered * priceEach) AS 총매출액
    , AVG(quantityOrdered * priceEach) AS 평균매출액
    , stddev_samp(quantityOrdered * priceEach) AS 표준편차
    , var_samp(quantityOrdered * priceEach) AS 분산
FROM
	orderdetails
GROUP BY 
	productCode
    , orderLineNumber
ORDER BY
	productCode
    , orderLineNumber
;

-- HAVING
-- 순서 : FROM ==> WHERE ==> GROUP BY ==> HAVING ==> SELECT ==> ...
-- 위에 있는 코드에서 HAVING 절 추가
-- orderLineNumber에서 1만 별도로 조회
SELECT 
	productCode
    , orderLineNumber
    , SUM(quantityOrdered * priceEach) AS 총매출액
    , AVG(quantityOrdered * priceEach) AS 평균매출액
    , stddev_samp(quantityOrdered * priceEach) AS 표준편차
    , var_samp(quantityOrdered * priceEach) AS 분산
FROM
	orderdetails
GROUP BY 
	productCode
    , orderLineNumber
HAVING 
	orderLineNumber = 1 -- S10_1678 : 21889.92
    AND 총매출액 >= 10000 -- 메모 : 다른 DBMS에서는 에러 날 가능성 존재
ORDER BY
	productCode
    , orderLineNumber
;

-- 테이블명 : orderdetails
-- 출력값 
-- ordernumber 주문갯수 매출액 
-- 10100       151    10223.83 
-- 조건 : 주문갯수 700개 이상만 조회
-- 주문번호 : 10222
SELECT 
  ordernumber, 
  SUM(quantityOrdered) AS 주문갯수, 
  SUM(priceeach * quantityOrdered) AS 매출액 
FROM 
  orderdetails 
GROUP BY 
  ordernumber 
HAVING 
  주문갯수 > 700;


-- JOIN 
-- 테이블 생성
DROP TABLE members; -- 테이블 삭제하는 명령어
CREATE TABLE members(
	member_id  INT AUTO_INCREMENT
    , name VARCHAR(100)
    , PRIMARY KEY (member_id)
)
;

INSERT INTO members(name)
VALUES('A'), ('B'), ('C'), ('D'), ('E')
;

SELECT * FROM members;

CREATE TABLE committees (
    committee_id INT AUTO_INCREMENT,
    name VARCHAR(100),
    PRIMARY KEY (committee_id) -- 기본키는 중복을 허용하지 않음
);

INSERT INTO committees(name)
VALUES('A'),('B'),('C'),('F');

-- INNER JOIN 
SELECT * FROM members;
SELECT * FROM committees;

-- 문법1
/* 
SELECT *
FROM table_1
INNER JOIN table_2 USING (column_name) -- 컬럼명이 같으면 유용
*/

-- 원래는 name을 쓰면 안됨 (일반적으로 name에는 중복값이 존재)
-- 여기에서는 모두 유일값이 있으므로 임시로 사용
SELECT *
FROM members m
INNER JOIN committees c USING(name);

-- 문법2
-- 문법1과 결과가 어떻게 다른지 확인
SELECT *
FROM members m
INNER JOIN committees c ON c.committee_id = m.member_id;

-- LEFT JOIN : 문법1
SELECT *
FROM members m
LEFT JOIN committees c USING(name);

-- LEFT JOIN : 문법2
SELECT *
FROM members m
LEFT JOIN committees c ON c.name = m.name;

-- RIGHT JOIN : 문법1
SELECT *
FROM members m
RIGHT JOIN committees c USING(name);

-- RIGHT JOIN : 문법2
SELECT *
FROM members m
RIGHT JOIN committees c ON c.name = m.name;

-- NULL 값 조회
SELECT *
FROM members m
RIGHT JOIN committees c USING(name)
WHERE m.member_id IS NULL
;

-- SELECT 문법
SELECT 
	m.name AS member_name
    , c.name AS committee_name
FROM members m
RIGHT JOIN committees c ON c.name = m.name;

-- 일별 매출액 조회 
-- 테이블명 : orders, orderdetails
-- 두 테이블 조합 후, 일자별로 매출액을 산출하세용
-- 출력값
-- orderdate       priceeach*quantityordered 
-- 2003-01-06      4080.00

-- INNER JOIN
SELECT 
	orderDate
	, priceEach * quantityOrdered AS 매출액
FROM orders
INNER JOIN orderdetails USING(orderNumber)
;

-- LEFT JOIN
SELECT 
	orderDate
	, priceEach * quantityOrdered AS 매출액
FROM orders
LEFT JOIN orderdetails USING(orderNumber)
;

-- RIGHT JOIN
SELECT 
	orderDate
	, priceEach * quantityOrdered AS 매출액
FROM orders
RIGHT JOIN orderdetails USING(orderNumber)
;

-- 월별 매출액
-- 함수 : SUBSTR() 활용해서 월별 매출액 구하세요
-- 단, 형태는 orderDate 출력은 2003-04 형태로..
-- INDEX 번호가 1부터 시작
SELECT SUBSTR('Quadratically', 5);
SELECT SUBSTR('Quadratically',5,6);
-- 테스트 
SELECT 
	SUBSTR(orderdate, 1, 7) month
	, SUM(priceEach * quantityOrdered) AS 매출액
FROM orders
LEFT JOIN orderdetails USING(orderNumber)
GROUP BY SUBSTR(orderdate, 1, 7) -- 1도 가능, 1이 의미하는 것은
;

-- 문법2 
SELECT 
	SUBSTR(orderdate, 1, 7) month
	, SUM(priceEach * quantityOrdered) AS 매출액
FROM orders A
LEFT JOIN orderdetails B 
	ON A.ordernumber = B.ordernumber
GROUP BY SUBSTR(orderdate, 1, 7)
;
	
-- 연도별 매출액 조회
SELECT 
	SUBSTR(orderdate, 1, 4) year -- 연도만 추출
	, SUM(priceEach * quantityOrdered) AS 매출액
FROM orders A
LEFT JOIN orderdetails B 
	ON A.ordernumber = B.ordernumber
GROUP BY SUBSTR(orderdate, 1, 4)
;

-- YEAR() 확인 
SELECT YEAR('1987-01-01');
SELECT 
	YEAR(orderdate) year
	, DAYNAME(orderdate) Days -- 연도만 추출
	, SUM(priceEach * quantityOrdered) AS 매출액
FROM orders A
LEFT JOIN orderdetails B 
	ON A.ordernumber = B.ordernumber
GROUP BY 
	YEAR(orderdate)
    , DAYNAME(orderdate)
;

-- 지난 시간, 일별, 월별, 연도별 매출액 
-- 이번시간에는 구매건수
SELECT * FROM orders ORDER BY customernumber;
SELECT customernumber, ordernumber, orderdate
FROM orders ORDER BY customernumber;

-- 가정 : 한 명의 고객이 여러 번 구매할 수 있음 
-- 혹시나, 주문번호가 동일한 경우, 개수가 2개가 될 것을 방지하기 위해서 
-- 중복값 제거
SELECT orderdate, customernumber, ordernumber
FROM orders;

-- 개수가 동일하니깐, 다행스럽게도 중복된 주문번호는 없음
SELECT 
	COUNT(ordernumber) 주문갯수
    , COUNT(DISTINCT ordernumber) 중복확인
FROM 
	orders
;

-- 일자별 주문건수
SELECT 
	SUBSTR(orderdate, 1, 7) 월별
    , COUNT(DISTINCT customernumber) 구매자수 
    , COUNT(DISTINCT ordernumber) 주문건수
FROM 
	orders
GROUP BY 1
ORDER BY 1
;

-- 인당 매출액 구하기
-- JOIN 
-- 출력값
-- 연도별 인당 매출액
-- 출력값
-- YEAR    구매자수     매출액
-- 2003      74       3317348
SELECT 
	YEAR(orderdate) 연도별
    , COUNT(DISTINCT A.customernumber) AS 구매자수
    , SUM(priceeach * quantityordered) AS 매출액
    , SUM(priceeach * quantityordered) / COUNT(DISTINCT A.customernumber) AMV
FROM orders A
LEFT JOIN orderdetails B USING(ordernumber)
GROUP BY 1
ORDER BY 1
;

-- 국가별, 도시별 매출액
-- JOIN 2번 진행
SELECT 
	A.ordernumber
    , A.customernumber
    , B.priceeach
    , B.quantityordered
    , C.country
    , C.state
    , C.city
FROM 
	orders A 
LEFT JOIN orderdetails B
	ON A.ordernumber = B.ordernumber
LEFT JOIN customers C 
	ON A.customernumber = C.customernumber
;

-- 국가별, 도시별 총 매출액 계산
SELECT 
    C.country
    , C.city
    , SUM(B.priceeach * B.quantityordered) 매출액
FROM 
	orders A 
LEFT JOIN orderdetails B
	ON A.ordernumber = B.ordernumber
LEFT JOIN customers C 
	ON A.customernumber = C.customernumber
GROUP BY 1, 2
ORDER BY 1, 2
;

-- CASE WHEN : IF-ELSE 조건문
SELECT * FROM orderdetails;
SELECT 
	ordernumber
    , quantityOrdered
    , CASE WHEN quantityOrdered > 30 THEN "주문건수 30개 초과"
		   WHEN quantityOrdered = 30 THEN "주문건수 30개"
           ELSE "30개 미만"
	  END AS 조건문
FROM 
	orderdetails
;

-- 문제
-- customers 테이블에서  country 컬럼 사용해서 북미지역과 비북미지역으로 구분
-- 북미지역 : USA, CANADA / 그 외 나머지
-- HINT : IN 연산자를 적절하게 사용
-- country 컬럼
-- country, 구분
-- USA      북미지역

SELECT 
	country
	, CASE WHEN country IN ('USA', 'Canada') THEN "북미지역"
    ELSE "비북미지역" END AS 지역구분
FROM customers
;

-- 북미지역 매출액과 비북미지역 매출액을 구하세요!! 
-- 출력값 
-- 지역구분    매출액
-- 북미지역    3479192
-- 비북미지역  6124999

SELECT 
	CASE WHEN country IN ('USA', 'Canada') THEN "북미지역"
		ELSE "비북미지역" END AS 지역구분
    , SUM(B.priceeach * B.quantityordered) 매출액
FROM 
	orders A 
LEFT JOIN orderdetails B
	ON A.ordernumber = B.ordernumber
LEFT JOIN customers C 
	ON A.customernumber = C.customernumber
GROUP BY 1
ORDER BY 1
;

sample_df = 
	customer_df_2023.groupby(['기준년월', '연령대', '성별', '고객등급', '자택_시도', '자택_시군구'], group_keys=False).apply(lambda x: x.sample(frac=0.01))
sample_df.shape