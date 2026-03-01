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


