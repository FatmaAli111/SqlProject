
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--MOHAMED
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

create or alter procedure sp_CreateDatabaseBackup
as
begin
    set nocount on;

    declare @CurrentUserID int;
    declare @BackupFile nvarchar(512);
    declare @CurrentDate nvarchar(20);
    
    declare @BackupPath nvarchar(256) = 'C:\Backup\';
    
    begin try

        set @CurrentUserID = user_id(user_name());

        if not exists
        (
            select 1
            from UserAccounts
            where userRole = 'AdminRole'
        )
        begin
            raiserror('Unauthorized: Only users in AdminRole can create backups.',16,1);
            return;
        end

        set @CurrentDate = format(getdate(),'yyyyMMdd_HHmmss');
        set @BackupFile = @BackupPath + 'ExaminationSystem_' + @CurrentDate + '.bak';
        
        print 'Backup will be created at: ' + @BackupFile;

        backup database ExaminationSystem
        to disk = @BackupFile
        with init, stats = 10;

        insert into DataChangeAudit
        (
            UserID,
            TableName,
            ChangeType,
            NewValue,
            ChangeTime
        )
        values
        (
            @CurrentUserID,
            'System',
            'BACKUP',
            'Backup created at: ' + @BackupFile,
            getdate()
        );

        print 'Backup completed successfully.';

    end try

    begin catch

        if error_message() like '%Access is denied%'
        begin
            raiserror('Backup failed due to a permissions issue. Ensure the SQL Server service account has write access to the C:\ drive. It is recommended to use a dedicated backup folder instead.',16,1);
        end
        else
        begin
            declare @ErrorMessage nvarchar(4000) = error_message();
            raiserror(@ErrorMessage,16,1);
        end

        return;

    end catch
end;
go