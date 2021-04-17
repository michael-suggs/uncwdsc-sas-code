proc format;
 value priceCat
 low-200000='Up to $200K'
 200000<-300000='Over $200K, Up to $300K'
 300000<-high='Above $300K'
 ;
run;

proc logistic data=statdata.realestate;
 model price = sq_ft|bedrooms;
 format price priceCat.;
 ods select fitstatistics;
run;

proc logistic data=statdata.realestate;
 model price = sq_ft|bedrooms / unequalslopes;
 format price priceCat.;
 ods select fitstatistics;
run;

proc logistic data=statdata.realestate;
 model price = sq_ft|bedrooms / unequalslopes=sq_ft;
 format price priceCat.;
 ods select fitstatistics;
run;

proc logistic data=statdata.realestate;
 model price = sq_ft|bedrooms / unequalslopes=bedrooms;
 format price priceCat.;
 ods select fitstatistics;
run;

proc logistic data=statdata.realestate;
 model price = sq_ft|bedrooms / unequalslopes=sq_ft*bedrooms;
 format price priceCat.;
 ods select fitstatistics;
run;

proc logistic data=statdata.realestate;
 model price = sq_ft|bedrooms / unequalslopes=(sq_ft sq_ft*bedrooms);
 format price priceCat.;
 ods select fitstatistics;
run;

proc logistic data=statdata.realestate;
 model price = sq_ft|bedrooms / unequalslopes=(bedrooms sq_ft*bedrooms);
 format price priceCat.;
 ods select fitstatistics;
run;

proc logistic data=statdata.realestate;
 model price = sq_ft|bedrooms / unequalslopes=(sq_ft bedrooms);
 format price priceCat.;
 ods select fitstatistics;
run;

/***Full proportional odds, chosen by SBC***/
proc standard data=statdata.realestate mean=0 out=reSTD;
 var sq_ft bedrooms;
run;

proc logistic data=reSTD;
 model price = sq_ft|bedrooms;
 format price priceCat.;
 *ods select fitstatistics;
run;

proc logistic data=reSTD;
 model price = sq_ft|bedrooms / unequalslopes;
 format price priceCat.;
 *ods select fitstatistics;
run;

ods graphics off;
proc glm data=reSTD;
 model price = sq_ft|bedrooms ;
 *ods select fitstatistics;
run;