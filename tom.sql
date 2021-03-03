USE INFO430_Proj_10
GO

---------------------------------------------------------------------------------------------------
-- Create Tables
---------------------------------------------------------------------------------------------------
CREATE TABLE tblCUSTOMER_TYPE (
	CustomerTypeID INT IDENTITY(1,1) PRIMARY KEY,
	CustomerTypeName VARCHAR(50),
	CustomerTypeDesc VARCHAR(1000)
)
GO

CREATE TABLE tblSUPPLIER (
	SupplierID INT IDENTITY(1,1) PRIMARY KEY,
	SupplierName VARCHAR(50),
	SupplierDesc VARCHAR(1000)
)
GO

CREATE TABLE tblPRODUCT (
	ProductID INT IDENTITY(1,1) PRIMARY KEY,
	ProductName VARCHAR(50),
	ProductDesc VARCHAR(1000),
	SupplierID INT FOREIGN KEY REFERENCES tblSupplier(SupplierID)
)
GO

CREATE TABLE tblORDER_PRODUCT (
	Order_ProductID INT IDENTITY(1,1) PRIMARY KEY,
	ProductID INT FOREIGN KEY REFERENCES tblProduct(ProductID),
	OrderID INT FOREIGN KEY REFERENCES tblORDER(OrderID),
	Quantity INT
)
GO

CREATE TABLE tblDETAIL (
	DetailID INT IDENTITY(1,1) PRIMARY KEY,
	DetailName VARCHAR(50),
	DetailDesc VARCHAR(1000)
)
GO

CREATE TABLE tblPRODUCT_DETAIL (
	ProductDetailID INT IDENTITY(1,1) PRIMARY KEY,
	ProductID INT FOREIGN KEY REFERENCES tblProduct(ProductID),
	DetailID INT FOREIGN KEY REFERENCES tblDetail(DetailID),
	Value VARCHAR(1000)
)
GO

---------------------------------------------------------------------------------------------------
-- GetID Procedures
---------------------------------------------------------------------------------------------------
CREATE OR ALTER PROC GetCustomerTypeID
@_CustomerTypeName VARCHAR(50),
@_Out INT OUTPUT
AS
	SET @_Out = (
		SELECT CustomerTypeID FROM tblCUSTOMER_TYPE WHERE CustomerTypeName = @_CustomerTypeName
	)
GO

CREATE OR ALTER PROC GetSupplierID
@_SupplierName VARCHAR(50),
@_Out INT OUTPUT
AS
	SET @_Out = (
		SELECT SupplierID FROM tblSUPPLIER WHERE SupplierName = @_SupplierName
	)
GO

CREATE OR ALTER PROC GetProductID
@_ProductName VARCHAR(50),
@_Out INT OUTPUT
AS
	SET @_Out = (
		SELECT ProductID FROM tblPRODUCT WHERE ProductName = @_ProductName
	)
GO

CREATE OR ALTER PROC GetDetailID
@_DetailName VARCHAR(50),
@_Out INT OUTPUT
AS
	SET @_Out = (
		SELECT DetailID FROM tblDETAIL WHERE DetailName = @_DetailName
	)
GO

---------------------------------------------------------------------------------------------------
-- Stored Procedures
---------------------------------------------------------------------------------------------------
CREATE OR ALTER PROC Ins_Supplier
@SupplierName VARCHAR(50),
@SupplierDesc VARCHAR(1000),
@CityName INT
AS
	DECLARE @CityID INT
	EXEC GetCityID
	@C_Name = @CityName,
	@C_ID = @CityID OUTPUT

	IF @CityID IS NULL
		THROW 51000, 'City not found', 1;

	BEGIN TRAN T1
		INSERT INTO tblSUPPLIER (SupplierName, SupplierDesc, SupplierID)
		VALUES (@SupplierName, @SupplierDesc, @CityID)

		IF @@ERROR <> 0
		BEGIN
			ROLLBACK TRAN T1;
			THROW 51001, 'Something went wrong', 1;
		END
	COMMIT TRAN T1
GO

CREATE OR ALTER PROC Ins_Product
@ProductName VARCHAR(50),
@ProductDesc VARCHAR(1000),
@SupplierName VARCHAR(50)
AS
	DECLARE @SupplierID INT
	EXEC GetSupplierID
	@_SupplierName = @SupplierName,
	@_Out = @SupplierID OUTPUT

	IF @SupplierID IS NULL
		THROW 52000, 'Supplier not found', 1;

	BEGIN TRAN T1
		INSERT INTO tblPRODUCT (ProductName, ProductDesc, SupplierID)
		VALUES (@ProductName, @ProductDesc, @SupplierID)

		IF @@ERROR <> 0
		BEGIN
			ROLLBACK TRAN T1;
			THROW 52001, 'Something went wrong', 1;
		END
	COMMIT TRAN T1
GO

CREATE OR ALTER PROC Ins_ProductDetail
@ProductName VARCHAR(50),
@DetailName VARCHAR(50),
@Value VARCHAR(1000)
AS
	DECLARE @ProductID INT
	EXEC GetProductID
	@_ProductName = @ProductName,
	@_Out = @ProductID OUTPUT
	
	IF @ProductID IS NULL
		THROW 53000, 'Product not found', 1;

	DECLARE @DetailID INT
	EXEC GetDetailID
	@_DetailName = @DetailName,
	@_Out = @DetailID OUTPUT
	
	IF @DetailName IS NULL
		THROW 53001, 'Detail not found', 1;

	BEGIN TRAN T1
		INSERT INTO tblPRODUCT_DETAIL (ProductID, DetailID, [Value])
		VALUES (@ProductID, @DetailID, @Value)

		IF @@ERROR <> 0
		BEGIN
			ROLLBACK TRAN T1;
			THROW 53002, 'Something went wrong', 1;
		END
	COMMIT TRAN T1
GO

---------------------------------------------------------------------------------------------------
-- Populate Look-Up Tables: tblSUPPLIER, tblDETAIL
---------------------------------------------------------------------------------------------------
-- The data below is taken from https://en.wikipedia.org/wiki/COVID-19_vaccine
IF NOT EXISTS (SELECT TOP 1 * FROM tblSUPPLIER)
	INSERT INTO tblSUPPLIER (SupplierName, SupplierDesc) VALUES
	('Pfizer–BioNTech', 'The best vaccine right now, collaborate effort from United States and Germany.'),
	('Gamaleya Research Institute', 'The first ever vaccine from Russia.'),
	('Oxford–AstraZeneca', 'Also a good vaccine from United Kingdom.'),
	('Sinopharm', 'Kinda shady vaccine from China.'),
	('Sinovac', 'Also kinda shady vaccine from China.'),
	('Moderna', 'On par with Pfizer, and made from United States.'),
	('Johnson & Johnson', 'This is the new one from United States and Netherlands.')

IF NOT EXISTS (SELECT TOP 1 * FROM tblDETAIL)
	INSERT INTO tblDETAIL (DetailName, DetailDesc) VALUES
	('Minimum Temperature', 'Minimum temperature in celsius that the product can withstand.'),
	('Maximum Temperature', 'Maximum temperature in celsius that the product can withstand'),
	('Recommended Temperature', 'Recommended temperature in celsius for storing the product'),
	('Weight', 'Weight in grams for a single product unit.')

---------------------------------------------------------------------------------------------------
-- Populate Transaction Tables: tblPRODUCT, tblPRODUCT_DETAIL, tblDETAIL
---------------------------------------------------------------------------------------------------
SELECT *, ROW_NUMBER() OVER(ORDER BY SupplierID) AS RowNumber INTO Temp_tblSUPPLIER FROM tblSUPPLIER
CREATE OR ALTER PROC PopulateProduct
@N INT
AS
	DECLARE @Run INT = 1
	WHILE @Run <= @N
	BEGIN
		DECLARE @RandProductName VARCHAR(50) = (
			-- This line of code was taken and modified from https://www.sqlteam.com/forums/topic.asp?TOPIC_ID=21132
			SELECT CHAR(CAST((90 - 65) * RAND() + 65 AS INT)) +
				CHAR(CAST((90 - 65) * RAND() + 65 AS INT)) +
				CHAR(CAST((90 - 65) * RAND() + 65 AS INT)) +
				'-' +
				CAST(1000 * RAND() AS CHAR)
		)

		DECLARE @RandProductDesc VARCHAR(1000) = (
			'This is a random product description given a number of ' + CAST(RAND() AS VARCHAR(10))
		)

		DECLARE @RandSupplierRowNumber INT = FLOOR(RAND() * (SELECT COUNT(*) FROM tblSUPPLIER) + 1)
		DECLARE @RandSupplierName VARCHAR(50) = (SELECT SupplierName FROM Temp_tblSUPPLIER WHERE RowNumber = @RandSupplierRowNumber)

		EXEC Ins_Product
		@ProductName = @RandProductName,
		@ProductDesc = @RandProductDesc,
		@SupplierName = @RandSupplierName

		DECLARE @RandMinTemp INT = RAND() * -100
		EXEC Ins_ProductDetail
		@ProductName = @RandProductName,
		@DetailName = 'Minimum Temperature',
		@Value = @RandMinTemp

		DECLARE @RandMaxTemp INT = @RandMinTemp + RAND() * 10
		EXEC Ins_ProductDetail
		@ProductName = @RandProductName,
		@DetailName = 'Maximum Temperature',
		@Value = @RandMaxTemp

		DECLARE @RandRecTemp INT = @RandMaxTemp - RAND() * 5
		EXEC Ins_ProductDetail
		@ProductName = @RandProductName,
		@DetailName = 'Recommended Temperature',
		@Value = @RandRecTemp

		DECLARE @RandWeight INT = RAND() * 10
		EXEC Ins_ProductDetail
		@ProductName = @RandProductName,
		@DetailName = 'Weight',
		@Value = @RandWeight

		SET @Run = @Run + 1
	END
GO

IF (SELECT COUNT(*) FROM tblPRODUCT) <> 100
	EXEC PopulateProduct @N = 100

IF EXISTS (SELECT TOP 1 * FROM Temp_tblSUPPLIER)
	DROP TABLE Temp_tblSUPPLIER

---------------------------------------------------------------------------------------------------
-- Check constraints
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
-- Computed columns
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
-- Views
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
-- Ignore: Debug Code
---------------------------------------------------------------------------------------------------
SELECT * FROM tblDETAIL
SELECT * FROM tblSUPPLIER
DELETE FROM tblSUPPLIER
DBCC CHECKIDENT ('tblDETAIL', RESEED, 0)
