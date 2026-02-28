create nonclustered index IX_UserAccounts_UserName_Password on [dbo].[UserAccounts]([userName], [userPassword])

create nonclustered index IX_Student_Email on [dbo].[Student]([email])

create nonclustered index IX_Student_TrackId_UserId on [dbo].[Student]([userId], [trackId])

create nonclustered index IX_Instructor_Email on [dbo].[Instructor]([Email])

