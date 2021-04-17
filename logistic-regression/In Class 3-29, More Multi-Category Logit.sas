proc format;
 value $CholReOrder
 'Desirable'='1. Desirable'
 'Borderline'='2. Borderline'
 'High'='3. High'
 ;
run;

proc logistic data=sashelp.heart;
 format chol_status $CholReOrder.;
 model chol_status = AgeAtStart Weight / link=logit;
 ods select ResponseProfile FitStatistics CumulativeModelTest
   ParameterEstimates OddsRatios;
run;

Title "No Proportional Odds";
proc logistic data=sashelp.heart;
 format chol_status $CholReOrder.;
 model chol_status = AgeAtStart Weight / link=logit unequalslopes;
 ods select FitStatistics;
run;

Title "Proportional Odds for Weight Only";
proc logistic data=sashelp.heart;
 format chol_status $CholReOrder.;
 model chol_status = AgeAtStart Weight / link=logit unequalslopes=AgeAtStart;
 ods select FitStatistics;
run;

Title "Proportional Odds for Age Only";
proc logistic data=sashelp.heart;
 format chol_status $CholReOrder.;
 model chol_status = AgeAtStart Weight / link=logit unequalslopes=Weight;
 ods select FitStatistics;
run;/***this looks good...other does not**/

data _null_;
 diff1=10617.343-10612.558;
 p_val1=1-probchi(diff1,1);
 put p_val1;
 diff2=10613.035-10612.558;
 p_val2=1-probchi(diff2,1);
 put p_val2;
run;


Title "Proportional Odds for Age Only";
proc logistic data=sashelp.heart descending;
 format chol_status $CholReOrder.;
 model chol_status = AgeAtStart Weight / link=logit unequalslopes=Weight;
 *ods select FitStatistics;
run;

/***For age, e^(-0.0595)=0.942 or  e^(0.0595)=1.061 ->
   For a one-year increase in age (weight fixed) the
    odds of cholesterol status being worse increase by 6.1% ***/
   
/***For a one pound increase in weight, age fixed,
  odds of high cholesterol increase by 0.4%
  and odds of borderline or high (not optimal) increase by 0.6% ***/
 
 
Title "No Proportional Odds";
proc logistic data=sashelp.heart;
 format chol_status $CholReOrder.;
 model chol_status = AgeAtStart Weight / link=logit unequalslopes;
 ods select FitStatistics;
run;

Title "Proportional Odds for Weight Only";
proc logistic data=sashelp.heart;
 format chol_status $CholReOrder.;
 model chol_status = AgeAtStart Weight / link=logit unequalslopes=AgeAtStart;
 ods select FitStatistics;
run;

Title "Proportional Odds for Age Only";
proc logistic data=sashelp.heart;
 format chol_status $CholReOrder.;
 model chol_status = AgeAtStart Weight / link=logit unequalslopes=Weight;
 ods select FitStatistics;
run;
    
Title "Full Proportional Odds";
proc logistic data=sashelp.heart;
 format chol_status $CholReOrder.;
 model chol_status = AgeAtStart Weight / link=logit;
 ods select FitStatistics;
run;

title;
proc genmod data=sashelp.heart;
 format chol_status $CholReOrder.;
 model chol_status = AgeAtStart Weight / dist=multinomial;/***GENMOD only does cumulative,
   uses proportional odds, and it cannot be changed***/
run;



Title "No Proportional Odds";
proc logistic data=sashelp.heart;
 format chol_status $CholReOrder.;
 model chol_status = AgeAtStart Weight / link=alogit unequalslopes;
 ods select FitStatistics;
run;

Title "Proportional Odds for Weight Only";
proc logistic data=sashelp.heart;
 format chol_status $CholReOrder.;
 model chol_status = AgeAtStart Weight / link=alogit unequalslopes=AgeAtStart;
 ods select FitStatistics;
run;

Title "Proportional Odds for Age Only";
proc logistic data=sashelp.heart;
 format chol_status $CholReOrder.;
 model chol_status = AgeAtStart Weight / link=alogit unequalslopes=Weight;
 ods select FitStatistics;
run;/***once again, this is best by testing and AIC...***/
    
Title "Full Proportional Odds";
proc logistic data=sashelp.heart;
 format chol_status $CholReOrder.;
 model chol_status = AgeAtStart Weight / link=alogit;
 ods select FitStatistics;
run;/*** this is best by SBC***/

