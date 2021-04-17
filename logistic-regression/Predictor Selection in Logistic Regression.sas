proc logistic data=statdata.realestate;
 model quality = price--year lot highway / selection=stepwise slentry=0.10 slstay=0.10;
run;

proc logistic data=statdata.realestate;
 model quality = price--year lot highway / selection=stepwise unequalslopes=price;
run;

proc logistic data=statdata.realestate;
 model quality = price sq_ft bedrooms bathrooms ac year
  / unequalslopes=price;
run;

proc logistic data=statdata.realestate;
 model quality = price sq_ft bedrooms bathrooms ac year
  / unequalslopes;
run;

proc logistic data=statdata.realestate;
 model quality = price--year lot highway / selection=stepwise unequalslopes;
run;
/***You have forward, backward, and stepwise methods available in logistic,
 but they have to applied to specific proportional odds assumptions when
 working with ordinal responses***/

proc hpgenselect data=statdata.realestate; /***HP->High Performance GEN-Generalized Linear Models***/
 model quality = price--year lot highway / dist=mult link=logit;
 selection selection=stepwise;
run;/***Proportional odds (and cumulative link) only for ordinal responses***/

proc hpgenselect data=statdata.realestate; 
 model quality = price--year lot highway / dist=mult link=logit;
 selection selection=stepwise(choose=aic);
run;

proc logistic data=sashelp.cars;
 class drivetrain;
 model origin = drivetrain--length / selection=stepwise link=glogit;
run;

proc hpgenselect data=sashelp.cars;
 class drivetrain;
 model origin = drivetrain--length / dist=mult link=glogit;
 selection selection=stepwise;
run;