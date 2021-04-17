%let rc=%sysfunc(dlgcdir('/home/blumj/Documents/'));
%put &rc;

ods listing image_dpi=300;/***ods listing turns on the direct to file destination for graphs***/
ods graphics / reset imagename='MyImage' imagefmt=gif height=9cm width=16cm;
/***reset sets all graphics options to the default, and also then
	restarts the naming***/
proc sgplot data=sashelp.cars;
	hbar origin / response=mpg_city stat=mean;
run;

ods graphics / imagename='AnotherGraph';
proc sgplot data=sashelp.cars;
	hbar type / response=mpg_city stat=mean;
run;