-- create table Student(SId varchar(10),Sname varchar(10),Sage datetime,Ssex varchar(10));
-- insert into Student values('01' , '赵雷' , '1990-01-01' , '男');
-- insert into Student values('02' , '钱电' , '1990-12-21' , '男');
-- insert into Student values('03' , '孙风' , '1990-05-20' , '男');
-- insert into Student values('04' , '李云' , '1990-08-06' , '男');
-- insert into Student values('05' , '周梅' , '1991-12-01' , '女');
-- insert into Student values('06' , '吴兰' , '1992-03-01' , '女');
-- insert into Student values('07' , '郑竹' , '1989-07-01' , '女');
-- insert into Student values('09' , '张三' , '2017-12-20' , '女');
-- insert into Student values('10' , '李四' , '2017-12-25' , '女');
-- insert into Student values('11' , '李四' , '2017-12-30' , '女');
-- insert into Student values('12' , '赵六' , '2017-01-01' , '女');
-- insert into Student values('13' , '孙七' , '2018-01-01' , '女');

-- create table Course(CId varchar(10),Cname nvarchar(10),TId varchar(10));
-- insert into Course values('01' , '语文' , '02');
-- insert into Course values('02' , '数学' , '01');
-- insert into Course values('03' , '英语' , '03');

-- create table Teacher(TId varchar(10),Tname varchar(10));
-- insert into Teacher values('01' , '张三');
-- insert into Teacher values('02' , '李四');
-- insert into Teacher values('03' , '王五');

-- create table SC(SId varchar(10),CId varchar(10),score decimal(18,1));
-- insert into SC values('01' , '01' , 80);
-- insert into SC values('01' , '02' , 90);
-- insert into SC values('01' , '03' , 99);
-- insert into SC values('02' , '01' , 70);
-- insert into SC values('02' , '02' , 60);
-- insert into SC values('02' , '03' , 80);
-- insert into SC values('03' , '01' , 80);
-- insert into SC values('03' , '02' , 80);
-- insert into SC values('03' , '03' , 80);
-- insert into SC values('04' , '01' , 50);
-- insert into SC values('04' , '02' , 30);
-- insert into SC values('04' , '03' , 20);
-- insert into SC values('05' , '01' , 76);
-- insert into SC values('05' , '02' , 87);
-- insert into SC values('06' , '01' , 31);
-- insert into SC values('06' , '03' , 34);
-- insert into SC values('07' , '02' , 89);
-- insert into SC values('07' , '03' , 98);

-- select sid,sname,sage,ssex
-- from student;

-- 开始修改  修改数据库的编码
-- alter table student default character set utf8mb4;
-- alter table teacher default character set utf8mb4;

-- 更改列的编码
-- alter table student change ssex ssex varchar(10) character set utf8mb4;
-- alter table teacher change tname tname varchar(10) character set utf8mb4;

-- show create table student

-- 1、查询「李」姓老师的数量（5分）
select count(tname) as li
from teacher 
where tname like "李%";

-- 2、查询" 01 "课程比" 02 "课程成绩高的学生的信息及课程分数 （10分）
SELECT * 
FROM student AS s RIGHT JOIN 
(SELECT a.SId, a.score AS class1, b.score AS class2 
FROM (SELECT * FROM sc WHERE sc.CId='01')as a,(SELECT * FROM sc WHERE sc.CId='02')as b 
WHERE a.SId=b.SId 
  AND a.score > b.score) AS t1
ON s.SId = t1.SId;
/*
1、找出有01成绩的同学成绩信息 SELECT * from sc WHERE sc.CId='01'
2、找出有02成绩的同学成绩信息 SELECT * from sc WHERE sc.CId='02'
3、以上两种结果需要满足一定条件（1）SId要一致【同一人】（2）且01.score>02.score
SELECT* FROM (SELECT * from sc WHERE sc.CId='01')as a,(SELECT * from sc WHERE sc.CId='02')as b
4、接下来嫁接条件——行过滤——where a.SId=b.SId AND a.score>b.score
5、更改SELECT条件，SELECT a.SId,a.score class1,b.score class2
6、假装这是一个新表结果，命名为t1，和student联合一查，查出满足
SELECT * from student RIGHT JOIN （……）as t1  ON student.SId=r.SId
*/

-- 3、查询同时存在" 01 "课程和" 02 "课程的情况 （5分）
select *
from student AS s right join
(select c1.sid
from (select * from sc where sc.cid = "01") AS c1, (select * from sc where sc.cid = "02") AS c2
where c1.sid = c2.sid) AS t1
on s.sid = t1.sid;



-- 4、查询存在" 01 "课程但可能不存在" 02 "课程的情况(不存在时显示为 null ) （10分）
SELECT *
FROM (SELECT * FROM  SC WHERE SC.CId="01") AS c1 LEFT JOIN (SELECT * FROM  SC WHERE SC.CId="02") AS c2
ON c1.SId = c2.SId; 

-- 5、查询不存在" 01 "课程但存在" 02 "课程的情况（15分）
SELECT *
FROM (SELECT * FROM  SC WHERE SC.CId="01") AS c1 right JOIN (SELECT * FROM  SC WHERE SC.CId="02") AS c2
ON c1.SId = c2.SId
WHERE c1.SId IS NULL; 

-- 6、查询平均成绩大于等于 60 分的同学的学生编号和学生姓名和平均成绩（20分）
/*
1、找出
select sc.sid, student.sname, avg(sc.score) as avgscore from student, sc group by sc.sid having avgscore > 60
*/
select s.sid,s.sname,t1.avgscore
from student as s right join
(select sc.sid, avg(sc.score) as avgscore 
from sc 
group by sc.sid 
having avgscore > 60) as t1
on s.sid = t1.sid;

-- 7、查询在 SC 表存在成绩的学生信息（15分）
-- 方法1
select *
from student right join
(select distinct sid
from (select * from sc where sc.score > 0) as t1) as t2
on student.sid = t2.sid;

-- 方法2 
select distinct student.*
FROM student,sc
WHERE student.sid= sc.sid;

-- 8、查询所有同学的学生编号、学生姓名、选课总数、所有课程的总成绩(没成绩的显示为 null )（20分）
/*
每个学生选课总数：
select sid, count(sc.cid) from sc group by sc.sid;
所有课程总成绩：
select sum(sc.score) from sc group by sc.sid;
*/
select s.sid, s.sname, cn.coursenum, cn.scorenum
from student as s left join (select sid, count(sc.cid) as coursenum, sum(sc.score) as scorenum from sc group by sc.sid) as cn
on s.sid = cn.sid;
