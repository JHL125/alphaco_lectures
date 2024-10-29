use classicmodels;
CREATE TABLE sales
SELECT
    productLine,
    YEAR(orderDate) orderYear,
    SUM(quantityOrdered * priceEach) orderValue
FROM
    orderDetails
        INNER JOIN
    orders USING (orderNumber)
        INNER JOIN
    products USING (productCode)
GROUP BY
    productLine ,
    YEAR(orderDate);

select *from sales;

-- group by
-- rollup 메서드

select 
	productLine
    , sum(ordervalue) as 값
from sales
group by 1
;

select sum(ordervalue) as 총합 from sales;
SELECT NULL, sum(ordervalue) as 총합 from sales;

-- UNION ALL
select 
	productLine
    , sum(ordervalue) as 값
from sales
group by 1
UNION ALL
SELECT 
	NULL, 
    sum(ordervalue) as 총합 
from sales;

-- ROLLUP : GROUPING 함수
SELECT PRODUCTLINE
    , sum(ordervalue) as 값
from sales
group by PRODUCTLINE WITH ROLLUP
;

SELECT 
	ORDERYEAR,
    PRODUCTLINE
    , sum(ordervalue) as 값
from sales
GROUP BY 
	ORDERYEAR
    , PRODUCTLINE
WITH ROLLUP
;

-- SELF JOIN
-- 출력 : 매니저, 보고대상자
SELECT *FROM EMPLOYEES;

select 
	concat(m.lastname, ',', m.firstname) as 직원
    ,concat(e.lastname, ',', e.firstname) as 보고대상자
from 
	employees e
INNER JOIN employees m
	ON e.employeenumber = m.reportsTO
order by 1
;