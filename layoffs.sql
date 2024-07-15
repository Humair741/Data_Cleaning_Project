-- Data Cleaning

SELECT 
    *
FROM
    layoffs;
    
-- 1. Remove Duplicates
-- 2. Standardize Data 
-- 3. Null Values or Blank values
-- 4. Remove any Columns or Rows

CREATE TABLE layoffs_staging LIKE layoffs;

SELECT 
    *
FROM
    layoffs_staging;

insert layoffs_staging
select *
from layoffs;



SELECT *,
ROW_NUMBER() OVER
				(Partition BY 
					company, 
                    industry, 
                    total_laid_off, 
                    percentage_laid_off, 
                    `date`) AS row_num
FROM layoffs_staging;



WITH duplicate_cte AS 
(
	SELECT *,
	ROW_NUMBER() OVER
				(Partition BY 
					company, 
                    industry, 
                    total_laid_off, 
                    percentage_laid_off, 
                    `date`) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;



CREATE TABLE `layoffs_staging2` (
    `company` TEXT,
    `location` TEXT,
    `industry` TEXT,
    `total_laid_off` INT DEFAULT NULL,
    `percentage_laid_off` TEXT,
    `date` TEXT,
    `stage` TEXT,
    `country` TEXT,
    `funds_raised_millions` INT DEFAULT NULL,
    `row_num` INT
)  ENGINE=INNODB DEFAULT CHARSET=UTF8MB4 COLLATE = UTF8MB4_0900_AI_CI;



SELECT 
    *
FROM
    layoffs_staging2
WHERE
    row_num > 1;



INSERT INTO layoffs_staging2
SELECT *,
	ROW_NUMBER() OVER
				(Partition BY 
					company, 
                    industry, 
                    total_laid_off, 
                    percentage_laid_off, 
                    `date`) AS row_num
FROM layoffs_staging;
    
    
    
DELETE FROM layoffs_staging2 
WHERE
    row_num > 1;



-- Standardizing data

SELECT 
    company, TRIM(company)
FROM
    layoffs_staging2;
    
UPDATE layoffs_staging2 
SET 
    company = TRIM(company);

SELECT DISTINCT
    industry
FROM
    layoffs_staging2
;

UPDATE layoffs_staging2 
SET 
    industry = 'Crypto'
WHERE
    industry LIKE 'Crypto%';


SELECT 
    country
FROM
    layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2 
SET 
    country = TRIM(TRAILING '.' FROM country)
WHERE
    country LIKE 'United States%';


SELECT 
    `date`
FROM
    layoffs_staging2;

UPDATE layoffs_staging2 
SET 
    `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT 
    *
FROM
    layoffs_staging2
WHERE
    total_laid_off IS NULL
        AND percentage_laid_off IS NULL;
   
UPDATE layoffs_staging2 
SET 
    industry = NULL
WHERE
    industry = '';
   
SELECT 
    *
FROM
    layoffs_staging2
WHERE
    industry IS NULL OR industry = '';
    
SELECT 
    *
FROM
    layoffs_staging2 t1
        JOIN
    layoffs_staging2 t2 ON t1.company = t2.company
        AND t1.location = t2.location
WHERE
    (t1.industry IS NULL OR t1.industry = '')
        AND t2.industry IS NOT NULL;
        

UPDATE layoffs_staging2 t1
        JOIN
    layoffs_staging2 t2 ON t1.company = t2.company 
SET 
    t1.industry = t2.industry
WHERE
    (t1.industry IS NULL OR t1.industry = '')
        AND t2.industry IS NOT NULL;

DELETE FROM layoffs_staging2 
WHERE
    total_laid_off IS NULL
    AND percentage_laid_off IS NULL;

SELECT 
    *
FROM
    layoffs_staging2
WHERE
    total_laid_off IS NULL
        AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

