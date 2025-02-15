[Myntra Fashion Clothing Dataset Analysis](https://github.com/Anmoljoshi19/Myntra_trend_analysis/blob/main/Myntra%20Fasion%20Clothing.zip)

**Overview**

This project contains SQL scripts for analyzing a dataset of Myntra's fashion clothing items. The dataset includes product details such as categories, brands, pricing, discounts, ratings, and reviews. The analysis aims to extract actionable insights for business growth and trend analysis.

--------------------------------------------------------------------------------------------------------------------------

**Tools Used**

MySQL – Data Cleaning, Transformation & Analysis
Power BI – For Visualizations

--------------------------------------------------------------------------------------------------------------------------

**Dataset**

This dataset contains 200,000 rows of fashion products from an e-commerce platform, Below are the key attributes in the dataset:
- Product Information (URL, Product_id, BrandName, Category, Individual_category, Description)
- Pricing Details (OriginalPrice, DiscountPrice, DiscountOffer)
- Customer Segmentation (category_by_Gender, SizeOption)
- Customer Feedback (Ratings, Reviews)

--------------------------------------------------------------------------------------------------------------------------

**Data Cleaning & Standardization**
```sql

-- Creating Table and Importing Data

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

--------------------------------------------------------------------------------------------------------------------------

-- Replacing Blank Values with NULL

UPDATE myntra_fasion_clothing 
SET 
    DiscountPrice = NULLIF(DiscountPrice, ''),
    DiscountOffer = NULLIF(DiscountOffer, ''),
    Ratings = NULLIF(Ratings, ''),
    Reviews = NULLIF(Reviews, '\r');

-- Changing Data Types

ALTER TABLE myntra_fasion_clothing
    MODIFY COLUMN DiscountPrice INT,
    MODIFY COLUMN OriginalPrice INT,
    MODIFY COLUMN Ratings INT,
    MODIFY COLUMN Reviews INT;

--------------------------------------------------------------------------------------------------------------------------

-- Filling Missing Discount Prices

-- 1. For Discount Offers in Rs.

UPDATE myntra_fasion_clothing 
SET 
    DiscountPrice = (OriginalPrice - REGEXP_SUBSTR(DiscountOffer, '[0-9]+'))
WHERE
    DiscountPrice IS NULL
    AND DiscountOffer LIKE '%Rs. %';

-- 2. For Discount Offers in Percentage

UPDATE myntra_fasion_clothing 
SET 
    DiscountPrice = (OriginalPrice - (OriginalPrice * (REGEXP_SUBSTR(DiscountOffer, '[0-9]+') / 100)))
WHERE
    DiscountPrice IS NULL
    AND DiscountOffer NOT LIKE '%Rs. %';


-- Standardizing Discount Offer Column

UPDATE myntra_fasion_clothing
SET DiscountOffer = CONCAT(ROUND(((OriginalPrice - DiscountPrice) / OriginalPrice) * 100, 0), '% OFF')
WHERE DiscountOffer LIKE '%Rs. %';

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


-- Setting Missing Discount Prices to Original Prices

UPDATE myntra_fasion_clothing
SET DiscountPrice = OriginalPrice
WHERE
    DiscountPrice IS NULL
    AND DiscountOffer IS NULL;


-- Merging Similar Categories

UPDATE myntra_fasion_clothing 
SET 
    Category = 'Inner Wear & Sleep Wear'
WHERE
    Category LIKE '%Sleep%';

```
--------------------------------------------------------------------------------------------------------------------------

-- **Trend Analysis Queries**
```sql

-- Trend Analysis Queries

-- 1. Top Performing Categories Based on Reviews

SELECT Category, COUNT(Reviews) AS Total_Reviews
FROM myntra_fasion_clothing
GROUP BY Category
ORDER BY Total_Reviews DESC;


-- 2. Top Brands Based on Reviews

SELECT 
    BrandName, COUNT(Reviews) AS Total_Reviews
FROM
    myntra_fasion_clothing
GROUP BY BrandName
ORDER BY Total_Reviews DESC
LIMIT 10;


-- 3. Most Popular Discount Ranges

SELECT 
    CASE
        WHEN LEFT(DiscountOffer, 2) < 10 THEN 'Less Than 10%'
        WHEN LEFT(DiscountOffer, 2) BETWEEN 10 AND 30 THEN '10% to 30%'
        WHEN LEFT(DiscountOffer, 2) BETWEEN 31 AND 50 THEN '31% to 50%'
        WHEN LEFT(DiscountOffer, 2) BETWEEN 51 AND 70 THEN '51% to 70%'
        ELSE 'Above 70%'
    END AS Discount_range,
    COUNT(Reviews) AS Total_Reviews
FROM
    myntra_fasion_clothing
GROUP BY Discount_range
ORDER BY Total_Reviews DESC;


-- 4. Gender-Based Product Trends (Top 10 per Gender)

SELECT category_by_Gender, Individual_category, total_reviews
FROM (
    SELECT 
        category_by_Gender, 
        Individual_category, 
        COUNT(Reviews) AS total_reviews,
        ROW_NUMBER() OVER (PARTITION BY category_by_Gender ORDER BY COUNT(Reviews) DESC) AS `rank`
    FROM myntra_fasion_clothing
    GROUP BY category_by_Gender, Individual_category
) AS Ranked
WHERE `rank` <= 10;


-- 5. Average Rating Per Category

SELECT 
    Category, ROUND(AVG(Ratings), 1) AS Avg_Rating
FROM myntra_fasion_clothing
GROUP BY Category
ORDER BY Avg_Rating DESC;


-- 6. Top-Rated Brands

SELECT 
    BrandName,
    ROUND(AVG(Ratings), 1) AS Avg_Rating,
    SUM(Reviews) AS Total_Reviews
FROM
    myntra_fasion_clothing
GROUP BY BrandName
ORDER BY Total_Reviews DESC, Avg_Rating DESC
LIMIT 10;


-- 7. Most Reviewed Products

SELECT 
    Product_id, Description, BrandName, Category, Reviews
FROM
    myntra_fasion_clothing
ORDER BY Reviews DESC
LIMIT 10;

```
[SQL-code-Myntra-Fashion-Clothing-Dataset-Analysis](https://github.com/Anmoljoshi19/Myntra_trend_analysis/blob/main/myntra_fasion_clothing.sql)

--------------------------------------------------------------------------------------------------------------------------

**Conclusion**

The dataset provides valuable insights into customer preferences, top-performing categories, and pricing trends in the fashion e-commerce industry. It enables businesses to optimize inventory, refine pricing strategies, and target gender-specific trends effectively. Leveraging these insights can drive growth, improve customer satisfaction, and enhance market competitiveness.

[Dashboard]()
[Dashboard_file]()
