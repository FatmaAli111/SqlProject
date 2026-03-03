
--Create view for instructor schedule
create view vw_InstructorSchedule as
select S.FullName as [Instructor Name],
C.[Course Name],
E.[Name], 
E.[Day],
format(cast(E.[StartTime]as datetime),'hh:mm tt') as StartTime,
format(cast(E.EndTime as datetime),'hh:mm tt') as EndTime,
cast(abs(E.ExamTotalTime) as varchar) + ' min' as ExamTotalTime

from [dbo].[Instructor] as S
join [dbo].[Exam] as E

on S.InstructorID=E.InstructorID
join [dbo].[Course] as C
on C.CourseID=E.CourseID
----------------------------------------
go
select * from vw_InstructorSchedule;
go
-----------------------------------------
--Create view for student exam history
create view VW_ExamStudentResults as
select concat(S.[fname],' ',S.[lname]) as [Student Name] ,
T.[trackName],
C.[Course Name],
E.[Name],
dbo.GetStudentResult (E.[ExamID] , S.[studentId]) as Degree,
dbo.GetStudentPassFail  (E.[ExamID] , S.[studentId]) as Result
from [dbo].[Student] as S
join [dbo].[Track] as T
on S.[trackId]=T.[trackId]
join [dbo].[Course] as C 
on c.[trackId]=T.[trackId]
join [dbo].[Exam] as E
on E.[CourseID]= C.[CourseID]
------------------------------------
go 
select * from VW_ExamStudentResults;
