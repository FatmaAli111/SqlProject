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

