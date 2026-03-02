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

declare @min_degree int;
declare @total_degree int;

select @min_degree=C.[Min Degree] from [dbo].[Course] C
join [dbo].[Exam] E on C.CourseID=E.CourseID
where E.ExamID=@exam_id;

set @total_degree=dbo.GetStudentResult(@exam_id, @student_id);

if(@total_degree>=@min_degree)
   return 'Pass';
return 'Fail';
end

go 

