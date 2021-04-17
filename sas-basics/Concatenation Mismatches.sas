filename RawData  'C:\Users\blumj\Documents\Book Files\Data\Raw Data Sets';
data work.Basic2005;
 infile RawData("IPUMS2005formatted.csv") dsd obs=10;
 input serial : 7. state : $25. city : $50. citypop : comma6.
  metro : 1. countyfips : 3. ownership : $6. MortgageStatus : $50.
  MortgagePayment : dollar12. HHIncome : dollar12. HomeValue : dollar12.;
  label metro='Metro Category';
  format HomeValue dollar16.2;
run;

data work.Basic2010B;
 infile RawData("IPUMS2010formatted.csv") dsd obs=100;
 input serial : $7. state : $25. city : $60. metro : 1. countyfips : 3.
  citypop : comma6. ownership : $6. MortStat : $50.
  MortPay : dollar12. HomeValue : dollar12. Inc : dollar12.;
  label metro='Metro Status' MortPay='Mortgage Payment';
  format MortPay HomeValue Inc dollar14.;
run;

data work.Basic05And10B;
 set work.basic2005          /***Name mis-matches can be aligned with RENAME= in the SET statement**/
     work.basic2010B(rename=(MortStat=MortgageStatus MortPay=MortgagePayment Inc=HHIncome
        serial=serial2010) in=in2010);
        /***but type mis-matches cannot, so we will force a mismatch on the names...**/
 if in2010 then serial=input(serial2010,best.);
       /***and use the IN= variable to help decide how to fix the type mismatch...***/
 drop serial2010;
       /***and drop the column we intentionally mis-aligned***/
run;

proc contents data=basic05And10B;
run;/***check the other mis-aligned attributes to see how they were resolved...***/