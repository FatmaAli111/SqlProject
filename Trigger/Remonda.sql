alter table [dbo].[Contain] drop column [StudentAnswer];

create table StudentAnswer(
studentId int not null,
examId int not null,
questionID int not null,
studentAnswer nvarchar(max),
studentDegree int default 0,

constraint fk_studentId foreign key (studentId) references [dbo].[Student]([studentId]),
constraint fk_examId foreign key (examId) references [dbo].[Exam]([ExamID]),
constraint fk_questionID foreign key (questionID) references [dbo].[QuestionPool]([QuestionID]),
constraint fk_examQuestion foreign key (examId, questionID)  references [dbo].[Contain](ExamID, QuestionID),

constraint pk_StudentAnswer primary key (studentId,examId,questionID)
)

go 

-- calculate student degree per question 
create trigger trg_CalculateStudentDegree
on [dbo].[StudentAnswer]
after insert, update
as begin
set nocount on;

declare @correct_answer nvarchar(max);
declare @student_answer nvarchar(max);
declare @question_id int;
declare @student_id int;
declare @exam_id int;
declare @degree int;

select @question_id=[QuestionID],@exam_id=[ExamID],@student_answer=[studentAnswer] , @student_id=[studentId] from inserted;

select @degree = [Degree]  from [dbo].[Contain]
where [QuestionID]=@question_id and [ExamID]=@exam_id;

select @correct_answer = [CorrectAnswer]  from [dbo].[QuestionPool]
where [QuestionID]=@question_id ;

if(@student_answer=@correct_answer)
begin
update [dbo].[StudentAnswer]
set [studentDegree]=@degree
where [QuestionID]=@question_id and [ExamID]=@exam_id and [studentId]=@student_id;
end

else
begin
update [dbo].[StudentAnswer]
set [studentDegree]=0
where [QuestionID]=@question_id and [ExamID]=@exam_id and [studentId]=@student_id;
end

end

go
-- Prevent insert answer after ExamTime
create trigger trg_PreventAnswerAfterExamTime
on [dbo].[StudentAnswer]
after insert, update
as begin
set nocount on;

declare @exam_id int;
declare @day date;
declare @start_time time;
declare @end_time time;

select @exam_id=[examId] from inserted;

select @start_time=[StartTime],@end_time=EndTime , @day=[Day] from [dbo].[Exam] 
where [ExamID]=@exam_id;

if(@day!= cast(getdate() as date) or (cast(getdate() as time)not between @start_time and @end_time))
begin
rollback;
raiserror('Exam is not available', 16, 1);
end

end

