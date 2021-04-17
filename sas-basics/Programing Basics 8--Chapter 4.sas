filename RawData 'C:\Users\blumj\Documents\Book Files\Data\Raw Data Sets';

data carfix;
  infile RawData('cars.datfile') dlm='09'x dsd firstobs=2;
  input make:$50. model:$50. type:$35. origin:$8. drivetrain:$10. msrp:comma10. invoice:comma10. 
   enginesize cylinders horsepower mpg_city mpg_highway weight:comma15. wheelbase length;
  if origin in ('Europe','Asia') then do;
    weight=weight*2.2;
    length=length/2.54;
    wheelbase=wheelbase/2.54;
  end;/***Do some unit conversions...***/
  
  model=' '||tranwrd(model,'4DR','4dr');
  /***this bizarre leading space in the SASHELP.CARS data is a nuisance***/
 
  if index(lowcase(make),'mercedes') ne 0 then make='Mercedes-Benz';
  /**Fix many inconsistencies with Mercedes**/
 
  if upcase(make) in ('GMC','MINI','BMW') then make=upcase(make);
   else make=propcase(make);
   /**Get the casing right...most are proper case, but not all**/
  
  if index(type,'Utility') ne 0 or index(type,'Ute') ne 0 then type='SUV';
    /**Find some stuff that will get the SUVs all the same***/
 run;
 
 proc sort data=sashelp.cars out=carbase nodupkey;
  by make model drivetrain;
 run;
 
 proc sort data=carfix;
  by make model drivetrain;
 run;
 /**get them both sorted on some set that works as a primary key**/

 proc compare base=carbase comp=carfix outbase outcomp outdiff outnoeq out=diffs criterion=1;
  /***need the criterion to fix the rounding issues on unit conversions***/
 run;