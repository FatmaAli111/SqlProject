
--- Exam Questions Entity ---

-- add Questions to Exam 

create proc sp_Instructor_Exam_AddQuestion @ques_id int , @exam_id int,  @degree int
as begin

begin try
 if NOT EXISTS(select 1 from [dbo].[Exam] where [ExamID]=@exam_id)
  begin
   raiserror( 'Exam not found',16,1);
   return;
  end

  if NOT EXISTS(select 1 from [dbo].[QuestionPool] where [QuestionID]=@ques_id)
  begin
   raiserror( 'Question not found',16,1);
   return;
  end

  if EXISTS(select 1 from [dbo].[Contain] where [QuestionID]=@ques_id and [ExamID]= @exam_id)
  begin
  raiserror( 'Question already exists in this exam',16,1);
   return;
  end

  declare @total int, @max_degree int;

  select @total =isnull(sum([Degree]),0)
  from [dbo].[Contain]
  where [ExamID]= @exam_id

  select @max_degree =C.[Max Degree]
  from [dbo].[Exam] as E
  join [dbo].[Course] as C
  on E.CourseID=C.CourseID
  where E.[ExamID]= @exam_id

  if(@degree+@total)>@max_degree
   begin
   raiserror( 'Adding this question exceeds the course max degree',16,1);
    return
   end

   insert into [dbo].[Contain]([Degree],[QuestionID],[ExamID])
   values (@degree,@ques_id,@exam_id)
   print 'Question added to exam successfully';
end try
begin catch
print 'Error : ' + error_message();
end catch
end

go

-- Remove Question from Exam
create proc sp_Instructor_Exam_RemoveQuestion @question_id int , @exam_id int
as begin

begin try
 if NOT EXISTS(select 1 from [dbo].[Exam] where [ExamID]=@exam_id)
  begin
   raiserror( 'Exam not found',16,1);
   return;
  end

  if NOT EXISTS(select 1 from [dbo].[Contain] where [QuestionID]=@question_id and [ExamID]= @exam_id)
  begin
  raiserror( 'Question not exists in this exam',16,1);
   return;
  end

   delete from  [dbo].[Contain]
   where [ExamID]=@exam_id and [QuestionID]=@question_id
   print 'Question removed from exam successfully';
end try
begin catch
print 'Error : ' + error_message();
end catch
end

go 

-- update question in exam
create proc sp_Instructor_Exam_UpdateQuestionDegree  @ques_id int , @exam_id int,  @new_degree int
as begin

begin try

  if NOT EXISTS(select 1 from [dbo].[Contain] where [QuestionID]=@ques_id and [ExamID]= @exam_id)
  begin
  raiserror( 'Question not found in this exam',16,1);
   return;
  end

  declare @total int, @max_degree int;

  select @total =isnull(sum([Degree]),0)
  from [dbo].[Contain]
  where [ExamID]= @exam_id and [QuestionID]<> @ques_id

  select @max_degree =C.[Max Degree]
  from [dbo].[Exam] as E
  join [dbo].[Course] as C
  on E.CourseID=C.CourseID
  where E.[ExamID]= @exam_id

  if(@new_degree+@total)>@max_degree
   begin
   raiserror( 'updating this question exceeds the course max degree',16,1);
    return
   end

   update [dbo].[Contain]
   set [Degree]=@new_degree
   where [ExamID]= @exam_id and [QuestionID]= @ques_id
   print 'Question updated successfully';
end try
begin catch
print 'Error : ' + error_message();
end catch
end

go

-- get questions from exam
create proc sp_Instructor_Exam_GetQuestions  @exam_id int
as begin

begin try
 if NOT EXISTS(select 1 from [dbo].[Exam] where [ExamID]=@exam_id)
  begin
   raiserror( 'Exam not found',16,1);
   return;
  end

  select Q.QuestionID,Q.QuestionType, Q.QuestionText,Q.CorrectAnswer ,C.Degree
  from [dbo].[Contain] as C
  join [dbo].[QuestionPool] as Q
  on C.QuestionID=Q.QuestionID
  where C.ExamID=@exam_id
end try
begin catch
print 'Error : ' + error_message();
end catch
end

go