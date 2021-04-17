/** Although the PDF said prefix, the comments here seem to
	indicate that suffixes (for the course number) are required.
	I hope I'm not misunderstanding here!
	
	I started an alternative one with
		cats(course_number,<var-string>,<course-number-or-code>)
	but it seemed very unwieldy and repetitive, such as some being
	cats(course_number,<name>,course_number). I have that one on
	hand, so if you would prefer that version please let me know!
	*/
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
	call symput(cats('Teacher',Course_Number),strip(Teacher));
	call symput(cats('Location',Course_Number),strip(Location));
	call symput(cats('Start',Course_Number),put(Begin_Date,worddate.));
	call symput(cats('Code',Course_Number),Course_Code);
	call symput(cats('Title',Course_Number),strip(Course_Title));
	call symput(cats('Days',Course_Number),put(Days,1.));
	call symput(cats('Fee',Course_Number),Fee);
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
 	end;
run;
%mend;
 
%macro CrsReport2(crs);
Title "Enrollment List for &&Title&crs";/***this reference changes, too**/
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
options mprint symbolgen nomlogic;
%CrsInfo2;
%CrsReport2(1);