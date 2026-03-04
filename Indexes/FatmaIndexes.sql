
create nonclustered index ix_exam_courseid_instructorid 
on [dbo].[exam] ([courseid], [instructorid]);

create nonclustered index ix_exam__instructorid
on [dbo].[exam] ([instructorid]);

create nonclustered index ix_exam_courseid
on [dbo].[exam] ([courseid]);

create nonclustered index ix_questionpool_courseid 
on [dbo].[questionpool] ([courseid]);

create nonclustered index ix_student_trackid 
on [dbo].[student] ([trackid]);

create nonclustered index ix_instructorcourses_courseid 
on [dbo].[instructorcourses] ([courseid]);


create nonclustered index ix_studentanswer_examid_studentid 
on [dbo].[studentanswer] ([examid], [studentid])
include ([studentdegree]);



