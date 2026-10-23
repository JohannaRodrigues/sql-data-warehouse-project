/*
=================================================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
=================================================================================================
Script Purpose:
  This stored procedure loads data into the 'bronze' schema from external CSV files. It performs the following actions:
  - Truncates the bronze tables before loading data.
  - Uses the BULK INSERT command to load data from csv Files to bronze tables.

Parameters: I
  None.
  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;
================================================================================================
*/

--Create Stored Procedure for repetitive tasks
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME; -- declare varialbes to be used later in the function
	BEGIN TRY
		SET @batch_start_time = GETDATE();

		PRINT '==================================================================================';
		PRINT 'lOADING BRONZE LAYER';
		PRINT '==================================================================================';

		PRINT '----------------------------------------------------------------------------------';
		PRINT 'LOADING CRM TABLES';
		PRINT '----------------------------------------------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table : bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info;
	
		--Using 'BULK INSERT' to quickly load data from .csv files(source systems) into DWH's Bronze Layer(data staging) 
		PRINT '>> Inserting Data Into : bronze.crm_cust_info';
		BULK INSERT bronze.crm_cust_info
		FROM  'C:\Users\Johanna\Documents\SQL Server Management Studio 22\Learning_SQL\sql-data-warehouse-project\01_datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK -- locks entire table while loading it for better perf. instead of smaller-granularity locks(e.g. row/page locks)
		); -- how to handle our file
		SET @end_time = GETDATE();
		PRINT '>> Load Duration : '+ CAST (DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + 'seconds';
		PRINT '>> ------------------';

		--SELECT * FROM bronze.crm_cust_info
		--SELECT COUNT(*) FROM bronze.crm_cust_info


		SET @start_time = GETDATE();
		PRINT '>> Truncating Table : bronze.crm_prd_info';
		TRUNCATE TABLE bronze.crm_prd_info;
	
		PRINT '>> Inserting Data Into : bronze.crm_prd_info';
		BULK INSERT bronze.crm_prd_info
		FROM  'C:\Users\Johanna\Documents\SQL Server Management Studio 22\Learning_SQL\sql-data-warehouse-project\01_datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK 
		); 
		SET @end_time = GETDATE();
		PRINT '>> Load Duration : '+ CAST (DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + 'seconds';
		PRINT '>> ------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table : bronze.crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details;
		PRINT '>> Inserting Data Into : bronze.crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		FROM  'C:\Users\Johanna\Documents\SQL Server Management Studio 22\Learning_SQL\sql-data-warehouse-project\01_datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK 
		); 
		SET @end_time = GETDATE();
		PRINT '>> Load Duration : '+ CAST (DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + 'seconds';
		PRINT '>> ------------------';


		PRINT '----------------------------------------------------------------------------------';
		PRINT 'LOADING ERP TABLES';
		PRINT '----------------------------------------------------------------------------------';
	
	    SET @start_time = GETDATE();
		PRINT '>> Truncating Table : bronze.erp_cust_az12';
		TRUNCATE TABLE bronze.erp_cust_az12;
	
		PRINT '>> Inserting Data Into : bronze.erp_cust_az12';
		BULK INSERT bronze.erp_cust_az12
		FROM  'C:\Users\Johanna\Documents\SQL Server Management Studio 22\Learning_SQL\sql-data-warehouse-project\01_datasets\source_erp\CUST_AZ12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK 
		); 
		SET @end_time = GETDATE();
		PRINT '>> Load Duration : '+ CAST (DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + 'seconds';
		PRINT '>> ------------------';


		SET @start_time = GETDATE();
		PRINT '>> Truncating Table : bronze.erp_loc_a101';
		TRUNCATE TABLE bronze.erp_loc_a101;
	
		PRINT '>> Inserting Data Into : bronze.erp_loc_a101';
		BULK INSERT bronze.erp_loc_a101
		FROM  'C:\Users\Johanna\Documents\SQL Server Management Studio 22\Learning_SQL\sql-data-warehouse-project\01_datasets\source_erp\LOC_A101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK 
		); 
		SET @end_time = GETDATE();
		PRINT '>> Load Duration : '+ CAST (DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + 'seconds';
		PRINT '>> ------------------';


		SET @start_time = GETDATE();
		PRINT '>> Truncating Table : bronze.erp_px_cat_g1v2';
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;
	
		PRINT '>> Inserting Data Into : bronze.erp_px_cat_g1v2';
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM  'C:\Users\Johanna\Documents\SQL Server Management Studio 22\Learning_SQL\sql-data-warehouse-project\01_datasets\source_erp\PX_CAT_G1V2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK 
		); 
		SET @end_time = GETDATE();
		PRINT '>> Load Duration : '+ CAST (DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + 'seconds';
		PRINT '>> ------------------';


		SET @batch_end_time = GETDATE();
		PRINT '=======================================================================================';
		PRINT 'Loading Bronze Layer is Completed';
		PRINT '	- Total Load Duration: '+ CAST (DATEDIFF(second, @batch_start_time, @batch_end_time) AS VARCHAR) + 'seconds';
		PRINT '=======================================================================================';

	END TRY

	BEGIN CATCH -- executed only if TRY block fails to handle the error
		PRINT '==============================================================================';
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
		PRINT 'Error Message: ' + ERROR_MESSAGE();
		PRINT 'Error Message: ' + CAST(ERROR_NUMBER() AS VARCHAR);
		PRINT 'Error Message: ' + CAST(ERROR_STATE() AS VARCHAR);
		PRINT '==============================================================================';
	END CATCH
END
