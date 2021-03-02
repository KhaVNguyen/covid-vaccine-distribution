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
CREATE PROCEDURE GetShipmentTypeID
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
CREATE PROCEDURE GetCarrierID
    @CR_Name    VARCHAR(50),
    @C_CityName VARCHAR(50),
    @CR_ID      INT OUTPUT
AS
IF @CR_Name IS NULL OR @C_CityName IS NULL
    THROW 50202, 'Carrier Name or City Name is null', 1; 
DECLARE @CityID INT

-- Combined from Kha
EXEC GetCityID
@C_Name = @C_CityName,
@C_ID = @CityID

SET @CR_ID = (
    SELECT CarrierID
    FROM tblCARRIER
    WHERE CarrierName = @CR_Name
    AND CityID = @CityID
)
GO

-- GET ShipmentID (with FK ShipmentType and FK Carrier)
CREATE PROCEDURE GetShipmentID
    @SP_TrackingNum         VARCHAR(50),
    @SP_Date                DATETIME,
    @SP_ShipmentTypeName    VARCHAR(50),
    @SP_CarrierName         VARCHAR(50),
    @SP_CityName            VARCHAR(50),
    @SP_ID                  INT OUTPUT
AS
IF @SP_TrackingNum IS NULL OR @SP_Date IS NULL OR @SP_ShipmentTypeName IS NULL OR 
    @SP_CarrierName IS NULL OR @SP_CityName IS NULL 
    THROW 50203, 'None of parameter should not be null', 1; 
DECLARE @ShipmentTypeID INT, @CarrierID INT

EXEC GetShipmentTypeID
@ST_Name = @SP_ShipmentTypeName,
@ST_ID = @ShipmentTypeID 

EXEC GetCarrierID
@CR_Name = @SP_CarrierName,
@C_CityName = @SP_CityName,
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
CREATE PROCEDURE GetEmployeeTypeID
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
CREATE PROCEDURE GetEmployeeID
    @E_FName            VARCHAR(50),
    @E_LName            VARCHAR(50),
    @E_DOB              DATE,
    @E_EmployeeTypeName VARCHAR(50),
    @E_ID        INT OUTPUT
AS 
IF @E_FName IS NULL OR @E_LName IS NULL OR @E_DOB IS NULL OR 
    @E_EmployeeTypeName IS NULL
    THROW 50205, 'None of parameter should not be null', 1; 
DECLARE @EmployeeTypeID INT

EXEC GetEmployeeTypeID
@ET_Name = @E_EmployeeTypeName,
@ET_ID = @EmployeeTypeID

SET @E_ID = (
    SELECT EmployeeID
    FROM tblEMPLOYEE
    WHERE EmployeeFName = @E_LName
    AND EmployeeLName = @E_LName
    AND EmployeeDOB = @E_DOB
    AND EmployeeTypeID = @EmployeeTypeID
)
GO

-- GET OrderID (with FK EmployeeID and FK Customer)
CREATE PROCEDURE GetOrderID
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
@E_ID = @EmployeeID

-- combined from Kha 
EXEC GetCustomerID
@C_Fname = @OR_CustFname,
@C_Lname = @OR_CustLname,
@C_DOB = @OR_CustDOB,
@C_Email= @OR_CustEmail,
@C_ID = @CustomerID

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
SELECT *, ROW_NUMBER() OVER(ORDER BY CityID) AS I INTO Temp FROM tblCITY
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
     DROP TABLE Temp

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
    @InsSP_CarrierName         VARCHAR(50),
    @InsSP_CityName            VARCHAR(50)
AS 
BEGIN
DECLARE @ShipmentTypeID INT, @CarrierID INT

EXEC GetShipmentTypeID
@ST_Name = @InsSP_ShipmentTypeName,
@ST_ID = @ShipmentTypeID OUTPUT

EXEC GetCarrierID
@CR_Name = @InsSP_CarrierName,
@C_CityName = @InsSP_CityName,
@CR_ID = @CarrierID OUTPUT

    IF @ShipmentTypeID IS NULL OR @CarrierID IS NULL 
        THROW 50207, '@ShipmentTypeID or @CarrierID not found', 1;
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


CREATE PROCEDURE PopulateShipment
@NumsShipment INT
AS
DECLARE @Run INT = 1
DECLARE @Shipment_TrackingNum VARCHAR(50), @Shipment_Date DATETIME, @Shipment_TypeName VARCHAR(50), @Shipment_CarrierName VARCHAR(50), @Shipment_CityName VARCHAR(50)
DECLARE @ShipmentTypeCount INT = (SELECT COUNT(*) FROM tblSHIPMENT_TYPE)
DECLARE @CarrierCount INT = (SELECT COUNT(*) FROM tblCARRIER)
DECLARE @ShipmentType_ID INT, @Carrier_ID INT
WHILE @RUN <= @NumsShipment
    BEGIN
            -- Get random shipmentTypeID 
            SET @ShipmentType_ID = (SELECT RAND() * @ShipmentTypeCount + 1)
            SET @Shipment_TypeName = (SELECT ShipmentTypeName FROM tblSHIPMENT_TYPE WHERE ShipmentTypeID = @ShipmentType_ID)
            -- Get random carrierID
            SET @Carrier_ID = (SELECT RAND() * @CarrierCount + 1)
            SET @Shipment_CarrierName = (SELECT CarrierName FROM tblCARRIER WHERE CarrierID = @Carrier_ID)
            SET @Shipment_CityName = (SELECT C.CityName FROM tblCITY C JOIN tblCARRIER CR
                                                        ON C.CityID = CR.CityID WHERE CarrierID = @Carrier_ID)
            EXEC Ins_Shipment
            @InsSP_TrackingNum = @Shipment_TrackingNum,
            @InsSP_Date = @Shipment_Date,
            @InsSP_ShipmentTypeName = @Shipment_TypeName,
            @InsSP_CarrierName = @Shipment_CarrierName,
            @InsSP_CityName = @Shipment_CityName
        SET @RUN = @RUN + 1
    END
GO
-- Test 
EXEC PopulateShipment
@NumsShipment = 10000

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