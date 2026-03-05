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
