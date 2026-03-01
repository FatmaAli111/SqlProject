
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
 if not exists(select 1 from [dbo].[Exam] where [ExamID]=@exam_id)
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

--- choices Questions Entity ---

--Add choice to an MCQ question
create proc sp_Instructor_Choice_Add @question_id int, @choice_text Nvarchar(max)
as begin
begin try

declare @type nvarchar(20);
select @type=[QuestionType] from [dbo].[QuestionPool]
where [QuestionID]=@question_id;

if(@type is null)
begin
raiserror('Question not found', 16, 1);
return;
end

if(@type != 'MCQ')
begin
raiserror('Question type must be MCQ', 16, 1);
return;
end

if EXISTS(select 1 from [dbo].[QuestionChoices] where ChoiceText=@choice_text and [QuestionID]= @question_id)
begin
raiserror( 'Choice already exists for this question',16,1);
return;
end
insert into [dbo].[QuestionChoices] ([QuestionID],[ChoiceText])
values (@question_id,@choice_text)
print 'Choice added to Question successfully';
end try
begin catch
print 'Error : ' + error_message();
end catch
end 

go


-- get choice for an MCQ question
create proc sp_Instructor_Choice_GetByQuestionId @question_id int
as begin
begin try
if NOT EXISTS(select 1 from  [dbo].[QuestionPool] where [QuestionID]=@question_id)
begin
raiserror('Question not found', 16, 1);
return;
end

select [ChoicesID], [ChoiceText] from [dbo].[QuestionChoices]
where [QuestionID]=@question_id;

end try
begin catch
print 'Error : ' + error_message();
end catch
end

go

-- update choice for an MCQ question
create proc sp_Instructor_Choice_Update @choice_id int , @choice_text nvarchar(50)
as begin
begin try
if not exists(select 1 from [dbo].[QuestionChoices] where [ChoicesID]=@choice_id)
begin
raiserror('Choice not found', 16, 1);
return;
end

if exists(select 1 from [dbo].[QuestionChoices] where ChoiceText=@choice_text
and QuestionID = (select QuestionID from QuestionChoices where ChoicesID = @choice_id))
begin
raiserror( 'Choice already exists for this question',16,1);
return;
end

update [dbo].[QuestionChoices]
set [ChoiceText]=@choice_text
where [ChoicesID]=@choice_id;
print 'choice updated successfully';

end try
begin catch
print 'Error : ' + error_message();
end catch
end

go


-- delete choice 
create proc sp_Instructor_Choice_Delete  @choice_id int 
as begin
begin try
if not exists(select 1 from [dbo].[QuestionChoices] where [ChoicesID]=@choice_id)
begin
raiserror('Choice not found', 16, 1);
return;
end

delete [dbo].[QuestionChoices]
where [ChoicesID]=@choice_id;
print 'deleted successfully';

end try
begin catch
print 'Error : ' + error_message();
end catch
end

go