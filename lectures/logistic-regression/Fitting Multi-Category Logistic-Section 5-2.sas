proc logistic data=statdata.senic;
 model region = risk stay / link=glogit;
 /***glogit is baseline/generalized, 
     which is used for nominal responses***/
run;

/***For a unit increase in infection risk, stay fixed,
 the odds ratio for region 1 (NE) vs 4 (W) is 0.417->
 For a unit increase in risk (stay fixed) the likelihood
  of being from the northeast is 58.3% less than being
  from the west.***/
 
 
 /***e^(2.1238 - 1.6088) = 1.674 -> for a one day increase
  in average length of stay (risk fixed) a hospital is 67.4% 
  more likely to be from NE vs NC***/
 
proc format;
 value price
 low-30000='$30K or Less'
 30000-50000='Over $30K and less than $50K'
 50000-high='Over $50K'
 ;/***three price categories instead of two***/
run;

proc logistic data=sashelp.cars;
 model msrp = horsepower length / link=logit;
 format msrp price.;
run;
/**two models, one for 30K or less vs over...
              one for 50k or less (30K or less + 30 to 50)
               vs over***/

/***For horsepower the parameter is -0.0434--
 e^(-0.0434)= 0.958
  
  for a one unit increase in HP (lenght fixed) the odds of being
   lower in price is 4.2% less--either for 30K or less vs over
      or for 50k or less vs over**/
     

proc logistic data=sashelp.cars;
 class origin;
 model msrp =origin horsepower length / link=alogit;
  /***alogit is adjacent-categories logistic...***/
 format msrp price.;
run;

proc format;
 value $wtCat
 'Underweight'='1. Underweight'
 'Normal'='2. Normal'
 'Overweight'='3. Overweight'
 ;
run;

proc logistic data=sashelp.heart;
 model weight_status = cholesterol diastolic ageatstart / link=logit;
 format weight_status $wtCat.;
run;


proc logistic data=sashelp.heart;
 model weight_status = cholesterol diastolic ageatstart / link=logit unequalslopes;
  /***unequalslopes removes the proportional odds assumption on all
    predictors***/
 format weight_status $wtCat.;
 ods select fitstatistics;
 title 'No Proportional Odds';
run;

proc logistic data=sashelp.heart;
 model weight_status = cholesterol diastolic ageatstart / link=logit unequalslopes=(cholesterol diastolic);
  /***unequalslopes removes the proportional odds assumption on all
    predictors***/
 format weight_status $wtCat.;
 ods select fitstatistics;
 title 'Proportional Odds on Age';
run;

proc logistic data=sashelp.heart;
 model weight_status = cholesterol diastolic ageatstart / link=logit unequalslopes=(cholesterol ageatstart);
  /***unequalslopes removes the proportional odds assumption on all
    predictors***/
 format weight_status $wtCat.;
 ods select fitstatistics;
 title 'Proportional Odds on Diastolic';
run;

proc logistic data=sashelp.heart;
 model weight_status = cholesterol diastolic ageatstart / link=logit unequalslopes=(diastolic ageatstart);
  /***unequalslopes removes the proportional odds assumption on all
    predictors***/
 format weight_status $wtCat.;
 ods select fitstatistics;
 title 'Proportional Odds on Cholesterol';
run;

data _null_;
 one=1-probchi(6858.595-6855.155,1); /***probchi(value,df) is probability of being less than the value***/
 put one;
 two=1-probchi(6855.613-6855.155,1);
 put two;
 three=1-probchi(6860.492-6855.155,1);
 put three;
run;


proc logistic data=sashelp.heart;
 model weight_status = cholesterol diastolic ageatstart / link=logit unequalslopes=(ageatstart);
  /***unequalslopes removes the proportional odds assumption on all
    predictors***/
 format weight_status $wtCat.;
 ods select fitstatistics;
 title 'Proportional Odds on Diastolic and Cholesterol';
run;


proc logistic data=sashelp.heart;
 model weight_status = cholesterol diastolic ageatstart / link=logit unequalslopes=(cholesterol);
  /***unequalslopes removes the proportional odds assumption on all
    predictors***/
 format weight_status $wtCat.;
 ods select fitstatistics;
 title 'Proportional Odds on Diastolic and Age';
run;

data _null_;
 one=1-probchi(6861.246-6855.155,2); /***probchi(value,df) is probability of being less than the value***/
 put one;
 two=1-probchi(6858.683-6855.155,2);
 put two;
run;

/***This is my model...***/

proc logistic data=sashelp.heart;
 model weight_status = cholesterol diastolic ageatstart / link=logit unequalslopes=(cholesterol);
  /***unequalslopes removes the proportional odds assumption on all
    predictors***/
 format weight_status $wtCat.;
 *ods select fitstatistics;
 title 'Proportional Odds on Diastolic and Age';
run;
