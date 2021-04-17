filename RawData ('C:\Users\blumj\Documents\Book Files\Data\Raw Data Sets');

data work.Dirty2005basic;
 infile RawData('IPUMS2005Dirtied.dat') dlm='09'x dsd;
 input Split:$40. CityPop : comma. Metro CountyFips Ownership : $50.
  MortgageStatus : $50. HHIncome : comma. HomeValue : comma.
  City : $50. MortgagePayment : comma.;

  *test=anyalpha(Split);/***ANYALPHA finds the first letter in a string 
     (returns the position of it, 0 if none are found)**/
  serial=input(substr(split,1,anyalpha(Split)-1),best.);
  state=substr(split,anyalpha(Split));
   /***second argument is where the first letter was found,
       no third because I want the rest of the string***/
  
 format hhIncome homeValue mortgagePayment dollar16.;
 drop split;
run;