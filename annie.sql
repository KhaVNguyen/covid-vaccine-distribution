USE INFO430_Proj_10

CREATE TABLE tblSHIPMENT_TYPE
(
    ShipmentTypeID INTEGER IDENTITY(1,1) PRIMARY KEY,
    ShipmentTypeName VARCHAR(50) NOT NULL,
    ShipmentTypeDesc VARCHAR(1000) NOT NULL
);
GO

CREATE TABLE tblCARRIER     --with FK
(
    CarrierID INTEGER IDENTITY(1,1) PRIMARY KEY,
    CarrierName VARCHAR(50) NOT NULL,
    CityID INTEGER FOREIGN KEY REFERENCES tblCITY(CityID)
);
GO

ALTER TABLE tblCARRIER
DROP CONSTRAINT FK_CityID
GO

ALTER TABLE tblCARRIER
DROP COLUMN CityID
GO

select * from tblCARRIER

delete from tblCARRIER where CarrierID > 2411728

CREATE TABLE tblSHIPMENT     --with FK
(
    ShipmentID INTEGER IDENTITY(1,1) PRIMARY KEY,
    TrackingNumber VARCHAR(50) NOT NULL,
    ShippingDate DATETIME NOT NULL,
    ShipmentTypeID INTEGER FOREIGN KEY REFERENCES tblSHIPMENT_TYPE(ShipmentTypeID),
    CarrierID INTEGER FOREIGN KEY REFERENCES tblCARRIER(CarrierID)
);
GO

CREATE TABLE tblPACKAGE     --with FK
(
    PackageID INTEGER IDENTITY(1,1) PRIMARY KEY,
    Order_ProductID INTEGER FOREIGN KEY REFERENCES tblORDER_PRODUCT(Order_ProductID),
    ShipmentID INTEGER FOREIGN KEY REFERENCES tblSHIPMENT(ShipmentID)
);
GO

CREATE TABLE tblEMPLOYEE_TYPE
(
    EmployeeTypeID INTEGER IDENTITY(1,1) PRIMARY KEY,
    EmployeeTypeName VARCHAR(50) NOT NULL,
    EmployeeTypeDesc VARCHAR(1000) NOT NULL
);
GO

CREATE TABLE tblEMPLOYEE     --with FK
(
    EmployeeID INTEGER IDENTITY(1,1) PRIMARY KEY,
    EmployeeFName VARCHAR(50) NOT NULL,
    EmployeeLName VARCHAR(50) NOT NULL,
    EmployeeDOB DATE NOT NULL,
    EmployeeTypeID INTEGER FOREIGN KEY REFERENCES tblEMPLOYEE_TYPE(EmployeeTypeID)
);
GO

CREATE TABLE tblORDER     --with FK
(
    OrderID INTEGER IDENTITY(1,1) PRIMARY KEY,
    OrderDate DATETIME NOT NULL,
    CustomerID INTEGER FOREIGN KEY REFERENCES tblCUSTOMER(CustomerID),
    EmployeeID INTEGER FOREIGN KEY REFERENCES tblEMPLOYEE(EmployeeID),
);
GO

-------------------------- Get ID Sproc --------------------------------------

-- GET ShipmentTypeID
ALTER PROCEDURE GetShipmentTypeID
    @ST_Name    VARCHAR(50),
    @ST_ID      INT OUTPUT 
AS 
IF @ST_Name IS NULL
    THROW 50201, 'ShipmentTypeName is null', 1; 
SET @ST_ID = (
    SELECT ShipmentTypeID
    FROM tblSHIPMENT_TYPE 
    WHERE ShipmentTypeName = @ST_Name
)
GO 

-- GET CarrierID
ALTER PROCEDURE GetCarrierID
    @CR_Name    VARCHAR(50),
    @CR_ID      INT OUTPUT
AS
IF @CR_Name IS NULL
    THROW 50202, 'Carrier Name is null', 1; 

SET @CR_ID = (
    SELECT CarrierID
    FROM tblCARRIER
    WHERE CarrierName = @CR_Name
)
GO

-- GET ShipmentID (with FK ShipmentType and FK Carrier)
ALTER PROCEDURE GetShipmentID
    @SP_TrackingNum         VARCHAR(50),
    @SP_Date                DATETIME,
    @SP_ShipmentTypeName    VARCHAR(50),
    @SP_CarrierName         VARCHAR(50),
    @SP_ID                  INT OUTPUT
AS
IF @SP_TrackingNum IS NULL OR @SP_Date IS NULL OR @SP_ShipmentTypeName IS NULL OR 
    @SP_CarrierName IS NULL
    THROW 50203, 'None of parameter should not be null', 1; 
DECLARE @ShipmentTypeID INT, @CarrierID INT

EXEC GetShipmentTypeID
@ST_Name = @SP_ShipmentTypeName,
@ST_ID = @ShipmentTypeID OUTPUT

EXEC GetCarrierID
@CR_Name = @SP_CarrierName,
@CR_ID = @CarrierID OUTPUT

SET @SP_ID = (
    SELECT ShipmentID 
    FROM tblSHIPMENT
    WHERE TrackingNumber = @SP_TrackingNum 
    AND ShippingDate = @SP_Date
    AND ShipmentTypeID = @ShipmentTypeID
    AND CarrierID = @CarrierID
)
GO

-- GET EmployeeTypeID
ALTER PROCEDURE GetEmployeeTypeID
    @ET_Name     VARCHAR(50),
    @ET_ID       INT OUTPUT 
AS 
IF @ET_Name IS NULL
    THROW 50204, 'EmployeeTypeName is null', 1; 
SET @ET_ID = (
    SELECT EmployeeTypeID
    FROM tblEMPLOYEE_TYPE 
    WHERE EmployeeTypeName = @ET_Name
)
GO

-- GET EmployeeID
ALTER PROCEDURE GetEmployeeID
    @E_FName VARCHAR(50),
    @E_LName VARCHAR(50),
    @E_DOB DATE,
    @E_ID INT OUTPUT
AS 
	SET @E_ID = (
		SELECT EmployeeID
		FROM tblEMPLOYEE
		WHERE EmployeeFName = @E_FName
		AND EmployeeLName = @E_LName
		AND EmployeeDOB = @E_DOB
	)
GO

-- GET OrderID (with FK EmployeeID and FK Customer)
ALTER PROCEDURE GetOrderID
    @OR_Date            DATETIME,
    @OR_EmpFName        VARCHAR(50),
    @OR_EmpLName        VARCHAR(50),
    @OR_EmpDOB          DATE,
    @OR_CustFname       VARCHAR(50),
    @OR_CustLname       VARCHAR(50),
    @OR_CustDOB         DATE,
    @OR_ID              INT OUTPUT
AS
IF  @OR_Date IS NULL OR 
    @OR_EmpFName IS NULL OR 
    @OR_EmpLName IS NULL OR 
    @OR_EmpDOB IS NULL OR 
    @OR_CustFname IS NULL OR 
    @OR_CustLname IS NULL OR 
    @OR_CustDOB IS NULL

DECLARE @EmployeeID INT, @CustomerID INT

EXEC GetEmployeeID
@E_FName = @OR_EmpFName,
@E_LName = @OR_EmpLName,
@E_DOB = @OR_EmpDOB,
@E_ID = @EmployeeID OUTPUT

-- combined from Kha 
EXEC GetCustomerID
@C_Fname = @OR_CustFname,
@C_Lname = @OR_CustLname,
@C_DOB = @OR_CustDOB,
@C_ID = @CustomerID OUTPUT

SET @OR_ID = (
    SELECT OrderID
    FROM tblORDER
    WHERE OrderDate = @OR_Date
    AND CustomerID = @CustomerID
    AND EmployeeID = @EmployeeID
)
GO
-------------------------- Raw data script --------------------------------------
-- EMPLOYEE DATA
CREATE TABLE  tblRAW_EmpData-- CREATE SCRIPT TABLE
(Emp_PK_ID INT IDENTITY (1,1) primary key,
Emp_FName VARCHAR(50) NOT NULL,
Emp_LName VARCHAR(50) NOT NULL,
Emp_DOB DATE NOT NULL)

INSERT INTO tblRAW_EmpData -- INSERT DATA FROM ORIGINAL TABLE/DATASET
(Emp_FName, Emp_LName, Emp_DOB)
SELECT CustomerFname, CustomerLname, DateOfBirth
FROM PEEPS.dbo.tblCUSTOMER

-- EMPLOYEE TYPE DATA
INSERT INTO tblEMPLOYEE_TYPE(EmployeeTypeName, EmployeeTypeDesc) 
VALUES('Part-Time', ''), ('Full-Time', ''), ('Contingent', ''), ('Temporary', ''),  ('Executive', '')

-- Carrier DATA
/*SELECT *, ROW_NUMBER() OVER(ORDER BY CityID) AS I INTO Temp FROM tblCITY
DECLARE @I INT = (SELECT COUNT(*) FROM tblCITY)
WHILE @I > 0
BEGIN
    DECLARE @CityID INT = (
        SELECT CityID FROM Temp WHERE I = @I
    )
    INSERT INTO tblCARRIER(CarrierName, CityID)
    VALUES('UPS', @CityID),('USPS', @CityID),('DHL', @CityID),('FedEx', @CityID)
    SET @I = @I - 1
END
IF EXISTS (SELECT TOP 1 * FROM Temp)
     DROP TABLE Temp*/

SELECT * FROM tblCARRIER


-- Shipment Type Data 
INSERT INTO tblSHIPMENT_TYPE(ShipmentTypeName, ShipmentTypeDesc)
VALUES('Priority Express', 'Estimated 1-2 days or Overnight'), ('Priority', 'Estimated 1-3 days'), ('Parcel', 'Estimated 2-8 days'), ('First Class', 'Estimated 1–3 days up to 13 oz')
GO

-------------------------- Insert Sproc --------------------------------------

-- Insert shipment 
ALTER PROCEDURE Ins_Shipment
    @InsSP_TrackingNum         VARCHAR(50),
    @InsSP_Date                DATETIME,
    @InsSP_ShipmentTypeName    VARCHAR(50),
    @InsSP_CarrierName         VARCHAR(50)
AS 
BEGIN
DECLARE @ShipmentTypeID INT, @CarrierID INT

EXEC GetShipmentTypeID
@ST_Name = @InsSP_ShipmentTypeName,
@ST_ID = @ShipmentTypeID OUTPUT

    IF @ShipmentTypeID IS NULL
        BEGIN
        THROW 50207, '@ShipmentTypeID is not found', 1;
    END

EXEC GetCarrierID
@CR_Name = @InsSP_CarrierName,
@CR_ID = @CarrierID OUTPUT
    
    IF @CarrierID IS NULL 
        BEGIN
        THROW 50300, '@CarrierID is not found', 1;
        END

    BEGIN TRANSACTION T1
        INSERT INTO tblSHIPMENT(TrackingNumber, ShippingDate, ShipmentTypeID, CarrierID)
        VALUES (@InsSP_TrackingNum, @InsSP_Date, @ShipmentTypeID, @CarrierID)
    IF @@ERROR <> 0 
        ROLLBACK TRANSACTION T1
    ELSE 
        COMMIT TRANSACTION T1
    END 
GO

-- insert Employee
CREATE OR ALTER PROCEDURE Ins_Employee
    @Ins_EmpFName            VARCHAR(50),
    @Ins_EmpLName            VARCHAR(50),
    @Ins_EmpDOB              DATE,
    @Ins_EmpTypeName         VARCHAR(50)
AS
BEGIN
DECLARE @EmployeeTypeID INT

    EXEC GetEmployeeTypeID
    @ET_Name = @Ins_EmpTypeName,
    @ET_ID = @EmployeeTypeID OUTPUT

    IF @EmployeeTypeID IS NULL
        THROW 50209, '@EmployeeTypeID is not found', 1;

    BEGIN TRANSACTION T1
        INSERT INTO tblEMPLOYEE(EmployeeFName, EmployeeLName, EmployeeDOB, EmployeeTypeID)
        VALUES(@Ins_EmpFName,@Ins_EmpLName, @Ins_EmpDOB, @EmployeeTypeID)
    IF @@ERROR <> 0 
        ROLLBACK TRANSACTION T1
    ELSE 
        COMMIT TRANSACTION T1
    END 
GO

-- Insert sproc order 
CREATE OR ALTER PROC Ins_PopulateOrder
@OrderDate DATETIME,
@C_FName1 VARCHAR(50),
@C_LName1 VARCHAR(50),
@C_DOB1 DATE,
@E_FName1 VARCHAR(50),
@E_LName1 VARCHAR(50),
@E_DOB1 DATE,
@ProductName1 VARCHAR(50),
@Quantity INT
AS
	DECLARE @CustomerID INT
	EXEC GetCustomerID
	@C_Fname = @C_FName1,
	@C_Lname = @C_LName1,
	@C_DOB = @C_DOB1,
	@C_ID = @CustomerID OUTPUT

	IF @CustomerID IS NULL
		THROW 54000, 'Customer not found', 1;

	DECLARE @EmployeeID INT
	EXEC GetEmployeeID
	@E_FName = @E_FName1,
	@E_LName = @E_LName1,
	@E_DOB = @E_DOB1,
	@E_ID = @EmployeeID OUTPUT

	IF @EmployeeID IS NULL
		THROW 54001, 'Employee not found', 1;

	DECLARE @ProductID INT
	EXEC GetProductID
	@_ProductName = @ProductName1,
	@_Out = @ProductID OUTPUT

	IF @ProductID IS NULL
		THROW 54002, 'Product not found', 1;

	BEGIN TRAN T1
		INSERT INTO tblORDER (OrderDate, CustomerID, EmployeeID)
		VALUES (@OrderDate, @CustomerID, @EmployeeID)

		DECLARE @OrderID INT = (SCOPE_IDENTITY())

		INSERT INTO tblORDER_PRODUCT (ProductID, OrderID, Quantity)
		VALUES (@ProductID, @OrderID, @Quantity)

		IF @@ERROR <> 0
		BEGIN
			ROLLBACK TRAN T1;
			THROW 54003, 'Something went wrong', 1;
		END
	COMMIT TRAN T1
GO

-------------------------- Populate EmployeeData --------------------------------------
INSERT INTO tblEMPLOYEE(EmployeeFName, EmployeeLName, EmployeeDOB, EmployeeTypeID)
SELECT TOP 10000 Emp_FName, Emp_LName, Emp_DOB, 2 
FROM tblRAW_EmpData


UPDATE tblEMPLOYEE
SET EmployeeTypeID = (SELECT EmployeeTypeID FROM tblEMPLOYEE_TYPE WHERE EmployeeTypeName = 'Executive')
WHERE EmployeeID LIKE '%51' 

UPDATE tblEMPLOYEE
SET EmployeeTypeID = (SELECT EmployeeTypeID FROM tblEMPLOYEE_TYPE WHERE EmployeeTypeName = 'Part-Time')
WHERE EmployeeID LIKE '%3_'

UPDATE tblEMPLOYEE
SET EmployeeTypeID = (SELECT EmployeeTypeID FROM tblEMPLOYEE_TYPE WHERE EmployeeTypeName = 'Contingent')
WHERE EmployeeID LIKE '%72'

UPDATE tblEMPLOYEE
SET EmployeeTypeID = (SELECT EmployeeTypeID FROM tblEMPLOYEE_TYPE WHERE EmployeeTypeName = 'Temporary')
WHERE EmployeeID LIKE '%84'

UPDATE tblEMPLOYEE SET EmployeeTypeID = (SELECT EmployeeTypeID FROM tblEMPLOYEE_TYPE WHERE EmployeeTypeName = 'Full-Time')

SELECT COUNT(*), ET.EmployeeTypeName FROM tblEMPLOYEE E 
        JOIN tblEMPLOYEE_TYPE ET ON E.EmployeeTypeID = ET.EmployeeTypeID
GROUP BY ET.EmployeeTypeName

IF EXISTS (SELECT TOP 1 * FROM tblRAW_EmpData)
     DROP TABLE tblRAW_EmpData
GO

-- generate tracking num
CREATE OR ALTER PROCEDURE GenerateTrackingNumber 
@Output VARCHAR(12) OUTPUT
AS
BEGIN
    DECLARE @Result VARCHAR(12) = ''
    DECLARE @Run INT = 1
    WHILE @Run <= 12
        BEGIN
            DECLARE @RandomNumber INT = FLOOR(RAND() * 10) 
            SET @Result = CONCAT(@Result, @RandomNumber)
            SET @Run = @Run + 1
        END
    SET @Output = @Result
END
GO

DECLARE @TrackingNum VARCHAR(12)
EXEC GenerateTrackingNumber @Output = @TrackingNum OUTPUT
PRINT (@TrackingNum)
GO

-- populate data for shipment
CREATE OR ALTER PROCEDURE PopulateShipment
@NumsShipment INT
AS
DECLARE @Shipment_TrackingNum VARCHAR(12), @Shipment_Date DATETIME, @Shipment_TypeName VARCHAR(50), @Shipment_CarrierName VARCHAR(50)
DECLARE @ShipmentTypeCount INT = (SELECT COUNT(*) FROM tblSHIPMENT_TYPE)
DECLARE @ShipmentType_ID INT, @Carrier_ID INT
DECLARE @RandShipDays INT, @Number INT
WHILE @NumsShipment > 0
    BEGIN
            SET @RandShipDays = (SELECT RAND() * 100)
            -- Generate random tracking number
            EXEC GenerateTrackingNumber
            @Output = @Shipment_TrackingNum OUTPUT 
            -- Generate random date 
            SET @Shipment_Date = DATEADD(DAY, @RandShipDays, GETDATE())
            -- Get random shipmentTypeID 
            SET @ShipmentType_ID = (SELECT RAND() * @ShipmentTypeCount + 1)
            SET @Shipment_TypeName = (SELECT ShipmentTypeName FROM tblSHIPMENT_TYPE WHERE ShipmentTypeID = @ShipmentType_ID)
            -- Get random carrierID
            SET @Number = (SELECT RAND() * 100) 
            SET @Shipment_CarrierName= (CASE
                                        WHEN @Number < 20
                                        THEN 'UPS'
                                        WHEN @Number BETWEEN 20 AND 40
                                        THEN 'USPS'
                                        WHEN @Number BETWEEN 40 AND 70
                                        THEN 'DHL'
                                        ELSE 'FedEx'
                                        END)

            EXEC Ins_Shipment
            @InsSP_TrackingNum = @Shipment_TrackingNum,
            @InsSP_Date = @Shipment_Date,
            @InsSP_ShipmentTypeName = @Shipment_TypeName,
            @InsSP_CarrierName = @Shipment_CarrierName

        SET @NumsShipment = @NumsShipment - 1
    END
GO

-- Test 
EXEC PopulateShipment
@NumsShipment = 5
GO


-- populate order and order product
CREATE OR ALTER PROCEDURE PopulateOrder
@NumsOrder INT
AS
    SELECT *, ROW_NUMBER() OVER(ORDER BY EmployeeID) AS RowNumber INTO Temp_tblEMPLOYEE FROM tblEMPLOYEE
    SELECT *, ROW_NUMBER() OVER(ORDER BY CustomerID) AS RowNumber INTO Temp_tblCUSTOMER FROM tblCUSTOMER
    SELECT *, ROW_NUMBER() OVER(ORDER BY ProductID) AS RowNumber INTO Temp_tblPRODUCT FROM tblPRODUCT

	-- ORDERDATE AND EMPLOYEE DATA
	DECLARE @RandOrderDate DATETIME, @Order_EmpFName VARCHAR(50), @Order_EmpLName VARCHAR(50), @Order_EmpBirthy DATE
	--CUSTOMER DATA
	DECLARE @Order_CustFName VARCHAR(50), @Order_CustLName VARCHAR(50), @Order_CustBirthy DATE
    --PRODUCT DATA
    DECLARE @Order_ProductName VARCHAR(50), @Qty INT
	-- COUNTING ROWS
	DECLARE @EmployeeCount INT = (SELECT COUNT(*) FROM tblEMPLOYEE)
	DECLARE @CustomerCount INT = (SELECT COUNT(*) FROM tblCUSTOMER)
    DECLARE @ProductCount INT = (SELECT COUNT(*) FROM tblPRODUCT)
	-- CUSTOMER ID AND EMPLOYEE ID 
	DECLARE @Emp_RandRowNumber INT, @Cust_RandRowNumber INT, @Prod_RandRowNumber INT
	-- RANDOM DAYS
	DECLARE @RandOrderDays INT
	WHILE @NumsOrder > 0
    BEGIN
            SET @RandOrderDays = (SELECT RAND() * 100)
            -- Generate random date 
            SET @RandOrderDate = DATEADD(DAY, @RandOrderDays, GETDATE())
            -- Get random EmployeeID
            SET @Emp_RandRowNumber = (SELECT RAND() * @EmployeeCount + 1)
            SET @Order_EmpFName = (SELECT EmployeeFName FROM Temp_tblEMPLOYEE WHERE RowNumber = @Emp_RandRowNumber)
            SET @Order_EmpLName = (SELECT EmployeeLName FROM Temp_tblEMPLOYEE WHERE RowNumber = @Emp_RandRowNumber)
            SET @Order_EmpBirthy = (SELECT EmployeeDOB FROM Temp_tblEMPLOYEE WHERE RowNumber = @Emp_RandRowNumber)
            -- Get random CustomerID
            SET @Cust_RandRowNumber = (SELECT RAND() * @CustomerCount + 1)
            SET @Order_CustFName = (SELECT CustomerFname FROM Temp_tblCUSTOMER WHERE RowNumber = @Cust_RandRowNumber)
            SET @Order_CustLName = (SELECT CustomerLname FROM Temp_tblCUSTOMER WHERE RowNumber = @Cust_RandRowNumber)
            SET @Order_CustBirthy = (SELECT CustomerDOB FROM Temp_tblCUSTOMER WHERE RowNumber = @Cust_RandRowNumber)
            -- Get random ProductID
            SET @Prod_RandRowNumber = (SELECT RAND() * @ProductCount + 1)
            SET @Order_ProductName = (SELECT ProductName FROM Temp_tblPRODUCT WHERE RowNumber = @Prod_RandRowNumber)
            SET @Qty = (SELECT RAND() * 100 + 1)

            EXEC Ins_PopulateOrder
			@OrderDate = @RandOrderDate,
			@C_FName1 = @Order_CustFName,
			@C_LName1 = @Order_CustLName,
			@C_DOB1 = @Order_CustBirthy,
			@E_FName1 = @Order_EmpFName,
			@E_LName1 = @Order_EmpLName,
			@E_DOB1 = @Order_EmpBirthy,
			@ProductName1 = @Order_ProductName,
			@Quantity = @Qty

        SET @NumsOrder = @NumsOrder - 1
    END

    DROP TABLE Temp_tblEMPLOYEE
    DROP TABLE Temp_tblCUSTOMER
    DROP TABLE Temp_tblPRODUCT
GO

EXEC PopulateOrder
@NumsOrder = 5
GO

-------------------------- Business Rules  --------------------------------------
-- 1. Order date should be earlier than shipping date
/*CREATE OR ALTER FUNCTION fn_OrderDateEarlierThanShippingDate()
RETURNS INTEGER
AS
BEGIN
DECLARE @RET INTEGER = 0 
IF EXISTS (SELECT O.OrderID, O.OrderDate FROM tblORDER O 
            JOIN tblCUSTOMER CS ON O.CustomerID = CS.CustomerID
            JOIN tblADDRESS A ON CS.AddressID = A.AddressID
            JOIN tblCITY C ON A.CityID = C.CityID
            JOIN tblCARRIER CR ON C.CityID = CR.CityID
            JOIN tblSHIPMENT S ON CR.CarrierID = S.CarrierID 
            WHERE S.ShippingDate >= O.OrderDate
            GROUP BY O.OrderID, O.OrderDate
        )
        BEGIN 
            SET @RET = 1
        END
RETURN @RET
END
GO


ALTER TABLE tblORDER with nocheck
ADD CONSTRAINT CK_OrderDateEarlierThanShippingDate
CHECK (dbo.fn_OrderDateEarlierThanShippingDate() = 0)

DROP FUNCTION fn_OrderDateEarlierThanShippingDate

ALTER TABLE tblORDER  
DROP CONSTRAINT CK_OrderDateEarlierThanShippingDate;
GO*/

CREATE OR ALTER FUNCTION fn_OrderDateEarlierThanShippingDate()
RETURNS INTEGER
AS
BEGIN
DECLARE @RET INTEGER = 0 
IF EXISTS (SELECT O.OrderID, O.OrderDate, S.ShippingDate FROM tblORDER O 
            JOIN tblORDER_PRODUCT OP ON O.OrderID = OP.OrderID
            JOIN tblPACKAGE PK ON OP.Order_ProductID = PK.Order_ProductID
            JOIN tblSHIPMENT S ON PK.ShipmentID = S.ShipmentID
            WHERE S.ShippingDate < O.OrderDate
            GROUP BY O.OrderID, O.OrderDate, S.ShippingDate
        )
        BEGIN 
            SET @RET = 1
        END
RETURN @RET
END
GO

ALTER TABLE tblORDER with nocheck
ADD CONSTRAINT CK_OrderDateEarlierThanShippingDate
CHECK (dbo.fn_OrderDateEarlierThanShippingDate() = 0)
GO



-- 2. Employee with less than 21 years old should not be full-time
CREATE OR ALTER FUNCTION fn_EmployeeMustBeOlder21ForFullTime()
RETURNS INTEGER
AS
BEGIN
DECLARE @RET INTEGER = 0 
IF EXISTS (SELECT EmployeeID, EmployeeFName, EmployeeLName, EmployeeDOB, CAST(DATEDIFF(day, EmployeeDOB, GETDATE()) / 365.25 AS INT) AS Age, E.EmployeeTypeID  
            FROM tblEMPLOYEE E
            JOIN tblEMPLOYEE_TYPE ET ON E.EmployeeTypeID = ET.EmployeeTypeID
            WHERE CAST(DATEDIFF(day, EmployeeDOB, GETDATE()) / 365.25 AS INT) < 21
            AND ET.EmployeeTypeName = 'Full-Time'
            GROUP BY EmployeeID, EmployeeFName, EmployeeLName, EmployeeDOB, E.EmployeeTypeID
        )
        BEGIN 
            SET @RET = 1
        END
RETURN @RET
END
GO

ALTER TABLE tblEMPLOYEE with nocheck
ADD CONSTRAINT CK_EmployeeMustBeOlder21ForFullTime
CHECK (dbo.fn_EmployeeMustBeOlder21ForFullTime() = 0)
GO


/*ALTER TABLE tblEMPLOYEE  
DROP CONSTRAINT CK_EmployeeMustBeOlder21ForFullTime;


DROP FUNCTION fn_EmployeeMustBeOlder21ForFullTime*/

-------------------------- Computed Columns --------------------------------------

-- 1. Total order in each state in the U.S.

CREATE OR ALTER FUNCTION FN_TotalOrderStates(@PK INT) 
RETURNS INT
AS
BEGIN

DECLARE @RET INT = (SELECT COUNT(O.OrderID)
                    FROM tblORDER O
                        JOIN tblCUSTOMER CS ON O.CustomerID = CS.CustomerID
                        JOIN tblADDRESS A ON CS.AddressID = A.AddressID
                        JOIN tblCITY C ON A.CityID = C.CityID
                        JOIN tblSTATE S ON C.StateID = S.StateID
                        WHERE S.StateID = @PK
                    )

RETURN @RET
END
GO

ALTER TABLE tblSTATE
ADD TototalOrder AS (dbo.FN_TotalOrderStates (StateID)) 
GO

-- 2. Total order of each product
CREATE OR ALTER FUNCTION FN_TotalOrderEachProduct(@PK INT)
RETURNS INT
AS
BEGIN 
    DECLARE @RET INT = (SELECT COUNT(OP.OrderID)
                        FROM tblORDER_PRODUCT OP
                        JOIN tblPRODUCT P ON OP.ProductID = P.ProductID
                        WHERE P.ProductID = @PK)
RETURN @RET
END
GO

ALTER TABLE tblORDER_PRODUCT
ADD TotalOrderProduct AS (dbo.FN_TotalOrderEachProduct (ProductID)) 
GO

SELECT * FROM tblORDER_PRODUCT
SELECT COUNT(OP.OrderID)
                        FROM tblORDER_PRODUCT OP
                        JOIN tblPRODUCT P ON OP.ProductID = P.ProductID
                        WHERE P.ProductID = '27'

-------------------------- Views --------------------------------------
-- Ranking 1 - 50 orders by states and nums of customer 
CREATE VIEW vwTop10OrderbyStates
AS
SELECT S.StateID, S.StateName, COUNT(O.CustomerID) AS TotalNumsCustomers ,SUM(OP.Quantity) AS TotalProductOrders,
RANK() OVER (ORDER BY SUM(OP.Quantity) DESC) AS RANK
FROM tblSTATE S 
    JOIN tblCITY C ON S.StateID = C.StateID
    JOIN tblADDRESS A ON C.CityID = A.CityID
    JOIN tblCUSTOMER CS ON A.AddressID = CS.AddressID
    JOIN tblORDER O ON CS.CustomerID = O.CustomerID
    JOIN tblORDER_PRODUCT OP ON O.OrderID = OP.OrderID
    GROUP BY S.StateID, S.StateName
GO

SELECT * FROM vwTop10OrderbyStates

-- most popular product by order nums 
CREATE VIEW vwPopularProduct
SELECT O.OrderID, P.ProductName,SUM(OP.Quantity) AS TotalOrderProduct
FROM tblORDER O
    JOIN tblORDER_PRODUCT OP ON O.OrderID = OP.OrderID
    JOIN tblPRODUCT P ON OP.ProductID = P.ProductID
    GROUP BY O.OrderID, P.ProductName
    ORDER BY SUM(OP.Quantity) DESC
GO









------------------------Code from Tom--------------------------------------
-- New GetCustomerID
/*CREATE OR ALTER PROCEDURE GetCustomerID
@C_Fname VARCHAR(50),
@C_Lname VARCHAR(50),
@C_DOB DATE,
@C_ID INT OUTPUT
AS
	SET @C_ID = (
		SELECT CustomerID
		FROM tblCUSTOMER
		WHERE CustomerFname = @C_Fname
			AND CustomerLname = @C_Lname
			AND CustomerDOB = @C_DOB
	)
GO

CREATE OR ALTER PROC Ins_PopulateOrder
@OrderDate DATETIME,
@C_FName VARCHAR(50),
@C_LName VARCHAR(50),
@C_DOB DATE,
@E_FName VARCHAR(50),
@E_LName VARCHAR(50),
@E_DOB DATE,
@ProductName VARCHAR(50),
@Quantity INT
AS
	DECLARE @CustomerID INT
	EXEC GetCustomerID
	@C_Fname = @C_FName,
	@C_Lname = @C_LName,
	@C_DOB = @C_DOB,
	@C_ID = @CustomerID OUTPUT

	IF @CustomerID IS NULL
		THROW 54000, 'Customer not found', 1;

	DECLARE @EmployeeID INT
	EXEC GetEmployeeID
	@E_FName = @E_FName,
	@E_LName = @E_LName,
	@E_DOB = @E_DOB,
	@E_ID = @EmployeeID OUTPUT

	IF @EmployeeID IS NULL
		THROW 54001, 'Employee not found', 1;

	DECLARE @ProductID INT
	EXEC GetProductID
	@_ProductName = @ProductName,
	@_Out = @ProductID OUTPUT

	IF @ProductID IS NULL
		THROW 54002, 'Product not found', 1;

	BEGIN TRAN T1
		INSERT INTO tblORDER (OrderDate, CustomerID, EmployeeID)
		VALUES (@OrderDate, @CustomerID, @EmployeeID)

		DECLARE @OrderID INT = (SCOPE_IDENTITY())

		INSERT INTO tblORDER_PRODUCT (ProductID, OrderID, Quantity)
		VALUES (@ProductID, @OrderID, @Quantity)

		IF @@ERROR <> 0
		BEGIN
			ROLLBACK TRAN T1;
			THROW 54003, 'Something went wrong', 1;
		END
	COMMIT TRAN T1
GO
*/

