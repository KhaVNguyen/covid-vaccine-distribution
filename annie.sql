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
)
GO

-------------------------- Insert Sproc --------------------------------------

-- Insert shipment 
CREATE PROCEDURE Ins_Shipment
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
/*CREATE OR ALTER PROCEDURE PopulateEmployeeInfo
AS
BEGIN
SELECT S.StaffFName, S.StaffLName, S.StaffBirth, PT.PositionTypeName 
    FROM UNIVERSITY.dbo.tblSTAFF S
    JOIN UNIVERSITY.dbo.tblSTAFF_POSITION SP ON S.StaffID = SP.StaffID
    JOIN UNIVERSITY.dbo.tblPOSITION P ON SP.PositionID = P.PositionID
    JOIN UNIVERSITY.dbo.tblPOSITION_TYPE PT ON P.PositionTypeID = PT.PositionTypeID

DECLARE @Run INT = 1
DECLARE @NumRows INT = (SELECT COUNT(*) FROM UNIVERSITY.dbo.tblSTAFF)
DECLARE @Emp_Firsty VARCHAR(20),@Emp_Lasty VARCHAR(20), @Emp_Birthy DATE, @Emp_Type VARCHAR(20), @Emp_TypeID INT

WHILE @Run <= @NumRows
    BEGIN
            SET @Emp_Firsty = (SELECT TOP 1 StaffFName FROM #EmployeeWorkingData)
            SET @Emp_Lasty = (SELECT TOP 1 StaffLName FROM #EmployeeWorkingData)
            SET @Emp_Birthy = (SELECT TOP 1 StaffBirth FROM #EmployeeWorkingData)
            SET @Emp_Type = (SELECT TOP 1 PositionTypeName FROM #EmployeeWorkingData)
        
            EXEC GetEmployeeTypeID
            @ET_Name = @Emp_Type,
            @ET_ID = @Emp_TypeID OUTPUT

            INSERT INTO tblEMPLOYEE(EmployeeFName, EmployeeLName, EmployeeDOB, EmployeeTypeID)
            VALUES(@Emp_Firsty, @Emp_Lasty, @Emp_Birthy, @Emp_TypeID)
            --DELETE TOP(1) FROM #EmployeeWorkingData
        SET @RUN = @RUN + 1
    END
END

SELECT TOP 10 * FROM UNIVERSITY.dbo.tblSTAFF*/

CREATE OR ALTER PROCEDURE PopulateEmployee
@NumsEmp INTEGER
AS
BEGIN
DECLARE @Run INT = 1
WHILE @Run <= @NumsEmp
    BEGIN 
        DECLARE @RandEmpID INTEGER = FLOOR(RAND() * (SELECT COUNT(*) FROM UNIVERSITY.dbo.tblSTAFF) + 1)
        DECLARE @RandEmpFName VARCHAR(20) = (SELECT StaffFName FROM UNIVERSITY.dbo.tblSTAFF WHERE StaffID = @RandEmpID)
        DECLARE @RandEmpLName VARCHAR(20) = (SELECT StaffLName FROM UNIVERSITY.dbo.tblSTAFF WHERE StaffID = @RandEmpID)
        DECLARE @RandEmpDOB DATE = (SELECT StaffBirth FROM UNIVERSITY.dbo.tblSTAFF WHERE StaffID = @RandEmpID)
        DECLARE @RandEmpType VARCHAR(20) = (SELECT PT.PositionTypeName 
    FROM UNIVERSITY.dbo.tblSTAFF S
    JOIN UNIVERSITY.dbo.tblSTAFF_POSITION SP ON S.StaffID = SP.StaffID
    JOIN UNIVERSITY.dbo.tblPOSITION P ON SP.PositionID = P.PositionID
    JOIN UNIVERSITY.dbo.tblPOSITION_TYPE PT ON P.PositionTypeID = PT.PositionTypeID WHERE S.StaffID = @RandEmpID)

        EXEC Ins_Employee
        @Ins_EmpFName = @RandEmpFName,
        @Ins_EmpLName = @RandEmpLName,
        @Ins_EmpDOB = @RandEmpDOB,
        @Ins_EmpTypeName = @RandEmpType

        SET @Run = @Run + 1

        END
    END
GO

SELECT * FROM tblEMPLOYEE





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

-- 2. Employee with less than 18 years old should not be full-time
CREATE OR ALTER FUNCTION fn_EmployeeMustBeOlder18ForFullTime()
RETURNS INTEGER
AS
BEGIN
DECLARE @RET INTEGER = 0 
IF EXISTS (SELECT EmployeeID, EmployeeFName, EmployeeLName, EmployeeDOB, CAST(DATEDIFF(day, GETDATE(), EmployeeDOB) / 365.25 AS INT) AS Age, E.EmployeeTypeID  
            FROM tblEMPLOYEE E
            JOIN tblEMPLOYEE_TYPE ET ON E.EmployeeTypeID = ET.EmployeeTypeID
            WHERE CAST(DATEDIFF(day, GETDATE(), EmployeeDOB) / 365.25 AS INT) < 18
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
ADD CONSTRAINT CK_EmployeeMustBeOlder18ForFullTime
CHECK (dbo.fn_EmployeeMustBeOlder18ForFullTime() = 0)
GO

-------------------------- Computed Columns --------------------------------------

-- need to check 
-- 1. Top 10 order states

CREATE FUNCTION FN_Top10_OrderStates (@PK INT) 
RETURNS INT
AS
BEGIN

DECLARE @RET INT = (SELECT TOP 10 COUNT(O.OrderID) AS NumOrder, S.StateName
FROM tblORDER O
    JOIN tblCUSTOMER CS ON O.CustomerID = CS.CustomerID
    JOIN tblADDRESS A ON CS.AddressID = A.AddressID
    JOIN tblCITY C ON A.CityID = C.CityID
    JOIN tblSTATE S ON C.StateID = S.StateID
)

RETURN @RET
END
GO

ALTER TABLE tblROOM
ADD TototalAmenityPoints AS (dbo.FN_TotalRoomAmenities (RoomID)) 
GO

-- 2.
