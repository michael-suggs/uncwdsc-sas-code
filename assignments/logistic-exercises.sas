/* Logistic Exercises
 * Michael Suggs <mjs3607@uncw.edu>
 * 16 April 2021
 */

/* Exercise 3 */
title "BP Status by Age, Weight, and Sex -- Cumulative-Logit";
proc logistic data=sashelp.heart;
	class Sex;
	model bp_status = AgeAtStart Weight Sex
		/ link=logit;
	ods select ParameterEstimates
			   OddsRatios;
run;

title "BP Status by Age, Weight, and Sex -- Adjacent-Logit";
proc logistic data=sashelp.heart;
	class Sex;
	model bp_status = AgeAtStart Weight Sex
		/ link=alogit;
	ods select ParameterEstimates
			   OddsRatios;
run;

/* title "BP -- No Proportional Odds"; */
/* proc logistic data=sashelp.heart; */
/* 	class Sex; */
/* 	model bp_status = AgeAtStart Weight Sex */
/* 		/ link=logit unequalslopes; */
/* 	ods select FitStatistics; */
/* run; */

title "BP Status -- Proportional Odds for Weight and Sex";
proc logistic data=sashelp.heart;
	class Sex;
	model bp_status = AgeAtStart Weight Sex
		/ link=logit unequalslopes=AgeAtStart;
	ods select ParameterEstimates
			   OddsRatios;
run;

proc format;
	value price
		low-<200000='$200K or less'
		200000-<300000='$200K to 300K'
		300000-high='Above 300K'
	;
run;

data real_estate;
	set sasprg.real_estate;
	sq_ftXbedrm = sq_ft * bedrm;
run;

title "Real Estate Pricing -- GLM";
proc glm data=sasprg.real_estate;
	class price;
	model price = sq_ft bedrm sq_ft*bedrm / solution;
	format price price.;
	ods select ParameterEstimates;
run;

title "Real Estate Pricing -- Reg";
proc reg data=real_estate;
	model price = sq_ft bedrm sq_ftXbedrm;
	format price price.;
	ods select ParameterEstimates;
run;

title "Real Estate Pricing -- Logistic";
proc logistic data=sasprg.real_estate;
	model price = sq_ft bedrm sq_ft*bedrm
		/ link=logit;
	format price price.;
	ods select ParameterEstimates;
run;
