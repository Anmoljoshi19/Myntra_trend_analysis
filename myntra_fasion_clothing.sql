-- Creating table and importing data, creating backup(table)

CREATE TABLE myntra_fasion_clothing (
    URL VARCHAR(255),
    Product_id INT,
    BrandName VARCHAR(100),
    Category VARCHAR(100),
    Individual_category VARCHAR(100),
    category_by_Gender VARCHAR(50),
    `Description` TEXT,
    DiscountPrice TEXT,
    OriginalPrice TEXT,
    DiscountOffer VARCHAR(50),
    SizeOption TEXT,
    Ratings TEXT,
    Reviews TEXT
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Myntra Fasion Clothing.csv'
INTO TABLE myntra_fasion_clothing
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- replacing blanck values with null so that we can change it's type

UPDATE myntra_fasion_clothing 
SET 
    DiscountPrice = NULLIF(DiscountPrice, ''),
    DiscountOffer = NULLIF(DiscountOffer, ''),
    Ratings = NULLIF(Ratings, ''),
    reviews = NULLIF(DiscountPrice, '');
  
-- changing type

ALTER TABLE myntra_fasion_clothing
    MODIFY COLUMN DiscountPrice INT,
    MODIFY COLUMN OriginalPrice INT,
    MODIFY COLUMN Ratings INT,
    MODIFY COLUMN Reviews INT;

-- filling discount price

SELECT 
    DiscountPrice
FROM
    myntra_fasion_clothing
WHERE
    DiscountPrice IS NULL;

SELECT 
    OriginalPrice,
    DiscountOffer,
    DiscountPrice,
    REGEXP_SUBSTR(DiscountOffer, '[0-9]+') AS discount_text,
    (OriginalPrice - REGEXP_SUBSTR(DiscountOffer, '[0-9]+')) AS new_discount_price_rs
FROM
    myntra_fasion_clothing
WHERE
    DiscountPrice IS NULL
        AND DiscountOffer LIKE '%Rs. %';
        
UPDATE myntra_fasion_clothing 
SET 
    DiscountPrice = (OriginalPrice - REGEXP_SUBSTR(DiscountOffer, '[0-9]+'))
WHERE
    DiscountPrice IS NULL
        AND DiscountOffer LIKE '%Rs. %';
        
-------------------------------

select OriginalPrice,DiscountOffer, DiscountPrice from myntra_fasion_clothing
where DiscountPrice is null
and DiscountOffer not like '%Rs. %';

SELECT 
    OriginalPrice,
    DiscountOffer,
    DiscountPrice,
    REGEXP_SUBSTR(DiscountOffer, '[0-9]+') AS discount_text,
    (OriginalPrice - (OriginalPrice * (REGEXP_SUBSTR(DiscountOffer, '[0-9]+') / 100))) AS new_discount_price
FROM
    myntra_fasion_clothing
WHERE
    DiscountPrice IS NULL
        AND DiscountOffer NOT LIKE '%Rs. %';
 
UPDATE myntra_fasion_clothing 
SET 
    DiscountPrice = (OriginalPrice - (OriginalPrice * (REGEXP_SUBSTR(DiscountOffer, '[0-9]+') / 100)))
WHERE
    DiscountPrice IS NULL
        AND DiscountOffer NOT LIKE '%Rs. %';

----------------------------------------------------- 
-- standardizing discount offer column

update myntra_fasion_clothing
set DiscountOffer = concat(round(((OriginalPrice-DiscountPrice)/OriginalPrice)*100,0),'% OFF')
where DiscountOffer like '%Rs. %';

UPDATE myntra_fasion_clothing 
SET 
    DiscountOffer = CONCAT(TRIM(LEFT(DiscountOffer, 3)), '% OFF')
WHERE
    DiscountOffer LIKE '% % OFF';

UPDATE myntra_fasion_clothing 
SET 
    DiscountOffer = CONCAT(TRIM(LEFT(DiscountOffer, 2)), '% OFF')
WHERE
    DiscountOffer LIKE '%Hurry%';

--------------------------------------------------------------------

update myntra_fasion_clothing
set DiscountPrice = OriginalPrice
WHERE
    DiscountPrice IS NULL
        AND DiscountOffer is null;
        
        
--------------------------------------------------------------------------------------------------------------------------
        
  -- both 'Lingerie & Sleep Wear' and 'Inner Wear &  Sleep Wear' have common items in the, (ex. Briefs), so merging these 2 categories 
  
  select distinct(Category), Individual_category
from myntra_fasion_clothing
where Category like '%Sleep%';

UPDATE myntra_fasion_clothing 
SET 
    Category = 'Inner Wear &  Sleep Wear'
WHERE
    Category LIKE '%Sleep%';


-------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------

-- Trend analysis

-- 1. Top Performing category and top brands based on reviews

SELECT Category, COUNT(Reviews) AS Total_Reviews
FROM myntra_fasion_clothing
GROUP BY Category
ORDER BY Total_Reviews DEsc;

SELECT 
    BrandName, COUNT(Reviews) AS Total_Reviews
FROM
    myntra_fasion_clothing
GROUP BY BrandName
ORDER BY Total_Reviews DESC
LIMIT 10;

-- 2. Most popular discount range

SELECT 
    CASE
        WHEN LEFT(DiscountOffer, 2) < 10 THEN 'Less Than 10%'
        WHEN LEFT(DiscountOffer, 2) BETWEEN 10 AND 30 THEN '10% to 30%'
        WHEN LEFT(DiscountOffer, 2) BETWEEN 31 AND 50 THEN '31% to 50%'
        WHEN LEFT(DiscountOffer, 2) BETWEEN 51 AND 70 THEN '51% to 70%'
        ELSE 'Above 70%'
    END AS Discount_range,
    COUNT(reviews) AS total_reviews
FROM
    myntra_fasion_clothing
GROUP BY Discount_range
ORDER BY total_reviews DESC;

-- 3. Gender based Product Trends (Top 10)

select category_by_Gender, Individual_category , total_reviews from  (select category_by_Gender , Individual_category, count(reviews) as total_reviews,
 ROW_NUMBER() OVER (PARTITION BY category_by_Gender ORDER BY COUNT(reviews) desc) AS `rank`
from myntra_fasion_clothing
group by category_by_Gender, Individual_category
order by category_by_Gender,total_reviews desc) as aa
where `rank` <= 10;

-- 4. Avg rating as per category

SELECT 
    category, ROUND(AVG(ratings), 1) AS avg_rating
FROM
    myntra_fasion_clothing
GROUP BY category
ORDER BY avg_rating DESC;

-- 5. Top rated brands

SELECT 
    BrandName,
    ROUND(AVG(ratings), 1) AS avg_rating,
    SUM(Reviews) AS Total_Reviews
FROM
    myntra_fasion_clothing
GROUP BY BrandName
ORDER BY Total_Reviews DESC , avg_rating DESC
LIMIT 10;

-- 6. most reviewed product 

SELECT 
    Product_id, Description, BrandName, Category, Reviews
FROM
    myntra_fasion_clothing
ORDER BY Reviews DESC
LIMIT 10;




