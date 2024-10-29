USE titanic;
SELECT * FROM titanic;

-- 중복값 확인
SELECT 
	COUNT(PassengerId) 승객수
	, COUNT(DISTINCT PassengerId) 중복승객수확인
FROM titanic
;

-- 성별에 따른 승객수와 생존자수 구하세요 
-- Column 확인 : 생존여부, 0 = 사망, 1 = 생존
SELECT * FROM titanic;

-- 출력값
SELECT 
	sex AS 성별
    , COUNT(PassengerId) AS 승객수
    , SUM(SURVIVED) AS 생존자수
FROM titanic
GROUP BY 1
;

-- 성별탑승객수와 생존자수의 비중 구하기
-- 성별에 따른 생존율 구하기
SELECT 
	sex AS 성별
    , COUNT(PassengerId) AS 승객수
    , SUM(SURVIVED) AS 생존자수
    , ROUND(SUM(SURVIVED) / COUNT(PassengerId), 3) AS 생존율
FROM titanic
GROUP BY 1
;

-- 연령에 따른 생존율 살펴보기
SELECT age FROM titanic;

-- SQL에서 연령대로 범주화
-- CASE WHEN 
-- 0~10세 ==> 0대
-- 11~20세 ==> 10대
SELECT FLOOR(21/10) * 10;
SELECT FLOOR(AGE/10) * 10 AGEBAND, AGE FROM titanic;

-- 연령별 승객수, 생존자수, 생존율
SELECT 
	FLOOR(AGE/10) * 10 AGEBAND
    , COUNT(PassengerId) AS 승객수
    , SUM(SURVIVED) AS 생존자수
    , ROUND(SUM(SURVIVED) / COUNT(PassengerId), 3) AS 생존율
FROM titanic
GROUP BY 1
ORDER BY 1
;

-- 연령별, 성별 승객수, 생존자수, 생존율
SELECT 
	FLOOR(AGE/10) * 10 AS 연령대
    , SEX AS 성별
    , COUNT(PassengerId) AS 승객수
    , SUM(SURVIVED) AS 생존자수
    , ROUND(SUM(SURVIVED) / COUNT(PassengerId), 3) AS 생존율
FROM titanic
GROUP BY 1, 2
ORDER BY 2, 1
;

-- 원하는 테이블
-- 연령대     남성생존율      여성생존율       생존율차이
-- 0         0.594         0.633          여성생존율 - 남성생존율 = 0.03

SELECT 
    A.연령대
    , A.생존율 AS 남성생존율
    , B.생존율 AS 여성생존율
    , B.생존율 - A.생존율 AS 생존율차이
FROM (
    SELECT 
        FLOOR(AGE/10) * 10 AS 연령대
        , SEX AS 성별
        , COUNT(PassengerId) AS 승객수
        , SUM(SURVIVED) AS 생존자수
        , ROUND(SUM(SURVIVED) / COUNT(PassengerId), 3) AS 생존율
    FROM titanic
    GROUP BY 1, 2
    HAVING SEX = 'male'
) A 
LEFT JOIN (
    SELECT 
        FLOOR(AGE/10) * 10 AS 연령대
        , SEX AS 성별
        , COUNT(PassengerId) AS 승객수
        , SUM(SURVIVED) AS 생존자수
        , ROUND(SUM(SURVIVED) / COUNT(PassengerId), 3) AS 생존율
    FROM titanic
    GROUP BY 1, 2
    HAVING SEX = 'female'
) B
ON A.연령대 = B.연령대
ORDER BY 1
;

-- 연령대 성별에 따른 생존율이 다른 이유는 무엇인가?
-- 분석 : 질적인 측면, 양적인 측면을 동시에 고려
-- 주어진 데이터에서는 더 이상의 분석은 불가
-- 다른 해상사고 찾아서 결과 확인 후 교차 검증 진행 
-- 역으로 다시 분석 및 추정

-- 객실 등급별로 승객 수, 생존자 수, 생존율 계산 
-- pclass
SELECT 
	pclass AS 객실등급
    , COUNT(PassengerId) AS 승객수
    , SUM(SURVIVED) AS 생존자수
    , ROUND(SUM(SURVIVED) / COUNT(PassengerId), 3) AS 생존율
FROM titanic
GROUP BY 1
ORDER BY 1
;

-- 객실등급 & 성별
SELECT 
	pclass AS 객실등급
    , sex AS 성별
    , COUNT(PassengerId) AS 승객수
    , SUM(SURVIVED) AS 생존자수
    , ROUND(SUM(SURVIVED) / COUNT(PassengerId), 3) AS 생존율
FROM titanic
GROUP BY 1, 2
ORDER BY 2, 1
;

-- 객실등급 & 성별 & 연령병
SELECT 
	pclass AS 객실등급
    , sex AS 성별
    , FLOOR(AGE/10) * 10 AS 연령대
    , COUNT(PassengerId) AS 승객수
    , SUM(SURVIVED) AS 생존자수
    , ROUND(SUM(SURVIVED) / COUNT(PassengerId), 3) AS 생존율
FROM titanic
GROUP BY 1, 2, 3
ORDER BY 2, 1
;

-- 결론 : 유아일수록 생존율이 높음, 
--       모든 객실 등급 등급에서 남성보다는 여성의 생존율이 높음

-- 탑승객 분석
-- 출발지, 도착지별 승객 수
SELECT * FROM titanic;

-- Boarded : 출발지
-- Destination : 목적지
-- 출발지-목적지별 승객 수 
SELECT 
	boarded 
    , destination
    , COUNT(PassengerId) 승객수 
FROM 
	titanic
GROUP BY 1, 2
ORDER BY 3 DESC
;

-- 상위 5개 경로를 추출할 때, 추출할 때, 탑승객 수로 순위를 매기기 
-- ROW_NUMBER() OVER
SELECT * 
FROM (
    SELECT 
        *
        , ROW_NUMBER() OVER(ORDER BY N_PASSENGERS DESC) RNK
    FROM (
            SELECT 
                BOARDED
                , DESTINATION
                , COUNT(PASSENGERID) N_PASSENGERS
            FROM titanic
            GROUP BY BOARDED, DESTINATION
    ) BASE
) BASE
WHERE RNK BETWEEN 1 AND 5
;

-- Hometown별 탑승객 수 생존율
SELECT * FROM titanic;
SELECT SUM(1);              -- 결과 1
SELECT SUM(1) FROM titanic; -- 결과 714

-- USE etc;
-- SELECT SUM(1) FROM sales; -- 결과 9
-- SUM(1)은 테이블의 행의 갯수를 구함
USE titanic; -- 데이터베이스 변경 

-- 승객수가 10명 이상이면서 생존율 0.5 이상인 HOMETOWN 출력
SELECT 
	HOMETOWN
    , SUM(1) 승객수
    , SUM(SURVIVED) / SUM(1) 생존율
FROM 
	titanic
GROUP BY 1
HAVING SUM(SURVIVED) / SUM(1) >= 0.5
	AND SUM(1) >= 10
;

-- 정규표현식 예제
-- 내용:
-- 문자와 기호:
-- .: 임의의 단일 문자
-- ^: 문자열의 시작
-- $: 문자열의 끝
-- *: 0개 이상의 반복
-- +: 1개 이상의 반복
-- ?: 0개 또는 1개의 반복
-- |: 논리적 OR
-- []: 범위 또는 문자 클래스
-- (): 그룹화

USE etc;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20)
);

-- 샘플 데이터 삽입

INSERT INTO users (username, email, phone) VALUES
('john.doe', 'john.doe@example.com', '123-456-7890'),
('jane_smith', 'jane.smith@example.net', '555-1234'),
('alice99', 'alice123@wonderland.com', '987-654-3210'),
('bob-builder', 'bob.builder@construction.org', '321-654-0987'),
('charlie.brown', 'charlie.brown@example.com', '555-9876');

SELECT * FROM users;
-- 1. 임의의 단일 문자 .
-- 문제 : username 컬럼에서 임의의 한 문자(t)가 있는 이름 찾아서 조회
SELECT * FROM users WHERE username REGEXP '.t';

-- 2. 문자열의 시작 : ^
-- 'a'로 시작하는 사용자 이름 찾는 쿼리
SELECT * FROM users WHERE username REGEXP '^ja';
SELECT * FROM users WHERE username REGEXP '^j';
SELECT * FROM users WHERE username REGEXP '^a';

-- 3. 문자열의 끝 : $
-- 'm'으로 끝나는 이메일을 찾는 쿼리
SELECT * FROM users WHERE email REGEXP 'm$';

-- 4. * : 0개 이상의 반복
SELECT * FROM users WHERE username REGEXP 'do.*';

-- 5. + : 1개 이상의 반복
-- 숫자를 하나 이상 포함하는 사용자 이름 찾기
SELECT * FROM users WHERE username REGEXP '[0-9]+';
SELECT * FROM users WHERE username REGEXP '[:digit:]+';

-- 6. 알파벳 소문자 'a'에서 'e'사이의 문자로 시작하는 사용자 이름 
SELECT * FROM users WHERE username REGEXP '^[a-e]';
SELECT * FROM users WHERE username REGEXP '^..[a-e]';

-- 리뷰 데이터 
USE dataset2;
SELECT * FROM dataset2;

SELECT `Review Text` FROM dataset2;

-- Department별 평균 평점 구하기
SELECT 
	`DEPARTMENT NAME`
    , AVG(RATING) AVG_RATE
FROM 
	dataset2
GROUP BY 1
ORDER BY 2 DESC
;

-- DIVISION NAME별 평균 평점 구하기
SELECT 
	`DIVISION NAME`
    , AVG(RATING) AVG_RATE
FROM 
	dataset2
GROUP BY 1
ORDER BY 2 DESC
;

-- TREND의 평점 3이하 조회 
SELECT * 
FROM 
	dataset2
WHERE `Department Name` = 'Trend'
	AND RATING <= 3
;

-- Trend의 평점 3점 이하 연령 분포 조회
-- AGE 활용 (타이타닉 통해서 이미 확인)
-- 출력값 
-- 연령대 명수
SELECT 
	FLOOR(AGE/10) * 10 연령대 
    , COUNT(*) 명수
FROM 
	dataset2
WHERE `Department Name` = 'Trend'
	AND RATING <= 3
GROUP BY 1
ORDER BY 1 
;

-- Department별 연령별 리뷰 수
SELECT 
	FLOOR(AGE/10) * 10 연령대 
    , COUNT(*) 명수
FROM 
	dataset2
WHERE `Department Name` = 'Trend'
GROUP BY 1
ORDER BY 1
;

-- 조건
-- 연령대 : 50대 Between 50 AND 59
-- 평점 : 3점 이하 
-- Department Name : Trend
SELECT 
	title
    , `Review Text`
FROM dataset2
WHERE `Department name` = 'TREND'
	AND RATING <= 3
    AND AGE BETWEEN 50 AND 59
;


-- Size Complain에 대해 조사 디테일하게 해봅시다!
-- 결론 : SQL에서 더 디테일하게 조사 불가
-- NLP or 텍스트 마이닝 ==> 딥러닝, 생성형 AI 활용해서 별도로 조사 
-- 간단한 집계 정도는 SQL에서 할 수 있지 않을까? 
-- 집계 TRUE / FALSE 

SELECT 
	`REVIEW TEXT`
    , CASE WHEN `REVIEW TEXT` LIKE '%SIZE%' THEN 1 ELSE 0 
      END SIZE_YN -- 리뷰 내용에서 SIZE가 있으면 1, 없으면 0으로 출력
FROM 
	dataset2
;

-- 전체 리뷰 개수 중에서 SIZE에 관한 리뷰는 몇%인지 계산 
-- 코드로 구현할 필요는 없고, 각각 개수 구하고 어림잡아서 판단하세요
SELECT 
	SUM(CASE WHEN `REVIEW TEXT` LIKE '%SIZE%' THEN 1 ELSE 0 END) AS SIZE_전체리뷰갯수
	, SUM(1) AS 전체리뷰갯수
FROM 
	dataset2
;


-- LARGE
-- SMALL
-- TIGHT
-- LOOSE 
SELECT 
	SUM(CASE WHEN `REVIEW TEXT` LIKE '%SIZE%' THEN 1 ELSE 0 END) AS SIZE_전체리뷰갯수
    , SUM(CASE WHEN `REVIEW TEXT` LIKE '%LARGE%' THEN 1 ELSE 0 END) AS LARGE_전체리뷰갯수
    , SUM(CASE WHEN `REVIEW TEXT` LIKE '%SMALL%' THEN 1 ELSE 0 END) AS SMALL_전체리뷰갯수
    , SUM(CASE WHEN `REVIEW TEXT` LIKE '%TIGHT%' THEN 1 ELSE 0 END) AS TIGHT_전체리뷰갯수
    , SUM(CASE WHEN `REVIEW TEXT` LIKE '%LOOSE%' THEN 1 ELSE 0 END) AS LOOSE_전체리뷰갯수
	, SUM(1) AS 전체리뷰갯수
FROM 
	dataset2
;

-- department name별로 집계
SELECT
	`department name`
	, SUM(CASE WHEN `REVIEW TEXT` LIKE '%SIZE%' THEN 1 ELSE 0 END) AS SIZE_전체리뷰갯수
    , SUM(CASE WHEN `REVIEW TEXT` LIKE '%LARGE%' THEN 1 ELSE 0 END) AS LARGE_전체리뷰갯수
    , SUM(CASE WHEN `REVIEW TEXT` LIKE '%SMALL%' THEN 1 ELSE 0 END) AS SMALL_전체리뷰갯수
    , SUM(CASE WHEN `REVIEW TEXT` LIKE '%TIGHT%' THEN 1 ELSE 0 END) AS TIGHT_전체리뷰갯수
    , SUM(CASE WHEN `REVIEW TEXT` LIKE '%LOOSE%' THEN 1 ELSE 0 END) AS LOOSE_전체리뷰갯수
	, SUM(1) AS 전체리뷰갯수
FROM 
	dataset2
GROUP BY 1
;

-- 연령대별로 집계
SELECT
	FLOOR(AGE/10) * 10 연령대 
	, SUM(CASE WHEN `REVIEW TEXT` LIKE '%SIZE%' THEN 1 ELSE 0 END) AS SIZE_전체리뷰갯수
    , SUM(CASE WHEN `REVIEW TEXT` LIKE '%LARGE%' THEN 1 ELSE 0 END) AS LARGE_전체리뷰갯수
    , SUM(CASE WHEN `REVIEW TEXT` LIKE '%SMALL%' THEN 1 ELSE 0 END) AS SMALL_전체리뷰갯수
    , SUM(CASE WHEN `REVIEW TEXT` LIKE '%TIGHT%' THEN 1 ELSE 0 END) AS TIGHT_전체리뷰갯수
    , SUM(CASE WHEN `REVIEW TEXT` LIKE '%LOOSE%' THEN 1 ELSE 0 END) AS LOOSE_전체리뷰갯수
	, SUM(1) AS 전체리뷰갯수
FROM 
	dataset2
GROUP BY 1
ORDER BY 1
;
-- department name, 연령대별로 집계
SELECT
	`department name`
	, FLOOR(AGE/10) * 10 연령대 
	, SUM(CASE WHEN `REVIEW TEXT` LIKE '%SIZE%' THEN 1 ELSE 0 END) AS SIZE_전체리뷰갯수
    , SUM(CASE WHEN `REVIEW TEXT` LIKE '%LARGE%' THEN 1 ELSE 0 END) AS LARGE_전체리뷰갯수
    , SUM(CASE WHEN `REVIEW TEXT` LIKE '%SMALL%' THEN 1 ELSE 0 END) AS SMALL_전체리뷰갯수
    , SUM(CASE WHEN `REVIEW TEXT` LIKE '%TIGHT%' THEN 1 ELSE 0 END) AS TIGHT_전체리뷰갯수
    , SUM(CASE WHEN `REVIEW TEXT` LIKE '%LOOSE%' THEN 1 ELSE 0 END) AS LOOSE_전체리뷰갯수
	, SUM(1) AS 전체리뷰갯수
FROM 
	dataset2
GROUP BY 1, 2
ORDER BY 2, 1
;
-- 각각의 비율 구할 수 있음 
SELECT
	`department name`
	, FLOOR(AGE/10) * 10 연령대 
	, SUM(CASE WHEN `REVIEW TEXT` LIKE '%SIZE%' THEN 1 ELSE 0 END) / SUM(1) AS SIZE_전체리뷰갯수
    , SUM(CASE WHEN `REVIEW TEXT` LIKE '%LARGE%' THEN 1 ELSE 0 END) / SUM(1) AS LARGE_전체리뷰갯수
    , SUM(CASE WHEN `REVIEW TEXT` LIKE '%SMALL%' THEN 1 ELSE 0 END) / SUM(1) AS SMALL_전체리뷰갯수
    , SUM(CASE WHEN `REVIEW TEXT` LIKE '%TIGHT%' THEN 1 ELSE 0 END) / SUM(1) AS TIGHT_전체리뷰갯수
    , SUM(CASE WHEN `REVIEW TEXT` LIKE '%LOOSE%' THEN 1 ELSE 0 END) / SUM(1) AS LOOSE_전체리뷰갯수
	, SUM(1) AS 전체리뷰갯수
FROM 
	dataset2
GROUP BY 1, 2
ORDER BY 2, 1
;
-- SUM (case when ~~~ ) / SUM(1) 
SELECT * FROM dataset2;
SELECT
	`department name`
	, FLOOR(AGE/10) * 10 연령대 
    , Rating
	, SUM(CASE WHEN `REVIEW TEXT` LIKE '%SIZE%' THEN 1 ELSE 0 END) / SUM(1) AS SIZE_전체리뷰갯수
    , SUM(CASE WHEN `REVIEW TEXT` LIKE '%LARGE%' THEN 1 ELSE 0 END) / SUM(1) AS LARGE_전체리뷰갯수
    , SUM(CASE WHEN `REVIEW TEXT` LIKE '%SMALL%' THEN 1 ELSE 0 END) / SUM(1) AS SMALL_전체리뷰갯수
    , SUM(CASE WHEN `REVIEW TEXT` LIKE '%TIGHT%' THEN 1 ELSE 0 END) / SUM(1) AS TIGHT_전체리뷰갯수
    , SUM(CASE WHEN `REVIEW TEXT` LIKE '%LOOSE%' THEN 1 ELSE 0 END) / SUM(1) AS LOOSE_전체리뷰갯수
	, SUM(1) AS 전체리뷰갯수
FROM 
	dataset2
GROUP BY 1, 2, 3
ORDER BY 2, 1, 3 DESC
;