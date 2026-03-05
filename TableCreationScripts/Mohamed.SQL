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