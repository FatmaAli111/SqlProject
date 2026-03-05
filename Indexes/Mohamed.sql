create nonclustered index IX_UserAccounts_UserName_Password on [dbo].[UserAccounts]([userName], [userPassword])

create nonclustered index IX_Student_Email on [dbo].[Student]([email])

create nonclustered index IX_Student_TrackId_UserId on [dbo].[Student]([userId], [trackId])

create nonclustered index IX_Instructor_Email on [dbo].[Instructor]([Email])

exec [dbo].[sp_CreateSecureUser] 'fatma1', 'fatma123123123', 'InstructorRole'

exec [dbo].[sp_CreateSecureUser] 'manager', 'manager123123', 'TrainingManagerRole'

exec [dbo].[sp_CreateSecureUser] 'mohamed11', 'mohamed123123123', 'InstructorRole'

exec [dbo].[sp_CreateSecureUser] 'fatma1', 'fatma123123123', 'StudentRole'



