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
	('Pfizer�BioNTech', 'The best vaccine right now, collaborate effort from United States and Germany.'),
	('Gamaleya Research Institute', 'The first ever vaccine from Russia.'),
	('Oxford�AstraZeneca', 'Also a good vaccine from United Kingdom.'),
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

IF NOT EXISTS (SELECT TOP 1 * FROM tblCUSTOMER_TYPE)
	INSERT INTO tblCUSTOMER_TYPE (CustomerTypeName) VALUES
	('Hospital'), ('Clinic'), ('Household'), ('Individual'), ('Federal Institution'),
	('State Institution'), ('Research Institution'), ('University'), ('School')

---------------------------------------------------------------------------------------------------
-- Populate Transaction Tables: tblPRODUCT, tblPRODUCT_DETAIL, tblDETAIL
---------------------------------------------------------------------------------------------------
CREATE OR ALTER PROC PopulateProduct
@N INT
AS
	SELECT *, ROW_NUMBER() OVER(ORDER BY SupplierID) AS RowNumber INTO Temp_tblSUPPLIER FROM tblSUPPLIER

	DECLARE @Run INT = 1
	WHILE @Run <= @N
	BEGIN
		DECLARE @RandProductName VARCHAR(50) = (
			-- This line of code was taken and modified from https://www.sqlteam.com/forums/topic.asp?TOPIC_ID=21132
			SELECT CHAR(CAST((90 - 65) * RAND() + 65 AS INT)) +
				CHAR(CAST((90 - 65) * RAND() + 65 AS INT)) +
				'-' +
				CHAR(CAST((90 - 65) * RAND() + 65 AS INT)) +
				CHAR(CAST((90 - 65) * RAND() + 65 AS INT)) +
				CHAR(CAST((90 - 65) * RAND() + 65 AS INT)) +
				'-' +
				CAST(FLOOR(10000 * RAND()) AS CHAR)
		)

		DECLARE @RandProductDesc VARCHAR(1000) = (
			'This is a random product description given a number of ' + CAST(RAND() AS VARCHAR(10))
		)

		DECLARE @RandSupplierRowNumber INT = FLOOR(RAND() * (SELECT COUNT(*) FROM tblSUPPLIER) + 1)
		DECLARE @RandSupplierName VARCHAR(50) = (SELECT SupplierName FROM Temp_tblSUPPLIER WHERE RowNumber = @RandSupplierRowNumber)

		DECLARE @RandMinTemp INT = RAND() * -100
		DECLARE @RandMaxTemp INT = @RandMinTemp + RAND() * 10
		DECLARE @RandRecTemp INT = @RandMaxTemp - RAND() * 5
		DECLARE @RandWeight INT = RAND() * 10

		BEGIN TRAN T1
			EXEC Ins_Product
			@ProductName = @RandProductName,
			@ProductDesc = @RandProductDesc,
			@SupplierName = @RandSupplierName

			EXEC Ins_ProductDetail
			@ProductName = @RandProductName,
			@DetailName = 'Minimum Temperature',
			@Value = @RandMinTemp

			EXEC Ins_ProductDetail
			@ProductName = @RandProductName,
			@DetailName = 'Maximum Temperature',
			@Value = @RandMaxTemp

			EXEC Ins_ProductDetail
			@ProductName = @RandProductName,
			@DetailName = 'Recommended Temperature',
			@Value = @RandRecTemp

			EXEC Ins_ProductDetail
			@ProductName = @RandProductName,
			@DetailName = 'Weight',
			@Value = @RandWeight

			IF @@ERROR <> 0
			BEGIN
				ROLLBACK TRAN T1;
				THROW 54000, 'Something went wrong', 1;
			END
		COMMIT TRAN T1

		SET @Run = @Run + 1
	END

	DROP TABLE Temp_tblSUPPLIER
GO

IF (SELECT COUNT(*) FROM tblPRODUCT) <> 50
	EXEC PopulateProduct @N = 50

---------------------------------------------------------------------------------------------------
-- Computed columns
---------------------------------------------------------------------------------------------------
-- Number of orders for each supplier
CREATE OR ALTER FUNCTION fn_OrderCountPerSupplier(@PK INT)
RETURNS INT
AS
BEGIN
	RETURN (
		SELECT COUNT(*)
		FROM tblORDER O
			JOIN tblORDER_PRODUCT O_P ON O.OrderID = O_P.OrderID
			JOIN tblPRODUCT P ON O_P.ProductID = P.ProductID
			JOIN tblSUPPLIER S ON P.SupplierID = S.SupplierID
		WHERE S.SupplierID = @PK
	)
END
GO

IF COL_LENGTH('tblSUPPLIER', 'OrderCount') IS NULL
BEGIN
	ALTER TABLE tblSUPPLIER
	ADD OrderCount AS (dbo.fn_OrderCountPerSupplier(SupplierID))
END

-- Number of employees for each customer type
CREATE OR ALTER FUNCTION fn_CountEmployeePerCustomerType(@PK INT)
RETURNS INT
AS
BEGIN
	RETURN (
		SELECT COUNT(*)
		FROM tblEMPLOYEE E
			JOIN tblORDER O ON E.EmployeeID = O.EmployeeID
			JOIN tblCUSTOMER Cust ON O.CustomerID = Cust.CustomerID
			JOIN tblCUSTOMER_TYPE C_T ON Cust.CustomerTypeID = C_T.CustomerTypeID
		WHERE C_T.CustomerTypeID = @PK
	)
END
GO

IF COL_LENGTH('tblCUSTOMER_TYPE', 'EmployeeCount') IS NULL
BEGIN
	ALTER TABLE tblCUSTOMER_TYPE
	ADD EmployeeCount AS (dbo.fn_CountEmployeePerCustomerType(CustomerTypeID))
END

---------------------------------------------------------------------------------------------------
-- Check constraints
---------------------------------------------------------------------------------------------------
-- A customer type 'Individual' below the age of 30, can only order 1 quantity  of a product at a time.
CREATE OR ALTER FUNCTION fn_HasMoreThan1ProductQuanityPerOrder()
RETURNS INT
AS
BEGIN
	IF EXISTS (
		SELECT *
		FROM tblCUSTOMER_TYPE C_T
			JOIN tblCUSTOMER C ON C_T.CustomerTypeID = C_T.CustomerTypeID
			JOIN tblORDER O ON C.CustomerID = O.CustomerID
			JOIN tblORDER_PRODUCT O_P ON O.OrderID = O_P.OrderID
		WHERE C_T.CustomerTypeName = 'Individual'
			AND C.CustomerDOB > DATEADD(YEAR, -30, GETDATE())
			AND O_P.Quantity > 1
	) RETURN 1
	RETURN 0
END
GO

ALTER TABLE tblORDER WITH NOCHECK
ADD CONSTRAINT ck_HasMoreThan1ProductQuanityPerOrder
CHECK (dbo.fn_HasMoreThan1ProductQuanityPerOrder() = 0)

-- A customer type 'Individual' and 'Household' can not order a product that has a minimum storage temperature below -10 celsius.
CREATE OR ALTER FUNCTION fn_HasProductMinTempBelowNegative10()
RETURNS INT
AS
BEGIN
	IF EXISTS (
		SELECT *
		FROM tblCUSTOMER_TYPE C_T
			JOIN tblCUSTOMER C ON C_T.CustomerTypeID = C.CustomerTypeID
			JOIN tblORDER O ON C.CustomerID = O.CustomerID
			JOIN tblORDER_PRODUCT O_P ON O.OrderID = O_P.OrderID
			JOIN tblPRODUCT P ON O_P.ProductID = P.ProductID
			JOIN tblPRODUCT_DETAIL P_D ON P.ProductID = P_D.ProductID
			JOIN tblDETAIL D ON P_D.DetailID = D.DetailID
		WHERE (C_T.CustomerTypeName = 'Individual' OR C_T.CustomerTypeName = 'Household')
			AND D.DetailName = 'Minimum Temperature'
			AND CAST(P_D.[Value] AS INT) < -10
	) RETURN 1
	RETURN 0
END
GO

ALTER TABLE tblORDER WITH NOCHECK
ADD CONSTRAINT ck_HasProductMinTempBelowNegative10
CHECK (dbo.fn_HasProductMinTempBelowNegative10() = 0)

---------------------------------------------------------------------------------------------------
-- Views
---------------------------------------------------------------------------------------------------
-- The top 1 supplier in each state, that received the most number of orders from.
CREATE OR ALTER VIEW vw_Top1SupplierInEachStateByNumberOfOrders
AS
	-- The code below was taken and modified from: https://stackoverflow.com/a/6841644
	WITH cte
	AS (
		SELECT S.StateID, S.StateName, SP.SupplierName,
		COUNT(O.OrderID) AS OrderCount,
		ROW_NUMBER() OVER (PARTITION BY S.StateID ORDER BY COUNT(O.OrderID) DESC) AS TopNumberOfOrdersRank
		FROM tblSTATE S
			JOIN tblCITY CT ON S.StateID = CT.StateID
			JOIN tblADDRESS A ON CT.CityID = A.CityID
			JOIN tblCUSTOMER C ON A.AddressID = C.AddressID
			JOIN tblORDER O ON C.CustomerID = O.CustomerID
			JOIN tblORDER_PRODUCT O_P ON O.OrderID = O_P.OrderID
			JOIN tblPRODUCT P ON O_P.ProductID = P.ProductID
			JOIN tblSUPPLIER SP ON P.SupplierID = SP.SupplierID
		GROUP BY S.StateID, S.StateName, SP.SupplierName
	)
	SELECT StateID, StateName, SupplierName, OrderCount
	FROM cte
	WHERE TopNumberOfOrdersRank = 1
GO

-- The lowest temperature that an employee had to deal with.
CREATE OR ALTER VIEW vw_EmployeeMinTemp
AS
	WITH cte
	AS (
		SELECT E.EmployeeID, E.EmployeeFName, E.EmployeeLName, P_D.[Value] AS MinTempValue,
		ROW_NUMBER() OVER (PARTITION BY E.EmployeeID ORDER BY CAST(P_D.[Value] AS INT) ASC) AS LowestTempRank
		FROM tblEMPLOYEE E
			JOIN tblORDER O ON E.EmployeeID = O.EmployeeID
			JOIN tblORDER_PRODUCT O_P ON O.OrderID = O_P.OrderID
			JOIN tblPRODUCT P ON O_P.ProductID = P.ProductID
			JOIN tblPRODUCT_DETAIL P_D ON P.ProductID = P_D.ProductID
			JOIN tblDETAIL D ON P_D.DetailID = D.DetailID
		WHERE D.DetailName = 'Minimum Temperature'
		GROUP BY E.EmployeeID, E.EmployeeFName, E.EmployeeLName, P_D.[VALUE]
	)
	SELECT EmployeeID, EmployeeFName, EmployeeLName, MinTempValue
	FROM cte
	WHERE LowestTempRank = 1
GO
