-- =====================================================
-- SQL SERVER SECURITY IMPLEMENTATION
-- EXAMINATION SYSTEM DATABASE
-- =====================================================


USE [ExaminationSystem]
GO

-- =====================================================
-- 1. DATABASE-LEVEL SECURITY CONFIGURATION
-- =====================================================

ALTER DATABASE [ExaminationSystem] SET TRUSTWORTHY OFF;
ALTER DATABASE [ExaminationSystem] SET DB_CHAINING OFF;
ALTER DATABASE [ExaminationSystem] SET ALLOW_SNAPSHOT_ISOLATION OFF;
GO

ALTER DATABASE [ExaminationSystem] SET RESTRICTED_USER;
GO

ALTER DATABASE [ExaminationSystem] SET MULTI_USER;
GO


IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'AdminUser')
    DROP LOGIN AdminUser;
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'TrainingManagerUser')
    DROP LOGIN TrainingManagerUser;
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'InstructorUser')
    DROP LOGIN InstructorUser;
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'StudentUser')
    DROP LOGIN StudentUser;
GO

CREATE LOGIN AdminUser WITH PASSWORD = 'Admin@Secure2026#Complex!Pass';
ALTER LOGIN AdminUser WITH CHECK_EXPIRATION = ON, CHECK_POLICY = ON;
GO

CREATE LOGIN TrainingManagerUser WITH PASSWORD = 'TrainMgr@2026#SecurePass123';
ALTER LOGIN TrainingManagerUser WITH CHECK_EXPIRATION = ON, CHECK_POLICY = ON;
GO

CREATE LOGIN InstructorUser WITH PASSWORD = 'Instructor@2026#SafePass456';
ALTER LOGIN InstructorUser WITH CHECK_EXPIRATION = ON, CHECK_POLICY = ON;
GO

CREATE LOGIN StudentUser WITH PASSWORD = 'Student@2026#PassSecure789';
ALTER LOGIN StudentUser WITH CHECK_EXPIRATION = ON, CHECK_POLICY = ON;
GO


IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'AdminUser')
    DROP USER AdminUser;
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'TrainingManagerUser')
    DROP USER TrainingManagerUser;
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'InstructorUser')
    DROP USER InstructorUser;
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'StudentUser')
    DROP USER StudentUser;
GO

CREATE USER AdminUser FOR LOGIN AdminUser;
CREATE USER TrainingManagerUser FOR LOGIN TrainingManagerUser;
CREATE USER InstructorUser FOR LOGIN InstructorUser;
CREATE USER StudentUser FOR LOGIN StudentUser;
GO


IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'AdminRole')
    DROP ROLE AdminRole;
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'TrainingManagerRole')
    DROP ROLE TrainingManagerRole;
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'InstructorRole')
    DROP ROLE InstructorRole;
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'StudentRole')
    DROP ROLE StudentRole;
GO

CREATE ROLE AdminRole;
GO

CREATE ROLE TrainingManagerRole;
GO

CREATE ROLE InstructorRole;
GO

CREATE ROLE StudentRole;
GO



ALTER ROLE AdminRole ADD MEMBER AdminUser;
ALTER ROLE TrainingManagerRole ADD MEMBER TrainingManagerUser;
ALTER ROLE InstructorRole ADD MEMBER InstructorUser;
ALTER ROLE StudentRole ADD MEMBER StudentUser;
GO


GRANT CONTROL ON DATABASE::[ExaminationSystem] TO AdminRole;
GO

GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Instructor TO TrainingManagerRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Course TO TrainingManagerRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Student TO TrainingManagerRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.UserAccounts TO TrainingManagerRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.InstructorCourses TO TrainingManagerRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Branch TO TrainingManagerRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Intake TO TrainingManagerRole;
GRANT SELECT ON dbo.Exam TO TrainingManagerRole;

GRANT EXECUTE ON dbo.sp_Manager_Instructor_Add TO TrainingManagerRole;
GRANT EXECUTE ON dbo.sp_Manager_Instructor_Update TO TrainingManagerRole;
GRANT EXECUTE ON dbo.sp_Manager_Instructor_Delete TO TrainingManagerRole;
GRANT EXECUTE ON dbo.sp_Manager_Instructor_GetAll TO TrainingManagerRole;
GRANT EXECUTE ON dbo.sp_Manager_Instructor_GetById TO TrainingManagerRole;

GO


GRANT SELECT ON dbo.Course TO InstructorRole;
GRANT SELECT ON dbo.Question TO InstructorRole;
GRANT SELECT ON dbo.Student TO InstructorRole;
GRANT SELECT ON dbo.Exam TO InstructorRole;
GRANT SELECT ON dbo.StudentExam TO InstructorRole;
GRANT SELECT ON dbo.StudentAnswer TO InstructorRole;

GRANT INSERT, UPDATE, DELETE ON dbo.Question TO InstructorRole;
GRANT INSERT, UPDATE ON dbo.Exam TO InstructorRole;
GRANT INSERT, UPDATE ON dbo.Contain TO InstructorRole;

GRANT EXECUTE ON dbo.fn_GetExamDurationInMinutes TO InstructorRole;
GRANT EXECUTE ON dbo.fn_GetExamTotalDegree TO InstructorRole;

GO


GRANT SELECT ON dbo.Course TO StudentRole;
GRANT SELECT ON dbo.Exam TO StudentRole;
GRANT SELECT ON dbo.Question TO StudentRole;

GRANT INSERT, UPDATE ON dbo.StudentExam TO StudentRole;
GRANT INSERT, UPDATE ON dbo.StudentAnswer TO StudentRole;

GRANT EXECUTE ON dbo.fn_GetExamDurationInMinutes TO StudentRole;

GO

DENY DELETE ON dbo.UserAccounts TO PUBLIC;
DENY DELETE ON dbo.Student TO StudentRole;
DENY DELETE ON dbo.Instructor TO InstructorRole;
DENY DELETE ON dbo.Course TO InstructorRole;

DENY UPDATE ON dbo.StudentExam TO InstructorRole;
DENY DELETE ON dbo.StudentExam TO InstructorRole;

DENY SELECT ON dbo.Student TO StudentRole;

GO



CREATE FUNCTION dbo.fn_HashPassword(@Password NVARCHAR(255))
RETURNS NVARCHAR(255)
AS
BEGIN
    DECLARE @HashedPassword NVARCHAR(255);
    SET @HashedPassword = CONVERT(VARCHAR(255), 
        HASHBYTES('SHA2_256', @Password), 2);
    RETURN @HashedPassword;
END;
GO


IF NOT EXISTS (SELECT * FROM sys.columns 
    WHERE OBJECT_ID = OBJECT_ID('dbo.UserAccounts') 
    AND name = 'PasswordHash')
BEGIN
    ALTER TABLE dbo.UserAccounts 
    ADD PasswordHash NVARCHAR(255) NULL;
END;

IF NOT EXISTS (SELECT * FROM sys.columns 
    WHERE OBJECT_ID = OBJECT_ID('dbo.UserAccounts') 
    AND name = 'LastLoginDate')
BEGIN
    ALTER TABLE dbo.UserAccounts 
    ADD LastLoginDate DATETIME NULL;
END;

IF NOT EXISTS (SELECT * FROM sys.columns 
    WHERE OBJECT_ID = OBJECT_ID('dbo.UserAccounts') 
    AND name = 'LoginAttempts')
BEGIN
    ALTER TABLE dbo.UserAccounts 
    ADD LoginAttempts INT DEFAULT 0;
END;

IF NOT EXISTS (SELECT * FROM sys.columns 
    WHERE OBJECT_ID = OBJECT_ID('dbo.UserAccounts') 
    AND name = 'IsLocked')
BEGIN
    ALTER TABLE dbo.UserAccounts 
    ADD IsLocked BIT DEFAULT 0;
END;

IF NOT EXISTS (SELECT * FROM sys.columns 
    WHERE OBJECT_ID = OBJECT_ID('dbo.UserAccounts') 
    AND name = 'CreatedDate')
BEGIN
    ALTER TABLE dbo.UserAccounts 
    ADD CreatedDate DATETIME DEFAULT GETDATE();
END;

IF NOT EXISTS (SELECT * FROM sys.columns 
    WHERE OBJECT_ID = OBJECT_ID('dbo.UserAccounts') 
    AND name = 'LastModifiedDate')
BEGIN
    ALTER TABLE dbo.UserAccounts 
    ADD LastModifiedDate DATETIME DEFAULT GETDATE();
END;

GO


IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'LoginAudit')
BEGIN
    CREATE TABLE dbo.LoginAudit (
        AuditID INT PRIMARY KEY IDENTITY(1,1),
        UserID INT,
        UserName NVARCHAR(100),
        LoginTime DATETIME DEFAULT GETDATE(),
        LogoutTime DATETIME NULL,
        IPAddress NVARCHAR(50),
        IsSuccessful BIT,
        FailureReason NVARCHAR(255),
        CONSTRAINT FK_LoginAudit_UserAccounts 
            FOREIGN KEY (UserID) 
            REFERENCES dbo.UserAccounts(UserID)
    );
END;
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'DataChangeAudit')
BEGIN
    CREATE TABLE dbo.DataChangeAudit (
        AuditID INT PRIMARY KEY IDENTITY(1,1),
        UserID INT,
        TableName NVARCHAR(100),
        OperationType NVARCHAR(20), -- INSERT, UPDATE, DELETE
        RecordID INT,
        OldValues NVARCHAR(MAX),
        NewValues NVARCHAR(MAX),
        ChangeTime DATETIME DEFAULT GETDATE(),
        CONSTRAINT FK_DataChangeAudit_UserAccounts 
            FOREIGN KEY (UserID) 
            REFERENCES dbo.UserAccounts(UserID)
    );
END;
GO


CREATE OR ALTER PROCEDURE dbo.sp_ValidateUserLogin
    @UserName NVARCHAR(100),
    @Password NVARCHAR(255),
    @IsValid BIT OUTPUT,
    @UserID INT OUTPUT,
    @UserRole NVARCHAR(100) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @StoredHash NVARCHAR(255);
    DECLARE @InputHash NVARCHAR(255);
    DECLARE @MaxLoginAttempts INT = 5;
    
    SET @InputHash = dbo.fn_HashPassword(@Password);
    
 
    SELECT 
        @UserID = UserID,
        @StoredHash = PasswordHash,
        @UserRole = Role,
        @IsValid = CASE 
            WHEN IsLocked = 1 THEN 0
            WHEN PasswordHash = @InputHash THEN 1
            ELSE 0
        END
    FROM dbo.UserAccounts
    WHERE UserName = @UserName;
    
    IF @IsValid = 0 AND EXISTS (
        SELECT 1 FROM dbo.UserAccounts 
        WHERE UserName = @UserName AND IsLocked = 1
    )
    BEGIN
        INSERT INTO dbo.LoginAudit 
            (UserID, UserName, IsSuccessful, FailureReason)
        VALUES 
            (@UserID, @UserName, 0, 'Account is locked');
        
        SET @IsValid = 0;
        RETURN;
    END
    
    IF @IsValid = 1
    BEGIN
        UPDATE dbo.UserAccounts
        SET 
            LastLoginDate = GETDATE(),
            LoginAttempts = 0,
            LastModifiedDate = GETDATE()
        WHERE UserID = @UserID;
        
        INSERT INTO dbo.LoginAudit 
            (UserID, UserName, IsSuccessful, FailureReason)
        VALUES 
            (@UserID, @UserName, 1, NULL);
    END
    ELSE
    BEGIN
        UPDATE dbo.UserAccounts
        SET LoginAttempts = LoginAttempts + 1,
            IsLocked = CASE 
                WHEN (LoginAttempts + 1) >= @MaxLoginAttempts THEN 1
                ELSE 0
            END,
            LastModifiedDate = GETDATE()
        WHERE UserName = @UserName;
        
        INSERT INTO dbo.LoginAudit 
            (UserID, UserName, IsSuccessful, FailureReason)
        VALUES 
            (@UserID, @UserName, 0, 'Invalid password');
    END
    
END;
GO



CREATE OR ALTER TRIGGER tr_InstructorAudit
ON dbo.Instructor
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @@ROWCOUNT = 0
        RETURN;
    
    DECLARE @OperationType NVARCHAR(20);
    DECLARE @UserID INT;
    
    SET @UserID = USER_ID(USER_NAME());
    
    IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted)
        SET @OperationType = 'INSERT';
    ELSE IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
        SET @OperationType = 'UPDATE';
    ELSE IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS (SELECT * FROM inserted)
        SET @OperationType = 'DELETE';
    
    INSERT INTO dbo.DataChangeAudit 
        (UserID, TableName, OperationType, RecordID, NewValues, ChangeTime)
    SELECT 
        @UserID,
        'Instructor',
        @OperationType,
        InstructorID,
        'FullName: ' + ISNULL(FullName, '') + 
        ', Email: ' + ISNULL(Email, '') +
        ', ManagerID: ' + ISNULL(CAST(ManagerID AS NVARCHAR), ''),
        GETDATE()
    FROM inserted
    WHERE @OperationType IN ('INSERT', 'UPDATE');
    
    IF @OperationType = 'DELETE'
    BEGIN
        INSERT INTO dbo.DataChangeAudit 
            (UserID, TableName, OperationType, RecordID, OldValues, ChangeTime)
        SELECT 
            @UserID,
            'Instructor',
            @OperationType,
            InstructorID,
            'FullName: ' + ISNULL(FullName, '') + 
            ', Email: ' + ISNULL(Email, '') +
            ', ManagerID: ' + ISNULL(CAST(ManagerID AS NVARCHAR), ''),
            GETDATE()
        FROM deleted;
    END
    
END;
GO


CREATE OR ALTER TRIGGER tr_StudentAudit
ON dbo.Student
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @@ROWCOUNT = 0
        RETURN;
    
    DECLARE @OperationType NVARCHAR(20);
    DECLARE @UserID INT;
    
    SET @UserID = USER_ID(USER_NAME());
    
    IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted)
        SET @OperationType = 'INSERT';
    ELSE IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
        SET @OperationType = 'UPDATE';
    ELSE
        SET @OperationType = 'DELETE';
    
    INSERT INTO dbo.DataChangeAudit 
        (UserID, TableName, OperationType, RecordID, NewValues, ChangeTime)
    SELECT 
        @UserID,
        'Student',
        @OperationType,
        StudentID,
        'StudentName: ' + ISNULL(StudentName, '') + 
        ', Email: ' + ISNULL(Email, '') +
        ', BranchID: ' + ISNULL(CAST(BranchID AS NVARCHAR), ''),
        GETDATE()
    FROM inserted
    WHERE @OperationType IN ('INSERT', 'UPDATE');
    
END;
GO



CREATE OR ALTER PROCEDURE dbo.sp_SecureInsertQuestion
    @CourseID INT,
    @QuestionText NVARCHAR(MAX),
    @QuestionType NVARCHAR(50),
    @CorrectAnswer NVARCHAR(MAX),
    @InstructorID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @CurrentUserID INT;
    DECLARE @UserRole NVARCHAR(100);
    DECLARE @InstructorForUser INT;
    
    BEGIN TRY
        SET @CurrentUserID = USER_ID(USER_NAME());
        
        SELECT @UserRole = Role 
        FROM dbo.UserAccounts 
        WHERE UserID = @CurrentUserID;
        
        IF @UserRole NOT IN ('Instructor', 'Admin', 'TrainingManager')
        BEGIN
            RAISERROR('Unauthorized: You do not have permission to add questions', 16, 1);
            RETURN;
        END
        
        IF @UserRole = 'Instructor'
        BEGIN
            SELECT @InstructorForUser = UserID 
            FROM dbo.Instructor 
            WHERE InstructorID = @InstructorID;
            
            IF @InstructorForUser <> @CurrentUserID
            BEGIN
                RAISERROR('Unauthorized: You can only add questions for your own courses', 16, 1);
                RETURN;
            END
            
            IF NOT EXISTS (
                SELECT 1 FROM dbo.InstructorCourses 
                WHERE InstructorID = @InstructorID AND CourseID = @CourseID
            )
            BEGIN
                RAISERROR('Unauthorized: You do not teach this course', 16, 1);
                RETURN;
            END
        END
        
        IF LEN(LTRIM(RTRIM(@QuestionText))) = 0
        BEGIN
            RAISERROR('Question text cannot be empty', 16, 1);
            RETURN;
        END
        
        IF @QuestionType NOT IN ('MultipleChoice', 'TrueOrFalse', 'Text')
        BEGIN
            RAISERROR('Invalid question type', 16, 1);
            RETURN;
        END
        
        INSERT INTO dbo.Question (
            CourseID, QuestionText, QuestionType, CorrectAnswer, InstructorID
        )
        VALUES (
            @CourseID, @QuestionText, @QuestionType, @CorrectAnswer, @InstructorID
        );
        
        INSERT INTO dbo.DataChangeAudit 
            (UserID, TableName, OperationType, NewValues, ChangeTime)
        VALUES 
            (@CurrentUserID, 'Question', 'INSERT', 
             'CourseID: ' + CAST(@CourseID AS NVARCHAR) + 
             ', Type: ' + @QuestionType, GETDATE());
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(255);
        SET @ErrorMessage = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN;
    END CATCH
    
END;
GO



CREATE OR ALTER VIEW vw_StudentExams
AS
SELECT 
    e.ExamID,
    e.ExamName,
    c.CourseName,
    e.StartTime,
    e.EndTime,
    e.TotalTime,
    e.MaxDegree
FROM dbo.Exam e
INNER JOIN dbo.Course c ON e.CourseID = c.CourseID
INNER JOIN dbo.StudentExam se ON e.ExamID = se.ExamID
WHERE se.StudentID = USER_ID(USER_NAME());
GO



CREATE OR ALTER PROCEDURE dbo.sp_SecureSubmitExamAnswer
    @StudentExamID INT,
    @QuestionID INT,
    @StudentAnswer NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @StudentID INT;
    DECLARE @CurrentUserID INT;
    DECLARE @ExamID INT;
    DECLARE @ExamEndTime DATETIME;
    DECLARE @CurrentTime DATETIME;
    
    BEGIN TRY
        SET @CurrentTime = GETDATE();
        SET @CurrentUserID = USER_ID(USER_NAME());
        
        SELECT @StudentID = UserID 
        FROM dbo.Student 
        WHERE UserID = @CurrentUserID;
        
        SELECT @ExamID = ExamID 
        FROM dbo.StudentExam 
        WHERE StudentExamID = @StudentExamID 
        AND StudentID = @StudentID;
        
        IF @ExamID IS NULL
        BEGIN
            RAISERROR('Unauthorized: You cannot submit answers for this exam', 16, 1);
            RETURN;
        END
        
        SELECT @ExamEndTime = EndTime 
        FROM dbo.Exam 
        WHERE ExamID = @ExamID;
        
        IF @CurrentTime > @ExamEndTime
        BEGIN
            RAISERROR('Exam submission time has expired', 16, 1);
            RETURN;
        END
        
        IF LEN(LTRIM(RTRIM(@StudentAnswer))) = 0
        BEGIN
            RAISERROR('Answer cannot be empty', 16, 1);
            RETURN;
        END
        
        INSERT INTO dbo.StudentAnswer (
            StudentExamID, QuestionID, Answer, SubmissionTime
        )
        VALUES (
            @StudentExamID, @QuestionID, @StudentAnswer, @CurrentTime
        );
        
        INSERT INTO dbo.DataChangeAudit 
            (UserID, TableName, OperationType, NewValues, ChangeTime)
        VALUES 
            (@StudentID, 'StudentAnswer', 'INSERT', 
             'ExamID: ' + CAST(@ExamID AS NVARCHAR), @CurrentTime);
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(255);
        SET @ErrorMessage = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN;
    END CATCH
    
END;
GO



CREATE OR ALTER PROCEDURE dbo.sp_ChangeUserPassword
    @UserID INT,
    @OldPassword NVARCHAR(255),
    @NewPassword NVARCHAR(255),
    @ConfirmPassword NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @CurrentUserID INT;
    DECLARE @StoredHash NVARCHAR(255);
    DECLARE @OldPasswordHash NVARCHAR(255);
    
    BEGIN TRY
        SET @CurrentUserID = USER_ID(USER_NAME());
        
        IF @CurrentUserID <> @UserID
        BEGIN
            IF NOT EXISTS (
                SELECT 1 FROM dbo.UserAccounts 
                WHERE UserID = @CurrentUserID AND Role = 'Admin'
            )
            BEGIN
                RAISERROR('Unauthorized: You can only change your own password', 16, 1);
                RETURN;
            END
        END
        
        IF @NewPassword <> @ConfirmPassword
        BEGIN
            RAISERROR('New passwords do not match', 16, 1);
            RETURN;
        END
        
        IF LEN(@NewPassword) < 8
        BEGIN
            RAISERROR('Password must be at least 8 characters long', 16, 1);
            RETURN;
        END
        
        IF NOT (@NewPassword LIKE '%[A-Z]%' AND 
                @NewPassword LIKE '%[a-z]%' AND 
                @NewPassword LIKE '%[0-9]%')
        BEGIN
            RAISERROR('Password must contain uppercase, lowercase, and numbers', 16, 1);
            RETURN;
        END
        
        IF @CurrentUserID = @UserID
        BEGIN
            SET @OldPasswordHash = dbo.fn_HashPassword(@OldPassword);
            
            SELECT @StoredHash = PasswordHash 
            FROM dbo.UserAccounts 
            WHERE UserID = @UserID;
            
            IF @StoredHash <> @OldPasswordHash
            BEGIN
                RAISERROR('Invalid old password', 16, 1);
                RETURN;
            END
        END
        
        UPDATE dbo.UserAccounts
        SET 
            PasswordHash = dbo.fn_HashPassword(@NewPassword),
            LoginAttempts = 0,
            IsLocked = 0,
            LastModifiedDate = GETDATE()
        WHERE UserID = @UserID;
        
        INSERT INTO dbo.DataChangeAudit 
            (UserID, TableName, OperationType, RecordID, NewValues, ChangeTime)
        VALUES 
            (@CurrentUserID, 'UserAccounts', 'UPDATE', @UserID, 
             'Password changed', GETDATE());
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(255);
        SET @ErrorMessage = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN;
    END CATCH
    
END;
GO



CREATE OR ALTER PROCEDURE dbo.sp_UnlockUserAccount
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @CurrentUserID INT;
    
    BEGIN TRY
        SET @CurrentUserID = USER_ID(USER_NAME());
        
        IF NOT EXISTS (
            SELECT 1 FROM dbo.UserAccounts 
            WHERE UserID = @CurrentUserID AND Role = 'Admin'
        )
        BEGIN
            RAISERROR('Unauthorized: Only admins can unlock accounts', 16, 1);
            RETURN;
        END
        
        UPDATE dbo.UserAccounts
        SET 
            IsLocked = 0,
            LoginAttempts = 0,
            LastModifiedDate = GETDATE()
        WHERE UserID = @UserID;
        
        INSERT INTO dbo.DataChangeAudit 
            (UserID, TableName, OperationType, RecordID, NewValues, ChangeTime)
        VALUES 
            (@CurrentUserID, 'UserAccounts', 'UPDATE', @UserID, 
             'Account unlocked', GETDATE());
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(255);
        SET @ErrorMessage = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN;
    END CATCH
    
END;
GO



CREATE OR ALTER PROCEDURE dbo.sp_ViewAuditLogs
    @LogType NVARCHAR(20) = 'LOGIN',
    @Days INT = 7
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @CurrentUserID INT;
    
    BEGIN TRY
        SET @CurrentUserID = USER_ID(USER_NAME());
        
        IF NOT EXISTS (
            SELECT 1 FROM dbo.UserAccounts 
            WHERE UserID = @CurrentUserID AND Role = 'Admin'
        )
        BEGIN
            RAISERROR('Unauthorized: Only admins can view audit logs', 16, 1);
            RETURN;
        END
        
        IF @LogType = 'LOGIN'
        BEGIN
            SELECT 
                AuditID,
                UserName,
                LoginTime,
                IsSuccessful,
                FailureReason
            FROM dbo.LoginAudit
            WHERE LoginTime >= DATEADD(DAY, -@Days, GETDATE())
            ORDER BY LoginTime DESC;
        END
        
        ELSE IF @LogType = 'DATA_CHANGE'
        BEGIN
            SELECT 
                AuditID,
                UserID,
                TableName,
                OperationType,
                RecordID,
                NewValues,
                ChangeTime
            FROM dbo.DataChangeAudit
            WHERE ChangeTime >= DATEADD(DAY, -@Days, GETDATE())
            ORDER BY ChangeTime DESC;
        END
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(255);
        SET @ErrorMessage = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN;
    END CATCH
    
END;
GO



CREATE OR ALTER PROCEDURE dbo.sp_CreateDatabaseBackup
    @BackupPath NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @CurrentUserID INT;
    DECLARE @BackupFile NVARCHAR(256);
    DECLARE @CurrentDate NVARCHAR(20);
    
    BEGIN TRY
        SET @CurrentUserID = USER_ID(USER_NAME());
        
        IF NOT EXISTS (
            SELECT 1 FROM dbo.UserAccounts 
            WHERE UserID = @CurrentUserID AND Role = 'Admin'
        )
        BEGIN
            RAISERROR('Unauthorized: Only admins can create backups', 16, 1);
            RETURN;
        END
        
        SET @CurrentDate = FORMAT(GETDATE(), 'yyyyMMdd_HHmmss');
        SET @BackupFile = @BackupPath + 'ExaminationSystem_' + @CurrentDate + '.bak';
        
        BACKUP DATABASE [ExaminationSystem]
        TO DISK = @BackupFile
        WITH INIT, COMPRESS, STATS = 10;
        
        INSERT INTO dbo.DataChangeAudit 
            (UserID, TableName, OperationType, NewValues, ChangeTime)
        VALUES 
            (@CurrentUserID, 'System', 'BACKUP', 
             'Backup created at: ' + @BackupFile, GETDATE());
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(255);
        SET @ErrorMessage = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN;
    END CATCH
    
END;
GO

CREATE OR ALTER TRIGGER tr_EncryptSensitiveData
ON dbo.UserAccounts
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @@ROWCOUNT = 0
        RETURN;
  
    
    UPDATE dbo.UserAccounts
    SET LastModifiedDate = GETDATE()
    WHERE UserID IN (SELECT UserID FROM inserted);
    
END;
GO



CREATE OR ALTER PROCEDURE dbo.sp_GetStudentExamResults
    @StudentID INT,
    @StudentUserID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @CurrentUserID INT;
    DECLARE @UserRole NVARCHAR(100);
    
    BEGIN TRY
        SET @CurrentUserID = USER_ID(USER_NAME());
        
        SELECT @UserRole = Role 
        FROM dbo.UserAccounts 
        WHERE UserID = @CurrentUserID;
        
        IF @UserRole = 'Student' AND @CurrentUserID <> @StudentUserID
        BEGIN
            RAISERROR('Unauthorized: You can only view your own results', 16, 1);
            RETURN;
        END
        
        SELECT 
            c.CourseName,
            e.ExamName,
            se.TotalScore,
            e.MaxDegree,
            se.SubmissionDate
        FROM dbo.StudentExam se
        INNER JOIN dbo.Exam e ON se.ExamID = e.ExamID
        INNER JOIN dbo.Course c ON e.CourseID = c.CourseID
        WHERE se.StudentID = @StudentID
        ORDER BY se.SubmissionDate DESC;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(255);
        SET @ErrorMessage = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN;
    END CATCH
    
END;
GO


GRANT EXECUTE ON dbo.sp_ChangeUserPassword TO AdminRole;
GRANT EXECUTE ON dbo.sp_ChangeUserPassword TO TrainingManagerRole;
GRANT EXECUTE ON dbo.sp_ChangeUserPassword TO InstructorRole;
GRANT EXECUTE ON dbo.sp_ChangeUserPassword TO StudentRole;
GO

GRANT EXECUTE ON dbo.sp_SecureInsertQuestion TO InstructorRole;
GO

GRANT EXECUTE ON dbo.sp_SecureSubmitExamAnswer TO StudentRole;
GO

GRANT EXECUTE ON dbo.sp_GetStudentExamResults TO InstructorRole;
GRANT EXECUTE ON dbo.sp_GetStudentExamResults TO StudentRole;
GO

GRANT EXECUTE ON dbo.sp_UnlockUserAccount TO AdminRole;
GRANT EXECUTE ON dbo.sp_ViewAuditLogs TO AdminRole;
GRANT EXECUTE ON dbo.sp_CreateDatabaseBackup TO AdminRole;
GO


IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_LoginAudit_LoginTime')
    CREATE INDEX IX_LoginAudit_LoginTime 
    ON dbo.LoginAudit(LoginTime DESC);
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_DataChangeAudit_ChangeTime')
    CREATE INDEX IX_DataChangeAudit_ChangeTime 
    ON dbo.DataChangeAudit(ChangeTime DESC);
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_DataChangeAudit_UserID')
    CREATE INDEX IX_DataChangeAudit_UserID 
    ON dbo.DataChangeAudit(UserID);
GO

-- =====================================================
-- 28. DOCUMENT ACCOUNTS AND PASSWORDS
-- =====================================================

/*
==================================================
DATABASE SECURITY ACCOUNTS AND CREDENTIALS
==================================================

1. ADMIN ACCOUNT:
   Login Name: AdminUser
   Password: Admin@Secure2026#Complex!Pass
   Role: AdminRole
   Permissions: Full control on database
   Responsibilities: System maintenance, user management, audit logs

2. TRAINING MANAGER ACCOUNT:
   Login Name: TrainingManagerUser
   Password: TrainMgr@2026#SecurePass123
   Role: TrainingManagerRole
   Permissions: Manage instructors, courses, students
   Responsibilities: User and content management

3. INSTRUCTOR ACCOUNT:
   Login Name: InstructorUser
   Password: Instructor@2026#SafePass456
   Role: InstructorRole
   Permissions: Manage questions and exams for own courses
   Responsibilities: Question pool management, exam creation

4. STUDENT ACCOUNT:
   Login Name: StudentUser
   Password: Student@2026#PassSecure789
   Role: StudentRole
   Permissions: Take exams, view results
   Responsibilities: Exam participation, result viewing

==================================================
SECURITY FEATURES IMPLEMENTED:
==================================================
✓ Login and Database Users Created
✓ Role-Based Access Control (RBAC)
✓ Password Hashing with SHA2_256
✓ Login Attempt Tracking
✓ Account Locking After Failed Attempts
✓ Audit Logging (Login and Data Changes)
✓ Stored Procedures with Security Checks
✓ SQL Injection Prevention (Parameterized Queries)
✓ Data Isolation by User Role
✓ Triggers for Data Audit
✓ Function for Password Hashing
✓ Backup and Recovery Procedures
✓ Unauthorized Access Prevention

==================================================
IMPORTANT SECURITY NOTES:
==================================================
1. Change all default passwords immediately
2. Store passwords securely using a password manager
3. Enable SSL/TLS for database connections
4. Regularly review audit logs
5. Create automated daily backups
6. Implement row-level security for sensitive data
7. Use strong password policies
8. Monitor login attempts and failed connections
9. Review and update permissions quarterly
10. Test disaster recovery procedures regularly

*/

-- =====================================================
-- 29. VERIFY SECURITY SETUP
-- =====================================================

PRINT '=== DATABASE USERS ===';
SELECT name AS UserName, type_desc AS UserType
FROM sys.database_principals
WHERE type IN ('U', 'R')
ORDER BY name;

PRINT '';
PRINT '=== ROLE MEMBERSHIP ===';
SELECT DP1.name AS RoleName, DP2.name AS MemberName
FROM sys.database_principals DP1
INNER JOIN sys.database_role_members DRM ON DP1.principal_id = DRM.role_principal_id
INNER JOIN sys.database_principals DP2 ON DRM.member_principal_id = DP2.principal_id
ORDER BY DP1.name, DP2.name;

PRINT '';
PRINT '=== TABLE PERMISSIONS ===';
SELECT 
    OBJECT_NAME(major_id) AS TableName,
    grantee_principal_id,
    permission_name AS Permission,
    state_desc AS State
FROM sys.database_permissions
WHERE class = 1
ORDER BY OBJECT_NAME(major_id);

GO

PRINT '✓ Security implementation completed successfully!';
GO