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
        DECLARE @RandEmpType VARCHAR(50) = (SELECT PT.PositionTypeName 
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

SELECT * FROM UNIVERSITY.dbo.tblSTAFF S
                                            JOIN UNIVERSITY.dbo.tblSTAFF_POSITION SP ON S.StaffID = SP.StaffID
                                            JOIN UNIVERSITY.dbo.tblPOSITION P ON SP.PositionID = P.PositionID
                                            JOIN UNIVERSITY.dbo.tblPOSITION_TYPE PT ON P.PositionTypeID = PT.PositionTypeID


INSERT INTO tblEMPLOYEE_TYPE(EmployeeTypeName, EmployeeTypeDesc) 
VALUES('Part-Time', ''), ('Full-Time', ''), ('Contingent', ''), ('Temporary', ''),  ('Executive', '')

EXEC PopulateEmployee
@NumsEmp = 50



SELECT * FROM tblEMPLOYEE_TYPE
SELECT * FROM UNIVERSITY.dbo.tblPOSITION_TYPE

