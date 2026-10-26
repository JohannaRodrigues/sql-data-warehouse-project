/*
===============================================================================================================
Quality Checks
===============================================================================================================
Script Purpose:
  This script performs various quality checks for data consistency, accuracy,
  and standardization across the 'silver' schemas. It includes checks for:
  - Null or duplicate primary keys.
  - Unwanted spaces in string fields.
  - Data standardization and consistency.
  - Invalid date ranges and orders.
  - Data consistency between related fields.

Usage Notes:
  - Run these checks after data loading in the Silver Layer.
  - Investigate and resolve any discrepancies found during the checks.
*/

--Check for Nulls or Duplicates in Primary Key
--Expectation: No Result
SELECT
cst_id,
COUNT(*) AS total_count
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL; -- displays even if 1 null primary exists

-- =======================================================================
-- Checking 'silver.crm_cust_info'
-- =======================================================================

--Check for Unwanted Spaces to Improve Data Consistency
--Expectation : No Results
SELECT
cst_firstname -- unwanted spaces exists
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)
--Similarly check for other cols - cst_lastname, cst_marital_status, cst_gndr

--Data Normalization/Standardization & Consistency
SELECT DISTINCT cst_gndr 
FROM silver.crm_cust_info

SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info

-- =======================================================================
-- Checking 'silver.crm_prd_info'
-- =======================================================================

--Check for Nulls or Duplicates in Primary Key
--Expectation: No Result
SELECT
prd_id,
COUNT(*) AS total_count -- also displays NULL values if exist
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL; -- displays even if 1 null primary key

--Check for Unwanted Spaces to Improve Data Consistency
--Expectation : No Results
SELECT
prd_nm -- no unwanted spaces exists
FROM silver.crm_prd_info
where prd_nm != TRIM(prd_nm)

--Check for Nulls or Negative Numbers
SELECT
prd_cost
FROM silver.crm_prd_info
WHERE prd_cost IS NULL OR prd_cost < 0

--Data Normalization/Standardization & Consistency
SELECT DISTINCT prd_line
FROM silver.crm_prd_info

-- Check for Invalid Date Orders
SELECT
*
FROM silver.crm_prd_info
WHERE prd_start_dt > prd_end_dt

--For complex Transformations in SQL, we'll narrow it down to a specific example and brainstorm multiple solution approaches (Working performed in Excel)

-- Solution
--SELECT
--prd_id,
--prd_key,
--prd_nm,
--prd_start_dt,
--DATEADD(day, -1, LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)) AS prd_end_dt
--FROM silver.crm_prd_info
--WHERE prd_key IN ('AC-HE-HL-U509-R', 'AC-HE-HL-U509')

-- =======================================================================
-- Checking 'silver.crm_sales_details'
-- =======================================================================

SELECT
sls_ord_num -- unwanted spaces exists
FROM silver.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num)

-- Check for Invalid Dates : Negative Numbers or Zeros can't be cast to a date
--Result : Even if no result is found, we'll apply the CASE statements to avoid future issues
SELECT
NULLIF(sls_order_dt,0) as sls_order_dt
FROM silver.crm_sales_details
WHERE sls_order_dt <= 0 
OR LEN(sls_order_dt) !=8
OR sls_order_dt > 20500101 -- Data Cleansing : Outlier Detection
OR sls_order_dt < 19000101

SELECT
NULLIF(sls_ship_dt,0) as sls_ship_dt
FROM silver.crm_sales_details
WHERE sls_ship_dt <= 0 
OR LEN(sls_ship_dt) !=8
OR sls_ship_dt > 20500101 
OR sls_ship_dt < 19000101

SELECT
NULLIF(sls_due_dt,0) as sls_due_dt
FROM silver.crm_sales_details
WHERE sls_due_dt <= 0 
OR LEN(sls_due_dt) !=8
OR sls_due_dt > 20500101 
OR sls_due_dt < 19000101

--Check for Invalid Date Orders
SELECT
*
from silver.crm_sales_details
where sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

--Check for Data Consistency : Btw Sales, Quantity & Price
--Rules :
-->> Sales = Qty x Price
-->> Values must not be NULL, zero or negative
-->> If Sales is negative, zero, null, sales != qty x price derive it using Quantity x Price
-->> If Price is negative, zero or null, calculate it using Sales & Quantity

SELECT
sls_sales,
sls_quantity,
sls_price
--CASE 
--	WHEN sls_sales <= 0 OR sls_sales IS NULL OR sls_sales != ABS(sls_price) * sls_quantity THEN ABS(sls_price) * sls_quantity
--	ELSE sls_sales
--END AS sls_sales,
--CASE 
--	WHEN sls_price <= 0 OR sls_price IS NULL THEN sls_sales / NULLIF(sls_quantity,0)
--	ELSE sls_price
--END AS sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_price * sls_quantity
OR sls_sales <= 0 OR sls_sales IS NULL
OR sls_price <= 0 OR sls_price IS NULL
OR sls_quantity <= 0 OR sls_quantity IS NULL
ORDER BY sls_sales, sls_quantity, sls_price

-- =======================================================================
-- Checking 'silver.erp_cust_az12'
-- =======================================================================

--Identify Out of Range Dates (Old Customers)
SELECT DISTINCT
bdate
FROM silver.erp_cust_az12
WHERE  bdate < '1924-01-01' 
	OR bdate > GETDATE(); -- Data Cleansing : Outlier Detection
-- bdate > GETDATE() multiple cases , so either we consider this 'bad data' and leave it as-is or we apply some transformations like replacing it with 'NULL'

--Data Standardisation & Consistency
SELECT DISTINCT 
gen
FROM silver.erp_cust_az12;

-- =======================================================================
-- Checking 'silver.erp_loc_a101'
-- =======================================================================

-- Data Normalisation & Consistency
SELECT DISTINCT
cntry
FROM silver.erp_loc_a101
ORDER BY cntry;

-- =======================================================================
-- Checking 'silver.erp_px_cat_g1v2'
-- =======================================================================

--Check for Unwanted Spaces
--Expectations : No Results
SELECT
*
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat)
   OR subcat != TRIM(subcat)
   OR maintenance != TRIM(maintenance);

-- Data Normalisation & Consistency
SELECT DISTINCT
cat
FROM silver.erp_px_cat_g1v2;
--Similaryly, check for subcat & maintenance
