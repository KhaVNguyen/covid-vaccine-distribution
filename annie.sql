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
    THROW 50001, 'ShipmentTypeName is null', 1; 
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
    THROW 50002, 'Carrier Name or City Name is null', 1; 
DECLARE @CityID INT

EXEC GetCityID
@C_Name = @C_CityName
@C_ID = @CityID

SET @CR_ID = (
    SELECT CarrierID
    FROM tblCARRIER
    WHERE CarrierName = @CR_Name
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
    THROW 50003, 'None of parameter should not be null', 1; 
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
)
GO

-- GET EmployeeTypeID
CREATE PROCEDURE GetEmployeeTypeID
    @ET_Name     VARCHAR(50),
    @ET_ID       INT OUTPUT 
AS 
IF @ET_Name IS NULL
    THROW 50004, 'EmployeeTypeName is null', 1; 
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
    THROW 50005, 'None of parameter should not be null', 1; 
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
    THROW 50006, 'None of parameter should not be null', 1;

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
)
GO

