%let num=3;
%let Val1=1;
%let Val2=2;
%let Val3=2;
%let Add=Val1+Val2;
%let Sum=&Val1+&Val2;
%let MVar1=This Text;
%let MVar2=That Text;
%let Variable=Sum;

%put &=add;
%put &=sum;
%let ActualSum=%eval(&Val1+&Val2);
%put &=actualsum;

%let this=%eval(4/3);
%put &=this;
%let that=%eval(8.0/2);
%put &=that;
%let another=%sysevalf(8.0/3);
%put &=another;

%put &MVar&Val1;

%put &&MVar&Val2;

%put &&val&num;

%put &&&&MVar&&Val&Num;

%put &Variable;
%put &&Variable; /***&&->&, variable is alone--&variable->sum***/
%put &&&Variable;
/**&&->&, &variable->sum--&sum->1+2 ***/

%put %eval(&&&Variable);

/***Exercise 1***/
%macro CrsInfo2;
data _null_;
set sasprg.schedule;
call symput(cats('Teacher',Course_Number),strip(Teacher));
call symput(cats('Location',Course_Number),strip(Location));
call symput(cats('Start',Course_Number),put(Begin_Date,worddate.));
call symput(cats('Code',Course_Number),Course_Code);
run;
data _null_;
set sasprg.courses;
call symput(cats('Title',Course_Code),strip(Course_Title));
call symput(cats('Days',Course_Code),put(Days,1.));
call symput(cats('Fee',Course_Code),Fee);
run;
data _null_;
set sasprg.register;
by Course_Number;
if first.Course_Number then do;
enrollment=0;
feePaid=0;
end;
enrollment+1;
if paid eq 'Y' then feePaid+1;
if last.Course_Number then do;
  call symput(cats('Enrolled',Course_Number),put(enrollment,best3.));
  call symput(cats('PaidUp',Course_Number),put(feepaid,best3.));
  call symput(cats('Outstanding',Course_Number),
     put((enrollment-feepaid)*symget(cats('Fee',symget(cats('Code',course_number)))),dollar8.));
  call symput(cats('FeesPaid',Course_Number),
     put(feepaid*symget(cats('Fee',symget(cats('Code',course_number)))),dollar8.));
end;
run;
%mend;
options mprint symbolgen nomlogic;
%CrsInfo2;
%macro CrsReport2(crs);
Title "Enrollment List for &&&&Title&&Code&crs";
Title2 "&&Location&crs, Starting &&Start&crs";
Title3 "Taught by &&teacher&crs";
proc report data=sasprg.register;
where course_number eq &crs;
column Student_Name Paid;
define Student_Name / 'Student';
define Paid / 'Fees Paid';
compute after _page_;
line "&&Enrolled&crs students enrolled; &&PaidUp&crs paid";
line "&&FeesPaid&crs in Fees Paid, &&Outstanding&crs in Fees Due";
endcomp;
run;
%mend;
%CrsReport2(1);
%put _user_;

%macro dummy;
proc sql noprint;
 /***write a sql query that determines the number of courses...***/
 select put(count(course_title),2.)
 into :num
 from sasprg.courses inner join sasprg.schedule
     on courses.course_code eq schedule.course_code ;
 %put &=num;
 
 select course_title, fee format=best12., location, begin_date, teacher
 into :crsTitle1-:crsTitle&num, :crsFee1-:crsFee&num, :crsLocation1-:crsLocation&num,
      :crsBegin1-:crsBegin&num, :crsTeacher1-:crsTeacher&num
 from sasprg.courses inner join sasprg.schedule
     on courses.course_code eq schedule.course_code
 order by course_number
 ;

 select count(student_name), sum(paid eq 'Y')
   into :crsEnroll1-:crsEnroll&num, :crsPaid1-:crsPaid&num
   from sasprg.register
   group by course_number;
 ;
 %put _user_;
quit;
%mend;
options mprint;
%dummy;

data _null_;
set sasprg.schedule;
call symput(cats('Teacher',Course_Number),strip(Teacher));
call symput(cats('Location',Course_Number),strip(Location));
call symput(cats('Start',Course_Number),put(Begin_Date,worddate.));
call symput(cats('Code',Course_Number),Course_Code);
run;
%put &teacher1;

proc sql noprint;
 /***write a sql query that determines the number of courses...***/
 select count(course_title)
 into :num
 from sasprg.courses inner join sasprg.schedule
     on courses.course_code eq schedule.course_code ;
 %put &=num;
 %let num=&num;
 %put &=num;
  
 select course_title, fee format=best12., location, begin_date, teacher
 into :crsTitle1-:crsTitle&num, :crsFee1-:crsFee&num, :crsLocation1-:crsLocation&num,
      :crsBegin1-:crsBegin&num, :crsTeacher1-:crsTeacher&num
 from sasprg.courses inner join sasprg.schedule
     on courses.course_code eq schedule.course_code
 order by course_number
 ;

 select count(student_name), sum(paid eq 'Y')
   into :crsEnroll1-:crsEnroll&num, :crsPaid1-:crsPaid&num
   from sasprg.register
   group by course_number;
 ;
 %put _user_;
quit;


proc sql noprint;
 select count(student_name) as enrollment, sum(paid eq 'Y') as paidFee,
    (calculated enrollment - calculated paidFee)*Fee as outstanding
  into :crsEnroll1-:crsEnroll18, :crsPaid1-:crsPaid18, :crsOutstanding1-:crsOutstanding18
  from (sasprg.register inner join sasprg.schedule  on register.course_number eq schedule.course_number)
         inner join sasprg.courses on courses.course_code eq schedule.course_code
  group by register.course_number, Fee;
 ;
 %put _user_;
quit;

proc sql noprint;
 select course_title, fee format=best12., location, begin_date, teacher
  into :crsTitle1-:crsTitle18, :crsFee1-:crsFee18, :crsLocation1-:crsLocation18,
       :crsBegin1-:crsBegin18, :crsTeacher1-:crsTeacher18
  from sasprg.courses inner join sasprg.schedule
    on courses.course_code eq schedule.course_code
  order by course_number
 ;
 select count(student_name) as enrollment, sum(paid eq 'Y') as paidFee,
    (calculated enrollment - calculated paidFee)*Fee as outstanding format=dollar6.
  into :crsEnroll1-:crsEnroll18, :crsPaid1-:crsPaid18, :crsOutstanding1-:crsOutstanding18
  from (sasprg.register inner join sasprg.schedule  on register.course_number eq schedule.course_number)
         inner join sasprg.courses on courses.course_code eq schedule.course_code
  group by register.course_number, Fee;
 ;
 %put _user_;
quit;


%macro CrsReport4(crs);
Title "Enrollment List for &&crsTitle&crs";
Title2 "&&crsLocation&crs, Starting &&crsBegin&crs";
proc report data=sasprg.register;
where course_number eq &crs;
column Student_Name Paid;
define Student_Name / 'Student';
define Paid / 'Fees Paid';
compute after _page_;

line "&&crsEnroll&crs students enrolled; &&crsPaid&crs paid";
line "&&crsOutstanding&crs in Fees Due";
endcomp;
run;
%mend;
options mprint symbolgen;
%CrsReport4(1);

libname myMacros 'C:\users\blumj\desktop';
options mstored sasmstore=myMacros;
/***MSTORED tells SAS you want to use stored macros, or store macros***/
/***SASMSTORE= sets a library where a catalog will be referenced for storage
 or access to macros***/

%macro CrsInfo2 / store source des='Macro for generating title and footer info';
  /***As an option, after / , we can say STORE to get it stored
   SOURCE stores source code,
   des= is a description***/
data _null_;
 set sasprg.schedule;
 call symput(cats('Teacher',Course_Number),strip(Teacher));
 call symput(cats('Location',Course_Number),strip(Location));
 call symput(cats('Start',Course_Number),put(Begin_Date,worddate.));
 call symput(cats('Code',Course_Number),Course_Code);
run;
data _null_;
 set sasprg.courses;
 call symput(cats('Title',Course_Code),strip(Course_Title));
 call symput(cats('Days',Course_Code),put(Days,1.));
 call symput(cats('Fee',Course_Code),Fee);
run;
data _null_;
 set sasprg.register;
 by Course_Number;
 if first.Course_Number then do;
  enrollment=0;
  feePaid=0;
 end;
 
 enrollment+1;
 if paid eq 'Y' then feePaid+1;
 if last.Course_Number then do;
  call symput(cats('Enrolled',Course_Number),put(enrollment,best3.));
  call symput(cats('PaidUp',Course_Number),put(feepaid,best3.));
  call symput(cats('Outstanding',Course_Number),
  put((enrollment-feepaid)*symget(cats('Fee',symget(cats('Code',course_number)))),
    dollar8.));
 end;
run;
%mend;

proc catalog catalog=mymacros.sasmacr;
 contents;
run;

%copy CrsInfo2 / source ;