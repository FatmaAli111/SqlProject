--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--MOHAMED
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

Create view vw_ExamFullDetails
as
select
E.[ExamID],
E.[Name] as ExamName,
E.[Type] as ExamType,
E.[Day] as ExamDay,
E.[StartTime],
E.[EndTime],
C.[CourseID],
C.[Course Name],
I.[InstructorID],
I.[FullName] as FullName,
C.[Max Degree] as CourseMaxDegree,
(select isnull(sum(EQ.[Degree]),0) from [dbo].[Contain] EQ where EQ.[ExamID] = E.[ExamID]) as ExamTotalDegree,
(select count(*) from [dbo].[Contain] EQ where EQ.ExamID = E.[ExamID]) as NumberOfQuestions

from 
[dbo].[Exam] E join [dbo].[Course] C
on E.[CourseID] = C.[CourseID]
join [dbo].[Instructor] I
on E.[InstructorID] = I.[InstructorID]

-------------------------------------------------------------------------------------------------------------

create view vw_StudentResults
as
select
    S.studentId,
    S.fname + ' ' + S.lname AS StudentName,
    E.ExamID,
    E.Name AS ExamName,
    C.[Course Name],
    (select isnull(sum(SA.studentDegree), 0) 
     from dbo.StudentAnswer SA 
     where SA.studentId = S.studentId AND SA.examId = E.ExamID) AS TotalMarksScored,
    (select isnull(sum(EQ.Degree), 0) 
     from dbo.Contain EQ 
     where EQ.ExamID = E.ExamID) AS ExamTotalDegree
from
    dbo.Student AS S
join
    dbo.Enrollments AS EN ON S.studentId = EN.StudentID
join
    dbo.Exam AS E ON EN.CourseID = E.CourseID
join
    dbo.Course AS C ON E.CourseID = C.CourseID;

-------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--Fatma
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

create view ViewCourseStatistics
as
with StudentExamTotals as
(
    select 
        sa.examid,
        sa.studentid,
        sum(sa.[studentDegree]) as totalgrade
    from StudentAnswer sa
    group by sa.examid, sa.studentid
)

select 
    ex.examid,
    ex.courseid,
    ex.name as examname,
    count(distinct seto.studentid) as total_students,
    max(seto.totalgrade) as max_grade,
    min(seto.totalgrade) as min_grade,
    
    cast(
        sum(
            case 
                when seto.totalgrade >= dbo.fn_GetExamTotalDegree(ex.examid) * 0.5 
                then 1 else 0 
            end
        ) * 100.0
        /
        count(seto.studentid)
    as decimal(5,2)) as success_rate

from exam ex
inner join StudentExamTotals seto
    on ex.examid = seto.examid
group by 
    ex.examid,
    ex.courseid,
    ex.name;

	select * from ViewCourseStatistics


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--remonda
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


--Create view for instructor schedule
create view vw_InstructorSchedule as
select S.FullName as [Instructor Name],
C.[Course Name],
E.[Name] as [Exam Name], 
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
E.[Name] as [Exam Name],
dbo.GetStudentResult (E.[ExamID] , S.[studentId]) as Degree,
dbo.GetStudentPassFail  (E.[ExamID] , S.[studentId]) as Result

from [dbo].[Student] as S
join [dbo].[Track] as T 
on S.[trackId] = T.[trackId]
join [dbo].[Enrollments] as EN 
on EN.[StudentID] = S.[studentId]
join [dbo].[Course] as C 
on C.[CourseID] = EN.[CourseID]
join [dbo].[Exam] as E 
on E.[CourseID] = C.[CourseID]
------------------------------------
go 
select * from VW_ExamStudentResults;



