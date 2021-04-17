filename BRawDat 'C:\Users\blumj\Documents\Book Files\Data\Business Case Study\Raw Data';

data NonColaNorth;
 infile BRawDat('Non-Cola--NC,SC,GA.dat') firstobs=7;
 input StateFIPS 1-2 CountyFIPS 3-5 ProductName$ 6-25 Size$ 26-35
   UnitSize 36-38 @39 Date mmddyy10. @49 UnitsSold comma7.;
   /**to read with an informat for fixed position use
    
     @startColumn VarName informatW. 
     
     ***/
   
   /**Clean up some casing variations***/
   ProductName=propcase(ProductName);
   Size=propcase(size);
   
   /**Make some substitutions***/
   Size=tranwrd(size,'Liter','L');
   Size=tranwrd(size,'Ounces','Oz');  
   
   /***We should be able to match the size units to the SAS
    data given on colas in the chapter 2 part,
     it should be done as a composition of these types of functions
     ***/
   
   /***The informat is only a reading instruction...
    if you want a different display format, provide one***/
   format date worddate.;
run;

proc freq data=NonColaNorth;
 table productName Size;
run;
