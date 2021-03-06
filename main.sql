USE INFO430_Proj_10
GO

---------------------------------------------------------------------------------------------------
-- Shipping process Tables
---------------------------------------------------------------------------------------------------

-- Made by Kha
CREATE TABLE tblSTATE
(
    StateID INTEGER IDENTITY(1,1) PRIMARY KEY,
    StateName VARCHAR(50) NOT NULL,
    StateCode VARCHAR(2) NOT NULL
);
GO

-- Made by Kha
CREATE TABLE tblCITY
(
    CityID INTEGER IDENTITY(1,1) PRIMARY KEY,
    CityName VARCHAR(50) NOT NULL,
    StateID INTEGER FOREIGN KEY REFERENCES tblSTATE(StateID)
);
GO

-- Made by Kha
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

-- Made by Jisu
CREATE TABLE tblCARRIER
(
    CarrierID INTEGER IDENTITY(1,1) PRIMARY KEY,
    CarrierName VARCHAR(50) NOT NULL
);
GO

-- Made by Jisu
CREATE TABLE tblSHIPMENT_TYPE
(
    ShipmentTypeID INTEGER IDENTITY(1,1) PRIMARY KEY,
    ShipmentTypeName VARCHAR(50) NOT NULL,
    ShipmentTypeDesc VARCHAR(1000) NOT NULL
);
GO

-- Made by Jisu
CREATE TABLE tblSHIPMENT
(
    ShipmentID INTEGER IDENTITY(1,1) PRIMARY KEY,
    TrackingNumber VARCHAR(50) NOT NULL,
    ShippingDate DATETIME NOT NULL,
    ShipmentTypeID INTEGER FOREIGN KEY REFERENCES tblSHIPMENT_TYPE(ShipmentTypeID),
    CarrierID INTEGER FOREIGN KEY REFERENCES tblCARRIER(CarrierID)
);
GO

-- Made by Jisu
CREATE TABLE tblEMPLOYEE_TYPE
(
    EmployeeTypeID INTEGER IDENTITY(1,1) PRIMARY KEY,
    EmployeeTypeName VARCHAR(50) NOT NULL,
    EmployeeTypeDesc VARCHAR(1000) NOT NULL
);
GO

-- Made by Jisu
CREATE TABLE tblEMPLOYEE
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
-- Made by Kha
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

-- Made by Jisu
CREATE TABLE tblORDER
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

-- Made by Kha
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
-- Made by Tom
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

-- Made by Kha
CREATE OR ALTER PROCEDURE GetStateID
@S_Name VARCHAR(50),
@S_ID INT OUTPUT
AS
SET @S_ID = (SELECT StateID FROM tblSTATE WHERE StateName = @S_Name)
GO

-- Made by Kha
CREATE OR ALTER PROCEDURE GetCityID
@C_Name VARCHAR(50),
@C_ID INT OUTPUT
AS
SET @C_ID = (SELECT CityID FROM tblCITY WHERE CityName = @C_Name)
GO

-- Made by Kha
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

-- Made by Kha
CREATE OR ALTER PROCEDURE GetPriorityID
@P_Name VARCHAR(50),
@P_ID INT OUTPUT
AS
SET @P_ID = (SELECT PriorityID FROM tblPRIORITY WHERE PriorityName = @P_Name)
GO

-- Made by Kha
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

-- Made by Jisu
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

-- Made by Jisu
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

-- Made by Jisu
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

-- Made by Jisu
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

-- Made by Jisu
CREATE OR ALTER PROCEDURE GetEmployeeID
    @E_FName            VARCHAR(50),
    @E_LName            VARCHAR(50),
    @E_DOB              DATE,
    @E_ID        INT OUTPUT
AS
SET @E_ID = (
    SELECT EmployeeID
    FROM tblEMPLOYEE
    WHERE EmployeeFName = @E_FName
        AND EmployeeLName = @E_LName
        AND EmployeeDOB = @E_DOB
)
GO

-- Made by Jisu
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

-- Made by Kha
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
-- Made by Jisu
-- EMPLOYEE DATA
CREATE TABLE  tblRAW_EmpData-- CREATE SCRIPT TABLE
(Emp_PK_ID INT IDENTITY (1,1) primary key,
Emp_FName VARCHAR(50) NOT NULL,
Emp_LName VARCHAR(50) NOT NULL,
Emp_DOB DATE NOT NULL)

-- Made by Jisu
INSERT INTO tblRAW_EmpData -- INSERT DATA FROM ORIGINAL TABLE/DATASET
(Emp_FName, Emp_LName, Emp_DOB)
SELECT CustomerFname, CustomerLname, DateOfBirth
FROM PEEPS.dbo.tblCUSTOMER

-- Made by Jisu
-- EMPLOYEE TYPE DATA
INSERT INTO tblEMPLOYEE_TYPE(EmployeeTypeName, EmployeeTypeDesc)
VALUES('Part-Time', ''), ('Full-Time', ''), ('Contingent', ''), ('Temporary', ''),  ('Executive', '')

-- Made by Jisu
-- Shipment Type Data
INSERT INTO tblSHIPMENT_TYPE(ShipmentTypeName, ShipmentTypeDesc)
VALUES('Priority Express', 'Estimated 1-2 days or Overnight'), ('Priority', 'Estimated 1-3 days'), ('Parcel', 'Estimated 2-8 days'), ('First Class', 'Estimated 1–3 days up to 13 oz')

-- Made by Jisu
-- Carrier Data
INSERT INTO tblCARRIER(CarrierName)
VALUES('UPS'),('USPS'),('DHL'),('FedEx')
GO

-- Made by Tom
-- The data below is taken from https://en.wikipedia.org/wiki/COVID-19_vaccine
IF NOT EXISTS (SELECT TOP 1 * FROM tblSUPPLIER)
	INSERT INTO tblSUPPLIER (SupplierName, SupplierDesc) VALUES
	('Pfizer�BioNTech', 'The best vaccine right now, collaborate effort from United States and Germany.'),
	('Gamaleya Research Institute', 'The first ever vaccine from Russia.'),
	('Oxford�AstraZeneca', 'Also a good vaccine from United Kingdom.'),
	('Sinopharm', 'Kinda shady vaccine from China.'),
	('Sinovac', 'Also kinda shady vaccine from China.'),
	('Moderna', 'On par with Pfizer, and made from United States.'),
	('Johnson & Johnson', 'This is the new one from United States and Netherlands.')

-- Made by Tom
IF NOT EXISTS (SELECT TOP 1 * FROM tblDETAIL)
	INSERT INTO tblDETAIL (DetailName, DetailDesc) VALUES
	('Minimum Temperature', 'Minimum temperature in celsius that the product can withstand.'),
	('Maximum Temperature', 'Maximum temperature in celsius that the product can withstand'),
	('Recommended Temperature', 'Recommended temperature in celsius for storing the product'),
	('Weight', 'Weight in grams for a single product unit.')

-- Made by Tom
IF NOT EXISTS (SELECT TOP 1 * FROM tblCUSTOMER_TYPE)
	INSERT INTO tblCUSTOMER_TYPE (CustomerTypeName) VALUES
	('Hospital'), ('Clinic'), ('Household'), ('Individual'), ('Federal Institution'),
	('State Institution'), ('Research Institution'), ('University'), ('School')
GO
---------------------------------------------------------------------------------------------------
-- Insert Stored Procedure
---------------------------------------------------------------------------------------------------

-- Insert address
-- Made by Kha
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
BEGIN
    PRINT 'CityID is null';
    THROW 55000, 'City does not exist', 1;
END

EXEC GetStateID
@S_Name = @StateName,
@S_ID = @StateID OUTPUT
IF @StateID IS NULL
BEGIN
    PRINT 'StateID is null';
    THROW 55001, 'State does not exist', 1;
END

IF (SELECT StateID FROM tblCITY WHERE CityID = @CityID) <> @StateID
BEGIN
    PRINT 'Check CityID Again..';
    THROW 55002, 'This city is not in this state', 1;
END

BEGIN TRANSACTION
INSERT INTO tblADDRESS(AddressLine1, AddressLine2, Zip, CityID, StateID)
VALUES (@AddressLine1, @AddressLine2, @Zip, @CityID, @StateID)
IF @@ERROR <> 0
    ROLLBACK
ELSE
    COMMIT
END
GO

-- Insert customer
-- Made by Kha
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
BEGIN
    PRINT 'PriorityID is null';
    THROW 58000, 'Priority does not exist', 1;
END

-- Get Customer Type ID
EXEC GetCustomerTypeID
@_CustomerTypeName = @CustomerType,
@_OUT = @CustomerTypeID OUTPUT
IF @CustomerTypeID IS NULL
BEGIN
    PRINT 'CustomerTypeID is null';
    THROW 59000, 'Customer type does not exist', 1
END

BEGIN TRANSACTION
INSERT INTO tblCUSTOMER (CustomerFname, CustomerLname, CustomerDOB, CustomerEmail, AddressID, PriorityID, CustomerTypeID)
VALUES (@CustomerFname, @CustomerLname, @CustomerDOB, @CustomerEmail, @AddressID, @PriorityID, @CustomerTypeID)

IF @@ERROR <> 0
    ROLLBACK
ELSE
    COMMIT
END
GO

-- Made by Jisu
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
        PRINT 'ShipmentTypeID is null';
        THROW 50207, '@ShipmentTypeID is not found', 1;
    END

EXEC GetCarrierID
@CR_Name = @InsSP_CarrierName,
@CR_ID = @CarrierID OUTPUT

    IF @CarrierID IS NULL
    BEGIN
        PRINT 'CarrierID is null';
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

-- Insert Package
CREATE OR ALTER PROCEDURE Ins_Package
@ProductName VARCHAR(50),
@Order_Date DATETIME,
@Order_EmpFName VARCHAR(50),
@Order_EmpLName VARCHAR(50),
@Order_EmpDOB DATE,
@Order_CustFname VARCHAR(50),
@Order_CustLname VARCHAR(50),
@Order_CustDOB DATE,
@Quantity INTEGER,
@ShipmentTrackingNum VARCHAR(50),
@ShipmentShippingDate DATETIME,
@ShipmentCarrierName VARCHAR(50),
@ShipmentTypeName VARCHAR(50)
AS
BEGIN
    DECLARE @ProductID INT = (SELECT ProductID FROM tblPRODUCT WHERE ProductName = @ProductName)
    DECLARE @OrderID INT

    EXEC GetOrderID
    @OR_Date = @Order_Date,
    @OR_EmpFName = @Order_EmpFName,
    @OR_EmpLName = @Order_EmpLName,
    @OR_EmpDOB = @Order_EmpDOB,
    @OR_CustFname = @Order_CustFname,
    @OR_CustLname = @Order_CustLname,
    @OR_CustDOB = @Order_CustDOB,
    @OR_ID = @OrderID OUTPUT

    DECLARE @OrderProductID INT = (
        SELECT Order_ProductID
        FROM tblORDER_PRODUCT
        WHERE ProductID = @ProductID
            AND OrderID = @OrderID
        AND Quantity = @Quantity
    )

    DECLARE @ShipmentID INT

    EXEC GetShipmentID
    @SP_TrackingNum = @ShipmentTrackingNum,
    @SP_Date = @ShipmentShippingDate,
    @SP_ShipmentTypeName = @ShipmentTypeName,
    @SP_CarrierName = @ShipmentCarrierName,
    @SP_ID = @ShipmentID OUTPUT

    IF @ShipmentID IS NULL
    BEGIN
        PRINT 'ShipmentID is null';
        THROW 60000, 'Shipment does not exist', 1
    END

    BEGIN TRANSACTION
    INSERT INTO tblPACKAGE(Order_ProductID, ShipmentID)
    VALUES (@OrderProductID, @ShipmentID)
    IF @@ERROR <> 0
        ROLLBACK
    ELSE
        COMMIT
END
GO

-- Made by Jisu
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
        PRINT 'EmployeeTypeID is null';
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

-- Made by Jisu and Made by Tom
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
    BEGIN
        PRINT 'CustomerID is null';
		THROW 54000, 'Customer not found', 1;
    END

	DECLARE @EmployeeID INT
	EXEC GetEmployeeID
	@E_FName = @E_FName1,
	@E_LName = @E_LName1,
	@E_DOB = @E_DOB1,
	@E_ID = @EmployeeID OUTPUT

	IF @EmployeeID IS NULL
    BEGIN
        PRINT 'EmployeeID is null';
		THROW 54001, 'Employee not found', 1;
    END

	DECLARE @ProductID INT
	EXEC GetProductID
	@_ProductName = @ProductName1,
	@_Out = @ProductID OUTPUT

	IF @ProductID IS NULL
    BEGIN 
        PRINT 'ProductID is null';
		THROW 54002, 'Product not found', 1;
    END

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

-- Made by Tom
CREATE OR ALTER PROC Ins_Supplier
@SupplierName VARCHAR(50),
@SupplierDesc VARCHAR(1000),
@CityName INT
AS
	DECLARE @CityID INT
	EXEC GetCityID
	@C_Name = @CityName,
	@C_ID = @CityID OUTPUT

	IF @CityID IS NULL
    BEGIN 
        PRINT 'CityID is null';
		THROW 51000, 'City not found', 1;
    END

	BEGIN TRAN T1
		INSERT INTO tblSUPPLIER (SupplierName, SupplierDesc, SupplierID)
		VALUES (@SupplierName, @SupplierDesc, @CityID)

		IF @@ERROR <> 0
		BEGIN
			ROLLBACK TRAN T1;
			THROW 51001, 'Something went wrong', 1;
		END
	COMMIT TRAN T1
GO

-- Made by Tom
CREATE OR ALTER PROC Ins_Product
@ProductName VARCHAR(50),
@ProductDesc VARCHAR(1000),
@SupplierName VARCHAR(50)
AS
	DECLARE @SupplierID INT
	EXEC GetSupplierID
	@_SupplierName = @SupplierName,
	@_Out = @SupplierID OUTPUT

	IF @SupplierID IS NULL
    BEGIN
        PRINT 'SupplierID is null';
		THROW 52000, 'Supplier not found', 1;
    END

	BEGIN TRAN T1
		INSERT INTO tblPRODUCT (ProductName, ProductDesc, SupplierID)
		VALUES (@ProductName, @ProductDesc, @SupplierID)

		IF @@ERROR <> 0
		BEGIN
			ROLLBACK TRAN T1;
			THROW 52001, 'Something went wrong', 1;
		END
	COMMIT TRAN T1
GO

-- Made by Tom
CREATE OR ALTER PROC Ins_ProductDetail
@ProductName VARCHAR(50),
@DetailName VARCHAR(50),
@Value VARCHAR(1000)
AS
	DECLARE @ProductID INT
	EXEC GetProductID
	@_ProductName = @ProductName,
	@_Out = @ProductID OUTPUT

	IF @ProductID IS NULL
    BEGIN
        PRINT 'ProductID is null';
		THROW 53000, 'Product not found', 1;
    END

	DECLARE @DetailID INT
	EXEC GetDetailID
	@_DetailName = @DetailName,
	@_Out = @DetailID OUTPUT

	IF @DetailName IS NULL
    BEGIN 
        PRINT 'DetailName is null';
		THROW 53001, 'Detail not found', 1;
    END

	BEGIN TRAN T1
		INSERT INTO tblPRODUCT_DETAIL (ProductID, DetailID, [Value])
		VALUES (@ProductID, @DetailID, @Value)

		IF @@ERROR <> 0
		BEGIN
			ROLLBACK TRAN T1;
			THROW 53002, 'Something went wrong', 1;
		END
	COMMIT TRAN T1
GO

-- Populate Packages
CREATE OR ALTER PROCEDURE PopulatePackages
@NumPackages INT
AS
BEGIN
    DECLARE @Run INT = 1
    WHILE @Run <= @NumPackages
        BEGIN
            DECLARE @RandomOrderProductID INT = (
                SELECT TOP 1 Order_ProductID
                FROM tblORDER_PRODUCT
                ORDER BY NEWID()
            )

            DECLARE @RandomProductName VARCHAR(50) = (
                SELECT ProductName
                FROM tblORDER_PRODUCT
                JOIN tblPRODUCT ON tblORDER_PRODUCT.ProductID = tblPRODUCT.ProductID
                WHERE Order_ProductID = @RandomOrderProductID
            )

            DECLARE @RandomOrderID INT = (
                SELECT OrderID
                FROM tblORDER_PRODUCT
                WHERE Order_ProductID = @RandomOrderProductID
            )

            DECLARE @RandomOrderDate DATETIME = (
                SELECT OrderDate
                FROM tblORDER
                WHERE OrderID = @RandomOrderID
            )

            DECLARE @RandomOrderEmpFname VARCHAR(50) = (
                SELECT EmployeeFName
                FROM tblORDER
                JOIN tblEMPLOYEE ON tblORDER.EmployeeID = tblEMPLOYEE.EmployeeID
                WHERE OrderID = @RandomOrderID
            )

            DECLARE @RandomOrderEmpLname VARCHAR(50) = (
                SELECT EmployeeLName
                FROM tblORDER
                JOIN tblEMPLOYEE ON tblORDER.EmployeeID = tblEMPLOYEE.EmployeeID
                WHERE OrderID = @RandomOrderID
            )

            DECLARE @RandomOrderEmpDOB DATE = (
                SELECT EmployeeDOB
                FROM tblORDER
                JOIN tblEMPLOYEE ON tblORDER.EmployeeID = tblEMPLOYEE.EmployeeID
                WHERE OrderID = @RandomOrderID
            )

            DECLARE @RandomOrderCustFname VARCHAR(50) = (
                SELECT CustomerFname
                FROM tblORDER
                JOIN tblCUSTOMER ON tblORDER.CustomerID = tblCUSTOMER.CustomerID
                WHERE OrderID = @RandomOrderID
            )

            DECLARE @RandomOrderCustLname VARCHAR(50) = (
                SELECT CustomerLname
                FROM tblORDER
                JOIN tblCUSTOMER ON tblORDER.CustomerID = tblCUSTOMER.CustomerID
                WHERE OrderID = @RandomOrderID
            )

            DECLARE @RandomOrderCustDOB DATE = (
                SELECT CustomerDOB
                FROM tblORDER
                JOIN tblCUSTOMER ON tblORDER.CustomerID = tblCUSTOMER.CustomerID
                WHERE OrderID = @RandomOrderID
            )

            DECLARE @RandomQuantity INT = (
                SELECT Quantity
                FROM tblORDER_PRODUCT
                WHERE Order_ProductID = @RandomOrderProductID
            )

            DECLARE @RandomShipmentID INT = (
                SELECT TOP 1 ShipmentID
                FROM tblSHIPMENT
                ORDER BY NEWID()
            )

            DECLARE @RandomShipmentTrackingNum VARCHAR(50) = (
                SELECT TrackingNumber
                FROM tblSHIPMENT
                WHERE ShipmentID = @RandomShipmentID
            )

            DECLARE @RandomShipmentDate DATETIME = (
                SELECT ShippingDate
                FROM tblSHIPMENT
                WHERE ShipmentID = @RandomShipmentID
            )

            DECLARE @RandomShipmentCarrierName VARCHAR(50) = (
                SELECT CarrierName
                FROM tblSHIPMENT
                JOIN tblCARRIER ON tblSHIPMENT.CarrierID = tblCARRIER.CarrierID
                WHERE ShipmentID = @RandomShipmentID
            )

            DECLARE @RandomShipmentTypeName VARCHAR(50) = (
                SELECT ShipmentTypeName
                FROM tblSHIPMENT
                JOIN tblSHIPMENT_TYPE ON tblSHIPMENT.ShipmentTypeID = tblSHIPMENT_TYPE.ShipmentTypeID
                WHERE ShipmentID = @RandomShipmentID
            )

            EXEC Ins_Package
            @ProductName = @RandomProductName,
            @Order_Date = @RandomOrderDate,
            @Order_EmpFName = @RandomOrderEmpFname,
            @Order_EmpLName = @RandomOrderEmpLname,
            @Order_EmpDOB = @RandomOrderEmpDOB,
            @Order_CustFname = @RandomOrderCustFname,
            @Order_CustLname = @RandomOrderCustLname,
            @Order_CustDOB = @RandomOrderCustDOB,
            @Quantity = @RandomQuantity,
            @ShipmentTrackingNum = @RandomShipmentTrackingNum,
            @ShipmentShippingDate = @RandomShipmentDate,
            @ShipmentCarrierName = @RandomShipmentCarrierName,
            @ShipmentTypeName = @RandomShipmentTypeName

            SET @Run = @Run + 1
        END
END
GO

---------------------------------------------------------------------------------------------------
-- Populating Data
---------------------------------------------------------------------------------------------------
-- populate priorities
-- Made by Kha
INSERT INTO tblPRIORITY (PriorityName, PriorityDesc)
VALUES
    ('1A - LTCF & Healthcare Personnel', 'Long term care facility members and authorized front-line healthcare workers'),
    ('1B - 75+ & Frontline Essential Workers', 'Older people of 75+ years & frontline essential workers, key to functionality of critical operations'),
    ('1C - 65-74 & High Risk', 'Those between ages 65-74 or those with high risk medical conditions'),
    ('2 - Older Adults', 'Older adults not served in Phase 1 (ages 40+)'),
    ('3 - Young Adults & Children', 'Younger adults (ages 18-39) and children')
GO

-- populate cities and states
-- Insert cities and states
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

-- Populate addresses
-- Made by Kha
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

-- populate customers
-- Made by Kha
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

-- Made by Jisu
-- populate employees
INSERT INTO tblEMPLOYEE(EmployeeFName, EmployeeLName, EmployeeDOB, EmployeeTypeID)
SELECT TOP 10000 Emp_FName, Emp_LName, Emp_DOB, 2
FROM tblRAW_EmpData

UPDATE tblEMPLOYEE SET EmployeeTypeID = (SELECT EmployeeTypeID FROM tblEMPLOYEE_TYPE WHERE EmployeeTypeName = 'Full-Time')

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

SELECT COUNT(*), ET.EmployeeTypeName FROM tblEMPLOYEE E
        JOIN tblEMPLOYEE_TYPE ET ON E.EmployeeTypeID = ET.EmployeeTypeID
GROUP BY ET.EmployeeTypeName

IF EXISTS (SELECT TOP 1 * FROM tblRAW_EmpData)
     DROP TABLE tblRAW_EmpData
GO

-- Made by Jisu and Kha
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

-- Made by Jisu
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

-- Made by Jisu and Made by Tom
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
-- Populate Transaction Tables: tblPRODUCT, tblPRODUCT_DETAIL, tblDETAIL
---------------------------------------------------------------------------------------------------
-- TOm
CREATE OR ALTER PROC PopulateProduct
@N INT
AS
	SELECT *, ROW_NUMBER() OVER(ORDER BY SupplierID) AS RowNumber INTO Temp_tblSUPPLIER FROM tblSUPPLIER

	DECLARE @Run INT = 1
	WHILE @Run <= @N
	BEGIN
		DECLARE @RandProductName VARCHAR(50) = (
			-- This line of code was taken and modified from https://www.sqlteam.com/forums/topic.asp?TOPIC_ID=21132
			SELECT CHAR(CAST((90 - 65) * RAND() + 65 AS INT)) +
				CHAR(CAST((90 - 65) * RAND() + 65 AS INT)) +
				'-' +
				CHAR(CAST((90 - 65) * RAND() + 65 AS INT)) +
				CHAR(CAST((90 - 65) * RAND() + 65 AS INT)) +
				CHAR(CAST((90 - 65) * RAND() + 65 AS INT)) +
				'-' +
				CAST(FLOOR(10000 * RAND()) AS CHAR)
		)

		DECLARE @RandProductDesc VARCHAR(1000) = (
			'This is a random product description given a number of ' + CAST(RAND() AS VARCHAR(10))
		)

		DECLARE @RandSupplierRowNumber INT = FLOOR(RAND() * (SELECT COUNT(*) FROM tblSUPPLIER) + 1)
		DECLARE @RandSupplierName VARCHAR(50) = (SELECT SupplierName FROM Temp_tblSUPPLIER WHERE RowNumber = @RandSupplierRowNumber)

		DECLARE @RandMinTemp INT = RAND() * -100
		DECLARE @RandMaxTemp INT = @RandMinTemp + RAND() * 10
		DECLARE @RandRecTemp INT = @RandMaxTemp - RAND() * 5
		DECLARE @RandWeight INT = RAND() * 10

		BEGIN TRAN T1
			EXEC Ins_Product
			@ProductName = @RandProductName,
			@ProductDesc = @RandProductDesc,
			@SupplierName = @RandSupplierName

			EXEC Ins_ProductDetail
			@ProductName = @RandProductName,
			@DetailName = 'Minimum Temperature',
			@Value = @RandMinTemp

			EXEC Ins_ProductDetail
			@ProductName = @RandProductName,
			@DetailName = 'Maximum Temperature',
			@Value = @RandMaxTemp

			EXEC Ins_ProductDetail
			@ProductName = @RandProductName,
			@DetailName = 'Recommended Temperature',
			@Value = @RandRecTemp

			EXEC Ins_ProductDetail
			@ProductName = @RandProductName,
			@DetailName = 'Weight',
			@Value = @RandWeight

			IF @@ERROR <> 0
			BEGIN
				ROLLBACK TRAN T1;
				THROW 54000, 'Something went wrong', 1;
			END
		COMMIT TRAN T1

		SET @Run = @Run + 1
	END

	DROP TABLE Temp_tblSUPPLIER
GO

IF (SELECT COUNT(*) FROM tblPRODUCT) <> 50
	EXEC PopulateProduct @N = 50

---------------------------------------------------------------------------------------------------
-- Test Populating Data
---------------------------------------------------------------------------------------------------
EXEC PopulateCitiesAndStates

EXEC PopulateAddresses
@NumberOfAddresses = 5

EXEC PopulateCustomers
@NumberOfCustomers = 5

EXEC PopulateShipment
@NumsShipment = 5

EXEC PopulateOrder
@NumsOrder = 5

EXEC PopulatePackages
@NumPackages = 5

GO

---------------------------------------------------------------------------------------------------
-- Business Rules
---------------------------------------------------------------------------------------------------
-- Cities must be in the correct state for addresses
-- Made by Kha
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
		SET @RET = 1;
	END
RETURN @RET
END
GO

ALTER TABLE tblADDRESS with nocheck
ADD CONSTRAINT CK_AddressCityMustBeInState
CHECK (dbo.fn_AddressCityMustBeInState() = 0)
GO

-- Only 50 states can exist
-- Made by Kha
CREATE FUNCTION fn_50StatesMaxAndNoDupes()
RETURNS INTEGER
AS
BEGIN
DECLARE @RET INTEGER = 0
	IF
    (
		SELECT COUNT(*)
		FROM tblSTATE
	) > 50
    OR
    (
        SELECT COUNT(*)
        FROM tblSTATE
        GROUP BY StateName
        HAVING COUNT(*) > 1
    ) > 0
	BEGIN
		SET @RET = 1;
	END
RETURN @RET
END
GO

ALTER TABLE tblSTATE with nocheck
ADD CONSTRAINT CK_50StatesMax
CHECK (dbo.fn_50StatesMaxAndNoDupes() = 0)
GO

-- Made by Jisu
-- Order date should be earlier than shipping date
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

-- Made by Jisu
-- Employee with less than 21 years old should not be full-time
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

-- Made by Tom
-- A customer type 'Individual' below the age of 30, can only order 1 quantity  of a product at a time.
CREATE OR ALTER FUNCTION fn_HasMoreThan1ProductQuanityPerOrder()
RETURNS INT
AS
BEGIN
	IF EXISTS (
		SELECT *
		FROM tblCUSTOMER_TYPE C_T
			JOIN tblCUSTOMER C ON C_T.CustomerTypeID = C_T.CustomerTypeID
			JOIN tblORDER O ON C.CustomerID = O.CustomerID
			JOIN tblORDER_PRODUCT O_P ON O.OrderID = O_P.OrderID
		WHERE C_T.CustomerTypeName = 'Individual'
			AND C.CustomerDOB > DATEADD(YEAR, -30, GETDATE())
			AND O_P.Quantity > 1
	) RETURN 1
	RETURN 0
END
GO

ALTER TABLE tblORDER WITH NOCHECK
ADD CONSTRAINT ck_HasMoreThan1ProductQuanityPerOrder
CHECK (dbo.fn_HasMoreThan1ProductQuanityPerOrder() = 0)
GO

-- Made by Tom
-- A customer type 'Individual' and 'Household' can not order a product that has a minimum storage temperature below -10 celsius.
CREATE OR ALTER FUNCTION fn_HasProductMinTempBelowNegative10()
RETURNS INT
AS
BEGIN
	IF EXISTS (
		SELECT *
		FROM tblCUSTOMER_TYPE C_T
			JOIN tblCUSTOMER C ON C_T.CustomerTypeID = C.CustomerTypeID
			JOIN tblORDER O ON C.CustomerID = O.CustomerID
			JOIN tblORDER_PRODUCT O_P ON O.OrderID = O_P.OrderID
			JOIN tblPRODUCT P ON O_P.ProductID = P.ProductID
			JOIN tblPRODUCT_DETAIL P_D ON P.ProductID = P_D.ProductID
			JOIN tblDETAIL D ON P_D.DetailID = D.DetailID
		WHERE (C_T.CustomerTypeName = 'Individual' OR C_T.CustomerTypeName = 'Household')
			AND D.DetailName = 'Minimum Temperature'
			AND CAST(P_D.[Value] AS INT) < -10
	) RETURN 1
	RETURN 0
END
GO

ALTER TABLE tblORDER WITH NOCHECK
ADD CONSTRAINT ck_HasProductMinTempBelowNegative10
CHECK (dbo.fn_HasProductMinTempBelowNegative10() = 0)
GO
---------------------------------------------------------------------------------------------------
-- Computed Columns
---------------------------------------------------------------------------------------------------
-- Number of address lines
-- Made by Kha
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

-- Customer age
-- Made by Kha
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


-- Number of Residents in an Address Household
-- Made by Kha
CREATE FUNCTION fn_NumberInHouseholdWithHighPriority(@PK INT)
RETURNS INT
AS
BEGIN
    DECLARE @RET INT = (
        SELECT COUNT(*)
        FROM tblADDRESS
            JOIN tblCUSTOMER ON tblADDRESS.AddressID = tblCUSTOMER.AddressID
            JOIN tblPRIORITY ON tblCUSTOMER.PriorityID = tblPRIORITY.PriorityID
        WHERE tblAddress.AddressID = @PK
        AND (
            PriorityName = '1A - LTCF & Healthcare Personnel'
            OR PriorityName = '1B - 75+ & Frontline Essential Workers'
        )
    )
	RETURN @RET
END
GO

ALTER TABLE tblADDRESS
ADD NumberHighPriorityPeople AS (dbo.fn_NumberInHouseholdWithHighPriority(AddressID))
GO

--  Total order in each state in the U.S.
-- Made by Jisu
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

--  Total order of each product
-- Made by Jisu
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

-- Made by Tom
-- Number of orders for each supplier
CREATE OR ALTER FUNCTION fn_OrderCountPerSupplier(@PK INT)
RETURNS INT
AS
BEGIN
	RETURN (
		SELECT COUNT(*)
		FROM tblORDER O
			JOIN tblORDER_PRODUCT O_P ON O.OrderID = O_P.OrderID
			JOIN tblPRODUCT P ON O_P.ProductID = P.ProductID
			JOIN tblSUPPLIER S ON P.SupplierID = S.SupplierID
		WHERE S.SupplierID = @PK
	)
END
GO

IF COL_LENGTH('tblSUPPLIER', 'OrderCount') IS NULL
BEGIN
	ALTER TABLE tblSUPPLIER
	ADD OrderCount AS (dbo.fn_OrderCountPerSupplier(SupplierID))
END
GO

-- Made by Tom
-- Number of employees for each customer type
CREATE OR ALTER FUNCTION fn_CountEmployeePerCustomerType(@PK INT)
RETURNS INT
AS
BEGIN
	RETURN (
		SELECT COUNT(*)
		FROM tblEMPLOYEE E
			JOIN tblORDER O ON E.EmployeeID = O.EmployeeID
			JOIN tblCUSTOMER Cust ON O.CustomerID = Cust.CustomerID
			JOIN tblCUSTOMER_TYPE C_T ON Cust.CustomerTypeID = C_T.CustomerTypeID
		WHERE C_T.CustomerTypeID = @PK
	)
END
GO

IF COL_LENGTH('tblCUSTOMER_TYPE', 'EmployeeCount') IS NULL
BEGIN
	ALTER TABLE tblCUSTOMER_TYPE
	ADD EmployeeCount AS (dbo.fn_CountEmployeePerCustomerType(CustomerTypeID))
END
GO
---------------------------------------------------------------------------------------------------
-- Complex Queries (Views)
---------------------------------------------------------------------------------------------------
-- Show customers grouped by priority and their total counts
-- Made by Kha
CREATE OR ALTER VIEW CustomerPriorityCounts AS
SELECT
    (
        CASE
            WHEN PriorityName = '1A - LTCF & Healthcare Personnel'
            THEN 'Highest Priority'
            WHEN PriorityName = '1B - 75+ & Frontline Essential Workers'
            THEN 'High Priority'
            WHEN PriorityName = '1C - 65-74 & High Risk'
            THEN 'Medium Priority'
            WHEN PriorityName = '2 - Older Adults'
            THEN 'Lower Priority'
            WHEN PriorityName = '3 - Young Adults & Children'
            THEN 'Lowest Priority'
            ELSE 'No Priority'
        END
    ) AS PriorityLevel, COUNT(*) AS TotalCount
FROM tblCUSTOMER
    JOIN tblPRIORITY ON tblCUSTOMER.PriorityID = tblPRIORITY.PriorityID
    JOIN tblADDRESS ON tblCUSTOMER.AddressID = tblADDRESS.AddressID
    JOIN tblCITY ON tblADDRESS.CityID = tblCITY.CityID
    JOIN tblSTATE ON tblCITY.StateID = tblSTATE.StateID
GROUP BY
    (
        CASE
            WHEN PriorityName = '1A - LTCF & Healthcare Personnel'
            THEN 'Highest Priority'
            WHEN PriorityName = '1B - 75+ & Frontline Essential Workers'
            THEN 'High Priority'
            WHEN PriorityName = '1C - 65-74 & High Risk'
            THEN 'Medium Priority'
            WHEN PriorityName = '2 - Older Adults'
            THEN 'Lower Priority'
            WHEN PriorityName = '3 - Young Adults & Children'
            THEN 'Lowest Priority'
            ELSE 'No Priority'
        END
    )
GO

-- Made by Kha
CREATE OR ALTER VIEW NumNonPriorityHouseholdsRanking AS
SELECT RANK() OVER(ORDER BY COUNT(*) DESC) AS Rank, tblSTATE.StateName AS State, COUNT(*) AS Count
FROM tblADDRESS
    JOIN tblCUSTOMER ON tblADDRESS.AddressID = tblCUSTOMER.AddressID
    JOIN tblSTATE ON tblADDRESS.StateID = tblSTATE.StateID
WHERE tblCustomer.CustomerID NOT IN
    (
        SELECT CustomerID
        FROM tblCUSTOMER
            JOIN tblPRIORITY ON tblCUSTOMER.PriorityID = tblPRIORITY.PriorityID
        WHERE PriorityName = '1A - LTCF & Healthcare Personnel' OR PriorityName = '1C - 65-74 & High Risk'
    )
GROUP BY tblADDRESS.StateID, tblSTATE.StateName
GO

-- Ranking 1 - 50 orders by states and nums of customer
-- Made by Jisu
CREATE OR ALTER VIEW vwTopOrderbyStates
AS
SELECT S.StateID, S.StateName, COUNT(O.CustomerID) AS TotalNumsCustomers ,COUNT(O.OrderID) AS TotalProductOrders,
RANK() OVER (ORDER BY COUNT(O.OrderID) DESC) AS RANK
FROM tblSTATE S
    JOIN tblCITY C ON S.StateID = C.StateID
    JOIN tblADDRESS A ON C.CityID = A.CityID
    JOIN tblCUSTOMER CS ON A.AddressID = CS.AddressID
    JOIN tblORDER O ON CS.CustomerID = O.CustomerID
    JOIN tblORDER_PRODUCT OP ON O.OrderID = OP.OrderID
    GROUP BY S.StateID, S.StateName
GO

-- TOP 10 MOST POPULAR PRODCUT
-- Made by Jisu
CREATE OR ALTER VIEW vwTheMostTop10PopularProduct
AS
SELECT TOP 10 P.ProductID, P.ProductName, COUNT(O.OrderID) AS TotalOrderProduct
FROM tblORDER O
    JOIN tblORDER_PRODUCT OP ON O.OrderID = OP.OrderID
    JOIN tblPRODUCT P ON OP.ProductID = P.ProductID
    GROUP BY P.ProductID, P.ProductName
    ORDER BY COUNT(O.OrderID) DESC
GO

-- Made by Tom
-- The top 1 supplier in each state, that received the most number of orders from.
CREATE OR ALTER VIEW vw_Top1SupplierInEachStateByNumberOfOrders
AS
	-- The code below was taken and modified from: https://stackoverflow.com/a/6841644
	WITH cte
	AS (
		SELECT S.StateID, S.StateName, SP.SupplierName,
		COUNT(O.OrderID) AS OrderCount,
		ROW_NUMBER() OVER (PARTITION BY S.StateID ORDER BY COUNT(O.OrderID) DESC) AS TopNumberOfOrdersRank
		FROM tblSTATE S
			JOIN tblCITY CT ON S.StateID = CT.StateID
			JOIN tblADDRESS A ON CT.CityID = A.CityID
			JOIN tblCUSTOMER C ON A.AddressID = C.AddressID
			JOIN tblORDER O ON C.CustomerID = O.CustomerID
			JOIN tblORDER_PRODUCT O_P ON O.OrderID = O_P.OrderID
			JOIN tblPRODUCT P ON O_P.ProductID = P.ProductID
			JOIN tblSUPPLIER SP ON P.SupplierID = SP.SupplierID
		GROUP BY S.StateID, S.StateName, SP.SupplierName
	)
	SELECT StateID, StateName, SupplierName, OrderCount
	FROM cte
	WHERE TopNumberOfOrdersRank = 1
GO

-- Made by Tom
-- The lowest temperature that an employee had to deal with.
CREATE OR ALTER VIEW vw_EmployeeMinTemp
AS
	WITH cte
	AS (
		SELECT E.EmployeeID, E.EmployeeFName, E.EmployeeLName, P_D.[Value] AS MinTempValue,
		ROW_NUMBER() OVER (PARTITION BY E.EmployeeID ORDER BY CAST(P_D.[Value] AS INT) ASC) AS LowestTempRank
		FROM tblEMPLOYEE E
			JOIN tblORDER O ON E.EmployeeID = O.EmployeeID
			JOIN tblORDER_PRODUCT O_P ON O.OrderID = O_P.OrderID
			JOIN tblPRODUCT P ON O_P.ProductID = P.ProductID
			JOIN tblPRODUCT_DETAIL P_D ON P.ProductID = P_D.ProductID
			JOIN tblDETAIL D ON P_D.DetailID = D.DetailID
		WHERE D.DetailName = 'Minimum Temperature'
		GROUP BY E.EmployeeID, E.EmployeeFName, E.EmployeeLName, P_D.[VALUE]
	)
	SELECT EmployeeID, EmployeeFName, EmployeeLName, MinTempValue
	FROM cte
	WHERE LowestTempRank = 1
GO

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
SELECT * FROM tblPACKAGE
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
