--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--MOHAMED
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


create table Course
(
CourseID int identity(1,1) not null,
[Course Name] nvarchar(100) not null,
[Description] nvarchar(max) null,
[Max Degree] int not null,
[Min Degree] int not null,

constraint PK_COURSE primary key (CourseID),
constraint UQ_COURSE_NAME unique ([Course Name]),
constraint CHK_COURSE_DEGREE check	([Min Degree] >= 0 and [Max Degree] > [Min Degree])
);


----------------------------------------------------------------------------------------------------------

create table QuestionPool
(
QuestionID int identity(1,1) not null,
QuestionText nvarchar(max) not null,
QuestionType nvarchar(4) not null,
CorrectAnswer nvarchar(max) null,
CourseID int not null,

constraint QuestionPool_PK Primary key (QuestionID),
constraint FK_QuestionPool_Course foreign key (CourseID) references COURSE(CourseID) on delete cascade,
constraint CHK_QuestionType check (QuestionType in ('MCQ', 'T/F', 'Text')),
constraint CHK_CorrectAnswer_NotEmpty check (len(CorrectAnswer) > 0)

);


---------------------------------------------------------------------------------------------------------

create table Enrollments
(
StudentID int not null,
CourseID int not null,
constraint PK_Enrollments primary key (CourseID, StudentID),
constraint FK_Enrollments_Course foreign key (CourseID) references COURSE(CourseID) on delete cascade,
constraint Fk_Enrollments_Student foreign key (StudentID) references STUDENT(StudentID) on delete cascade
);

---------------------------------------------------------------------------------------------------------

create table InstructorCourses
(
InstructorID int not null,
CourseID int not null,
constraint PK_Instructor_Courses primary key (InstructorID, CourseID),
constraint FK_InstructorCourses_Instructor  foreign key (InstructorID) references Instructor(InstructorID) on delete cascade,
constraint FK_InstructorCourses_Course  foreign key (CourseID) references Course(CourseID) on delete cascade
)

----------------------------------------------------------------------------------------------------------

create table StudentExam(
StudentExamID int identity(1,1) not null,
StudentID int not null,
ExamID int not null,
TotalScore int null,
 constraint PK_StudentExam primary key clustered 
(
	[StudentExamID] asc
)with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on, optimize_for_sequential_key = off) on [PRIMARY],
 constraint [UQ_Student_Exam] unique nonclustered 
(
	[StudentID] asc,
	[ExamID] asc
)with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on, optimize_for_sequential_key = off) on [PRIMARY]
) on [PRIMARY]
go

alter table [dbo].[StudentExam]  with check add  constraint [FK_StudentExam_Exam] foreign key([ExamID])
references [dbo].[Exam] ([ExamID])
on delete cascade
go

alter table [dbo].[StudentExam] check constraint [FK_StudentExam_Exam]
go

alter table [dbo].[StudentExam]  with check add  constraint [FK_StudentExam_Student] foreign key([StudentID])
references [dbo].[Student] ([studentId])
on delete cascade
go

alter table [dbo].[StudentExam] check constraint [FK_StudentExam_Student]

----------------------------------------------------------------------------------------------------------

create table DataChangeAudit
(
AuditID int identity(1,1) not null,
UserID int not null,
TableName nvarchar(128) null,
ChangeType nvarchar(20) null,
OldValue nvarchar(max) null,
NewValue nvarchar(max) null,
ChangeTime datetime null,

constraint DataChangeAudit_PK primary key (AuditID),
constraint FK_DataChangeAudit_UserID foreign key (UserID) references UserAccounts(userId),
constraint DF_DataChangeAudit_ChangeTime default getdate() for ChangeTime
);

----------------------------------------------------------------------------------------------------------

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
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--Fatma
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

alter table exam drop column examtotaltime;
alter table exam
add examtotaltime as (datediff(minute,[starttime],[endtime])) persisted;
create table Exam(
ExamID int primary Key identity(1,1),
[Name] varchar(20) not null,
[Type] varchar(10) not null check([Type] in ('Corrective','Exam')),
StartTime time not null,
EndTime time  not null,
[Day] date ,
CourseID int not null,
InstructorID int not null,
ExamTotalTime as datediff(minute,StartTime,EndTime) persisted,--stored permenantly
foreign key (CourseID) references Course(CourseID),
foreign key (InstructorID) references Instructor(InstructorID),
constraint chkExamTime check(EndTime >StartTime),
constraint chkExamTotalTime check(DateDiff(minute, StartTime, EndTime) >=60),
constraint chkSameDate check(cast(StartTime as datetime)<cast(EndTime as datetime))

)
create table ExamAllowanceOptions (
OptionText varchar(20),
ExamID int foreign key (ExamID) references Exam(ExamID),
primary key(OptionText,ExamID)
)
--constraint check if time between end and start > hour
--create table QuestionPool(
--QuestionID int primary Key identity,
--QuestionText nvarchar(max),
--[Type] varchar(4) check([Type] in ('Text','MCQ','T&F'))
--CorrectAnswer varchar(max),
--CourseID int not null,
--foreign key (CourseID) references Course(CourseID) 
--)

create table Contain(
Degree int not null,
StudentAnswer varchar(max) ,
QuestionID int not null,
ExamID int not null,
foreign key (ExamID) references Exam(ExamID) ,
foreign key (QuestionID) references QuestionPool(QuestionID) ,
primary key (ExamID,QuestionID)
)

create table QuestionChoices(
ChoicesID int primary key identity(1,1),
ChoiceText varchar(50) unique,
QuestionID int,
foreign key (QuestionID) references QuestionPool(QuestionID) 
)

create table Instructor(
InstructorID int primary key identity(1,1),
FullName varchar(20) not null ,
Email nvarchar(30) unique,
CourseID int,
ManagerID int,
foreign key (ManagerID) references Instructor(InstructorID),
foreign key (CourseID) references Course(CourseID),
constraint chkManagerSelf check(ManagerID<>InstructorID)

)
create type PhoneUDD from varchar(11) not null 
create  table InstructorPhone(
phone  PhoneUDD CHECK (phone Like '01[0-9]%'),
InstructorID int,

foreign key (InstructorID) references Instructor(InstructorID),
primary key(phone,InstructorID)
)
--Edit instructor table
alter table instructor drop constraint FK__Instructo__Cours__6754599E 

exec sp_rename 'InstructorID','CourseID','UserID'

alter table instructor add constraint FKUserRef foreign key (UserID) references [dbo].[UserAccounts](UserID)



--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--remonda
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


create table Branch (
branchId int identity(1,1) primary key,
branchName nvarchar(30) not null unique
);

create table Intake (
intakeId int identity(1,1) primary key,
intakeName nvarchar(30) not null
);

create table BranchIntake (
branchId int not null,
intakeId int not null,

constraint pk_branchintake primary key (branchId, intakeId),
constraint fk_branchintake_branch foreign key (branchId) references Branch(branchId),
constraint fk_branchintake_intake foreign key (intakeId) references Intake(intakeId)
);

create table Department (
departmentId int identity(1,1) primary key,
departmentName nvarchar(30) not null
);

create table Track (
trackId int identity(1,1) primary key,
trackName nvarchar(30) not null,
departmentId int not null,

constraint fk_track_department foreign key (departmentId) references Department(departmentId)
);

create table IntakeTrack (
 intakeId int not null,
 trackId int not null,

constraint pk_intaketrack primary key (intakeId, trackId),
constraint fk_intaketrack_intake foreign key (intakeId) references Intake(intakeId),
constraint fk_intaketrack_track foreign key (trackId) references Track(trackId)
);

create table UserAccounts (
userId int identity(1,1) primary key,
userName nvarchar(30) not null unique,
userPassword nvarchar(30) not null,
userRole nvarchar(30) not null check (userRole in ('student','instructor','manager','admin'))
);

create table Student (
studentId int identity(1,1) primary key,
fname nvarchar(30) not null,
lname nvarchar(30),
email nvarchar(30) unique,
userId int not null,
trackId int not null,

constraint fk_student_useraccounts foreign key (userId) references UserAccounts(userId),
constraint fk_student_track foreign key (trackId) references Track(trackId)
);

create table StudentPhone (
phone PhoneUDD CHECK (phone Like '01[0-9]%'),
studentId int not null,

constraint pk_studentphone primary key (studentId, phone),
constraint fk_studentphone_student foreign key (studentId) references Student(studentId)
);




alter table [dbo].[Contain] drop column [StudentAnswer];

create table StudentAnswer(
studentId int not null,
examId int not null,
questionID int not null,
studentAnswer nvarchar(max),
studentDegree int default 0,

constraint fk_studentId foreign key (studentId) references [dbo].[Student]([studentId]),
constraint fk_examId foreign key (examId) references [dbo].[Exam]([ExamID]),
constraint fk_questionID foreign key (questionID) references [dbo].[QuestionPool]([QuestionID]),
constraint fk_examQuestion foreign key (examId, questionID)  references [dbo].[Contain](ExamID, QuestionID),

constraint pk_StudentAnswer primary key (studentId,examId,questionID)
)

go 



----------user-------------------
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
    
END
GO


/*

sp_HashPassword - Encrypt the password EXEC dbo.sp_HashPassword @plainPassword, @hashedPassword OUTPUT;
sp_VerifyPassword - Verify the password EXEC dbo.sp_VerifyPassword @userName, @plainPassword, @isValid OUTPUT;
sp_UpdatePassword - Update the password EXEC dbo.sp_UpdatePassword @userId, @oldPassword, @newPassword;
sp_CreateSecureUser - Create a new user securely EXEC dbo.sp_CreateSecureUser @userName, @plainPassword, @userRole;
sp_UnlockUserAccount - Unlock a locked account EXEC dbo.sp_UnlockUserAccount @userId;

PasswordChangeHistory - Logs the history of password changes New Columns in UserAccounts:
userPasswordHash - The encrypted password
LastPasswordChange - The last password change date
FailedLoginAttempts - The number of failed login attempts
IsLocked - The lock status of the account
*/



----------------functions 
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--MOHAMED
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------



Create function fn_GetExamDurationInMinutes (@ExamID int)
returns int
as
begin

	declare @Duration int

select @Duration = DATEDIFF(Minute, [StartTime], [EndTime])
from [dbo].[Exam]
where [ExamID] = @ExamID

return isnull (@Duration, 0)

end;

------------------------------------------------------------------------------------------------------------

Create function fn_GetExamTotalDegree (@ExamID int)
returns int
as
begin
	
	declare @TotalDegree int;

select @TotalDegree = isnull(sum([Degree]), 0)
from [dbo].[Contain]
where [ExamID] = @ExamID

return @TotalDegree;

end;

------------------------------------------------------------------------------------------------------------

CREATE FUNCTION dbo.fn_HashPassword(@Password NVARCHAR(255))
RETURNS NVARCHAR(255)
AS
BEGIN
    DECLARE @HashedPassword NVARCHAR(255);
    SET @HashedPassword = CONVERT(VARCHAR(255), 
        HASHBYTES('SHA2_256', @Password), 2);
    RETURN @HashedPassword;
END;


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--Fatma
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

create function fn_countinstructorexams
(
    @instructorid int,
    @courseid int
)
returns int
as
begin
    declare @total int;

    select @total = count(*)
    from exam
    where instructorid = @instructorid
      and courseid = @courseid;

    return isnull(@total,0);
end



create function fn_countCourseQuestions
(
@CourseRef int 
)
returns int 
as begin
declare @var int 
select @var=count(questionid) from QuestionPool 
where CourseID=@CourseRef
return isnull(@var,0)
end

------------------------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--remonda
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

create function GetStudentResult (@exam_id int , @student_id int)
returns int
as begin
declare @total_degree int;

select @total_degree=sum([studentDegree]) from [dbo].[StudentAnswer]
where [studentId]=@student_id and [examId]=@exam_id;

return @total_degree;

end

go 

create function GetStudentPassFail  (@exam_id int , @student_id int)
returns nvarchar(10)
as begin
declare @total_degree int;
declare @exam_total int;
set @exam_total  = dbo.fn_GetExamTotalDegree(@exam_id);
set @total_degree=dbo.GetStudentResult(@exam_id, @student_id);

if(@total_degree >= (@exam_total * 0.5))
   return 'Pass';
return 'Fail';
end

go 

-----------------indexes
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--MOHAMED
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

create nonclustered index IX_UserAccounts_UserName_Password on [dbo].[UserAccounts]([userName], [userPassword])

create nonclustered index IX_Student_Email on [dbo].[Student]([email])

create nonclustered index IX_Student_TrackId_UserId on [dbo].[Student]([userId], [trackId])

create nonclustered index IX_Instructor_Email on [dbo].[Instructor]([Email])


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--Fatma
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


create nonclustered index ix_exam_courseid_instructorid 
on [dbo].[exam] ([courseid], [instructorid]);

create nonclustered index ix_exam__instructorid
on [dbo].[exam] ([instructorid]);

create nonclustered index ix_exam_courseid
on [dbo].[exam] ([courseid]);

create nonclustered index ix_questionpool_courseid 
on [dbo].[questionpool] ([courseid]);

create nonclustered index ix_student_trackid 
on [dbo].[student] ([trackid]);

create nonclustered index ix_instructorcourses_courseid 
on [dbo].[instructorcourses] ([courseid]);


create nonclustered index ix_studentanswer_examid_studentid 
on [dbo].[studentanswer] ([examid], [studentid])
include ([studentdegree]);

---------------------procedures
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--MOHAMED
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

create procedure [dbo].[sp_instructor_exam_addrandomquestions]
     @examid int,
     @numberofquestions int,
     @degreeperquestion int
 as
 begin
     if not exists (select 1 from dbo.exam where examid = @examid) throw 50004, 'exam not found.', 1;

     declare @totalnewdegrees int = @numberofquestions * @degreeperquestion;
     declare @currentexamdegrees int;
     declare @coursemaxdegrees int;

     select @currentexamdegrees = isnull(sum(degree), 0) from dbo.contain where examid = @examid;
     select @coursemaxdegrees = c.[max degree] from dbo.exam e join dbo.course c on e.courseid = c.courseid where e.examid = @examid;

     if (@currentexamdegrees + @totalnewdegrees > @coursemaxdegrees)
     begin
         declare @errormsg nvarchar(200) = formatmessage('cannot add questions. adding %d degrees would exceed the course max degree of %d. current exam degree is %d.', @totalnewdegrees, @coursemaxdegrees, @currentexamdegrees);
         throw 50005, @errormsg, 1;
     end

     insert into dbo.contain (examid, questionid, degree)
     select top (@numberofquestions)
         @examid,
         q.questionid,
         @degreeperquestion
     from 
         dbo.questionpool q
     where 
         q.courseid = (select courseid from dbo.exam where examid = @examid)
         and q.questionid not in (select questionid from dbo.contain where examid = @examid)
     order by 
         newid();

     print formatmessage('success: %d random questions of type %s added to exam %d.', @@rowcount, @questiontype, @examid);
 end
--------------------------------------------------------------------------------

create proc sp_Manager_Instructor_Add @FullName nvarchar(20), @Email nvarchar(20), @ManagerID int, @UserID int
as
begin

set nocount on;

	if not exists (select 1 from [dbo].[UserAccounts] where [UserID]= @UserID)
	begin
		raiserror('The specified UserID does not exist in UserAccounts.', 16, 1);
		return;
	end

	if exists (select 1 from [dbo].[Instructor] where [Email]= @Email)
	begin
		raiserror('An instructor with this email already exists.', 16, 1)
		return;
	end

	  insert into [dbo].[Instructor] (FullName, Email, ManagerID, userId)
    values (@FullName, @Email, @ManagerID, @userId);

end

--------------------------------------------------------------------------------------------------------------

create proc sp_Manager_Instructor_GetAll
as
begin 

set nocount on;

select *from [dbo].[Instructor]

end

--------------------------------------------------------------------------------------------------------------

create proc sp_Manager_Instructor_GetById @InstructorID int
as
begin

set nocount on;

select *from [dbo].[Instructor]
where [dbo].[Instructor].[InstructorID] = @InstructorID

end

--------------------------------------------------------------------------------------------------------------

create proc sp_Manager_Instructor_Update @InstructorID int, @FullName nvarchar(20), @Email nvarchar(30), @ManagerID int = null, @UserID int
as
begin

set nocount on;

	if not exists ( select 1 from [dbo].[UserAccounts]  where [userId] = @UserID)
		begin
		raiserror('The specified UserID does not exist in UserAccounts.', 16, 1);
		return;
		end
	
	if not exists (select 1 from [dbo].[Instructor] where [InstructorID] = @InstructorID)
		begin
		raiserror('Cannot update. Instructor with the specified ID does not exist.', 16, 1);
		return;
		end
	
	if exists (select 1 from [dbo].[Instructor] where [Email] = @Email and [InstructorID] <> @InstructorID)
		begin
		raiserror('Cannot update. The new email is already in use by another instructor.', 16, 1);
		return;
		end
	
	update [dbo].[Instructor]
	set [FullName] = @FullName,
		[Email] = @Email,
		[UserID] = @UserID,
		ManagerID = @ManagerID
	where [InstructorID] = @InstructorID;

	PRINT 'Instructor updated successfully.';

end

--------------------------------------------------------------------------------------------------------------

create proc sp_Manager_Instructor_Delete @InstructorID int
as
begin

set nocount on;

	if not exists (select 1 from [dbo].[Instructor] where [InstructorID] = @InstructorID)
		begin
		raiserror ('Cannot delete. No instructor exists with this ID.', 16, 1);
		return;
		end

	if exists (select 1 from [dbo].[Instructor] where  [ManagerID]= @InstructorID)
		begin
		raiserror ('Cannot delete. This instructor is currently a manager for other instructors. Please reassign them first.', 16, 1);
		return;
		end

	if exists (select 1 from [dbo].[InstructorCourses] where [InstructorID] = @InstructorID)
		begin
		raiserror('Cannot delete. This instructor is assigned to one or more courses.', 16, 1);
		return;
		end

begin try
delete from [dbo].[Instructor]
where [InstructorID] = @InstructorID
end try
begin catch
	throw;
	end catch

end

--------------------------------------------------------------------------------------------------------------

create proc sp_Manager_Course_Add @CourseName nvarchar(100), @Description nvarchar(max) = null, @MaxDegree int, @MinDegree int
as
begin

set nocount on;

	if exists (select 1 from [dbo].[Course] where [Course Name] = @CourseName)
        begin
            raiserror ('a Course with this name already exists.', 16, 1);
            return;
        end

	 if (@MinDegree >= @MaxDegree)
        begin
            raiserror ('min degree must be less than max degree.', 16, 1);
            return;
        end

        insert into [dbo].[Course] ([Course Name],[Description] , [Max Degree], [Min Degree])
        values (@CourseName, @Description, @MaxDegree, @MinDegree);

        print 'Course Added Successfully.';
end

--------------------------------------------------------------------------------------------------------------

create proc sp_Manager_Course_GetAll
as
begin

set nocount on;

select *from [dbo].[Course]

end

--------------------------------------------------------------------------------------------------------------

create proc sp_Manager_Course_GetById @CourseID int
as
begin

set nocount on; 

	if not exists (select 1 from [dbo].[Course] where [CourseID] = @CourseID)
		begin
		raiserror('No course found with the specified ID.', 16, 1);
		return;
		end

select *from [dbo].[Course]
where [CourseID] = @CourseID
end

--------------------------------------------------------------------------------------------------------------

create proc sp_Manager_Course_Update @CourseID int, @Description nvarchar(max), @CourseName nvarchar(100), @MaxDegree int, @MinDegree int
as
begin

set nocount on;
	begin try
	if not exists ( select 1 from [dbo].[Course] where [CourseID] = @CourseID)
		begin
		raiserror('No course found with the specified ID.', 16, 1);
		return;
		end

	if exists (select 1 from [dbo].[Course] where [Course Name] = @CourseName and [CourseID] <> @CourseID)
		begin
		raiserror('A course with this name already exists.', 16, 1);
		return;
		end

	if (@MinDegree >= @MaxDegree)
        begin
            raiserror ('min degree must be less than max degree.', 16, 1);
            return;
        end

update [dbo].[Course]
set [Course Name] = @CourseName,
	[Description] = @Description,
	[Max Degree] = @MaxDegree,
	[Min Degree] = @MinDegree
where [CourseID] = @CourseID
	
	end try
	begin catch
		throw;
	end catch
end

--------------------------------------------------------------------------------------------------------------

create proc sp_Manager_Course_Delete @CourseID int
as
begin
	
	set nocount on;

	begin try
	if not exists (select 1 from [dbo].[Course] where [CourseID] = @CourseID)
		begin
		raiserror('No course found with the specified ID.', 16, 1);
		return;
		end

	if exists (select 1 from dbo.Exam where CourseID = @CourseID)
        begin
        raiserror ('Cannot delete. This course is used in one or more exams.', 16, 1);
        return;
        end

	 if exists (select 1 from dbo.InstructorCourses where CourseID = @CourseID)
        begin
        raiserror ('Cannot delete. This course is currently assigned to one or more instructors.', 16, 1);
        return;
        end

	 if exists (select 1 from [dbo].[Enrollments] where [CourseID] = @CourseID)
		begin
		raiserror('Cannot delete. There are students currently enrolled in this course.', 16, 1)
		return;
		end


delete from [dbo].[Course]
	where [CourseID] = @CourseID
	print 'Course deleted successfully.';


	end try
	begin catch
		throw;
	end catch

end

--------------------------------------------------------------------------------------------------------------

create procedure sp_Instructor_EnrollStudentInExam
(
@examId int,
@studentId int
)
as
begin

set nocount on;

if not exists (select 1 from Exam where ExamID = @examId)
throw 50020, 'Exam not found.', 1;

if not exists (select 1 from Student where studentId = @studentId)
throw 50021, 'Student not found.', 1;

declare @courseId int;

select @courseId = CourseID
from Exam
where ExamID = @examId;

if not exists
(
select 1
from Enrollments
where StudentID = @studentId
and CourseID = @courseId
)
begin
    throw 50022, 'This student is not enrolled in the course for this exam.', 1;
end

insert into StudentExam (ExamID, StudentID)
values (@examId, @studentId);

print 'SUCCESS: Student enrolled in the exam.';

end

--------------------------------------------------------------------------------------------------------------

create procedure sp_Instructor_GradeTextQuestion
(
@studentId int,
@examId int,
@questionId int,
@degree int
)
as
begin

if not exists
(
select 1
from QuestionPool
where QuestionID = @questionId
and QuestionType = 'Text'
)
begin
    throw 50006, 'This procedure can only be used for "Text" type questions.', 1;
end

declare @maxDegreeForQuestion int;

select @maxDegreeForQuestion = Degree
from Contain
where ExamID = @examId
and QuestionID = @questionId;

if (@degree > @maxDegreeForQuestion)
begin
    throw 50007, 'Assigned degree cannot be greater than the maximum degree for this question in the exam.', 1;
end

update StudentAnswer
set studentDegree = @degree
where studentId = @studentId
and examId = @examId
and questionID = @questionId;

if (@@rowcount = 0)
begin
    throw 50008, 'No answer found for the specified student, exam, and question.', 1;
end

print 'SUCCESS: Student answer graded successfully.';

end

--------------------------------------------------------------------------------------------------------------

CREATE   PROCEDURE [dbo].[sp_CorrectExamAutomatically]
        @examId INT
    AS
    BEGIN
        SET NOCOUNT ON;
        IF NOT EXISTS (SELECT 1 FROM dbo.Exam WHERE ExamID = @examId) THROW 50030, 'Exam not found.', 1;

        UPDATE sa
        SET 
            sa.studentDegree = CASE 
                                WHEN LTRIM(RTRIM(LOWER(sa.studentAnswer))) = LTRIM(RTRIM(LOWER(qp.CorrectAnswer)))
                                THEN c.Degree
                                ELSE 0 
                               END
        FROM 
            dbo.StudentAnswer sa
        JOIN 
            dbo.QuestionPool qp ON sa.questionID = qp.QuestionID
        JOIN 
            dbo.Contain c ON sa.examId = c.ExamID AND sa.questionID = c.QuestionID
        WHERE 
            sa.examId = @examId
            AND qp.QuestionType IN ('MCQ', 'T/F');

        PRINT FORMATMESSAGE('SUCCESS: Auto-correction completed for ExamID %d. %d rows affected.', @examId, @@ROWCOUNT);
    END


--------------------------------------------------------------------------------------------------------------


    CREATE   PROCEDURE [dbo].[sp_Manager_Branch_Add] @branchName NVARCHAR(30)
    AS
    BEGIN
        INSERT INTO dbo.Branch (branchName) VALUES (@branchName);
        PRINT 'SUCCESS: Branch added.';
    END


--------------------------------------------------------------------------------------------------------------

CREATE   PROCEDURE [dbo].[sp_Manager_Branch_Delete]
    @branchId INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dbo.Branch WHERE branchId = @branchId;
    PRINT 'SUCCESS: Procedure [sp_Manager_Branch_Delete] executed and branch deleted.';
END

--------------------------------------------------------------------------------------------------------------

CREATE   PROCEDURE [dbo].[sp_Manager_Branch_Update]
    @branchId INT, @branchName NVARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Branch SET branchName = @branchName WHERE branchId = @branchId;
    PRINT 'SUCCESS: Procedure [sp_Manager_Branch_Update] executed and branch updated.';
END

--------------------------------------------------------------------------------------------------------------


    CREATE   PROCEDURE [dbo].[sp_Manager_Intake_Add] @intakeName NVARCHAR(30)
    AS
    BEGIN
        INSERT INTO dbo.Intake (intakeName) VALUES (@intakeName);
        PRINT 'SUCCESS: Intake added.';
    END

--------------------------------------------------------------------------------------------------------------

CREATE   PROCEDURE [dbo].[sp_Manager_Intake_Delete]
    @intakeId INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dbo.Intake WHERE intakeId = @intakeId;
    PRINT 'SUCCESS: Intake deleted.';
END

--------------------------------------------------------------------------------------------------------------

CREATE   PROCEDURE [dbo].[sp_Manager_Intake_Update]
    @intakeId INT, @intakeName NVARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Intake SET intakeName = @intakeName WHERE intakeId = @intakeId;
    PRINT 'SUCCESS: Intake updated.';
END

--------------------------------------------------------------------------------------------------------------

 CREATE   PROCEDURE [dbo].[sp_Manager_Student_Add]
        @fname NVARCHAR(30), @lname NVARCHAR(30), @email NVARCHAR(30), @userId INT, @trackId INT
    AS
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM dbo.UserAccounts WHERE userId = @userId) THROW 50001, 'UserID does not exist.', 1;
        IF NOT EXISTS (SELECT 1 FROM dbo.Track WHERE trackId = @trackId) THROW 50002, 'TrackID does not exist.', 1;
        INSERT INTO dbo.Student (fname, lname, email, userId, trackId) VALUES (@fname, @lname, @email, @userId, @trackId);
        PRINT 'SUCCESS: Student added.';
    END

--------------------------------------------------------------------------------------------------------------

CREATE   PROCEDURE [dbo].[sp_Manager_Student_Delete]
    @studentId INT
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.Student WHERE studentId = @studentId) THROW 50010, 'Student not found.', 1;
    IF EXISTS (SELECT 1 FROM dbo.StudentAnswer WHERE studentId = @studentId) THROW 50011, 'Cannot delete student. They have existing answers in exams.', 1;
    DELETE FROM dbo.Student WHERE studentId = @studentId;
    PRINT 'SUCCESS: Procedure [sp_Manager_Student_Delete] executed and student deleted.';
END

--------------------------------------------------------------------------------------------------------------

CREATE   PROCEDURE [dbo].[sp_Manager_Student_Update]
    @studentId INT, @fname NVARCHAR(30), @lname NVARCHAR(30), @email NVARCHAR(30), @trackId INT
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.Student WHERE studentId = @studentId) THROW 50010, 'Student not found.', 1;
    UPDATE dbo.Student 
    SET fname = @fname, lname = @lname, email = @email, trackId = @trackId
    WHERE studentId = @studentId;
    PRINT 'SUCCESS: Procedure [sp_Manager_Student_Update] executed and student updated.';
END

--------------------------------------------------------------------------------------------------------------


  CREATE   PROCEDURE [dbo].[sp_Manager_Track_Add] @trackName NVARCHAR(30), @departmentId INT
    AS
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM dbo.Department WHERE departmentId = @departmentId) THROW 50003, 'DepartmentID does not exist.', 1;
        INSERT INTO dbo.Track (trackName, departmentId) VALUES (@trackName, @departmentId);
        PRINT 'SUCCESS: Track added.';
    END

--------------------------------------------------------------------------------------------------------------

CREATE   PROCEDURE [dbo].[sp_Manager_Track_Delete]
    @trackId INT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM dbo.Student WHERE trackId = @trackId) THROW 50012, 'Cannot delete track. It is assigned to existing students.', 1;
    DELETE FROM dbo.Track WHERE trackId = @trackId;
    PRINT 'SUCCESS: Track deleted.';
END

--------------------------------------------------------------------------------------------------------------

CREATE   PROCEDURE [dbo].[sp_Manager_Track_Update]
    @trackId INT, @trackName NVARCHAR(30), @departmentId INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Track SET trackName = @trackName, departmentId = @departmentId WHERE trackId = @trackId;
    PRINT 'SUCCESS: Track updated.';
END

--------------------------------------------------------------------------------------------------------------

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

--------------------------------------------------------------------------------------------------------------


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

--------------------------------------------------------------------------------------------------------------

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
            RAISERROR('User not found', 16, 1);
            RETURN -1;
        END
        
        EXEC dbo.sp_VerifyPassword @userName, @oldPassword, @isValid OUTPUT;
        
        IF @isValid = 0
        BEGIN
            RAISERROR('Old PassWord Is Nor True', 16, 1);
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

--------------------------------------------------------------------------------------------------------------


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

--------------------------------------------------------------------------------------------------------------



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


--------------------------------------------------------------------------------------------------------------


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
            WHERE UserID = @CurrentUserID AND Role = 'AdminRole'
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

--------------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE dbo.sp_GetStudentExamsForStudent
    @StudentID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CurrentUserID INT;
    DECLARE @CurrentUserRole NVARCHAR(100);

    BEGIN TRY
        SELECT 
            @CurrentUserID = ua.userId, 
            @CurrentUserRole = ua.userRole
        FROM 
            dbo.UserAccounts ua
        WHERE 
            ua.userName = SUSER_SNAME();

        IF @CurrentUserRole = 'student' AND NOT EXISTS (SELECT 1 FROM dbo.Student WHERE studentId = @StudentID AND userId = @CurrentUserID)
        BEGIN
            RAISERROR('Unauthorized: You can only view your own exams.', 16, 1);
            RETURN;
        END

        SELECT 
            E.ExamID,
            E.Name AS ExamName,
            C.[Course Name] AS CourseName,
            E.[Day] AS ExamDay,
            E.StartTime,
            E.EndTime,
            (SELECT ISNULL(SUM(c.Degree), 0) FROM dbo.Contain c WHERE c.ExamID = E.ExamID) AS MaxDegree,
            CASE 
                WHEN EXISTS (SELECT 1 FROM dbo.StudentExam se WHERE se.StudentID = S.studentId AND se.ExamID = E.ExamID)
                THEN 'Taken'
                ELSE 'Available'
            END AS ExamStatus
        FROM 
            dbo.Student AS S
        JOIN 
            dbo.Enrollments AS EN ON S.studentId = EN.StudentID
        JOIN 
            dbo.Exam AS E ON EN.CourseID = E.CourseID
        JOIN 
            dbo.Course AS C ON E.CourseID = C.CourseID
        WHERE 
            S.studentId = @StudentID
        ORDER BY 
            E.[Day] DESC, E.StartTime DESC;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('An error occurred while fetching the student''s exams: %s', 16, 1, @ErrorMessage);
        RETURN;
    END CATCH
END;
GO

PRINT 'Procedure sp_GetStudentExamsForStudent has been created successfully.';
GO

--------------------------------------------------------------------------------------------------------------



CREATE OR ALTER PROCEDURE dbo.sp_GetStudentExamResults
    @StudentID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CurrentUserID INT;
    DECLARE @CurrentUserRole NVARCHAR(100);

    BEGIN TRY
        SELECT 
            @CurrentUserID = ua.userId, 
            @CurrentUserRole = ua.userRole
        FROM 
            dbo.UserAccounts ua
        WHERE 
            ua.userName = SUSER_SNAME();

        IF @CurrentUserRole = 'student' AND NOT EXISTS (SELECT 1 FROM dbo.Student WHERE studentId = @StudentID AND userId = @CurrentUserID)
        BEGIN
            RAISERROR('Unauthorized: You can only view your own results.', 16, 1);
            RETURN;
        END

        SELECT 
            C.[Course Name] AS CourseName,
            E.Name AS ExamName,
            (SELECT ISNULL(SUM(sa.studentDegree), 0) 
             FROM dbo.StudentAnswer sa 
             WHERE sa.studentId = S.studentId AND sa.examId = E.ExamID) AS StudentScore,
            (SELECT ISNULL(SUM(c.Degree), 0) 
             FROM dbo.Contain c 
             WHERE c.ExamID = E.ExamID) AS MaxDegree,
            E.[Day] AS ExamDay
        FROM 
            dbo.Student AS S
        JOIN 
            dbo.StudentExam AS SE ON S.studentId = SE.StudentID
        JOIN 
            dbo.Exam AS E ON SE.ExamID = E.ExamID
        JOIN 
            dbo.Course AS C ON E.CourseID = C.CourseID
        WHERE 
            S.studentId = @StudentID
        ORDER BY 
            E.[Day] DESC;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('An error occurred while fetching exam results: %s', 16, 1, @ErrorMessage);
        RETURN;
    END CATCH
END;
GO

PRINT 'Procedure sp_GetStudentExamResults has been updated to show taken exams results successfully.';
GO

---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------
--remonda
---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------

--- Exam Questions Entity ---

-- add Questions to Exam 
create proc sp_Instructor_Exam_AddQuestion @ques_id int , @exam_id int,  @degree int
as begin
SET NOCOUNT ON;
begin try
if NOT EXISTS(select 1 from [dbo].[Exam] where [ExamID]=@exam_id)
begin
raiserror( 'Exam not found',16,1);
return;
end

if NOT EXISTS(select 1 from [dbo].[QuestionPool] where [QuestionID]=@ques_id
 and CourseID = (select CourseID from Exam where ExamID = @exam_id))
begin
raiserror( 'Question does not belong to the exam course',16,1);
return;
end

if EXISTS(select 1 from [dbo].[Contain] where [QuestionID]=@ques_id and [ExamID]= @exam_id)
begin
raiserror( 'Question already exists in this exam',16,1);
return;
end

declare @total int, @max_degree int;

select @total =isnull(sum([Degree]),0)
from [dbo].[Contain]
where [ExamID]= @exam_id

select @max_degree =C.[Max Degree]
from [dbo].[Exam] as E
join [dbo].[Course] as C
on E.CourseID=C.CourseID
where E.[ExamID]= @exam_id

if(@degree+@total)>@max_degree
begin
raiserror( 'Adding this question exceeds the course max degree',16,1);
return
end

insert into [dbo].[Contain]([Degree],[QuestionID],[ExamID])
values (@degree,@ques_id,@exam_id)
print 'Question added to exam successfully';
end try
begin catch
throw;
end catch
end

go

-- Remove Question from Exam
create proc sp_Instructor_Exam_RemoveQuestion @question_id int , @exam_id int
as begin
SET NOCOUNT ON;
begin try
if NOT EXISTS(select 1 from [dbo].[Exam] where [ExamID]=@exam_id)
begin
raiserror( 'Exam not found',16,1);
return;
end

if NOT EXISTS(select 1 from [dbo].[Contain] where [QuestionID]=@question_id and [ExamID]= @exam_id)
begin
raiserror( 'Question not exists in this exam',16,1);
return;
end

delete from  [dbo].[Contain]
where [ExamID]=@exam_id and [QuestionID]=@question_id
print 'Question removed from exam successfully';
end try
begin catch
throw;
end catch
end

go 

-- update question in exam
create proc sp_Instructor_Exam_UpdateQuestionDegree  @ques_id int , @exam_id int,  @new_degree int
as begin
SET NOCOUNT ON;
begin try

if NOT EXISTS(select 1 from [dbo].[Contain] where [QuestionID]=@ques_id and [ExamID]= @exam_id)
begin
raiserror( 'Question not found in this exam',16,1);
return;
end

declare @total int, @max_degree int;

select @total =isnull(sum([Degree]),0)
from [dbo].[Contain]
where [ExamID]= @exam_id and [QuestionID]<> @ques_id

select @max_degree =C.[Max Degree]
from [dbo].[Exam] as E
join [dbo].[Course] as C
on E.CourseID=C.CourseID
where E.[ExamID]= @exam_id

if(@new_degree+@total)>@max_degree
begin
raiserror( 'updating this question exceeds the course max degree',16,1);
return
end

update [dbo].[Contain]
set [Degree]=@new_degree
where [ExamID]= @exam_id and [QuestionID]= @ques_id
print 'Question updated successfully';
end try
begin catch
throw;
end catch
end

go


-- get questions from exam
create proc sp_Instructor_Exam_GetQuestions  @exam_id int
as begin

begin try
if not exists(select 1 from [dbo].[Exam] where [ExamID]=@exam_id)
begin
raiserror( 'Exam not found',16,1);
return;
end

select Q.QuestionID,Q.QuestionType, Q.QuestionText,Q.CorrectAnswer ,C.Degree
from [dbo].[Contain] as C
join [dbo].[QuestionPool] as Q
on C.QuestionID=Q.QuestionID
where C.ExamID=@exam_id
end try
begin catch
throw;
end catch
end

go

--- choices Questions Entity ---

--Add choice to an MCQ question
create proc sp_Instructor_Choice_Add @question_id int, @choice_text Nvarchar(max)
as begin
SET NOCOUNT ON;
begin try

declare @type nvarchar(20);
select @type=[QuestionType] from [dbo].[QuestionPool]
where [QuestionID]=@question_id;

if(@type is null)
begin
raiserror('Question not found', 16, 1);
return;
end

if(@type != 'MCQ')
begin
raiserror('Question type must be MCQ', 16, 1);
return;
end

if EXISTS(select 1 from [dbo].[QuestionChoices] where ChoiceText=@choice_text and [QuestionID]= @question_id)
begin
raiserror( 'Choice already exists for this question',16,1);
return;
end
insert into [dbo].[QuestionChoices] ([QuestionID],[ChoiceText])
values (@question_id,@choice_text)
print 'Choice added to Question successfully';
end try
begin catch
throw;
end catch
end 

go


-- get choice for an MCQ question
create proc sp_Instructor_Choice_GetByQuestionId @question_id int
as begin
begin try
if NOT EXISTS(select 1 from  [dbo].[QuestionPool] where [QuestionID]=@question_id)
begin
raiserror('Question not found', 16, 1);
return;
end

select [ChoicesID], [ChoiceText] from [dbo].[QuestionChoices]
where [QuestionID]=@question_id;

end try
begin catch
throw;
end catch
end

go

-- update choice for an MCQ question
create proc sp_Instructor_Choice_Update @choice_id int , @choice_text nvarchar(50)
as begin
SET NOCOUNT ON;
begin try
if not exists(select 1 from [dbo].[QuestionChoices] where [ChoicesID]=@choice_id)
begin
raiserror('Choice not found', 16, 1);
return;
end

if exists(select 1 from [dbo].[QuestionChoices] where ChoiceText=@choice_text
and QuestionID = (select QuestionID from QuestionChoices where ChoicesID = @choice_id))
begin
raiserror( 'Choice already exists for this question',16,1);
return;
end

update [dbo].[QuestionChoices]
set [ChoiceText]=@choice_text
where [ChoicesID]=@choice_id;
print 'choice updated successfully';

end try
begin catch
throw;
end catch
end

go


-- delete choice 
create proc sp_Instructor_Choice_Delete  @choice_id int 
as begin
SET NOCOUNT ON;
begin try
if not exists(select 1 from [dbo].[QuestionChoices] where [ChoicesID]=@choice_id)
begin
raiserror('Choice not found', 16, 1);
return;
end

delete [dbo].[QuestionChoices]
where [ChoicesID]=@choice_id;
print 'deleted successfully';

end try
begin catch
throw;
end catch
end

go


-- 1. Course
INSERT INTO Course ([Course Name], [Description], [Max Degree], [Min Degree])
VALUES ('Python Basics', 'Intro to Python', 100, 50);

-- 2. Instructor
INSERT INTO Instructor (FullName, Email)
VALUES ('Ahmed Ali', 'ahmed@test.com');

-- 3. Exam
INSERT INTO Exam ([Name], [Type], StartTime, EndTime, [Day], CourseID, InstructorID)
VALUES ('Midterm', 'Exam', '09:00', '11:00', '2024-03-15', 1, 1);

-- 4. QuestionPool
INSERT INTO QuestionPool (QuestionText, QuestionType, CorrectAnswer, CourseID)
VALUES 
('What is Python?', 'MCQ', 'A programming language', 1),
('Is Python case-sensitive?', 'T/F', 'True', 1);

------------------TEST-------------------

-- Test sp_Instructor_Exam_AddQuestion
exec sp_Instructor_Exam_AddQuestion @ques_id=7, @exam_id=1, @degree=1;

exec sp_Instructor_Exam_AddQuestion @ques_id=1, @exam_id=999, @degree=10;

exec sp_Instructor_Exam_AddQuestion @ques_id=999, @exam_id=1, @degree=10;

exec sp_Instructor_Exam_AddQuestion @ques_id=1, @exam_id=1, @degree=10;

exec sp_Instructor_Exam_AddQuestion @ques_id=5, @exam_id=1, @degree=999;

-- Test sp_Instructor_Exam_RemoveQuestion
exec sp_Instructor_Exam_RemoveQuestion @question_id=1, @exam_id=1;

exec sp_Instructor_Exam_RemoveQuestion @question_id=1, @exam_id=999;

exec sp_Instructor_Exam_RemoveQuestion @question_id=999, @exam_id=1;


-- Test sp_Instructor_Exam_UpdateQuestionDegree
exec sp_Instructor_Exam_AddQuestion @ques_id=1, @exam_id=1, @degree=10;

exec sp_Instructor_Exam_UpdateQuestionDegree @ques_id=1, @exam_id=1, @new_degree=20;

exec sp_Instructor_Exam_UpdateQuestionDegree @ques_id=999, @exam_id=1, @new_degree=20;

exec sp_Instructor_Exam_UpdateQuestionDegree @ques_id=1, @exam_id=1, @new_degree=999;

-- Test sp_Instructor_Exam_GetQuestions
exec sp_Instructor_Exam_GetQuestions @exam_id=1;

exec sp_Instructor_Exam_GetQuestions @exam_id=999;

-- *******************************************

-- Test sp_Instructor_Choice_Add
exec sp_Instructor_Choice_Add @question_id=1, @choice_text='A programming language';

exec sp_Instructor_Choice_Add @question_id=999, @choice_text='Test';

exec sp_Instructor_Choice_Add @question_id=2, @choice_text='True';

exec sp_Instructor_Choice_Add @question_id=1, @choice_text='A programming language';

-- Test sp_Instructor_Choice_GetByQuestionId
exec sp_Instructor_Choice_GetByQuestionId @question_id=1;

exec sp_Instructor_Choice_GetByQuestionId @question_id=999;


-- Test sp_Instructor_Choice_Update
exec sp_Instructor_Choice_Update @choice_id=1, @choice_text='A scripting language';

exec sp_Instructor_Choice_Update @choice_id=999, @choice_text='Test';

exec sp_Instructor_Choice_Update @choice_id=1, @choice_text='A scripting language';

-- Test sp_Instructor_Choice_delete
exec sp_Instructor_Choice_Delete @choice_id=1;

exec sp_Instructor_Choice_Delete @choice_id=999;


---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------
--Fatma
---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------

--sp_Instructor_Question_Add
create proc sp_Instructor_Question_Add @Question nvarchar(max),@Type nvarchar(4),@Answer nvarchar(max),@fkCourseID int 
as begin 
begin try
if not exists(select CourseID from course where CourseID=@fkCourseID)
throw 51000,'CourseID Not Exist',1;

if(@Type not in ('MCQ','T/F','Text'))
throw 51001,'Type should in (MCQ,T/F,Text)',1;
if(@Type='MCQ' and @Answer is null)
throw 51002,'Answer Should Has Value',1;

if(@Type='T/F' and @Answer is null)
throw 51003,'Answer Should Has Value Either True Or False',1;

insert into [dbo].[QuestionPool](QuestionText,QuestionType,CorrectAnswer,CourseID)
values(@Question,@Type,@Answer,@fkCourseID)
print('Question Added Successfully')
end try
begin catch
throw;
end catch 
return 1;
end

--sp_Instructor_Question_GetByCourseId
alter proc sp_Instructor_Question_GetByCourseId @RefCourseId int
as begin
begin try 
if not exists(select QuestionText from [dbo].[QuestionPool]
where CourseID=@RefCourseId)
throw 51010,'CourseID not found',1;
else

select crs.[Course Name],QuestionText,QuestionType,CorrectAnswer from [dbo].[QuestionPool] as qs
inner join [dbo].[Course] as crs
on crs.CourseID=qs.CourseID
where qs.CourseID=@RefCourseId
end try
begin catch 
throw;
end catch
end
--sp_Instructor_Question_Update

alter proc sp_Instructor_Question_Update @QsID int, @Question nvarchar(max),@Type nvarchar(4),@Answer nvarchar(max),@fkCourseID int 
as begin 
begin try 
if not exists(select QuestionID from QuestionPool where QuestionID=@QsID)
throw 51011,'Question Not Found',1;

if not exists(select CourseID from course where CourseID=@fkCourseID)
throw 51000,'CourseID Not Exist',1;

if(@Type not in ('MCQ','T/F','Text'))
throw 51001,'Type should in (MCQ,T/F,Text)',1;
if(@Type='MCQ' and @Answer is null)
throw 51002,'Answer Should Has Value',1;

if(@Type='T/F' and @Answer is null)
throw 51003,'Answer Should Has Value Either True Or False',1;
update QuestionPool set QuestionText=@Question,QuestionType=@Type,[CorrectAnswer]=@Answer,CourseID=@fkCourseID
where QuestionID=@QsID
return 1;
end try
begin catch
throw;
end catch
end

--sp_Instructor_Question_Delete
alter proc sp_Instructor_Question_Delete @QsID int
as begin  

begin try 
if not exists(select QuestionID from QuestionPool where QuestionID=@QsID)
throw 51011,'Question Not Found',1;

if  exists(select 1 from contain where QuestionID=@QsID)
throw 51031,'Cannot delete Question: student answers exist',1;
if  exists(select 1 from QuestionChoices where QuestionID=@QsID)
throw 51031,'Cannot delete Question: QuestionChoices exist',1;

delete from [dbo].[QuestionPool] where QuestionID=@QsID
end try
begin catch 
throw;
end catch
end 

--GetAllQuestions
alter proc sp_Instructor_Question_GetAllQuestionsWithCourseName
as begin
select crs.[Course Name],QuestionText,QuestionType,CorrectAnswer from QuestionPool as qs
inner join Course as crs
on qs.CourseID=crs.CourseID
order by 1

end

--### 4. Exam Entity

alter table course add TrackID int 
alter table course add constraint fk_course_track foreign key (TrackID) references track(TrackID)
--sp_Instructor_Exam_Add
alter proc sp_Instructor_Exam_Add @ExamName varchar(20),@ExamType varchar(10),
@Examstarttime time,@ExamEndtime time ,@ExamDay date,@courseRef int ,@instructorRef int
as begin 
begin try 

if(@ExamType not in ('Corrective','Exam'))
throw 51012,'ExamType should be one of (Corrective,Exam)',1;
if(@Examstarttime>@ExamEndtime)
throw 51013,'ExamStartTime should be less than ExamEndTime',1;
if(datediff(minute,@Examstarttime,@ExamEndtime)<60)
throw 510125,'TotalTime should be Greater than or an hour',1;
if(@courseRef is null)
throw 51026,'courseRef shouldn''t be null',1;
else 
begin 
if not exists(select courseid from Course where
CourseID=@courseRef
)
throw 51027,'Course you Trieng to reference is not found',1;

end
if(@instructorRef is null)
throw 51028,'instructorRef shouldn''t be null',1;
else 
begin 
if not exists(select instructorid from Instructor where
InstructorID=@instructorRef
)
throw 51029,'instructor you Trying to reference is not found',1;
end
if exists(
select * from exam as ex inner join course as crs 
on ex.CourseID =crs.CourseID
where crs.trackid in (select trackId from Course
where CourseID=@courseRef
) and
@ExamDay=ex.Day 
and @Examstarttime<ex.endtime 
and @ExamEndtime>ex.starttime
)
throw 51000,'There is time overlab on more than one exam in one track',1;

insert into exam(Name,Type,StartTime,EndTime,[Day],CourseID,InstructorID)
values(@ExamName,@ExamType,@Examstarttime,@ExamEndtime,@ExamDay,@courseRef,@instructorRef)
end try
begin catch 
throw;
end catch
end
	--sp_Instructor_Exam_GetByCourseId
create proc sp_Instructor_Exam_GetByCourseId @RefCourseId int
as begin
set nocount on;
begin try
if not exists(select 1 from Exam where CourseID=@RefCourseId)
throw 51016,'RefCourseID is not Found',1;
select *,crs.[Course Name],ins.FullName from Exam as ex
inner join Course as crs
on crs.CourseID=ex.CourseID
inner join Instructor as ins
on ex.InstructorID=ins.InstructorID
where crs.CourseID=@RefCourseId
end try 
begin catch
throw;
end catch
end
--sp_Instructor_Exam_GetById
create proc sp_Instructor_Exam_GetById @id int
as begin
set nocount on;

begin try 
if not exists(select 1 from Exam where ExamID=@id)
throw 51016,'Exam is not Found',1;
select *,crs.[Course Name],ins.FullName from Exam as ex
inner join Course as crs
on crs.CourseID=ex.CourseID
inner join Instructor as ins
on ex.InstructorID=ins.InstructorID
where ex.ExamID=@id
end try 
begin catch
throw;
end catch
end

--sp_Instructor_Exam_Update
create proc sp_Instructor_Exam_Update @id int,@ExamName varchar(20),@ExamType varchar(10),
@Examstarttime time,@ExamEndtime time ,@ExamDay date,@courseRef int ,@instructorRef int
as begin 
set nocount on;

begin try 
if not exists(select 1 from Exam where ExamID=@id)
throw 51017,'Exam is not Found',1;

if(@ExamType not in ('Corrective','Exam'))
throw 51018,'ExamType should be one of (Corrective,Exam)',1;

if(@Examstarttime>@ExamEndtime)
throw 51019,'ExamStartTime should be less than ExamEndTime',1;
if(datediff(minute,@Examstarttime,@ExamEndtime)<60)
throw 51020,'TotalTime should be Greater than or an hour',1;
if(@courseRef is null)
throw 51021,'courseRef shouldn''t be null',1;
 
if not exists(select courseid from Course where
CourseID=@courseRef
)
throw 51022,'Course you Trieng to reference is not found',1;

if(@instructorRef is null)
throw 51023,'instructorRef shouldn''t be null',1;
 
if not exists(select instructorid from Instructor where
InstructorID=@instructorRef
)
throw 51024,'instructor you Trying to reference is not found',1;
update Exam set Name=@ExamName,Type=@ExamType,
StartTime=@Examstarttime,EndTime=@ExamEndtime,
Day=@ExamDay ,CourseID=@courseRef,InstructorID=@instructorRef
where ExamID=@id
end try
begin catch
throw;
end catch
end
--sp_Instructor_Exam_Delete

create proc sp_Instructor_Exam_Delete @id int
as begin
set nocount on;

begin try 
if not exists(select 1 from Exam where ExamID=@id)
throw 51030,'Exam is not Found',1;
if  exists(select 1 from contain where ExamID=@id)
throw 51031,'Cannot delete Exam: student answers exist',1;

delete from exam where ExamID=@id
end try
begin catch
throw;
end catch
end
-----------------------logic layer
create proc sp_addstudentanswer
    @studentid int,
    @examid int,
    @questionid int,
    @selectedanswer varchar(100)
as
begin
begin try
    if exists(
        select 1 from studentanswer
        where studentid=@studentid
        and examid=@examid
        and questionid=@questionid
    )
        throw 51050,'you already answered this question',1;

    insert into studentanswer(studentid,examid,questionid,studentanswer)
    values(@studentid,@examid,@questionid,@selectedanswer);
end try
begin catch
    throw;
end catch
end

----------------------triggers
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--remonda
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- calculate student degree per question 
create trigger trg_CalculateStudentDegree
on [dbo].[StudentAnswer]
after insert, update
as begin
set nocount on;

declare @correct_answer nvarchar(max);
declare @student_answer nvarchar(max);
declare @question_type nvarchar(4);
declare @question_id int;
declare @student_id int;
declare @exam_id int;
declare @degree int;

select @question_id=[QuestionID],@exam_id=[ExamID],@student_answer=[studentAnswer] , @student_id=[studentId] from inserted;

select @degree = [Degree]  from [dbo].[Contain]
where [QuestionID]=@question_id and [ExamID]=@exam_id;

select @correct_answer = [CorrectAnswer],@question_type= [QuestionType] from [dbo].[QuestionPool]
where [QuestionID]=@question_id ;

if(@question_type != 'Text')
begin
if(@student_answer=@correct_answer)
begin
update [dbo].[StudentAnswer]
set [studentDegree]=@degree
where [QuestionID]=@question_id and [ExamID]=@exam_id and [studentId]=@student_id;
end
else
begin
update [dbo].[StudentAnswer]
set [studentDegree]=0
where [QuestionID]=@question_id and [ExamID]=@exam_id and [studentId]=@student_id;
end
end
end

go
-- Prevent insert answer after ExamTime
create trigger trg_PreventAnswerAfterExamTime
on [dbo].[StudentAnswer]
after insert, update
as begin
set nocount on;

declare @exam_id int;
declare @day date;
declare @start_time time;
declare @end_time time;

select @exam_id=[examId] from inserted;

select @start_time=[StartTime],@end_time=EndTime , @day=[Day] from [dbo].[Exam] 
where [ExamID]=@exam_id;

if(@day!= cast(getdate() as date) or (cast(getdate() as time)not between @start_time and @end_time))
begin
rollback;
raiserror('Exam is not available', 16, 1);
end

end



CREATE   TRIGGER [dbo].[trg_AutoCorrectStudentAnswers]
ON [dbo].[StudentAnswer]
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM inserted)
    BEGIN
        RETURN;
    END

   
    UPDATE sa
    SET 
        sa.studentDegree = CASE 
                               WHEN qp.QuestionType <> 'Text' AND 
                                    LTRIM(RTRIM(LOWER(i.studentAnswer))) = LTRIM(RTRIM(LOWER(qp.CorrectAnswer)))
                               THEN c.Degree 
                               ELSE 0     
                           END
    FROM 
        dbo.StudentAnswer AS sa
    INNER JOIN 
        inserted AS i ON sa.studentId = i.studentId AND sa.examId = i.examId AND sa.questionID = i.questionID 
    INNER JOIN 
        dbo.QuestionPool AS qp ON i.questionID = qp.QuestionID
    INNER JOIN 
        dbo.Contain AS c ON i.examId = c.ExamID AND i.questionID = c.QuestionID;

    PRINT FORMATMESSAGE('Auto-correction trigger fired. %d row(s) processed.', @@ROWCOUNT);

END
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--MOHAMED
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

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


exec [dbo].[sp_Manager_Student_Update] 1, 'omar', 'ahmed', 'omar.h@example.com', 1



CREATE OR ALTER TRIGGER trg_Audit_Student_Changes
ON dbo.Student
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF @@ROWCOUNT = 0 RETURN;

    DECLARE @ChangeType NVARCHAR(10);
    DECLARE @CurrentUserID INT;


    SELECT @CurrentUserID = userId 
    FROM dbo.UserAccounts 
    WHERE userName = SUSER_SNAME();

    IF @CurrentUserID IS NULL
    BEGIN
        SET @CurrentUserID = 0; 
    END

    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
        SET @ChangeType = 'UPDATE';
    ELSE IF EXISTS (SELECT * FROM inserted)
        SET @ChangeType = 'INSERT';
    ELSE
        SET @ChangeType = 'DELETE';

    IF @ChangeType IN ('INSERT', 'UPDATE')
    BEGIN
        INSERT INTO dbo.DataChangeAudit (UserID, TableName, ChangeType, OldValue, NewValue)
        SELECT
            @CurrentUserID,
            'Student',
            @ChangeType,
            ISNULL('fname: ' + d.fname + ', lname: ' + d.lname + ', email: ' + d.email, 'N/A'),
            'fname: ' + i.fname + ', lname: ' + i.lname + ', email: ' + i.email
        FROM inserted i
        LEFT JOIN deleted d ON i.studentId = d.studentId;
    END

    IF @ChangeType = 'DELETE'
    BEGIN
        INSERT INTO dbo.DataChangeAudit (UserID, TableName, ChangeType, OldValue, NewValue)
        SELECT
            @CurrentUserID,
            'Student',
            @ChangeType,
            'fname: ' + d.fname + ', lname: ' + d.lname + ', email: ' + d.email,
            NULL
        FROM deleted d;
    END
END;



CREATE OR ALTER TRIGGER trg_Audit_Instructor_Changes
ON dbo.Instructor
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF @@ROWCOUNT = 0 RETURN;

    DECLARE @ChangeType NVARCHAR(10);
    DECLARE @CurrentUserID INT;

    SELECT @CurrentUserID = userId 
    FROM dbo.UserAccounts 
    WHERE userName = SUSER_SNAME();

    IF @CurrentUserID IS NULL SET @CurrentUserID = 0;

    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
        SET @ChangeType = 'UPDATE';
    ELSE IF EXISTS (SELECT * FROM inserted)
        SET @ChangeType = 'INSERT';
    ELSE
        SET @ChangeType = 'DELETE';

    IF @ChangeType IN ('INSERT', 'UPDATE')
    BEGIN
        INSERT INTO dbo.DataChangeAudit (UserID, TableName, ChangeType, OldValue, NewValue)
        SELECT
            @CurrentUserID,
            'Instructor',
            @ChangeType,
            ISNULL('FullName: ' + d.FullName + ', Email: ' + d.Email, 'N/A'),
            'FullName: ' + i.FullName + ', Email: ' + i.Email
        FROM inserted i
        LEFT JOIN deleted d ON i.InstructorID = d.InstructorID;
    END

    IF @ChangeType = 'DELETE'
    BEGIN
        INSERT INTO dbo.DataChangeAudit (UserID, TableName, ChangeType, OldValue, NewValue)
        SELECT
            @CurrentUserID,
            'Instructor',
            @ChangeType,
            'FullName: ' + d.FullName + ', Email: ' + d.Email,
            NULL
        FROM deleted d;
    END
END;
GO

CREATE OR ALTER TRIGGER trg_Audit_Course_Changes
ON dbo.Course
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF @@ROWCOUNT = 0 RETURN;

    DECLARE @ChangeType NVARCHAR(10);
    DECLARE @CurrentUserID INT;

    SELECT @CurrentUserID = userId 
    FROM dbo.UserAccounts 
    WHERE userName = SUSER_SNAME();

    IF @CurrentUserID IS NULL SET @CurrentUserID = 0;

    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
        SET @ChangeType = 'UPDATE';
    ELSE IF EXISTS (SELECT * FROM inserted)
        SET @ChangeType = 'INSERT';
    ELSE
        SET @ChangeType = 'DELETE';

    IF @ChangeType IN ('INSERT', 'UPDATE')
    BEGIN
        INSERT INTO dbo.DataChangeAudit (UserID, TableName, ChangeType, OldValue, NewValue)
        SELECT
            @CurrentUserID,
            'Course',
            @ChangeType,
            ISNULL('Name: ' + d.[Course Name] + ', MaxDegree: ' + CAST(d.[Max Degree] AS VARCHAR(10)), 'N/A'),
            'Name: ' + i.[Course Name] + ', MaxDegree: ' + CAST(i.[Max Degree] AS VARCHAR(10))
        FROM inserted i
        LEFT JOIN deleted d ON i.CourseID = d.CourseID;
    END

    IF @ChangeType = 'DELETE'
    BEGIN
        INSERT INTO dbo.DataChangeAudit (UserID, TableName, ChangeType, OldValue, NewValue)
        SELECT
            @CurrentUserID,
            'Course',
            @ChangeType,
            'Name: ' + d.[Course Name] + ', MaxDegree: ' + CAST(d.[Max Degree] AS VARCHAR(10)),
            NULL
        FROM deleted d;
    end





--------------------views----------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--MOHAMED
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

Create view vw_ExamFullDetails
as
select
E.[ExamID],
E.[Name] as ExamName,
E.[Type] as ExamType,
E.[Day] as ExamDay,
E.[StartTime],
E.[EndTime],
C.[CourseID],
C.[Course Name],
I.[InstructorID],
I.[FullName] as FullName,
C.[Max Degree] as CourseMaxDegree,
(select isnull(sum(EQ.[Degree]),0) from [dbo].[Contain] EQ where EQ.[ExamID] = E.[ExamID]) as ExamTotalDegree,
(select count(*) from [dbo].[Contain] EQ where EQ.ExamID = E.[ExamID]) as NumberOfQuestions

from 
[dbo].[Exam] E join [dbo].[Course] C
on E.[CourseID] = C.[CourseID]
join [dbo].[Instructor] I
on E.[InstructorID] = I.[InstructorID]

-------------------------------------------------------------------------------------------------------------

create view vw_StudentResults
as
select
    S.studentId,
    S.fname + ' ' + S.lname AS StudentName,
    E.ExamID,
    E.Name AS ExamName,
    C.[Course Name],
    (select isnull(sum(SA.studentDegree), 0) 
     from dbo.StudentAnswer SA 
     where SA.studentId = S.studentId AND SA.examId = E.ExamID) AS TotalMarksScored,
    (select isnull(sum(EQ.Degree), 0) 
     from dbo.Contain EQ 
     where EQ.ExamID = E.ExamID) AS ExamTotalDegree
from
    dbo.Student AS S
join
    dbo.Enrollments AS EN ON S.studentId = EN.StudentID
join
    dbo.Exam AS E ON EN.CourseID = E.CourseID
join
    dbo.Course AS C ON E.CourseID = C.CourseID;



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


-------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--Fatma
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

create view ViewCourseStatistics
as
with StudentExamTotals as
(
    select 
        sa.examid,
        sa.studentid,
        sum(sa.[studentDegree]) as totalgrade
    from StudentAnswer sa
    group by sa.examid, sa.studentid
)

select 
    ex.examid,
    ex.courseid,
    ex.name as examname,
    count(distinct seto.studentid) as total_students,
    max(seto.totalgrade) as max_grade,
    min(seto.totalgrade) as min_grade,
    
    cast(
        sum(
            case 
                when seto.totalgrade >= dbo.fn_GetExamTotalDegree(ex.examid) * 0.5 
                then 1 else 0 
            end
        ) * 100.0
        /
        count(seto.studentid)
    as decimal(5,2)) as success_rate

from exam ex
inner join StudentExamTotals seto
    on ex.examid = seto.examid
group by 
    ex.examid,
    ex.courseid,
    ex.name;

	select * from ViewCourseStatistics


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--remonda
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


--Create view for instructor schedule
create view vw_InstructorSchedule as
select S.FullName as [Instructor Name],
C.[Course Name],
E.[Name] as [Exam Name], 
E.[Day],
format(cast(E.[StartTime]as datetime),'hh:mm tt') as StartTime,
format(cast(E.EndTime as datetime),'hh:mm tt') as EndTime,
cast(abs(E.ExamTotalTime) as varchar) + ' min' as ExamTotalTime

from [dbo].[Instructor] as S
join [dbo].[Exam] as E

on S.InstructorID=E.InstructorID
join [dbo].[Course] as C
on C.CourseID=E.CourseID
----------------------------------------
go
select * from vw_InstructorSchedule;
go
-----------------------------------------
--Create view for student exam history
create view VW_ExamStudentResults as
select concat(S.[fname],' ',S.[lname]) as [Student Name] ,
T.[trackName],
C.[Course Name],
E.[Name] as [Exam Name],
dbo.GetStudentResult (E.[ExamID] , S.[studentId]) as Degree,
dbo.GetStudentPassFail  (E.[ExamID] , S.[studentId]) as Result

from [dbo].[Student] as S
join [dbo].[Track] as T 
on S.[trackId] = T.[trackId]
join [dbo].[Enrollments] as EN 
on EN.[StudentID] = S.[studentId]
join [dbo].[Course] as C 
on C.[CourseID] = EN.[CourseID]
join [dbo].[Exam] as E 
on E.[CourseID] = C.[CourseID]
------------------------------------
go 
select * from VW_ExamStudentResults;



------------------------------security--------------
-- SQL SERVER SECURITY IMPLEMENTATION
-- EXAMINATION SYSTEM DATABASE


USE [ExaminationSystem]
GO

-- 1. DATABASE-LEVEL SECURITY CONFIGURATION

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

-- 28. DOCUMENT ACCOUNTS AND PASSWORDS

/*
DATABASE SECURITY ACCOUNTS AND CREDENTIALS

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

----SECURITY FEATURES IMPLEMENTED:

 Login and Database Users Created
 Role-Based Access Control (RBAC)
 Password Hashing with SHA2_256
 Login Attempt Tracking
 Account Locking After Failed Attempts
 Audit Logging (Login and Data Changes)
 Stored Procedures with Security Checks
 SQL Injection Prevention (Parameterized Queries)
 Data Isolation by User Role
 Triggers for Data Audit
 Function for Password Hashing
 Backup and Recovery Procedures
 Unauthorized Access Prevention

--IMPORTANT SECURITY NOTES:

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

-- 29. VERIFY SECURITY SETUP

PRINT '=== DATABASE USERS ===';
SELECT name AS UserName, type_desc AS UserType
FROM sys.database_principals
WHERE type IN ('U', 'R')
ORDER BY name;

SELECT DP1.name AS RoleName, DP2.name AS MemberName
FROM sys.database_principals DP1
INNER JOIN sys.database_role_members DRM ON DP1.principal_id = DRM.role_principal_id
INNER JOIN sys.database_principals DP2 ON DRM.member_principal_id = DP2.principal_id
ORDER BY DP1.name, DP2.name;

SELECT 
    OBJECT_NAME(major_id) AS TableName,
    grantee_principal_id,
    permission_name AS Permission,
    state_desc AS State
FROM sys.database_permissions
WHERE class = 1
ORDER BY OBJECT_NAME(major_id);






------------------backup

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