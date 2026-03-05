create function fn_countinstructorexams
(
    @instructorid int,
    @courseid int
)
returns int
as
begin
    declare @total int;

    select @total = count(*)
    from exam
    where instructorid = @instructorid
      and courseid = @courseid;

    return isnull(@total,0);
end



create function fn_countCourseQuestions
(
@CourseRef int 
)
returns int 
as begin
declare @var int 
select @var=count(questionid) from QuestionPool 
where CourseID=@CourseRef
return isnull(@var,0)
end

