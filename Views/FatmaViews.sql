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