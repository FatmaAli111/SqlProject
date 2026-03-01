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
create proc sp_Instructor_Question_Delete @QsID int
as begin  

begin try 
if not exists(select QuestionID from QuestionPool where QuestionID=@QsID)
throw 51011,'Question Not Found',1;

if  exists(select 1 from contain where QuestionID=@QsID)
throw 51031,'Cannot delete Question: student answers exist',1;

delete from [dbo].[QuestionPool] where QuestionID=@QsID
return 1;
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