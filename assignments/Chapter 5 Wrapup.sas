/* Michael Suggs (mjs3607@uncw.edu)
 * Chapter 5 Wrap-Up 20/10/2020
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

data work.ipums051015;
	set sasdata.ipums2005basic(in = in2005)
			sasdata.ipums2010basic(in = in2010)
			sasdata.ipums2015basic(in = in2015);
	if in2005 eq 1 then Year = 2005;
		else if in2010 eq 1 then Year = 2010;
			else if (in2015 eq 1) then Year = 2015;
run;

proc sort data=work.ipums051015 out=work.sorted051015;
	by SERIAL Year;
run;

data work.util05;
	infile mydata('Utility Cost 2005.txt') dlm='09'x dsd firstobs=4;
	input SERIAL electric:comma. gas:comma. water:comma. fuel:comma.;
	format electric gas water fuel dollar.;
	Year = 2005;
run;

data work.util10;
	infile mydata('Utility Costs 2010.csv') dsd firstobs=5;
	input SERIAL water:comma. gas:comma. electric: comma. fuel: comma.;
	format electric gas water fuel dollar.;
	Year = 2010;
run;

data work.util15;
	infile mydata('2015 Utility Cost.dat') firstobs=8;
	input @1 SERIAL 8. water comma5. gas comma5.
					 electric comma5. fuel comma5.;
	format electric gas water fuel dollar.;
	Year = 2015;
run;

data work.ipumsutil;
	merge work.sorted051015
				work.util05
				work.util10
				work.util15;
	HValue = HomeValue / 1000;
	by SERIAL Year;
	if HomeValue ge 9999999 then HomeValue=.;
	if electric ge 9000 then electric=.;
	if gas ge 9000 then gas=.;
	if water ge 9000 then water=.;
	if fuel ge 9000 then fuel=.;
run;

proc sort data=work.ipumsutil out=mylib.ipumsutil;
	by Year SERIAL;
run;

proc corr data=mylib.ipumsutil;
	var electric gas water fuel;
	with HomeValue HHIncome;
	by Year;
	ods select PearsonCorr;
run;

proc means data=mylib.ipumsutil mean;
	var gas electric;
	class Year state;
	where state in ('North Carolina', 'South Carolina', 'Virginia');
	ods output summary=work.GEMeans;
run;

proc transpose data=work.GEMeans out=work.tGEMeans name=Utility prefix=Cost;
	by Year state;
	var gas_Mean electric_Mean;
run;

proc sgplot data=work.GEMeans;
	scatter x=electric_Mean y=gas_Mean / group=state datalabel=Year
					markerattrs=(symbol=circlefilled);
	xaxis label='Mean Electric Cost ($)';
	yaxis label='Mean Gas Cost ($)';
	keylegend / position=topright location=inside title='';
run;

ods graphics / outputfmt=STATIC;
proc sgpanel data=mylib.ipumsutil(where=(HomeValue le 500000));
	panelby state Year / novarname headerbackcolor=white;
	where state in ('North Carolina', 'South Carolina') and HomeValue le 500000;
	pbspline x=HValue y=gas / legendlabel='Gas' nomarkers
					 lineattrs=(color=red);
	pbspline x=HValue y=electric / legendlabel='Elec.' nomarkers
					 lineattrs=(color=blue);
	pbspline x=HValue y=fuel / legendlabel='Fuel' nomarkers
					 lineattrs=(color=green);
	pbspline x=HValue y=water / legendlabel='Water' nomarkers
					 lineattrs=(color=yellow);
	colaxis label='Home Value x $1000' values=(0 to 599 by 200);
	rowaxis label='Cost ($)' values=(0 to 3500 by 1000) valuesformat=F8.;
	keylegend / position=bottom linelength=20%;
run;