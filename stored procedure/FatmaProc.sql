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
update QuestionPool set QuestionText=@Question,QuestionType=@Type,CourseID=@fkCourseID
where QuestionID=@QsID
return 1;
end try
begin catch
throw;
end catch
end

--sp_Instructor_Question_Delete
create proc sp_Instructor_Question_Delete @QsID int
as begin  

begin try 
if not exists(select QuestionID from QuestionPool where QuestionID=@QsID)
throw 51011,'Question Not Found',1;
else 
delete from [dbo].[QuestionPool] where QuestionID=@QsID
return 1;
end try
begin catch 
throw;
end catch
end 

--GetAllQuestions
create proc sp_Instructor_Question_GetAllQuestionsWithCourseName
as begin
select crs.[Course Name],QuestionText,QuestionType,CorrectAnswer from QuestionPool as qs
inner join Course as crs
on qs.CourseID=crs.CourseID

end

--### 4. Exam Entity

--sp_Instructor_Exam_Add
--sp_Instructor_Exam_GetByCourseId
--sp_Instructor_Exam_GetById
--sp_Instructor_Exam_Update
--sp_Instructor_Exam_Delete

