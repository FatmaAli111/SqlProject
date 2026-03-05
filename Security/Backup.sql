CREATE OR ALTER PROCEDURE dbo.sp_CreateDatabaseBackup
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CurrentUserID INT;
    DECLARE @BackupFile NVARCHAR(512);
    DECLARE @CurrentDate NVARCHAR(20);
    
    DECLARE @BackupPath NVARCHAR(256) = 'C:\Backup\';
    
    BEGIN TRY
        SET @CurrentUserID = USER_ID(USER_NAME());
        IF NOT EXISTS (
            SELECT 1 FROM dbo.UserAccounts 
            WHERE userRole = 'AdminRole'
        )
        BEGIN
            RAISERROR('Unauthorized: Only users in AdminRole can create backups.', 16, 1);
            RETURN;
        END

        SET @CurrentDate = FORMAT(GETDATE(), 'yyyyMMdd_HHmmss');
        SET @BackupFile = @BackupPath + 'ExaminationSystem_' + @CurrentDate + '.bak';
        
        PRINT 'Backup will be created at: ' + @BackupFile;

        BACKUP DATABASE [ExaminationSystem]
        TO DISK = @BackupFile
        WITH INIT, STATS = 10;
        
        INSERT INTO dbo.DataChangeAudit 
            (UserID, TableName, ChangeType, NewValue, ChangeTime)
        VALUES 
            (@CurrentUserID, 'System', 'BACKUP', 
             'Backup created at: ' + @BackupFile, GETDATE());
        
        PRINT 'Backup completed successfully.';

    END TRY
    BEGIN CATCH
        IF ERROR_MESSAGE() LIKE '%Access is denied%'
        BEGIN
            RAISERROR('Backup failed due to a permissions issue. Ensure the SQL Server service account has write access to the C:\ drive. It is recommended to use a dedicated backup folder instead.', 16, 1);
        END
        ELSE
        BEGIN
            DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
            RAISERROR(@ErrorMessage, 16, 1);
        END
        RETURN;
    END CATCH
END;
GO