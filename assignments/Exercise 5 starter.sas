
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
%put _user_;
/**Replace the two data steps above with...***/

data _null_;
 merge sasprg.schedule sasprg.courses;
 by course_code;
 /***make macro variables I need kind of like the above,
   but suffixed only on course_number***/
run;


data _null_;
 set sasprg.register;
 by course_number;
 if first.course_number then do;
  enrollment = 0;
  feePaid = 0;
 end;/***initialize your counters at the start of each course***/
 enrollment+1;
 if paid eq 'Y' then feePaid+1;
 if last.course_number then do;
 call symput(cats('Enrolled',course_number),put(enrollment,best3.));
 call symput(cats('PaidUp',course_number),put(feepaid,best3.));
 check=symget(cats('code',course_number));
 check2=symget(cats('Fee',symget(cats('code',course_number))));
 put check check2;
 call symput(cats('Outstanding',course_number),
  put((enrollment-feepaid)*symget(cats('Fee',symget(cats('code',course_number)))),dollar8.));
  /**this computation (macro variable references) will change a bit**/
 
 
%macro CrsReport2(crs);
Title "Enrollment List for &&&&Title&&Code&crs";/***this reference changes, too**/
Title2 "&&Location&crs, Starting &&Start&crs";
proc report data=sasprg.register;
 where course_number eq &crs;
 column Student_Name Paid;
 define Student_Name / 'Student';
 define Paid / 'Fees Paid';
 compute after _page_;
  line "&&Enrolled&crs students enrolled; &&PaidUp&crs paid";
  line "&&Outstanding&crs in Fees Due";
 endcomp;
run;
%mend;
%CrsReport2(1);
 end;
run;
%mend;