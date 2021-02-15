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

INSERT INTO tblADDRESS(AddressLine1, AddressLine2, Zip, CityID, StateID)
VALUES (@AddressLine1, @AddressLine2, @Zip, @CityID, @StateID)

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
    DECLARE @RandomCityID INTEGER = FLOOR(RAND() * ((SELECT COUNT(*) FROM tblCITY)) + 1)
    DECLARE @RandomCityName VARCHAR(100) = (
        SELECT TOP 1 CityName 
        FROM tblCITY
        WHERE CityID = @RandomCityID
    )

    -- get the state associated with that city
    DECLARE @RandomStateName VARCHAR(100) = (
        SELECT StateName
        FROM tblSTATE
        WHERE StateID = (SELECT StateID FROM tblCITY WHERE CityID = @RandomCityID)
    )

    EXEC CreateNewAddress
    @AddressLine1  = 'Random address line 1',
    @AddressLine2 = 'Random address line 2',
    @Zip = '00000',
    @CityName = @RandomCityName,
    @StateName = @RandomStateName

    SET @Run = @Run + 1
    
    END
END
GO