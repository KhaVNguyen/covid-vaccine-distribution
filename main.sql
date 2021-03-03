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
    CarrierName VARCHAR(50) NOT NULL,
    CityID INTEGER FOREIGN KEY REFERENCES tblCITY(CityID) -- DO NOT NEED
);
GO

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

/* needs to hook up with other people's code */
/* Please add error handling :) */
CREATE PROCEDURE GetCustomerID
@C_Fname VARCHAR(50),
@C_Lname VARCHAR(50),
@C_DOB DATE,
@C_Email VARCHAR(50),
@C_CustTypeName VARCHAR(50),
@C_Pname VARCHAR(50),
@C_ALine1 VARCHAR(100),
@C_ALine2 VARCHAR(100),
@C_AZip VARCHAR(5),
@C_ACityName VARCHAR(50),
@C_AStateName VARCHAR(50),
@C_ID INT OUTPUT
AS
DECLARE @AddressID INT, @PriorityID INT, @CustomerTypeID INT

EXEC GetAddressID
@A_Line1 = @C_ALine1,
@A_Line2 = @C_ALine2,
@A_Zip = @C_AZip,
@A_CityName = @C_ACityName,
@A_StateName = @C_AStateName,
@A_ID = @AddressID

IF @AddressID IS NULL
    THROW 50300, 'Could not find that address', 1;

-- combined from Kha
EXEC GetPriorityID
@P_Name = @C_Pname,
@P_ID = @PriorityID

IF @PriorityID IS NULL
    THROW 50301, 'Could not find that priority type', 1;

EXEC GetCustomerTypeID
@_CustomerTypeName = @C_CustTypeName,
@_Out = @CustomerTypeID

IF @CustomerTypeID IS NULL
    THROW 50301, 'Could not find that customer type', 1;

SET @C_ID = (
    SELECT CustomerID
    FROM tblCUSTOMER
    WHERE CustomerFname = @C_Fname
        AND CustomerLname = @C_Lname
        AND CustomerDOB = @C_DOB
        AND CustomerEmail = @C_Email
        AND AddressID = @AddressID
        AND PriorityID = @PriorityID
        AND CustomerTypeID = @CustomerTypeID
)


GO



-- Annie
-- GET ShipmentTypeID
CREATE OR ALTER PROCEDURE GetShipmentTypeID
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
CREATE OR ALTER PROCEDURE GetCarrierID
    @CR_Name    VARCHAR(50),
    @CR_ID      INT OUTPUT
AS
IF @CR_Name IS NULL
    THROW 50202, 'Carrier Name or City Name is null', 1;

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
IF @SP_TrackingNum IS NULL OR @SP_Date IS NULL OR @SP_ShipmentTypeName IS NULL OR
    @SP_CarrierName IS NULL
    THROW 50203, 'None of parameter should not be null', 1;
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
IF @ET_Name IS NULL
    THROW 50204, 'EmployeeTypeName is null', 1;
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
CREATE OR ALTER PROCEDURE GetOrderID
    @OR_Date            DATETIME,
    @OR_EmpFName        VARCHAR(50),
    @OR_EmpLName        VARCHAR(50),
    @OR_EmpDOB          DATE,
    @OR_EmpTypeName     VARCHAR(50),
    @OR_CustFname       VARCHAR(50),
    @OR_CustLname       VARCHAR(50),
    @OR_CustDOB         DATE,
    @OR_CustEmail       VARCHAR(50),
    @OR_CustTypeName VARCHAR(50),
    @OR_Pname VARCHAR(50),
    @OR_ALine1 VARCHAR(100),
    @OR_ALine2 VARCHAR(100),
    @OR_AZip VARCHAR(5),
    @OR_ACityName VARCHAR(50),
    @OR_AStateName VARCHAR(50),
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
    @OR_CustEmail IS NULL OR
    @OR_CustTypeName IS NULL OR
    @OR_Pname IS NULL OR
    @OR_ALine1 IS NULL OR
    @OR_ALine2 IS NULL OR
    @OR_AZip IS NULL OR
    @OR_ACityName IS NULL OR
    @OR_AStateName IS NULL
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
@C_CustTypeName = @OR_CustTypeName,
@C_Pname = @OR_Pname,
@C_ALine1 = @OR_ALine1,
@C_ALine2 = @OR_ALine2,
@C_AZip = @OR_AZip,
@C_ACityName = @OR_ACityName,
@C_AStateName = @OR_AStateName,
@C_ID = @CustomerID

SET @OR_ID = (
    SELECT OrderID
    FROM tblORDER
    WHERE OrderDate = @OR_Date
        AND CustomerID = @CustomerID
        AND EmployeeID = @EmployeeID
)
GO
---------------------------------------------------------------------------------------------------
-- Insert Stored Procedure
---------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------
-- Populating Data
---------------------------------------------------------------------------------------------------
--code here

---------------------------------------------------------------------------------------------------
-- Synthetic Trans
---------------------------------------------------------------------------------------------------
--code here


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
SELECT * FROM tblCUSTOMER_TYPE -- not done yet
SELECT * FROM tblDETAIL -- not done yet

-- tables with FK
SELECT * FROM tblCARRIER
SELECT * FROM tblPACKAGE -- not done yet
SELECT * FROM tblORDER -- not done yet
SELECT * FROM tblORDER_PRODUCT -- not done yet
SELECT * FROM tblPRODUCT -- not done yet
SELECT * FROM tblPRODUCT_DETAIL -- not done yet
SELECT * FROM tblSUPPLIER -- not done yet
SELECT * FROM tblEMPLOYEE
SELECT * FROM tblCUSTOMER
SELECT * FROM tblSHIPMENT -- not done yet
SELECT * FROM tblCITY
SELECT * FROM tblADDRESS
