---------------------------------------------------------------------------------------------------
-- Tables
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
	SupplierDesc VARCHAR(1000),
	CityID INT FOREIGN KEY REFERENCES tblCITY(CityID)
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
-- GetID Procedure
---------------------------------------------------------------------------------------------------
CREATE OR ALTER PROC GetCustomerTypeID
@_Name VARCHAR(50),
@_Out INT OUTPUT
AS
	IF @_Name IS NULL
		THROW 50011, '_Name can not be null', 1;
	SET @_Out = (
		SELECT CustomerTypeID
		FROM tblCUSTOMER_TYPE
		WHERE CustomerTypeName = @_Name
	)
GO

CREATE OR ALTER PROC GetSupplierID
@_Name VARCHAR(50),
@_Out INT OUTPUT
AS
	IF @_Name IS NULL
		THROW 50012, '_Name can not be null', 1;
	SET @_Out = (
		SELECT SupplierID
		FROM tblSUPPLIER
		WHERE SupplierName = @_Name
	)
GO

CREATE OR ALTER PROC GetProductID
@_Name VARCHAR(50),
@_Out INT OUTPUT
AS
	IF @_Name IS NULL
		THROW 50013, '_Name can not be null', 1;
	SET @_Out = (
		SELECT ProductID
		FROM tblPRODUCT
		WHERE ProductName = @_Name
	)
GO

CREATE OR ALTER PROC GetDetailID
@_Name VARCHAR(50),
@_Out INT OUTPUT
AS
	IF @_Name IS NULL
		THROW 50014, '_Name can not be null', 1;
	SET @_Out = (
		SELECT DetailID
		FROM tblDETAIL
		WHERE DetailName = @_Name
	)
GO

---------------------------------------------------------------------------------------------------
-- Insert Proc
---------------------------------------------------------------------------------------------------
CREATE OR ALTER PROC AddSupplier
@SupplierName VARCHAR(50),
@SupplierDesc VARCHAR(1000),
@CityName INT
AS
	DECLARE @CityID INT
	EXEC GetCityID
	@C_Name = @CityName OUTPUT

	IF @CityID IS NULL
		THROW 50015, 'City not found', 1;

	BEGIN TRAN T1
		INSERT INTO tblSUPPLIER (SupplierName, SupplierDesc, SupplierID)
		VALUES (@SupplierName, @SupplierDesc, @CityID)

        IF @@ERROR <> 0
	ROLLBACK TRAN T1
        ELSE
	COMMIT TRAN T1
GO

CREATE OR ALTER PROC AddProduct
@ProductName VARCHAR(50),
@ProductDesc VARCHAR(1000),
@SupplierName VARCHAR(50)
AS
	DECLARE @SupplierID INT
	EXEC GetSupplierID
	@_Name = @SupplierName OUTPUT

	IF @SupplierID IS NULL
		THROW 50016, 'SupplierName not found', 1;

	BEGIN TRAN T1
		INSERT INTO tblPRODUCT (ProductName, ProductDesc, SupplierID)
		VALUES (@ProductName, @ProductDesc, @SupplierID)

        IF @@ERROR <> 0
	ROLLBACK TRAN T1
        ELSE
	COMMIT TRAN T1
GO

CREATE OR ALTER PROC AddProductDetail
@ProductName VARCHAR(50),
@DetailName VARCHAR(50),
@DetailDesc VARCHAR(1000),
@Value VARCHAR(1000)
AS
	DECLARE @ProductID INT
	EXEC GetProductID
	@_Name = @ProductName OUTPUT

	IF @ProductID IS NULL
		THROW 50017, 'ProductName not found', 1;

	BEGIN TRAN T1
		INSERT INTO tblDETAIL (DetailName, DetailDesc)
		VALUES (@DetailName, @DetailDesc)

		DECLARE @DetailID = (SCOPE_IDENTITY())

		INSERT INTO tblPRODUCT_DETAIL (ProductID, DetailID, [Value])
		VALUES (@ProductID, @DetailID, @Value)

        IF @@ERROR <> 0 AND @@TRANCOUNT <> 1
	ROLLBACK TRAN T1
        ELSE
	COMMIT TRAN T1
GO

---------------------------------------------------------------------------------------------------
-- Populate product
---------------------------------------------------------------------------------------------------
CREATE OR ALTER PROC PopulateProduct
@NProduct INT
AS
	DECLARE @Run INT = 1
	WHILE @Run <= @NProduct
	BEGIN
		DECLARE @RandProductName VARCHAR(50) = (
			-- This line of code was taken from https://www.sqlteam.com/forums/topic.asp?TOPIC_ID=21132
			SELECT CHAR(CAST((90 - 65) * RAND() + 65 AS INT)) +
				CHAR(CAST((90 - 65) * RAND() + 65 AS INT)) +
				CHAR(CAST((90 - 65) * RAND() + 65 AS INT)) +
				'-' +
				CAST(1000 * RAND() AS CHAR)
		)

		DECLARE @RandProductDesc VARCHAR(1000) = (
			'This is a random product description given given a number of ' +
			CAST(FLOOR(10000 * RAND()) AS VARCHAR(10))
		)

		DECLARE @RandSupplierID INT = FLOOR(RAND() * (SELECT COUNT(*) FROM tblSUPPLIER) + 1)
		DECLARE @RandSupplierName VARCHAR(50) = (SELECT SupplierName FROM tblSUPPLIER WHERE SupplierID = @RandSupplierID)

		EXEC AddProduct
		@ProductName = @RandProductName,
		@ProductDesc = @RandProductDesc,
		@SupplierName = @RandSupplierName

		SET @Run = @Run + 1
	END
GO
