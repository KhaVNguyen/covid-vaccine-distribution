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

CREATE PROCEDURE GetAddressID
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
CREATE PROCEDURE 
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
        
        -- Insert into tblSTATE
        IF NOT EXISTS (
            SELECT * FROM tblSTATE
            WHERE StateName = @State
        )
        BEGIN
            INSERT INTO tblSTATE(StateName)
            VALUES (@State)
        END

        -- Find StateID
        DECLARE @StateID INT = (
            SELECT StateID
            FROM tblSTATE
            WHERE StateName = @State
        )

        -- INSERT INTO tblCITY
        INSERT INTO tblCITY(CityName, StateID)
        VALUES (@City, @StateID)

        -- Delete from temp table
        DELETE TOP(1)
        FROM #CitiesAndStatesTemp

        SET @Run = @Run + 1
    END 
END
GO


CREATE PROCEDURE 
CreateNewAddress
@AddressLine1 VARCHAR(100),
@AddressLine2 VARCHAR(100),
@Zip VARCHAR(5),
@CityName INTEGER,
@StateName INTEGER
AS
BEGIN

DECLARE @CityID INT, @StateID INT

EXEC GetCityID 
@C_Name = @CityName,
@C_ID = @CityID
IF @CityID IS NULL 
    THROW 55000, 'City does not exist', 1

EXEC GetStateID 
@S_Name = @StateName,
@S_ID = @StateID
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

CREATE PROCEDURE 
PopulateAddresses
@NumberOfAddresses INTEGER
AS
BEGIN
DECLARE @Run INT = 1
WHILE @Run <= @NumberOfAddresses
    BEGIN
    -- get a random city
    DECLARE @RandomCityID INTEGER = FLOOR(RAND() * (SELECT COUNT(*) FROM tblCITY) + 1)
    DECLARE @RandomCityName VARCHAR(100) = (
        SELECT CityName 
        FROM tblCITY
        WHERE CityID = @RandomCityID
    )

    -- get the state associated with that city
    DECLARE @RandomStateName VARCHAR(100) = (
        SELECT StateName
        FROM tblSTATE
        WHERE StateID = (SELECT StateID FROM tblCITY WHERE CityID = @RandomCityID)
    )

    DECLARE @RandomHouseNumberID INTEGER = FLOOR(RAND() * (SELECT COUNT(*) FROM [PEEPS].[dbo].[tblHOUSE_NUMBER]) + 1)
    DECLARE @RandomHouseNumber VARCHAR(5) = (SELECT HouseNumber  FROM [PEEPS].[dbo].[tblHOUSE_NUMBER] WHERE HouseNumID = @RandomHouseNumberID)

    DECLARE @RandomStreetNameID INTEGER = FLOOR(RAND() * (SELECT COUNT(*) FROM [PEEPS].[dbo].[tblSTREET_NAME]) + 1)
    DECLARE @RandomStreetName VARCHAR(75) = (SELECT StreetName FROM [PEEPS].[dbo].[tblSTREET_NAME] WHERE StreetNameID = @RandomStreetNameID)
    
    DECLARE @RandomStreetSuffixID INTEGER = FLOOR(RAND() * (SELECT COUNT(*) FROM [PEEPS].[dbo].[tblSTREET_SUFFIX]) + 1)
    DECLARE @RandomStreetSuffix VARCHAR(25) = (SELECT StreetSuffix FROM [PEEPS].[dbo].[tblSTREET_SUFFIX] WHERE StreetSuffixID = @RandomStreetSuffixID)
    
    DECLARE @RandomCityStateZipID INTEGER = FLOOR(RAND() * (SELECT COUNT(*) FROM [PEEPS].[dbo].tblCITY_STATE_ZIP) + 1)
    DECLARE @RandomZip VARCHAR(5) = (SELECT Zip FROM [PEEPS].[dbo].[tblCITY_STATE_ZIP] WHERE CityStateZipID = @RandomCityStateZipID)

    DECLARE @RandomAddressLine1 VARCHAR(105) = CONCAT(@RandomHouseNumber, ' ', @RandomStreetName, ' ', @RandomStreetSuffix)

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