-- insert Employee
ALTER PROCEDURE Ins_Employee
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
    PRINT 'ERROR';
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


CREATE OR ALTER PROCEDURE PopulateEmployee
@Run INT
AS
DECLARE @NumsEmp INT = (SELECT COUNT(*) FROM UNIVERSITY.dbo.tblSTAFF)
DECLARE @Emp_Fname VARCHAR(50), @Emp_Lname VARCHAR(50), @Emp_Birthy DATE, @Emp_Type VARCHAR(50)
DECLARE @Emp_ID INT
WHILE @Run > 0
    BEGIN
        SET @Emp_ID = FLOOR(RAND() * @NumsEmp + 1)
        SET @Emp_Fname = (SELECT StaffFName FROM UNIVERSITY.dbo.tblSTAFF WHERE StaffID = @Emp_ID)
        SET @Emp_Lname = (SELECT StaffLName FROM UNIVERSITY.dbo.tblSTAFF WHERE StaffID = @Emp_ID)
        SET @Emp_Birthy = (SELECT StaffBirth FROM UNIVERSITY.dbo.tblSTAFF WHERE StaffID = @Emp_ID)
        SET @Emp_Type = (SELECT PT.PositionTypeName 
                        FROM UNIVERSITY.dbo.tblSTAFF S
                        JOIN UNIVERSITY.dbo.tblSTAFF_POSITION SP ON S.StaffID = SP.StaffID
                        JOIN UNIVERSITY.dbo.tblPOSITION P ON SP.PositionID = P.PositionID
                        JOIN UNIVERSITY.dbo.tblPOSITION_TYPE PT ON P.PositionTypeID = PT.PositionTypeID WHERE S.StaffID = @Emp_ID)

        /*DECLARE @RandEmpID INTEGER = FLOOR(RAND() * (SELECT COUNT(*) FROM UNIVERSITY.dbo.tblSTAFF) + 1)
        DECLARE @RandEmpFName VARCHAR(20) = (SELECT StaffFName FROM UNIVERSITY.dbo.tblSTAFF WHERE StaffID = @RandEmpID)
        DECLARE @RandEmpLName VARCHAR(20) = (SELECT StaffLName FROM UNIVERSITY.dbo.tblSTAFF WHERE StaffID = @RandEmpID)
        DECLARE @RandEmpDOB DATE = (SELECT StaffBirth FROM UNIVERSITY.dbo.tblSTAFF WHERE StaffID = @RandEmpID)
        DECLARE @RandEmpType VARCHAR(50) = (SELECT PT.PositionTypeName 
                                            FROM UNIVERSITY.dbo.tblSTAFF S
                                            JOIN UNIVERSITY.dbo.tblSTAFF_POSITION SP ON S.StaffID = SP.StaffID
                                            JOIN UNIVER                                JOIN UNIVERSITY.dbo.tblPOSITION_TYPE PT ON P.PositionTypeID = PT.PositionTypeID WHERE S.StaffID = @RandEmpID)*/

        EXEC Ins_Employee
        @Ins_EmpFName = @Emp_Fname,
        @Ins_EmpLName = @Emp_Lname,
        @Ins_EmpDOB = @Emp_Birthy,
        @Ins_EmpTypeName = @Emp_Type

        SET @Run = @Run - 1
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
@Run = 50

select * from tblEMPLOYEESITY.dbo.tblPOSITION P ON SP.PositionID = P.PositionID
            

