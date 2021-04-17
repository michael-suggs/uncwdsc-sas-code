proc transpose data=sashelp.cars ;
run;
/***by default, only numeric variables are transposed
 and the output data set is automatically named***/

proc transpose data=sashelp.cars out=try1 prefix=Car;
 var mpg_city mpg_highway;
run;

proc transpose data=sashelp.cars out=try2;
 var model mpg_highway;
 /**if you mix types in a column, numbers get converted to character***/
run;

proc sort data=sashelp.cars out=sorted nodupkey;
 by make model drivetrain;
run;

proc transpose data=sorted out=try3;
 var mpg_city mpg_highway;
  by make model drivetrain origin;/***transposition on unique "subjects"**/
run;

proc means data=sashelp.cars;
 var mpg_city mpg_highway;
 class origin;
run;

proc means data=try3;
 var col1;
 class origin _label_;
run;

proc transpose data=sorted out=transposed(rename=(col1=MPG _name_=type _label_=category));
 var mpg_city mpg_highway;
  by make model drivetrain origin;/***transposition on unique "subjects"**/
run;

proc means data=transposed;
 var MPG;
 class origin category;
run;

proc sgplot data=sashelp.cars;
 hbar origin / response=mpg_city stat=mean;
 hbar origin / response=mpg_highway stat=mean barwidth=0.6 transparency=0.5;
run;

proc sgplot data=transposed;
 hbar origin / response=mpg stat=mean group=category groupdisplay=cluster;
run;

proc sgplot data=sashelp.cars;
 hbar origin / response=mpg_city stat=mean barwidth=0.4 discreteoffset=0.2;
 hbar origin / response=mpg_highway stat=mean barwidth=0.4 discreteoffset=-0.2;
run;


proc sgplot data=transposed;
 hbar origin / response=mpg  group=category;
run;




