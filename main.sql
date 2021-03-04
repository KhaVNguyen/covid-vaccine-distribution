USE INFO430_Proj_10
GO

---------------------------------------------------------------------------------------------------
-- Shipping process Tables
---------------------------------------------------------------------------------------------------
CREATE TABLE tblSTATE
(
    StateID INTEGER IDENTITY(1,1) PRIMARY KEY,
    StateName VARCHAR(50) NOT NULL,
    StateCode VARCHAR(2) NOT NULL
);
GO

CREATE TABLE tblCITY
(
    CityID INTEGER IDENTITY(1,1) PRIMARY KEY,
    CityName VARCHAR(50) NOT NULL,
    StateID INTEGER FOREIGN KEY REFERENCES tblSTATE(StateID)
);
GO

CREATE TABLE tblADDRESS
(
    AddressID INTEGER IDENTITY(1,1) PRIMARY KEY,
    AddressLine1 VARCHAR(100),
    AddressLine2 VARCHAR(100),
    Zip VARCHAR(5),
    CityID INTEGER FOREIGN KEY REFERENCES tblCITY(CityID),
    StateID INTEGER FOREIGN KEY REFERENCES tblSTATE(StateID)
);
GO


CREATE TABLE tblCARRIER     --with FK
(
    CarrierID INTEGER IDENTITY(1,1) PRIMARY KEY,
    CarrierName VARCHAR(50) NOT NULL
);
GO
SELECT * FROM tblCARRIER
/*ALTER TABLE tblCARRIER
DROP CONSTRAINT FK_CityID
GO

ALTER TABLE tblCARRIER
DROP COLUMN CityID
GO

select * from tblCARRIER

delete from tblCARRIER where CarrierID > 2411728*/

CREATE TABLE tblSHIPMENT_TYPE
(
    ShipmentTypeID INTEGER IDENTITY(1,1) PRIMARY KEY,
    ShipmentTypeName VARCHAR(50) NOT NULL,
    ShipmentTypeDesc VARCHAR(1000) NOT NULL
);
GO

CREATE TABLE tblSHIPMENT     --with FK
(
    ShipmentID INTEGER IDENTITY(1,1) PRIMARY KEY,
    TrackingNumber VARCHAR(50) NOT NULL,
    ShippingDate DATETIME NOT NULL,
    ShipmentTypeID INTEGER FOREIGN KEY REFERENCES tblSHIPMENT_TYPE(ShipmentTypeID),
    CarrierID INTEGER FOREIGN KEY REFERENCES tblCARRIER(CarrierID)
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

---------------------------------------------------------------------------------------------------
-- Customer related Tables
---------------------------------------------------------------------------------------------------
CREATE TABLE tblPRIORITY
(
    PriorityID INTEGER IDENTITY(1,1) PRIMARY KEY,
    PriorityName VARCHAR(50),
    PriorityDesc VARCHAR(1000)
);
GO

CREATE TABLE tblCUSTOMER_TYPE (
	CustomerTypeID INT IDENTITY(1,1) PRIMARY KEY,
	CustomerTypeName VARCHAR(50),
	CustomerTypeDesc VARCHAR(1000)
)
GO

CREATE TABLE tblCUSTOMER
(
    CustomerID INTEGER IDENTITY(1,1) PRIMARY KEY,
    CustomerFname VARCHAR(50),
    CustomerLname VARCHAR(50),
    CustomerDOB DATE,
    CustomerEmail VARCHAR(50),
    AddressID INTEGER FOREIGN KEY REFERENCES tblADDRESS(AddressID),
    PriorityID INTEGER FOREIGN KEY REFERENCES tblPRIORITY(PriorityID),
    CustomerTypeID INTEGER FOREIGN KEY REFERENCES tblCUSTOMER_TYPE(CustomerTypeID)
);
GO

---------------------------------------------------------------------------------------------------
-- Order process Tables
---------------------------------------------------------------------------------------------------
CREATE TABLE tblORDER     --with FK
(
    OrderID INTEGER IDENTITY(1,1) PRIMARY KEY,
    OrderDate DATETIME NOT NULL,
    CustomerID INTEGER FOREIGN KEY REFERENCES tblCUSTOMER(CustomerID),
    EmployeeID INTEGER FOREIGN KEY REFERENCES tblEMPLOYEE(EmployeeID)
);
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

CREATE TABLE tblPACKAGE
(
    PackageID INTEGER IDENTITY(1,1) PRIMARY KEY,
    Order_ProductID INTEGER FOREIGN KEY REFERENCES tblORDER_PRODUCT(Order_ProductID),
    ShipmentID INTEGER FOREIGN KEY REFERENCES tblSHIPMENT(ShipmentID)
);
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
-- GetID Stored Procedure
---------------------------------------------------------------------------------------------------
-- Tom
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

-- Kha
CREATE OR ALTER PROCEDURE GetStateID
@S_Name VARCHAR(50),
@S_ID INT OUTPUT
AS
SET @S_ID = (SELECT StateID FROM tblSTATE WHERE StateName = @S_Name)
GO

CREATE OR ALTER PROCEDURE GetCityID
@C_Name VARCHAR(50),
@C_ID INT OUTPUT
AS
SET @C_ID = (SELECT CityID FROM tblCITY WHERE CityName = @C_Name)
GO

CREATE OR ALTER PROCEDURE GetAddressID
@A_Line1 VARCHAR(100),
@A_Line2 VARCHAR(100),
@A_Zip VARCHAR(5),
@A_CityName VARCHAR(50),
@A_StateName VARCHAR(50),
@A_ID INT OUTPUT
AS
DECLARE @CityID INT, @StateID INT

EXEC GetCityID
@C_Name = @A_CityName,
@C_ID = @CityID

EXEC GetStateID
@S_Name = @A_StateName,
@S_ID = @StateID

SET @A_ID = (
    SELECT AddressID
    FROM tblADDRESS
    WHERE AddressLine1 = @A_Line1
        AND AddressLine2 = @A_Line2
        AND Zip = @A_Zip
        AND CityID = @CityID
        AND StateID = @StateID
)
GO

CREATE OR ALTER PROCEDURE GetPriorityID
@P_Name VARCHAR(50),
@P_ID INT OUTPUT
AS
SET @P_ID = (SELECT PriorityID FROM tblPRIORITY WHERE PriorityName = @P_Name)
GO

CREATE OR ALTER PROCEDURE GetCustomerID
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

-- Annie
-- GET ShipmentTypeID
CREATE OR ALTER PROCEDURE GetShipmentTypeID
    @ST_Name    VARCHAR(50),
    @ST_ID      INT OUTPUT
AS
SET @ST_ID = (
    SELECT ShipmentTypeID
    FROM tblSHIPMENT_TYPE
    WHERE ShipmentTypeName = @ST_Name
)
GO

-- GET CarrierID
CREATE OR ALTER PROCEDURE GetCarrierID
    @CR_Name    VARCHAR(50),
    @CR_ID      INT OUTPUT
AS
SET @CR_ID = (
    SELECT CarrierID
    FROM tblCARRIER
    WHERE CarrierName = @CR_Name
)
GO

-- GET ShipmentID (with FK ShipmentType and FK Carrier)
CREATE OR ALTER PROCEDURE GetShipmentID
    @SP_TrackingNum         VARCHAR(50),
    @SP_Date                DATETIME,
    @SP_ShipmentTypeName    VARCHAR(50),
    @SP_CarrierName         VARCHAR(50),
    @SP_ID                  INT OUTPUT
AS
DECLARE @ShipmentTypeID INT, @CarrierID INT

EXEC GetShipmentTypeID
@ST_Name = @SP_ShipmentTypeName,
@ST_ID = @ShipmentTypeID

EXEC GetCarrierID
@CR_Name = @SP_CarrierName,
@CR_ID = @CarrierID

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
CREATE OR ALTER PROCEDURE GetEmployeeTypeID
    @ET_Name     VARCHAR(50),
    @ET_ID       INT OUTPUT 
AS 
SET @ET_ID = (
    SELECT EmployeeTypeID
    FROM tblEMPLOYEE_TYPE 
    WHERE EmployeeTypeName = @ET_Name
)
GO

-- GET EmployeeID
CREATE OR ALTER PROCEDURE GetEmployeeID
    @E_FName            VARCHAR(50),
    @E_LName            VARCHAR(50),
    @E_DOB              DATE,
    @E_ID        INT OUTPUT
AS
SET @E_ID = (
    SELECT EmployeeID
    FROM tblEMPLOYEE
    WHERE EmployeeFName = @E_LName
        AND EmployeeLName = @E_LName
        AND EmployeeDOB = @E_DOB
)
GO

-- GET OrderID (with FK EmployeeID and FK Customer)
CREATE OR ALTER PROCEDURE GetOrderID
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
---------------------------------------------------------------------------------------------------
-- Insert data into tables without FK
---------------------------------------------------------------------------------------------------
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

-- Shipment Type Data 
INSERT INTO tblSHIPMENT_TYPE(ShipmentTypeName, ShipmentTypeDesc)
VALUES('Priority Express', 'Estimated 1-2 days or Overnight'), ('Priority', 'Estimated 1-3 days'), ('Parcel', 'Estimated 2-8 days'), ('First Class', 'Estimated 1–3 days up to 13 oz')

-- Carrier Data
INSERT INTO tblCARRIER(CarrierName)
VALUES('UPS'),('USPS'),('DHL'),('FedEx')


---------------------------------------------------------------------------------------------------
-- Insert Stored Procedure
---------------------------------------------------------------------------------------------------
-- Insert shipment 
CREATE OR ALTER PROCEDURE Ins_Shipment
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


-- Insert Employee
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
    BEGIN
        THROW 50209, '@EmployeeTypeID is not found', 1;
    END
    
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

---------------------------------------------------------------------------------------------------
-- Populating Data
---------------------------------------------------------------------------------------------------
-- populate customer 
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


---------------------------------------------------------------------------------------------------
-- Test Populating Data
---------------------------------------------------------------------------------------------------
EXEC PopulateShipment
@NumsShipment = 5

EXEC PopulateOrder
@NumsOrder = 5


---------------------------------------------------------------------------------------------------
-- Business Rules
---------------------------------------------------------------------------------------------------
--code here


---------------------------------------------------------------------------------------------------
-- Computed Columns
---------------------------------------------------------------------------------------------------
--code here


---------------------------------------------------------------------------------------------------
-- Complex Queries (Views)
---------------------------------------------------------------------------------------------------
--code here


---------------------------------------------------------------------------------------------------
-- Checking Tables
---------------------------------------------------------------------------------------------------
-- lookups
SELECT * FROM tblSHIPMENT_TYPE
SELECT * FROM tblEMPLOYEE_TYPE
SELECT * FROM tblSTATE
SELECT * FROM tblPRIORITY
SELECT * FROM tblCUSTOMER_TYPE
SELECT * FROM tblDETAIL

-- tables with FK
SELECT * FROM tblCARRIER
SELECT * FROM tblPACKAGE -- not done yet
SELECT * FROM tblORDER
SELECT * FROM tblORDER_PRODUCT
SELECT * FROM tblPRODUCT
SELECT * FROM tblPRODUCT_DETAIL
SELECT * FROM tblSUPPLIER
SELECT * FROM tblEMPLOYEE
SELECT * FROM tblCUSTOMER
SELECT * FROM tblSHIPMENT
SELECT * FROM tblCITY
SELECT * FROM tblADDRESS
