-- 1
use classicmodels;
select * from customers;

select state
		,city
from customers
where state is not null
group by 1,2
order by 1;
;

-- 2
select*from orders;
select*from orderdetails;

select b.orderDate as 연도별
	,count(a.ordernumber) 구매자수
    ,sum(quantityOrdered*priceEach) 매출액
    
-- 3
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
    
-- 4
use classicmodels;
SELECT 
	customernumber
    , mx_order
    , '2005-06-01'
    , DATEDIFF('2005-06-01', mx_order) AS DIFF
FROM (
	SELECT 
		customernumber
		, MAX(orderdate) mx_order
	FROM 
		orders
	GROUP BY 1
) A
;

SELECT 
	CASE WHEN DIFF >= 90 THEN "이탈고객" 
           ELSE "비이탈고객" 
	END AS 이탈유무
    , COUNT(DISTINCT customernumber) AS 명수
FROM (
	SELECT 
		customernumber
		, mx_order
		, '2005-06-01'
		, DATEDIFF('2005-06-01', mx_order) AS DIFF
	FROM (
		SELECT 
			customernumber
			, MAX(orderdate) mx_order
		FROM 
			orders
		GROUP BY 1
	) A
) A
GROUP BY 1
order by 2 desc
;

-- 5
CREATE TABLE classicmodels.stat AS
SELECT 
	C.country
    , SUM(B.priceEach * B.quantityOrdered) AS sales
FROM 
	orders A
LEFT JOIN orderdetails B
	ON A.ordernumber = B.ordernumber
LEFT JOIN customers C 
	ON A.customerNumber = C.customerNumber
GROUP BY 1
ORDER BY 2 DESC
;

select*From stat;

SELECT 
	country 
    , SALES
    , DENSE_RANK() OVER(ORDER BY SALES desc) RNK
FROM stat
limit 5
;

-- 6
use titanic;
SELECT 
	FLOOR(AGE/10) * 10 AS AGEBAND
    , SEX AS SEX
    , COUNT(PassengerId) AS N_PASSENGERS
    , SUM(SURVIVED) AS N_SURVIVED
    , SUM(SURVIVED) / COUNT(PassengerId) AS SURVIVED_RATE
FROM titanic
where sex = 'female'
GROUP BY 1, 2
;

-- 7
USE dataset2;
SELECT * FROM dataset2;
SELECT `DEPARTMENT NAME`
		,`Clothing ID`
        ,AVG(RATING) AVG_RATE
		,DENSE_RANK() OVER(ORDER BY AVG_RATE DESC) RNK 
FROM (SELECT AVG(RATING) AVG_RATE
		FROM 
	dataset2)
WHERE `DEPARTMENT NAME` = 'BOTTOMS'
GROUP BY 2
ORDER BY 3
)
;

SELECT AVG(RATING) AVG_RATE
		FROM 
	dataset;