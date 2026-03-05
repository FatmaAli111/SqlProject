--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--MOHAMED
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------



Create function fn_GetExamDurationInMinutes (@ExamID int)
returns int
as
begin

	declare @Duration int

select @Duration = DATEDIFF(Minute, [StartTime], [EndTime])
from [dbo].[Exam]
where [ExamID] = @ExamID

return isnull (@Duration, 0)

end;

------------------------------------------------------------------------------------------------------------

Create function fn_GetExamTotalDegree (@ExamID int)
returns int
as
begin
	
	declare @TotalDegree int;

select @TotalDegree = isnull(sum([Degree]), 0)
from [dbo].[Contain]
where [ExamID] = @ExamID

return @TotalDegree;

end;

------------------------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--Fatma
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

create function fn_countinstructorexams
(
    @instructorid int,
    @courseid int
)
returns int
as
begin
    declare @total int;

    select @total = count(*)
    from exam
    where instructorid = @instructorid
      and courseid = @courseid;

    return isnull(@total,0);
end



create function fn_countCourseQuestions
(
@CourseRef int 
)
returns int 
as begin
declare @var int 
select @var=count(questionid) from QuestionPool 
where CourseID=@CourseRef
return isnull(@var,0)
end

------------------------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--remonda
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

create function GetStudentResult (@exam_id int , @student_id int)
returns int
as begin
declare @total_degree int;

select @total_degree=sum([studentDegree]) from [dbo].[StudentAnswer]
where [studentId]=@student_id and [examId]=@exam_id;

return @total_degree;

end

go 

create function GetStudentPassFail  (@exam_id int , @student_id int)
returns nvarchar(10)
as begin
declare @total_degree int;
declare @exam_total int;
set @exam_total  = dbo.fn_GetExamTotalDegree(@exam_id);
set @total_degree=dbo.GetStudentResult(@exam_id, @student_id);

if(@total_degree >= (@exam_total * 0.5))
   return 'Pass';
return 'Fail';
end

go 

