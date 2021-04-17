data heart;
 set sashelp.heart;
 if sex='Female' then female=1;
  else if sex='Male' then female=0;
   else female=.;
run;

proc glm data=heart;
 model female = weight|height;
 output out=results predicted=pFemale;
run;

proc sgplot data=results;
 scatter x=female y=pFemale / jitter;
run;

proc sgplot data=results;
 scatter x=weight y=height / colorresponse=pFemale 
        markerattrs=(symbol=circlefilled);
run;

data classify;
 set results;
 if pFemale ge 0.5 then predict='Female';
  else predict='Male';
run;

proc freq data=classify;
 table sex*predict/nopercent nocol;
run;

/***For this type of response, a binomial
 distribution is a better probability model
 than a normal--we consider each individual
 outcome to be a single binomial trial:
  Binomial(1,p) or Bernoulli(p)**/
 
 /***For binomial/Bernoulli the natural 
  link function is the logit--log(p/(1-p))
  
  so p(x)=e^xb/(1+e^xb)
   1-p(x)=1/(1+e^xb)
   ***/
  
proc logistic data=sashelp.heart;
 model sex = weight height;
run;

proc genmod data=sashelp.heart;
  model sex = weight|height / dist=binomial link=logit;
run;
 
 /***Since log(p/1-p)=xb,
  p/(1-p)=e^xb
  
  p/(1-p) is the odds of success...*/
 
 /**so we interpret paramters as changes in odds, 
  but as a ratio e^[b(x+1)+k]/e^[bx+k]-=e^b**/