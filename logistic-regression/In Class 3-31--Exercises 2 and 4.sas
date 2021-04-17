/***Exercise 2***/
proc format;
 value poverty
  10-high = '10% or More'
  other = 'Below 10%'
  ;
run;

proc logistic data=statdata.cdi;
 class region / param=glm;
 model poverty = ba_bs over65 region;
 format poverty poverty.;
run;

/**e^(-0.1181)=0.889 or e^(0.1181)=1.125

 For a 1% increase in BA/BS rate, others fixed, odds of
  poverty level being 10% or more decreases by 11.1%
  
  or odds of poverty level being below 10% increases by
   12.5%
   
   
 e^(-0.0719)=0.931 or e^(0.0719)=1.075
 For a 1% increase in population over 65, others fixed, odds of
  poverty level being 10% or more decreases by 6.9%
  
  or odds of poverty level being below 10% increases by
   7.5%
   
   e^(-1.0895)=0.336 or reciprocal is 2.97
   
   Odds of poverty level being 10% or more, for fixed BA/BS rate and
   population over 65, 66.4% lower in the northeast vs the west
   
   or odds of poverty level being below 10% are almost three times as
   much in the NE than the W
   
   Region 3 vs 4, south vs west--odds of high poverty level (10% or above)
    is twice as high in the south versus the west
    
    NE vs S has the biggest difference, with e^(.7670-(-1.0895))= 6.4,
     so odds of poverty below 10% is 6 times greater in the NE vs S.
     
     
   ***/
  
proc logistic data=statdata.cdi;
 class region(ref='3') / param=glm;
 model poverty = ba_bs over65 region;
 format poverty poverty.;
run;

/***Exercise 4***/

proc logistic data=statdata.cdi;
 model region = ba_bs inc_per_cap pop18_34 / link=glogit;
run;

/***e^(-0.2174)= 0.805 (or recip 1.243)

 for fixed income per capita and pop between 18 and 34, a 1% increase in BA/BS
  rate corresponds to a 19.5% lower likelihood of a county being in the NE vs W
  
   or 24.3% greater likelihood of a county being in the W vs NE
   
   
   e^(0.1608) = 1.174 

for fixed income per capita and BA/BS rate, a 1% increase in pop between 18 and 34
 corresponds to a  17.4% higher likelihood of a county being in the NC vs W
 
 for fixed income per capita and BA/BS rate, a 1% increase in pop between 18 and 34
 corresponds to a e^(0.1658-0.1608)= 1.005-> 0.5% greater likelihood of a 
 county being in the NE vs NC
 
 ***/


proc logistic data=statdata.cdi descending;
 model region = ba_bs inc_per_cap pop18_34 / link=glogit;
run;
 