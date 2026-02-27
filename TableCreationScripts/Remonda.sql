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
