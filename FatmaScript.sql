create table Exam(
ExamID int primary Key identity,
[Name] varchar(20) not null,
[Type] varchar(10) not null check([Type] in ('Corrective','Exam')),
StartDate Date not null,
EndDate Date check(EndDate >StartDate) not null,
--allowance options
CourseID int foreign key (CourseID) references Course(CourseID),
InstructorID int foreign key (InstructorID) references Instructor(InstructorID)
)
--constraint check if time between end and start > hour
create table QuestionPool(
QuestionID int primary Key identity,
QuestionText nvarchar(max),
[Type] varchar(4) check([Type] in ('Text','MCQ','T&F'))
CorrectAnswer varchar(max),
CourseID int foreign key (CourseID) references Course(CourseID) not null
)

create table Contain(
Degree int not null,
StudentAnswer varchar(max) ,
ExamID int foreign key (ExamID) references Exam(ExamID) not null,
QuestionID int foreign key (QuestionID) references QuestionPool(QuestionID) not null,
primary key (ExamID,QuestionID)
)

create table QuestionChoices(
ChoicesID int primary key identity,
ChoiceText varchar(50) ,
QuestionID int foreign key (QuestionID) references QuestionPool(QuestionID) 
)