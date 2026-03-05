--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--MOHAMED
--------------------------------------------------------------------------------
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