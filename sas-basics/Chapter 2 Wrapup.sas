/* Michael Suggs (mjs3607@uncw.edu)
 * Chapter 2 Wrap-Up 09/09/2020
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
%let libdir=C:\Users\mjs3607\Documents\SAS Code\DSC511\ch2lib;

%let datafile=ipums2010basic.csv;
%let sasfile=ipums2010basic;

filename mydata "&datadir";
libname mylib "&libdir";
libname sasdata "&sasdir";

proc format;
	value MetroExplicit
		0 = "Not Identifiable"
		1 = "Not in Metro Area"
		2 = "Metro, Inside City"
		3 = "Metro, Outside City"
		4 = "Metro, City Status Unknown"
	;
	value MetroOther
		2 = 'Metro, Inside City'
		3 = 'Metro, Outside City'
		4 = 'Metro, City Status Unknown'
	;
	value HHIfmt
		low-<0 = "Negative"
		0-45000 = "$0 to $45K"
		45000-90000 = "$45K to $90K"
		90000-high = "Above $90K"
	;
	value Mort
		low-350 = "$350 and Below"
		350<-1000 = "$351 to $1000"
		1000<-1600 = "$1001 to $1600"
		1600<-high = "Over $1600"
	;
run;

/* data set creation */
data mylib.ipumsdata;
	length State$57 City$43 MortgageStatus$45;
	infile mydata("&datafile") dsd;
	input ID State$ City$ CityPop Metro
				CountyFIPS Ownership$ MortgageStatus$
				MortgagePayment HHIncome HomeValue;
run;

proc compare base=mylib.ipumsdata compare=sasdata.&sasfile
						 out=work.diff outbase outcompare outdif outnoequal
						 method=absolute criterion=1E-9;
run;

proc means data=mylib.ipumsdata maxdec=1 nonobs;
	class Metro;
	var MortgagePayment;
	format Metro MetroExplicit.;
	where MortgagePayment >= 100;
run;

proc means data=mylib.ipumsdata maxdec=0 min median max nonobs;
	class Metro HHIncome;
	var MortgagePayment HomeValue;
	label MortgagePayment="Mortgage Payment" HomeValue="Home Value" HHIncome="Household Income";
	format Metro MetroOther. HHIncome HHIfmt.;
	where MortgagePayment >= 100 and Metro not in (0,1);
run;

proc freq data=mylib.ipumsdata;
	table HHIncome*MortgagePayment /nocol nopercent;
	label HHIncome="Household Income" MortgagePayment="Mortgage Payment";
	format HHIncome HHIfmt. MortgagePayment Mort.;
	where MortgagePayment >= 100;
run;

proc freq data=mylib.ipumsdata;
	format HHIncome HHIfmt. MortgagePayment Mort. Metro MetroOther.;
	table Metro*HHIncome*MortgagePayment /nocol nopercent;
	label HHIncome="Household Income" MortgagePayment="Mortgage Payment";
	where MortgagePayment >= 100 and Metro in (2,3,4);
run;