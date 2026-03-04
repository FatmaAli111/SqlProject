USE [ExaminationSystem]
GO



IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.UserAccounts') AND name = 'userPasswordHash')
BEGIN
    ALTER TABLE dbo.UserAccounts
    ADD userPasswordHash NVARCHAR(MAX) NULL;
    
END
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.UserAccounts') AND name = 'LastPasswordChange')
BEGIN
    ALTER TABLE dbo.UserAccounts
    ADD LastPasswordChange DATETIME DEFAULT GETDATE();
    
END
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.UserAccounts') AND name = 'FailedLoginAttempts')
BEGIN
    ALTER TABLE dbo.UserAccounts
    ADD FailedLoginAttempts INT DEFAULT 0;
    
END
GO



IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.UserAccounts') AND name = 'IsLocked')
BEGIN
    ALTER TABLE dbo.UserAccounts
    ADD IsLocked BIT DEFAULT 0;
    
    
END
GO



CREATE OR ALTER PROCEDURE dbo.sp_HashPassword
    @plainPassword NVARCHAR(MAX),
    @hashedPassword NVARCHAR(MAX) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        SET @hashedPassword = CONVERT(NVARCHAR(MAX), 
                                      HASHBYTES('SHA2_256', @plainPassword), 
                                      2);
        
        IF @hashedPassword IS NULL
        BEGIN
            RAISERROR('Hashing Failed', 16, 1);
            RETURN -1;
        END
        
        RETURN 0;
    END TRY
    BEGIN CATCH
        RAISERROR('Hashing Failed', 16, 1);
        RETURN -1;
    END CATCH
END
GO



CREATE OR ALTER PROCEDURE dbo.sp_VerifyPassword
    @userName NVARCHAR(30),
    @plainPassword NVARCHAR(MAX),
    @isValid BIT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @hashedPassword NVARCHAR(MAX);
    DECLARE @storedHash NVARCHAR(MAX);
    DECLARE @userId INT;
    DECLARE @isLocked BIT;
    
    BEGIN TRY
        SELECT @userId = userId, @storedHash = userPasswordHash, @isLocked = IsLocked
        FROM dbo.UserAccounts
        WHERE userName = @userName;
        
        IF @userId IS NULL
        BEGIN
            SET @isValid = 0;
            RAISERROR('Valid user', 16, 1);
            RETURN -1;
        END
        
        IF @isLocked = 1
        BEGIN
            SET @isValid = 0;
            RAISERROR('The account is closed due to multiple incorrect attempts.', 16, 1);
            RETURN -2;
        END
        
        EXEC dbo.sp_HashPassword @plainPassword, @hashedPassword OUTPUT;
        
        IF @hashedPassword = @storedHash
        BEGIN
            SET @isValid = 1;
            
            UPDATE dbo.UserAccounts
            SET FailedLoginAttempts = 0
            WHERE userId = @userId;
            
            INSERT INTO dbo.LoginAudit (UserID, LoginStatus, LoginTime)
            VALUES (@userId, 'Success', GETDATE());
            
            RETURN 0;
        END
        ELSE
        BEGIN
            SET @isValid = 0;
            
            UPDATE dbo.UserAccounts
            SET FailedLoginAttempts = FailedLoginAttempts + 1
            WHERE userId = @userId;
            
            IF (SELECT FailedLoginAttempts FROM dbo.UserAccounts WHERE userId = @userId) >= 10
            BEGIN
                UPDATE dbo.UserAccounts
                SET IsLocked = 1
                WHERE userId = @userId;
                
                RAISERROR('The account is closed due to multiple incorrect attempts.', 16, 1);
                RETURN -3;
            END
            
            INSERT INTO dbo.LoginAudit (UserID, LoginStatus, LoginTime)
            VALUES (@userId, 'Failed', GETDATE());
            
            RAISERROR('Wrong Password', 16, 1);
            RETURN -4;
        END
    END TRY
    BEGIN CATCH
        SET @isValid = 0;
        RAISERROR('unknown error ', 16, 1);
        RETURN -999;
    END CATCH
END
GO



CREATE OR ALTER PROCEDURE dbo.sp_UpdatePassword
    @userId INT,
    @oldPassword NVARCHAR(MAX),
    @newPassword NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @userName NVARCHAR(30);
    DECLARE @isValid BIT;
    DECLARE @hashedNewPassword NVARCHAR(MAX);
    
    BEGIN TRY
        SELECT @userName = userName FROM dbo.UserAccounts WHERE userId = @userId;
        
        IF @userName IS NULL
        BEGIN
            RAISERROR('المستخدم غير موجود', 16, 1);
            RETURN -1;
        END
        
        EXEC dbo.sp_VerifyPassword @userName, @oldPassword, @isValid OUTPUT;
        
        IF @isValid = 0
        BEGIN
            RAISERROR('كلمة السر القديمة غير صحيحة', 16, 1);
            RETURN -2;
        END
        
        IF LEN(@newPassword) < 12
        BEGIN
            RAISERROR('The password must be at least 12 characters long.', 16, 1);
            RETURN -3;
        END
        
        EXEC dbo.sp_HashPassword @newPassword, @hashedNewPassword OUTPUT;
        
        UPDATE dbo.UserAccounts
        SET userPasswordHash = @hashedNewPassword,
            LastPasswordChange = GETDATE(),
            FailedLoginAttempts = 0,
            IsLocked = 0
        WHERE userId = @userId;
        
        INSERT INTO dbo.DataChangeAudit (UserID, TableName, ChangeType, ChangeTime)
        VALUES (@userId, 'UserAccounts', 'Password Changed', GETDATE());
        
        PRINT 'Password updated successfully';
        RETURN 0;
    END TRY
    BEGIN CATCH
        RAISERROR('Password update error', 16, 1);
        RETURN -999;
    END CATCH
END
GO



CREATE OR ALTER PROCEDURE dbo.sp_CreateSecureUser
    @userName NVARCHAR(30),
    @plainPassword NVARCHAR(MAX),
    @userRole NVARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @hashedPassword NVARCHAR(MAX);
    DECLARE @userId INT;
    
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM dbo.UserAccounts WHERE userName = @userName)
        BEGIN
            RAISERROR('Username already exists', 16, 1);
            RETURN -1;
        END
        
        IF LEN(@plainPassword) < 12
        BEGIN
            RAISERROR('The password must be at least 12 characters long.', 16, 1);
            RETURN -2;
        END
        
        EXEC dbo.sp_HashPassword @plainPassword, @hashedPassword OUTPUT;
        
        INSERT INTO dbo.UserAccounts (userName, userPassword, userPasswordHash, userRole, LastPasswordChange, FailedLoginAttempts, IsLocked)
        VALUES (@userName, '***ENCRYPTED***', @hashedPassword, @userRole, GETDATE(), 0, 0);
        
        SET @userId = SCOPE_IDENTITY();
        
        INSERT INTO dbo.DataChangeAudit (UserID, TableName, ChangeType, ChangeTime)
        VALUES (@userId, 'UserAccounts', 'User Created', GETDATE());
        
        PRINT 'User created ' + @userName + ' Successfully';
        RETURN @userId;
    END TRY
    BEGIN CATCH
        RAISERROR('Error creating user', 16, 1);
        RETURN -999;
    END CATCH
END
GO



CREATE OR ALTER TRIGGER tr_SyncPasswordWithLogin
ON dbo.UserAccounts
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @userName NVARCHAR(30);
    DECLARE @hashedPassword NVARCHAR(MAX);
    
    SELECT @userName = userName, @hashedPassword = userPasswordHash
    FROM inserted;
    
    IF UPDATE(userPasswordHash)
    BEGIN
        INSERT INTO dbo.DataChangeAudit (UserID, TableName, ChangeType, ChangeTime)
        SELECT userId, 'UserAccounts', 'Password Synced with LOGIN', GETDATE()
        FROM inserted;
    END
END
GO



CREATE OR ALTER VIEW dbo.vw_SafeUserAccounts
AS
SELECT 
    userId,
    userName,
    userRole,
    LastPasswordChange,
    FailedLoginAttempts,
    IsLocked
FROM dbo.UserAccounts
GO



GRANT EXECUTE ON dbo.sp_UpdatePassword TO InstructorRole;
GRANT EXECUTE ON dbo.sp_VerifyPassword TO InstructorRole;

GRANT EXECUTE ON dbo.sp_UpdatePassword TO StudentRole;
GRANT EXECUTE ON dbo.sp_VerifyPassword TO StudentRole;

GRANT EXECUTE ON dbo.sp_CreateSecureUser TO AdminRole;
GRANT EXECUTE ON dbo.sp_HashPassword TO AdminRole;

DENY SELECT ON dbo.UserAccounts TO PUBLIC;
GRANT SELECT ON dbo.vw_SafeUserAccounts TO AdminRole;

GO




DECLARE @userId INT;
DECLARE @plainPassword NVARCHAR(MAX);
DECLARE @hashedPassword NVARCHAR(MAX);

DECLARE password_cursor CURSOR FOR
SELECT userId, userPassword FROM dbo.UserAccounts WHERE userPasswordHash IS NULL;

OPEN password_cursor;
FETCH NEXT FROM password_cursor INTO @userId, @plainPassword;

WHILE @@FETCH_STATUS = 0
BEGIN
    EXEC dbo.sp_HashPassword @plainPassword, @hashedPassword OUTPUT;
    
    UPDATE dbo.UserAccounts
    SET userPasswordHash = @hashedPassword
    WHERE userId = @userId;
    
    FETCH NEXT FROM password_cursor INTO @userId, @plainPassword;
END

CLOSE password_cursor;
DEALLOCATE password_cursor;





IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PasswordChangeHistory')
BEGIN
    CREATE TABLE dbo.PasswordChangeHistory (
        ChangeID INT IDENTITY(1,1) PRIMARY KEY,
        UserID INT NOT NULL,
        OldPasswordHash NVARCHAR(MAX),
        NewPasswordHash NVARCHAR(MAX),
        ChangeTime DATETIME DEFAULT GETDATE(),
        ChangedBy INT,
        CONSTRAINT FK_PasswordChangeHistory_UserID FOREIGN KEY (UserID) REFERENCES dbo.UserAccounts(userId)
    );
    
    CREATE INDEX IX_PasswordChangeHistory_UserID ON dbo.PasswordChangeHistory(UserID);
    CREATE INDEX IX_PasswordChangeHistory_ChangeTime ON dbo.PasswordChangeHistory(ChangeTime DESC);
    
    PRINT 'تم إنشاء جدول PasswordChangeHistory';
END
GO



CREATE OR ALTER TRIGGER tr_LogPasswordChanges
ON dbo.UserAccounts
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF UPDATE(userPasswordHash)
    BEGIN
        INSERT INTO dbo.PasswordChangeHistory (UserID, OldPasswordHash, NewPasswordHash, ChangeTime)
        SELECT 
            i.userId,
            d.userPasswordHash,
            i.userPasswordHash,
            GETDATE()
        FROM inserted i
        JOIN deleted d ON i.userId = d.userId;
    END
END
GO



CREATE OR ALTER PROCEDURE dbo.sp_UnlockUserAccount
    @userId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        UPDATE dbo.UserAccounts
        SET IsLocked = 0,
            FailedLoginAttempts = 0
        WHERE userId = @userId;
        
        INSERT INTO dbo.DataChangeAudit (UserID, TableName, ChangeType, ChangeTime)
        VALUES (@userId, 'UserAccounts', 'Account Unlocked', GETDATE());
        
        PRINT 'تم فتح الحساب بنجاح';
        RETURN 0;
    END TRY
    BEGIN CATCH
        RAISERROR('خطأ في فتح الحساب', 16, 1);
        RETURN -1;
    END CATCH
END
GO

GRANT EXECUTE ON dbo.sp_UnlockUserAccount TO AdminRole;

GO


exec sp_CreateSecureUser Mohamed, Mohamed123123, instructor
/*

1. sp_HashPassword - تشفير كلمة السر
   EXEC dbo.sp_HashPassword @plainPassword, @hashedPassword OUTPUT;

2. sp_VerifyPassword - التحقق من كلمة السر
   EXEC dbo.sp_VerifyPassword @userName, @plainPassword, @isValid OUTPUT;

3. sp_UpdatePassword - تحديث كلمة السر
   EXEC dbo.sp_UpdatePassword @userId, @oldPassword, @newPassword;

4. sp_CreateSecureUser - إنشاء مستخدم جديد بشكل آمن
   EXEC dbo.sp_CreateSecureUser @userName, @plainPassword, @userRole;

5. sp_UnlockUserAccount - فتح حساب مقفول
   EXEC dbo.sp_UnlockUserAccount @userId;

الجداول الجديدة:
- PasswordChangeHistory - تسجيل تاريخ تغييرات كلمات السر

الأعمدة الجديدة في UserAccounts:
- userPasswordHash - كلمة السر المشفرة
- LastPasswordChange - آخر تغيير لكلمة السر
- FailedLoginAttempts - عدد محاولات الدخول الفاشلة
- IsLocked - حالة قفل الحساب
*/

PRINT '✓ تم تطبيق جميع تحسينات الأمان بنجاح!';



USE [ExaminationSystem]
GO

-- ... (Previous code remains the same until sp_CreateSecureUser) ...

CREATE OR ALTER PROCEDURE dbo.sp_CreateSecureUser
    @userName NVARCHAR(30),
    @plainPassword NVARCHAR(MAX),
    @userRole NVARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @hashedPassword NVARCHAR(MAX);
    DECLARE @userId INT;
    DECLARE @sql NVARCHAR(MAX);

    BEGIN TRY
        -- Check if the user already exists in the UserAccounts table
        IF EXISTS (SELECT 1 FROM dbo.UserAccounts WHERE userName = @userName)
        BEGIN
            RAISERROR('Username already exists in the UserAccounts table.', 16, 1);
            RETURN -1;
        END

        IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = @userName)
        BEGIN
            RAISERROR('Login name already exists on the server.', 16, 1);
            RETURN -2;
        END

        IF LEN(@plainPassword) < 12
        BEGIN
            RAISERROR('Password must be at least 12 characters long.', 16, 1);
            RETURN -3;
        END

        SET @sql = N'CREATE LOGIN ' + QUOTENAME(@userName) + N' WITH PASSWORD = N''' + REPLACE(@plainPassword, '''', '''''') + N''';';
        EXEC sp_executesql @sql;
        PRINT 'Server login created successfully for: ' + @userName;

        SET @sql = N'CREATE USER ' + QUOTENAME(@userName) + N' FOR LOGIN ' + QUOTENAME(@userName) + N';';
        EXEC sp_executesql @sql;
        PRINT 'Database user created successfully for: ' + @userName;

        SET @sql = N'ALTER ROLE ' + QUOTENAME(@userRole) + N' ADD MEMBER ' + QUOTENAME(@userName) + N';';
        EXEC sp_executesql @sql;
        PRINT 'User ' + @userName + ' added to role ' + @userRole;

        EXEC dbo.sp_HashPassword @plainPassword, @hashedPassword OUTPUT;

        INSERT INTO dbo.UserAccounts (userName, userPassword, userPasswordHash, userRole, LastPasswordChange, FailedLoginAttempts, IsLocked)
        VALUES (@userName, '***ENCRYPTED***', @hashedPassword, @userRole, GETDATE(), 0, 0);

        SET @userId = SCOPE_IDENTITY();

        INSERT INTO dbo.DataChangeAudit (UserID, TableName, ChangeType, ChangeTime)
        VALUES (@userId, 'UserAccounts', 'User Created', GETDATE());

        PRINT 'User ' + @userName + ' created successfully in both the table and on the server.';
        RETURN @userId;
    END TRY
    BEGIN CATCH
        IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = @userName)
        BEGIN
            SET @sql = N'DROP LOGIN ' + QUOTENAME(@userName) + N';';
            EXEC sp_executesql @sql;
            PRINT 'Rolled back server login creation due to an error.';
        END
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
        
        RETURN -999;
    END CATCH
END
GO

drop proc dbo.sp_CreateSecureUser


GO
exec dbo.sp_CreateSecureUser Mohamed000, Mohamed123123, InstructorRole 