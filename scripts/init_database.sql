/*

=================================================================================
Create Database and Schemas
=================================================================================

Script Purpose:
This script creates a new database named 'Datawarehouse' after checking
If the database exists, it is dropped and recreated. Additionally,
within the database: 'bronze', 'silver', and 'gold'.

WARNING:
Running this script will drop the entire 'Datawarehouse' database
All data in the database will be permanently deleted. Proceed with
and ensure you have proper backups before running this script.

*/

USE master;
GO

--Drop & recreate the 'DataWarehouse' database
IF EXISTS (Select 1 from sys.databases where name = 'DataWarehouse' )
BEGIN
	ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE; -- SINGLE_USER allows one connection; ROLLBACK IMMEDIATE disconnects other sessions and rolls back uncommitted transactions.
	DROP DATABASE DataWarehouse;
END;
GO

--Create the 'DataWarehouse' database
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

--Create Schemas for the 3 layers of the Medallion Data Warehouse Architechture

CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
