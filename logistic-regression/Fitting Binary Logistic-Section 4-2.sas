proc format;
 value price
 low-40000='$40K or Less'
 40000<-high='More than $40K'
 ;
run;

proc logistic data=sashelp.cars;
 model msrp = horsepower length / link=logit;
 /**response in logistic is categorical...***/
 format msrp price.;
 /**...so it respects formats just like a class/table 
   statement, or group...***/
run;
/**model $40k or less is the "success"

p=P(success)-> log(p/(1-p))=x*beta***/

/***for a one-unit increase in HP (length fixed),
  odds of car costing 40K or less is 3.8% lower...
  or the odds of the car costing more than 40K increases
   by 4%***/

proc genmod data=sashelp.cars;
 model msrp = horsepower length / dist=binomial link=logit;
 /**response is categorical when I choose a distribution for
    categories...***/
 format msrp price.;
 /**...when you do that it respects formats just like a class/table 
   statement, or group...***/
run;


proc logistic data=sashelp.cars;
 class origin;
 model msrp = origin horsepower;
 format msrp price.;
 *ods select ParameterEstimates;
run;

proc genmod data=sashelp.cars;
 class origin;
 model msrp = origin horsepower / dist=binomial link=logit;
 format msrp price.;
 ods select ParameterEstimates;
run;
/**when you use a categorical predictor, logistic
 uses effects model parameterization, genmod uses
  reference (GLM) parameterization***/

proc logistic data=sashelp.cars;
 class origin / param=glm;
 model msrp = origin horsepower;
 format msrp price.;
 *ods select ParameterEstimates;
run;


proc logistic data=sashelp.cars;
 class origin;
 model msrp = origin|horsepower;
 format msrp price.;
 *ods select ParameterEstimates;
run;

proc standard data=sashelp.cars out=cars mean=0;
 var horsepower;
run;

proc logistic data=cars;
 class origin;
 model msrp = origin|horsepower;
 format msrp price.;
 *ods select ParameterEstimates;
run;


proc logistic data=cars;
 class origin / param=glm;
 model msrp = origin origin*horsepower / noint;
 format msrp price.;
 *ods select ParameterEstimates;
run;


