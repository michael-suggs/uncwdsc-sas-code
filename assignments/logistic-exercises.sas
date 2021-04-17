/* Logistic Exercises
 * Michael Suggs <mjs3607@uncw.edu>
 * 16 April 2021
 */

/* Exercise 3 */
proc logistic data=sashelp.heart;
	class Sex;
	model bp_status = AgeAtStart Weight Sex
		/ link=logit;
	ods select ResponseProfile
			   FitStatistics
			   CumulativeModelTest
			   ParameterEstimates
			   OddsRatios;
run;

proc logistic data=sashelp.heart;
	class Sex;
	model bp_status = AgeAtStart Weight Sex
		/ link=alogit;
	ods select ResponseProfile
			   FitStatistics
			   ParameterEstimates
			   OddsRatios;
run;

proc logistic data=sashelp.heart;
	class Sex;
	model bp_status = AgeAtStart Weight Sex
		/ link=logit unequalslopes;
	ods select FitStatistics;
run;

proc logistic data=sashelp.heart;
	class Sex;
	model bp_status = AgeAtStart Weight Sex
		/ link=logit unequalslopes=AgeAtStart;
	ods select ResponseProfile
			   FitStatistics
			   ParameterEstimates
			   OddsRatios;
run;