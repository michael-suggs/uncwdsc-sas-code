/***
Ho: mu = 200 (mu <= 200)
Ha: mu > 200
***/

proc ttest data=sashelp.heart h0=200;
 var cholesterol;
run;

/***95% CI has mean between 226.2 and 228.7 or 227.4 +/- 1.2

p-value is quite low <.0001/2, so there is substantial evidence
 that the mean is greater than 200.
 
The confidence interval agrees, and gives us some idea of
 how much greater than 200 we think it is. ***/
 
/***create groupings of higher than 200 and not for cholesterol***/ 
proc format;
 value chol
   low-200 = 'Good'
   200<-high = 'Bad'
   ;
run;

proc freq data=sashelp.heart order=formatted;
 table cholesterol / binomial(h0=0.65) alpha=0.01;
 /**Ho: p = 0.65
    Ha: p > 0.65***/
 format cholesterol chol.;
run;

/***Test says (p value < 0.0001) that the sample provides significant
 evidence that the proportion of people with bad cholesterol is greater
  than 65%.
  
  The interval agrees, estimating the proportion to be between 67.5 and 70.8%
  **/
