create table Branch(
BranchID int primary key,
BranchName nvarchar(30) not null unique
)

create table Intake(
IntakeID int primary key,
IntakeName nvarchar(30) not null
)

create table BranchIntake(
BranchID int not null,
IntakeID int not null,
constraint BranchFK foreign key (BranchID) references Branch(BranchID),
constraint IntakeFK foreign key (IntakeID) references Intake(IntakeID),
constraint BranchIntakePK primary key (BranchID, IntakeID)
)

create table Department(
DepartmentID int primary key,
DepartmentName nvarchar(30) not null
)

create table Track(
TrackID int primary key,
TrackName nvarchar(30) not null,
DepartmentID int not null,

constraint DepartmentFK foreign key (DepartmentID) references Department(DepartmentID)
)

-- ????? ?? ??? ???? ?? departmentId ? ???? ?? ? ?? ???????? ???? ????? ? intake ????? ????? ?? ??? ???? ???? ??? ?????? intake46 ????? ??? ???? .net ???
create table IntakeTrack(
IntakeID int not null,
TrackID int not null,
constraint TrackFK foreign key (TrackID) references Track(TrackID),
constraint IntakeFK foreign key (IntakeID) references Intake(IntakeID),
constraint IntakeTrackPK primary key (TrackID, IntakeID)
)

create table UserAccounts(
UserID int primary key,
UserName nvarchar(30) not null unique,
UserPassword nvarchar(30) not null,
UserRole nvarchar(30) not null,

constraint UserRoleCK
check (UserRole IN ('Student','Instructor','Manager','Admin'))
)

create table student(
StudentID int primary key,
FName nvarchar(30) not null,
LName nvarchar(30),
Email nvarchar(30),
UserID int not null,
TrackID int not null,

constraint UserFK foreign key (UserID) references UserAccounts(UserID),
constraint TrackFK foreign key (TrackID) references Track(TrackID)
)

create table StudentPhone(
phone varchar(11),
StudentID int,
constraint StudentFK foreign key (StudentID) references Student(StudentID),

constraint StudentPhonePK primary key (StudentID, phone)
)


