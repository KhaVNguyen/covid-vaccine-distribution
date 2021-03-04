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
    @OR_EmpTypeName     VARCHAR(50),
    @OR_CustFname       VARCHAR(50),
    @OR_CustLname       VARCHAR(50),
    @OR_CustDOB         DATE,
    @OR_CustEmail       VARCHAR(50),
    @OR_ID              INT OUTPUT
AS
IF  @OR_Date IS NULL OR 
    @OR_EmpFName IS NULL OR 
    @OR_EmpLName IS NULL OR 
    @OR_EmpDOB IS NULL OR 
    @OR_EmpTypeName IS NULL OR 
    @OR_CustFname IS NULL OR 
    @OR_CustLname IS NULL OR 
    @OR_CustDOB IS NULL OR 
    @OR_CustEmail IS NULL
    THROW 50206, 'None of parameter should not be null', 1;

DECLARE @EmployeeID INT, @CustomerID INT

EXEC GetEmployeeID
@E_FName = @OR_EmpFName,
@E_LName = @OR_EmpLName,
@E_DOB = @OR_EmpDOB,
@E_EmployeeTypeName = @OR_EmpTypeName,
@E_ID = @EmployeeID OUTPUT

-- combined from Kha 
EXEC GetCustomerID
@C_Fname = @OR_CustFname,
@C_Lname = @OR_CustLname,
@C_DOB = @OR_CustDOB,
@C_Email= @OR_CustEmail,
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

-- insert Order
CREATE PROCEDURE Ins_Order
    @Ins_OrderDate            DATETIME,
    @Ins_OrderEmpFName        VARCHAR(50),
    @Ins_OrderEmpLName        VARCHAR(50),
    @Ins_OrderEmpDOB          DATE,
    @Ins_OrderEmpTypeName     VARCHAR(50),
    @Ins_OrderCustFname       VARCHAR(50),
    @Ins_OrderCustLname       VARCHAR(50),
    @Ins_OrderCustDOB         DATE,
    @Ins_OrderCustEmail       VARCHAR(50),
    @Ins_OrderCustTypeName VARCHAR(50),
    @Ins_OrderPname VARCHAR(50),
    @Ins_OrderALine1 VARCHAR(100),
    @Ins_OrderALine2 VARCHAR(100),
    @Ins_OrderAZip VARCHAR(5),
    @Ins_OrderACityName VARCHAR(50),
    @Ins_OrderAStateName VARCHAR(50)
AS
BEGIN
    DECLARE @Ins_CustomerID INT, @Ins_EmployeeID INT
        EXEC GetCustomerID
        @C_Fname = @Ins_OrderCustFname,
        @C_Lname = @Ins_OrderCustLname,
        @C_DOB = @Ins_OrderCustDOB,
        @C_Email = @Ins_OrderCustEmail,
        @C_CustTypeName = @Ins_OrderCustTypeName,
        @C_Pname = @Ins_OrderPname,
        @C_ALine1 = @Ins_OrderALine1,
        @C_ALine2 = @Ins_OrderALine2,
        @C_AZip = @Ins_OrderAZip,
        @C_ACityName = @Ins_OrderACityName,
        @C_AStateName = @Ins_OrderAStateName,
        @C_ID = @Ins_CustomerID OUTPUT

        IF @Ins_CustomerID IS NULL
            THROW 50291, 'CustomerID should not be null', 1;

        EXEC GetEmployeeID
        @E_FName = @Ins_OrderEmpFName,
        @E_LName = @Ins_OrderEmpLName,
        @E_DOB = @Ins_OrderEmpDOB,
        @E_EmployeeTypeName = @Ins_OrderEmpTypeName,
        @E_ID = @Ins_EmployeeID OUTPUT

        IF @Ins_EmployeeID IS NULL
            THROW 50290, 'EmployeeID should not be null', 1;

        BEGIN TRAN T1
            INSERT INTO tblORDER(OrderDate, CustomerID, EmployeeID)
            VALUES (@Ins_OrderDate, @Ins_CustomerID, @Ins_EmployeeID)
        IF @@ERROR <> 0
            ROLLBACK TRAN T1
        ELSE
            COMMIT TRAN T1
END
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

SELECT * FROM tblCARRIER

SELECT * FROM tblSHIPMENT

-- populate Order
CREATE OR ALTER PROCEDURE PopulateOrder
@NumsOrder INT
AS
	-- ORDERDATE AND EMPLOYEE DATA
	DECLARE @RandOrderDate DATETIME, @Order_EmpFName VARCHAR(50), @Order_EmpLName VARCHAR(50), @Order_EmpBirthy DATE, @Order_EmpTypeName VARCHAR(50)
	--CUSTOMER DATA
	DECLARE @Order_CustFName VARCHAR(50), @Order_CustLName VARCHAR(50), @Order_CustBirthy DATE, @Order_CustEmail VARCHAR(50), @Order_CustTypeName VARCHAR(50)
	DECLARE @Order_Pname VARCHAR(50), @Order_ALine1 VARCHAR(100), @Order_ALine2 VARCHAR(100), @Order_AZip VARCHAR(5), @Order_ACityName VARCHAR(50), @Order_AStateName VARCHAR(50)
	-- COUNTING ROWS
	DECLARE @EmployeeCount INT = (SELECT COUNT(*) FROM tblEMPLOYEE)
	DECLARE @CustomerCount INT = (SELECT COUNT(*) FROM tblCUSTOMER)
	-- CUSTOMER ID AND EMPLOYEE ID 
	DECLARE @EmployeeID INT, @CustomerID INT
	-- RANDOM DAYS
	DECLARE @RandOrderDays INT
	WHILE @NumsOrder > 0
    BEGIN
            SET @RandOrderDays = (SELECT RAND() * 100)
            -- Generate random date 
            SET @OrderDate = DATEADD(DAY, @RandOrderDays, GETDATE())
            -- Get random EmployeeID
            SET @EmployeeID = (SELECT RAND() * @EmployeeCount + 1)
            SET @Order_EmpFName = (SELECT EmployeeFName FROM tblEMPLOYEE WHERE EmployeeID = @EmployeeID)
            SET @Order_EmpLName = (SELECT EmployeeLName FROM tblEMPLOYEE WHERE EmployeeID = @EmployeeID)
            SET @Order_EmpBirthy = (SELECT EmployeeDOB FROM tblEMPLOYEE WHERE EmployeeID = @EmployeeID)
            SET @Order_EmpTypeName = (SELECT ET.EmployeeTypeName FROM tblEMPLOYEE E JOIN tblEMPLOYEE_TYPE ET
                                                                                ON E.EmployeeTypeID = ET.EmployeeTypeID
                                                                                WHERE EmployeeID = @EmployeeID)
            -- Get random CustomerID
            SET @CustomerID = (SELECT TOP 1 CustomerID FROM tblCUSTOMER ORDER BY NEWID())
            SET @Order_CustFName = (SELECT CustomerFname FROM tblCUSTOMER WHERE CustomerID = @CustomerID)
            SET @Order_CustLName = (SELECT CustomerLname FROM tblCUSTOMER WHERE CustomerID = @CustomerID)
            SET @Order_CustBirthy = (SELECT CustomerDOB FROM tblCUSTOMER WHERE CustomerID = @CustomerID)
            SET @Order_CustEmail = (SELECT CustomerEmail FROM tblCUSTOMER WHERE CustomerID = @CustomerID)
            SET @Order_CustTypeName = (SELECT CT.CustomerTypeName FROM tblCUSTOMER C JOIN tblCUSTOMER_TYPE CT
                                                                                ON C.CustomerTypeID = CT.CustomerTypeID 
                                                                                WHERE CustomerID = @CustomerID)
            SET @Order_Pname = (SELECT P.PriorityName FROM tblCUSTOMER C JOIN tblPRIORITY P 
                                                                        ON C.PriorityID = P.PriorityID 
                                                                        WHERE CustomerID = @CustomerID)
            SET @Order_ALine1 = (SELECT A.AddressLine1 FROM tblCUSTOMER C JOIN tblADDRESS A
                                                                        ON C.AddressID = A.AddressID
                                                                        WHERE CustomerID = @CustomerID)
            SET @Order_ALine2 = (SELECT A.AddressLine2 FROM tblCUSTOMER C JOIN tblADDRESS A
                                                                        ON C.AddressID = A.AddressID
                                                                         WHERE CustomerID = @CustomerID)  
            SET @Order_AZip = (SELECT A.Zip FROM tblCUSTOMER C JOIN tblADDRESS A
                                                                        ON C.AddressID = A.AddressID
                                                                         WHERE CustomerID = @CustomerID)  
            SET @Order_ACityName = (SELECT CI.CityName FROM tblCUSTOMER C JOIN tblADDRESS A
                                                                        ON C.AddressID = A.AddressID
                                                                        JOIN tblCITY CI
                                                                        ON A.CityID = CI.CityID
                                                                        WHERE CustomerID = @CustomerID)
            SET @Order_AStateName = (SELECT S.StateName FROM tblCUSTOMER C JOIN tblADDRESS A
                                                                        ON C.AddressID = A.AddressID
                                                                        JOIN tblCITY CI
                                                                        ON A.CityID = CI.CityID
                                                                        JOIN tblSTATE S 
                                                                        ON CI.StateID = S.StateID
                                                                        WHERE CustomerID = @CustomerID)

            EXEC Ins_PopulateOrder
			@OrderDate = @RandOrderDate,
			@C_FName = 'Adelia',
			@C_LName = 'Sudbeck',
			@C_DOB = '2008-08-26',
			@E_FName = 'Jetta',
			@E_LName = 'Hunnings',
			@E_DOB = '1990-11-06',
			@ProductName = 'DJ-EPA-7733',
			@Quantity = 10

        SET @NumsOrder = @NumsOrder - 1
    END
GO

-------------------------- Business Rules  --------------------------------------
-- 1. Order date should be earlier than shipping date
CREATE OR ALTER FUNCTION fn_OrderDateEarlierThanShippingDate()
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
GO

-- 2. Employee with less than 21 years old should not be full-time
CREATE OR ALTER FUNCTION fn_EmployeeMustBeOlder21ForFullTime()
RETURNS INTEGER
AS
BEGIN
DECLARE @RET INTEGER = 0 
IF EXISTS (SELECT EmployeeID, EmployeeFName, EmployeeLName, EmployeeDOB, CAST(DATEDIFF(day, GETDATE(), EmployeeDOB) / 365.25 AS INT) AS Age, E.EmployeeTypeID  
            FROM tblEMPLOYEE E
            JOIN tblEMPLOYEE_TYPE ET ON E.EmployeeTypeID = ET.EmployeeTypeID
            WHERE CAST(DATEDIFF(day, GETDATE(), EmployeeDOB) / 365.25 AS INT) < 21
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

-------------------------- Computed Columns --------------------------------------

-- 1. Total order in each state in the U.S.

CREATE FUNCTION FN_TotalOrderStates(@PK INT) 
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
CREATE FUNCTION FN_TotalOrderEachProduct(@PK INT)
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

ALTER TABLE tblORDER
ADD TotalOrderProduct AS (dbo.FN_TotalOrderEachProduct (ProductID)) 
GO

--------------------------------------------------------------
-- New GetCustomerID
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

CREATE PROC Ins_PopulateOrder
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

	IF @EmployeeID IS NULL
		THROW 54001, 'Employee not found', 1;

	BEGIN TRAN T1
		INSERT INTO tblORDER (OrderDate, CustomerID, EmployeeID)
		VALUES (@OrderDate, @CustomerID, @EmployeeID)

		DECLARE @OrderID INT = (SCOPE_IDENTITY())

		INSERT INTO tblORDER_PRODUCT (ProductID, OrderID, Quantity)
		VALUES (@ProductID, @OrderID, @Quantity)

		IF @@ERROR <> 0
		BEGIN
			ROLLBACK TRAN T1;
			THROW 54002, 'Something went wrong', 1;
		END
	COMMIT TRAN T1
GO
