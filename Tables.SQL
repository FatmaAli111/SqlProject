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

create table [Question Pool] 
(
QuestionID int identity(1,1) not null,
[Question Text] nvarchar(max) not null,
[Question Type] nvarchar(20) not null,
[Correct Answer] nvarchar(20) not null,
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
constraint Fk_Enrollments_Student foreign key (StudentID) references STUDENTS(StudentID) on delete cascade
);

---------------------------------------------------------------------------------------------------------

create table [Instructor Courses]
(
InstructorID int not null,
CourseID int not null,
constraint PK_Instructor_Courses primary key (InstructorID, CourseID),
constraint FK_InstructorCourses_Instructor  foreign key (InstructorID) references Instructor(InstructorID) on delete cascade,
constraint FK_InstructorCourses_Course  foreign key (CourseID) references Course(CourseID) on delete cascade
)

----------------------------------------------------------------------------------------------------------

