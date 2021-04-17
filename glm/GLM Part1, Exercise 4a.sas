data RealEstate;
 set statdata.realestate;
 
 where quality ne .; 
  /**may want to be careful about missings**/
 
 high=0;medium=0;low=0; 
 /***make three dummy variables for quality levels
 initialize each to zero***/
 select(quality);
  when(1) high=1;
  when(2) medium=1;
  when(3) low=1;
 end;
run;

ods graphics off;
proc reg data=realestate;
 model price = quality;
run;

/** price = 633893 - 163010*quality (1,2,3)
  price drops, on average, by $163,010 for
  each level of quality (each step down the
  quality scale)**/

ods graphics off; 
proc reg data=realestate;
 model price = high medium low / noint;
 /***put in each dummy variable, 
   NOINT option removes the intercept***/
 ods select parameterestimates;
run;

/***Equation:
 price = 543,611*high + 273,766*medium + 175,018*low
 
 Average home prices are: $543,611 for high quality,
  $273,766 for medium, and $175,018 for low 
  
  This parameterization is referred to as a means model***/
proc means data=realestate;
 class quality;
 var price;
run;


ods graphics off; 
proc reg data=realestate;
 model price = high medium low ;
 /***three dummy variables, and their parameters,
   with the intercept are too many....
   can put a restriction on the parameters ***/
 restrict high + medium + low = 0;
  /**parameters for the dummy variables must add to zero**/
 ods select parameterestimates;
run;

/**Estimate:
 price = $330,798 + $212,812*high -$57,032*medium
          -$155,780*low
          
   330798+212812 = 543,610 - mean for high
   330798-57032 = 273,766 - mean for medium
   330798-155789 = 175019 - mean for low
   330798 - overall mean (not necessarily matching
    the mean of the data) 
   
   Effects model--each parameter for a category is
    the "effect" of being in that category
   ***/
  
ods graphics off; 
proc reg data=realestate;
 model price = high medium;
 /**another restriction is to just fix one
   parameter to zero--i.e. remove that dummy
   variable***/
 ods select parameterestimates;
run;

/**Estimate:
  price = 175,018 + 368,592*high + 98,748*medium
  
  175,018 is the mean for low quality (high=0,medium=0)
  175,018 + 368,592 = 543,610, mean for high quality
  175,018 + 98,748 = 273,766, mean for medium
  
  This is called a reference (baseline) category model--
  intercept models that category, other categories 
   are built from that one**/

ods graphics off; 
proc reg data=realestate;
 model price = low medium;
 /**another restriction is to just fix one
   parameter to zero--i.e. remove that dummy
   variable***/
 ods select parameterestimates;
run;

ods graphics off;
proc glm data=statdata.realestate;
 class quality; /***last one is set to zero by default***/
 model price = quality / solution;
 /**GLM doesn't always show the model estimate,
   SOLUTION forces it to***/
 ods select parameterestimates;
run;


ods graphics off;
proc glm data=statdata.realestate;
 class quality; 
 model price = quality / solution noint;
 /**NOINT is available...***/
 ods select parameterestimates;
run;

ods graphics off;
proc glm data=statdata.realestate;
 class quality(ref='1');
 model price = quality / solution;
 /**GLM doesn't always show the model estimate,
   SOLUTION forces it to***/
 ods select parameterestimates;
run;

proc logistic data=statdata.realestate;
 class quality;
 model ac = quality;
run;

proc genmod data=statdata.realestate;
 class quality;
 model ac = quality / link=logit;
run;

proc glm data=statdata.realestate;
 class quality(ref='1');
 model price = quality / solution;
 lsmeans quality;
 ods select parameterestimates lsmeans;
run;
