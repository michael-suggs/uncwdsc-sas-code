/* Michael Suggs (mjs3607@uncw.edu)
 * Chapter 6 Wrap-Up 2/11/2020
 * DSC 511
 */

/* Instructions:
 *	1. Change `datadir` to point to the directory encapsulating `datafile`.
 *	2. Change `sasdir` to point to the directory encapsulating `sasfile`.
 *	3. Change `libdir` to point to the desired directory for the library for this code.
 *
 * If filenames need to be changed (for files within datadir and sasdir):
 *	1. Change `datafile` to point to the desired .csv file within `datadir`.
 *	2. Change `sasfile` to point to desired .sas7bdat file within `sasdir`.
 */

%let datadir=C:\Users\mjs3607\OneDrive - UNC-Wilmington\SASBook\Data\Raw Data Sets;
%let sasdir=C:\Users\mjs3607\OneDrive - UNC-Wilmington\SASBook\71342_example\Data\SAS Data Sets;
%let libdir=C:\Users\mjs3607\Documents\SAS Code\DSC511\mylib;

filename mydata "&datadir";
libname mylib "&libdir";
libname sasdata "&sasdir";

ods trace on;

data mylib.ipums051015;
	set sasdata.ipums2005basic(in = in2005)
			sasdata.ipums2010basic(in = in2010)
			sasdata.ipums2015basic(in = in2015);
	if in2005 eq 1 then Year = 2005;
		else if in2010 eq 1 then Year = 2010;
			else if (in2015 eq 1) then Year = 2015;
run;

proc sort data=mylib.ipums051015 out=work.sorted051015;
	by SERIAL Year;
run;

data mylib.util05;
	infile mydata('Utility Cost 2005.txt') dlm='09'x dsd firstobs=4;
	input SERIAL electric:comma. gas:comma. water:comma. fuel:comma.;
	format electric gas water fuel dollar.;
	Year = 2005;
run;

data mylib.util10;
	infile mydata('Utility Costs 2010.csv') dsd firstobs=5;
	input SERIAL water:comma. gas:comma. electric: comma. fuel: comma.;
	format electric gas water fuel dollar.;
	Year = 2010;
run;

data mylib.util15;
	infile mydata('2015 Utility Cost.dat') firstobs=8;
	input @1 SERIAL 8. water comma5. gas comma5.
					 electric comma5. fuel comma5.;
	format electric gas water fuel dollar.;
	Year = 2015;
run;

data mylib.ipumsutil;
	merge work.sorted051015
				work.util05
				work.util10
				work.util15;
	by SERIAL Year;
	if HomeValue ge 9999999 then HomeValue=.;
	if electric ge 9000 then electric=.;
	if gas ge 9000 then gas=.;
	if water ge 9000 then water=.;
	if fuel ge 9000 then fuel=.;
run;

/* Output 6.2.1: Electricity Cost Summary Statistics */
proc report data=mylib.ipumsutil;
	where state in ('Connecticut','Massachusetts','New Jersey','New York');
	column state year ('Electricity Cost' electric=mean electric=median electric=std);
	define state / group 'State';
	define year / group 'Year';
	define mean / mean 'Mean' format=dollar10.2;
	define median / median 'Median' format=dollar10.2;
	define std / std 'Std. Dev.' format=dollar10.2;
	break after state / summarize suppress;
run;

/* Output 6.2.2:  */
proc report data=mylib.ipumsutil;
	where state in ('Connecticut','Massachusetts','New Jersey','New York');
	column state year,(HomeValue=mean HomeValue=median);
	define state / group 'State';
	define year / across 'Home Value Statistics';
	define HomeValue / '';
	define mean / mean 'Mean' format=dollar10.;
	define median / median 'Median' format=dollar10.;
run;