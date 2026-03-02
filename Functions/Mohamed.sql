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


