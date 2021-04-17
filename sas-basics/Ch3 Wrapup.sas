/* Michael Suggs (mjs3607@uncw.edu)
 * Chapter 3 Wrap-Up 21/09/2020
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

%let datafile=IPUMS2010formatted.csv;
%let sasfile=ipums2010basic;

filename mydata "&datadir";
libname mylib "&libdir";
libname sasdata "&sasdir";

proc format;
	value HHIfmt
		low-<0 = "Negative"
		0-45000 = "$0 to $45K"
		45000-90000 = "$45K to $90K"
		90000-high = "Above $90K"
	;
	value Mort
		0 = "None"
		0<-350 = "$350 and Below"
		350<-1000 = "$351 to $1000"
		1000<-1600 = "$1001 to $1600"
		1600<-high = "Over $1600"
	;
	value MortFour
		0-350 = "$350 and Below"
		350<-1000 = "$351 to $1000"
		1000<-1600 = "$1001 to $1600"
		1600<-high = "Over $1600"
	;
run;

data mylib.ipumsformatted;
	infile mydata(&datafile) dsd;
	input Serial : 8. State : $57. City ~ $quote43. Metro : 8.
				CountyFIPS : 8. CityPopC ~ $quote. Ownership : $6.
				MortgageStatus ~ $quote50. MortgagePaymentC ~ $quote16.
				HomeValueC ~ $quote16. HHIncomeC ~ $quote16.;
	CityPop=input(CityPopC, comma16.);
	HHIncome=input(HHIncomeC, dollar16.);
	HomeValue=input(HomeValueC, dollar16.);
	MortgagePayment=input(MortgagePaymentC, dollar16.);
	drop CityPopC HHIncomeC HomeValueC MortgagePaymentC;
run;

proc compare base=mylib.ipumsformatted comp=sasdata.&sasfile
						 out=work.diff outbase outcompare outdif outnoequal
						 method=absolute criterion=1E-9;
run;

proc freq data=mylib.ipumsformatted;
	table Ownership;
	table MortgageStatus;
	table City;
	table State;
run;

proc means data=mylib.ipumsformatted n nmiss min p25 p50 p75 max maxdec=1;
	var MortgagePayment;
run;

proc means data=mylib.ipumsformatted n p50 p60 p70 p80 p90 p95 p99 max maxdec=1;
	var MortgagePayment;
run;

proc sgplot data=mylib.ipumsformatted;
	hbar MortgagePayment / group=metro;
	format MortgagePayment Mort.;
	yaxis label='First mortgage monthly payment';
	keylegend / title='Metropolitan Status';
run;

proc freq data=mylib.ipumsformatted;
	table MortgagePayment;
	format MortgagePayment Mort.;
	ods output OneWayFreqs=work.Freqs;
run;

proc freq data=mylib.ipumsformatted;
	table HHIncome*MortgagePayment;
	format HHIncome HHIfmt. MortgagePayment Mort.;
	where MortgagePayment gt 0 and HHIncome ge 0;
	ods output CrossTabFreqs=work.TwoWay;
run;

proc sgplot data=work.Freqs noborder;
	vbar MortgagePayment / response=CumPercent barwidth=1;
	format MortgagePayment Mort.;
	yaxis label='Cumulative Percentage' offsetmax=0;
	xaxis label='Mortgage Payment';
/* 	title 'Cumulative Distribution of Mortgage Payments'; */
run;

proc sgplot data=work.TwoWay;
	hbar HHIncome / group=MortgagePayment groupdisplay=cluster response=RowPercent;
	keylegend / position=top across=2 title='Mortgage Payment';
	xaxis label='Percent within Income Class' grid griddattrs=(color=gray66)
				values=(0 to 65 by 5) offsetmax=0;
	yaxis label='Household Income';
	where HHIncome is not missing and MortgagePayment is not missing;
run;