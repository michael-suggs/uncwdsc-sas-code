ods graphics off;
proc glm data=statdata.realestate;
 class quality;
 model price = quality sq_ft / solution;
 ods select ParameterEstimates;
run;
/***model:

price = 7355 + 206794*q1 + 37921*q2 + 98.44*sqFt

**/
 
ods graphics off;
proc glm data=statdata.realestate;
 class quality;
 model price = quality sq_ft / noint solution;
 ods select ParameterEstimates;
run;
 
/***model:

price = 214148*q1 + 45276*q2 + 7355*q3 + 98.44*sqFt

Either one of these can be thought of as a set of
 parallel lines--three different intercepts, one
  for each category, and common slope against
  square footage
  
  Price increases, on average, by $98.44 per square
  foot for any quality level
**/

ods graphics off;
proc glm data=statdata.realestate;
 class quality;
 model price = quality|sq_ft/ solution;
 /** A|B is A, B, and A*B
     A|B|C is A, B, A*B, C, A*C, B*C, A*B*C
     
     A|B|C|D @ 2 is A B C D A*B A*C A*D B*C B*C C*D ***/
 ods select ParameterEstimates;
run;

/***Model:

price = 48418 + 289323*q1 - 44506*q2
       +74.33*sqFt - 12.82*q1*sqFt + 41.93*q2*sqFt
       
 for quality is 3 -> 48418 +74.33*sqFt
 for quality 2 -> (48418-44506) + (74.33 + 41.93)*sqFt
                   3912 + 116.26*sqFt
 for quality 3 -> (48418 + 289323) + (74.33 - 12.82)*sqFt
                   300K+ + 61.51*sqFt
                   
   This is three different lines--different intercepts
    and different slopes. For three groups, that only
    requires 6 parameters
    ***/
   
ods graphics off;
proc glm data=statdata.realestate;
 class quality;
 model price = quality quality*sq_ft / noint solution;
 ods select ParameterEstimates;
run;