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
