ods trace on;
proc logistic data=sashelp.cars;
 model origin = horsepower weight mpg_city msrp length / link=glogit;
 ods exclude ModelInfo Nobs ConvergenceStatus GlobalTests FitStatistics;
run;

proc logistic data=sashelp.cars descending;
 model origin = horsepower weight mpg_city msrp length / link=glogit;
 ods exclude ModelInfo Nobs ConvergenceStatus GlobalTests FitStatistics;
run;

/***
 log(p(Asia)/p(Europe)) = 
  -10.8539 + 0.0269*HP + 0.00017*WT + 0.0927*MPG * 0.000224*Price + 0.0558*Len
   
   p(Asia)/p(Europe)=
   e^(-10.8539 + 0.0269*HP + 0.00017*WT + 0.0927*MPG * 0.000224*Price + 0.0558*Len) 
   
   8.7727-19.6265 = -10.8538
   
   .0089-(-.0180)=0.0269***/
  
proc logistic data=sashelp.cars;
 model origin = horsepower weight mpg_city msrp length / link=glogit;
 ods exclude ModelInfo Nobs ConvergenceStatus GlobalTests FitStatistics;
 ods output oddsratios = or;
run;

proc print data=or;
 format oddsratioest lowercl uppercl 12.10;
run;


proc logistic data=sashelp.heart;
model bp_status = AgeAtStart Weight / link=logit;
ods select ResponseProfile ParameterEstimates OddsRatios;
run;

proc logistic data=sashelp.heart;
model bp_status = AgeAtStart Weight / link=alogit;
ods select ResponseProfile ParameterEstimates OddsRatios;
run;

/**For a unit increase in weight (1 lb), age fixed, the 
 parameter estimate 0.0199 from the cumulative logit model
 can be interpreted as...
  e^0.0199 = 1.020
  
  For a one pound increase in weight, at a fixed age, 
   the odds of having worse blood pressure are 2% higher 
   at any position on the scale
   
  
   For adjacent categories, we have e^0.0157=1.016
   
   For a one pound increase in weight, at a fixed age, 
   the likelihood of being in a worse blood pressure category
   are 1.6% higher at any position on the scale***/
  
proc genmod data=sashelp.heart;
  model bp_status = AgeAtStart Weight /
    dist=multinomial link=cumlogit ;
run;/***cumulative logit is the only multi-category logistic 
 that GENMOD can do***/

  