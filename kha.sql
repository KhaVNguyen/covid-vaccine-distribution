USE INFO430_Proj_10

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

CREATE TABLE tblPRIORITY
(
    PriorityID INTEGER IDENTITY(1,1) PRIMARY KEY,
    PriorityName VARCHAR(50),
    PriorityDesc VARCHAR(1000)
);
GO


INSERT INTO tblPRIORITY (PriorityName, PriorityDesc)
VALUES 
    ('1A - LTCF & Healthcare Personnel', 'Long term care facility members and authorized front-line healthcare workers'),
    ('1B - 75+ & Frontline Essential Workers', 'Older people of 75+ years & frontline essential workers, key to functionality of critical operations'),
    ('1C - 65-74 & High Risk', 'Those between ages 65-74 or those with high risk medical conditions'),
    ('2 - Older Adults', 'Older adults not served in Phase 1 (ages 40+)'),
    ('3 - Young Adults & Children', 'Younger adults (ages 18-39) and children')
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

CREATE TABLE tblPACKAGE
(
    PackageID INTEGER IDENTITY(1,1) PRIMARY KEY,
    Order_ProductID INTEGER FOREIGN KEY REFERENCES tblORDER_PRODUCT(Order_ProductID),
    ShipmentID INTEGER FOREIGN KEY REFERENCES tblSHIPMENT(ShipmentID)
);
GO

CREATE PROCEDURE GetStateID
@S_Name VARCHAR(50),
@S_ID INT OUTPUT
AS
SET @S_ID = (SELECT StateID FROM tblSTATE WHERE StateName = @S_Name)
GO

CREATE PROCEDURE GetCityID
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
@C_ID = @CityID OUTPUT

EXEC GetStateID 
@S_Name = @A_StateName,
@S_ID = @StateID OUTPUT

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

CREATE PROCEDURE GetPriorityID 
@P_Name VARCHAR(50),
@P_ID INT OUTPUT 
AS
SET @P_ID = (SELECT PriorityID FROM tblPRIORITY WHERE PriorityName = @P_Name)
GO

/* needs to hook up with other people's code */
-- CREATE PROCEDURE GetCustomerID
-- @C_Fname VARCHAR(50),
-- @C_Lname VARCHAR(50),
-- @C_DOB DATE,
-- @C_Email VARCHAR(50),
-- @C_
-- AS
-- DECLARE @AddressID INT, @PriorityID INT, @CustomerTypeID INT

/* Data Inserting Procedures */

-- Populate our own database cities and states table with data from PEEPS
CREATE OR ALTER PROCEDURE 
PopulateCitiesAndStates
AS 
BEGIN
-- create temporary table 
SELECT CityName, StateName 
INTO #CitiesAndStatesTemp
FROM [PEEPS].[dbo].[tblCITY_STATE_ZIP]

DECLARE @Run INT = 1
DECLARE @NumRows INT = (SELECT COUNT(*) FROM #CitiesAndStatesTemp)

WHILE @Run <= @NumRows 
    BEGIN 
        DECLARE @City VARCHAR(50) = (SELECT TOP 1 CityName FROM #CitiesAndStatesTemp)
        DECLARE @State VARCHAR(50) = (SELECT TOP 1 StateName FROM #CitiesAndStatesTemp)
        DECLARE @StateCode VARCHAR(2) = (SELECT TOP 1 RIGHT(StateName, 2) FROM #CitiesAndStatesTemp)

        -- Insert into tblSTATE
        IF NOT EXISTS (
            SELECT * FROM tblSTATE
            WHERE StateName = @State
        )
        BEGIN
            INSERT INTO tblSTATE(StateName, StateCode)
            VALUES (@State, @StateCode)
        END

        -- Find StateID
        DECLARE @StateID INT = (
            SELECT StateID
            FROM tblSTATE
            WHERE StateName = @State
        )

        -- INSERT INTO tblCITY
        IF NOT EXISTS (
            SELECT * FROM tblCITY
            WHERE CityName = @City
        )
        BEGIN
            INSERT INTO tblCITY (CityName, StateID)
            VALUES (@City, @StateID)
        END

        -- Delete from temp table
        DELETE TOP(1)
        FROM #CitiesAndStatesTemp

        SET @Run = @Run + 1
    END 
END
GO

EXEC PopulateCitiesAndStates
GO

CREATE OR ALTER PROCEDURE 
CreateNewAddress
@AddressLine1 VARCHAR(100),
@AddressLine2 VARCHAR(100),
@Zip VARCHAR(5),
@CityName VARCHAR(100),
@StateName VARCHAR(100)
AS
BEGIN

DECLARE @CityID INT, @StateID INT

EXEC GetCityID 
@C_Name = @CityName,
@C_ID = @CityID OUTPUT
IF @CityID IS NULL 
    THROW 55000, 'City does not exist', 1

EXEC GetStateID 
@S_Name = @StateName,
@S_ID = @StateID OUTPUT
IF @StateID IS NULL
    THROW 55001, 'State does not exist', 1

IF (SELECT StateID FROM tblCITY WHERE CityID = @CityID) <> @StateID
    THROW 55002, 'This city is not in this state', 1

BEGIN TRANSACTION
INSERT INTO tblADDRESS(AddressLine1, AddressLine2, Zip, CityID, StateID)
VALUES (@AddressLine1, @AddressLine2, @Zip, @CityID, @StateID)
IF @@ERROR <> 0 
    ROLLBACK
ELSE 
    COMMIT
END 
GO


CREATE OR ALTER PROCEDURE 
PopulateAddresses
@NumberOfAddresses INTEGER
AS
BEGIN
DECLARE @Run INTEGER = 1
WHILE @Run <= @NumberOfAddresses
    BEGIN
    -- get a random city
    
    DECLARE @RandomCityName VARCHAR(100) = (
        SELECT TOP 1 CityName 
        FROM tblCITY
        ORDER BY NEWID()
    )

    -- get the state associated with that city
    DECLARE @RandomStateName VARCHAR(100) = (
        SELECT StateName
        FROM tblCITY
            JOIN tblSTATE ON tblCITY.StateID = tblSTATE.StateID
        WHERE CityName = @RandomCityName
    )

    DECLARE @RandomHouseNumber VARCHAR(5) = (
        SELECT TOP 1 HouseNumber 
        FROM [PEEPS].[dbo].[tblHOUSE_NUMBER]
        ORDER BY NEWID()
    )

    DECLARE @RandomStreetName VARCHAR(75) = (
        SELECT TOP 1 StreetName 
        FROM [PEEPS].[dbo].[tblSTREET_NAME] 
        ORDER BY NEWID()
    )

    
    DECLARE @RandomStreetSuffix VARCHAR(25) = (
        SELECT TOP 1 StreetSuffix 
        FROM [PEEPS].[dbo].[tblSTREET_SUFFIX] 
        ORDER BY NEWID()
    )
    
    DECLARE @RandomZip VARCHAR(75) = (
        SELECT TOP 1 Zip  
        FROM [PEEPS].[dbo].[tblCITY_STATE_ZIP] 
        ORDER BY NEWID()
    )

    DECLARE @RandomAddressLine1 VARCHAR(500) = CONCAT(@RandomHouseNumber, ' ', @RandomStreetName, ' ', @RandomStreetSuffix)

    EXEC CreateNewAddress
    @AddressLine1  = @RandomAddressLine1,
    @AddressLine2 = 'Random address line 2',
    @Zip = @RandomZip,
    @CityName = @RandomCityName,
    @StateName = @RandomStateName

    SET @Run = @Run + 1

    END
END
GO

EXEC PopulateAddresses
@NumberOfAddresses = 1000
GO

SELECT * FROM tblADDRESS
GO

-- Customers 
CREATE OR ALTER PROCEDURE 
CreateNewCustomer
@CustomerFname VARCHAR(50),
@CustomerLname VARCHAR(50),
@CustomerDOB DATE,
@CustomerAddressLine1 VARCHAR(100),
@CustomerAddressLine2 VARCHAR(100),
@CustomerZip VARCHAR(5),
@CustomerCityName VARCHAR(100),
@CustomerStateName VARCHAR(100),
@CustomerEmail VARCHAR(50),
@Priority VARCHAR(50),
@CustomerType VARCHAR(50)
AS
BEGIN

DECLARE @AddressID INT, @PriorityID INT, @CustomerTypeID INT

EXEC GetAddressID 
@A_Line1 = @CustomerAddressLine1,
@A_Line2 = @CustomerAddressLine2,
@A_Zip = @CustomerZip,
@A_CityName = @CustomerCityName,
@A_StateName = @CustomerStateName,
@A_ID = @AddressID OUTPUT

IF @AddressID IS NULL 
    BEGIN
        EXEC CreateNewAddress
        @AddressLine1 = @CustomerAddressLine1,
        @Addressline2 = @CustomerAddressLine2,
        @Zip = @CustomerZip,
        @CityName = @CustomerCityName, 
        @StateName = @CustomerStateName
    END

EXEC GetAddressID 
@A_Line1 = @CustomerAddressLine1,
@A_Line2 = @CustomerAddressLine2,
@A_Zip = @CustomerZip,
@A_CityName = @CustomerCityName,
@A_StateName = @CustomerStateName,
@A_ID = @AddressID OUTPUT

EXEC GetPriorityID
@P_Name = @Priority,
@P_ID = @PriorityID OUTPUT
IF @PriorityID IS NULL 
    THROW 58000, 'Priority does not exist', 1

-- Get Customer Type ID
EXEC GetCustomerTypeID
@_CustomerTypeName = @CustomerType,
@_OUT = @CustomerTypeID OUTPUT
IF @CustomerTypeID IS NULL 
    THROW 59000, 'Customer type does not exist', 1

BEGIN TRANSACTION
INSERT INTO tblCUSTOMER (CustomerFname, CustomerLname, CustomerDOB, CustomerEmail, AddressID, PriorityID, CustomerTypeID)
VALUES (@CustomerFname, @CustomerLname, @CustomerDOB, @CustomerEmail, @AddressID, @PriorityID, @CustomerTypeID)

IF @@ERROR <> 0 
    ROLLBACK
ELSE 
    COMMIT
END 
GO

CREATE OR ALTER PROCEDURE 
PopulateCustomers
@NumberOfCustomers INT
AS 
BEGIN
DECLARE @Run INTEGER = 1
WHILE @Run <= @NumberOfCustomers
    BEGIN

    -- Generate random address
     DECLARE @RandomCityName VARCHAR(100) = (
        SELECT TOP 1 CityName 
        FROM tblCITY
        ORDER BY NEWID()
    )

    -- get the state associated with that city
    DECLARE @RandomStateName VARCHAR(100) = (
        SELECT StateName
        FROM tblCITY
            JOIN tblSTATE ON tblCITY.StateID = tblSTATE.StateID
        WHERE CityName = @RandomCityName
    )

    DECLARE @RandomHouseNumber VARCHAR(5) = (
        SELECT TOP 1 HouseNumber 
        FROM [PEEPS].[dbo].[tblHOUSE_NUMBER]
        ORDER BY NEWID()
    )

    DECLARE @RandomStreetName VARCHAR(75) = (
        SELECT TOP 1 StreetName 
        FROM [PEEPS].[dbo].[tblSTREET_NAME] 
        ORDER BY NEWID()
    )

    
    DECLARE @RandomStreetSuffix VARCHAR(25) = (
        SELECT TOP 1 StreetSuffix 
        FROM [PEEPS].[dbo].[tblSTREET_SUFFIX] 
        ORDER BY NEWID()
    )
    
    DECLARE @RandomZip VARCHAR(75) = (
        SELECT TOP 1 Zip  
        FROM [PEEPS].[dbo].[tblCITY_STATE_ZIP] 
        ORDER BY NEWID()
    )

    DECLARE @RandomAddressLine1 VARCHAR(500) = CONCAT(@RandomHouseNumber, ' ', @RandomStreetName, ' ', @RandomStreetSuffix)

    -- Generate customer info 
    DECLARE @RandomFirstName VARCHAR(50) = (
        SELECT TOP 1 FirstName 
        FROM [PEEPS].[dbo].[tblFIRST_NAME]
        ORDER BY NEWID()
    )

    DECLARE @RandomLastName VARCHAR(50) = (
        SELECT TOP 1 LastName 
        FROM [PEEPS].[dbo].[tblLAST_NAME]
        ORDER BY NEWID()
    )

    DECLARE @RandomEmail VARCHAR(50) = CONCAT(@RandomFirstName, @RandomLastName, '@gmail.com')

    DECLARE @RandomDateOfBirth DATE = DATEADD(DAY, -(ABS(CHECKSUM(NEWID()) % 36500 )), getdate())


    DECLARE @RandomPriority VARCHAR(50) = (
        SELECT TOP 1 PriorityName 
        FROM tblPRIORITY
        ORDER BY NEWID()
    )

    DECLARE @RandomCustomerType VARCHAR(50) = (
        SELECT TOP 1 CustomerTypeName 
        FROM tblCUSTOMER_TYPE
        ORDER BY NEWID()
    )

    EXEC CreateNewCustomer
    @CustomerFname = @RandomFirstName,
    @CustomerLname = @RandomLastName,
    @CustomerDOB = @RandomDateOfBirth,
    @CustomerAddressLine1 = @RandomAddressLine1,
    @CustomerAddressLine2 = 'Random address line 2',
    @CustomerZip = @RandomZip,
    @CustomerCityName = @RandomCityName,
    @CustomerStateName = @RandomStateName,
    @CustomerEmail = @RandomEmail,
    @Priority = @RandomPriority,
    @CustomerType = @RandomCustomerType

    SET @Run = @Run + 1

    END
END
GO

-- Run populate customers: 
SELECT * FROM tblCUSTOMER
SELECT * FROM tblADDRESS
SELECT * FROM tblORDER

DELETE FROM tblCUSTOMER
DELETE FROM tblADDRESS

EXEC PopulateCustomers
@NumberOfCustomers = 10
GO

-- Business Rules 
CREATE FUNCTION fn_AddressCityMustBeInState()
RETURNS INTEGER
AS
BEGIN
DECLARE @RET INTEGER = 0
	IF EXISTS 
    (
		SELECT *
		FROM tblADDRESS
        JOIN tblCITY ON tblADDRESS.CityID = tblCITY.CityID
		WHERE tblADDRESS.StateID <> tblCITY.StateID
	)
	BEGIN
		SET @RET = 1
	END
RETURN @RET
END
GO

CREATE FUNCTION fn_50StatesMax()
RETURNS INTEGER
AS
BEGIN
DECLARE @RET INTEGER = 0
	IF  
    (
		SELECT COUNT(*)
		FROM tblSTATE
	) > 50
	BEGIN
		SET @RET = 1
	END
RETURN @RET
END
GO

ALTER TABLE tblSTATE with nocheck
ADD CONSTRAINT CK_50StatesMax
CHECK (dbo.fn_50StatesMax() = 0)
GO

-- Computed Columns
CREATE FUNCTION fn_NumAddressLines(@PK INT)
RETURNS INT
AS
BEGIN
    DECLARE @RET INT = 0
    IF (
        SELECT AddressLine1 
        FROM tblADDRESS
        WHERE AddressID = @PK
    ) IS NOT NULL 
    BEGIN 
        SET @Ret = @Ret + 1
    END
    IF (
        SELECT AddressLine2 
        FROM tblADDRESS
        WHERE AddressID = @PK
    ) IS NOT NULL 
    BEGIN 
        SET @Ret = @Ret + 1
    END
	RETURN @RET
END
GO

ALTER TABLE tblADDRESS
ADD NumAddressLines AS (dbo.fn_NumAddressLines(AddressID))
GO

CREATE FUNCTION fn_CustomerAge(@PK INT)
RETURNS INT
AS
BEGIN
	DECLARE @RET INT = (
        SELECT FLOOR(DATEDIFF(DAY, CustomerDOB, GETDATE()) / 365.25) 
        FROM tblCUSTOMER
        WHERE CustomerID = @PK
    )
	RETURN @RET
END
GO

ALTER TABLE tblCUSTOMER
ADD CustomerAge AS (dbo.fn_CustomerAge(CustomerID))
GO

-- Views
CREATE VIEW CustomerShippingLabelTop10PrioritySeattle AS
SELECT TOP 10 PriorityID, CustomerFname, CustomerLname, AddressLine1, AddressLine2, Zip, CityName, StateName 
FROM tblCUSTOMER
    JOIN tblADDRESS ON tblCUSTOMER.AddressID = tblADDRESS.AddressID
    JOIN tblCITY ON tblADDRESS.CityID = tblCITY.CityID
    JOIN tblSTATE ON tblCITY.StateID = tblSTATE.StateID 
WHERE CityName = 'Seattle' AND StateName = 'Washington, WA'
ORDER BY PriorityID ASC
GO


SELECT * FROM tblCUSTOMER_TYPE