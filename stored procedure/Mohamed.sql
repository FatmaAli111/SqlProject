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