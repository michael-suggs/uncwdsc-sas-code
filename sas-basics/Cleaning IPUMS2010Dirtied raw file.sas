filename RawData 'C:\Users\blumj\Documents\Book Files\Data\Raw Data Sets';

data IPUMS2010Direct;
 infile RawData('ipums2010dirtied.dat') dlm='09'x dsd;
 input serial citypop:comma. metro countyfips ownership$ mortgagestatus:$45. hhincome:comma.
     homevalue:comma. city:$40. state:$25. mortgagepayment:comma.;
run;

proc freq data=ipums2010direct;
 table ownership city mortgageStatus state;
run;

data IPUMS2010Fix1;
 infile RawData('ipums2010dirtied.dat') dlm='09'x dsd;
 input serial citypop:comma. metro countyfips ownership$ mortgagestatus:$45. hhincome:comma.
     homevalue:comma. city:$40. state:$25. mortgagepaymentC:$20.;
     
 MortgagePayment=abs(input(tranwrd(mortgagePaymentC,'l','1'),comma20.));
 ownership=propcase(ownership);
 city = tranwrd(city,'-',', ');
 mortgageStatus = tranwrd(tranwrd(mortgageStatus,':','/'),'N.A.','N/A');
 state=propcase(state);
run;

proc compare base=bookdata.ipums2010basic compare=IPUMS2010Fix1 outbase outcompare outdif outnoeq out=diffs;
 var State;
run;


data IPUMS2010Fix2;
 infile RawData('ipums2010dirtied.dat') dlm='09'x dsd;
 input serial citypop:comma. metro countyfips ownership$ mortgagestatus:$45. hhincome:comma.
     homevalue:comma. city:$40. state:$25. mortgagepaymentC:$20.;
     
 MortgagePayment=abs(input(tranwrd(mortgagePaymentC,'l','1'),comma20.));
 ownership=propcase(ownership);
 /***These work...***/

 state=propcase(state);
 if index(state,'District') ne 0 then state=tranwrd(state,'Of','of');
 /**index searchs for the string you provide, and gives the
  starting position of its first occurance--0 if it isn't found**/

 mortgageStatus = tranwrd(tranwrd(mortgageStatus,':','/'),'N.A.','N/A');
 if mortgageStatus eq 'Yes, mortgaged/ deed of trust or similar' 
   then mortgageStatus = catx(' ',mortgageStatus,'debt');
   /***catx allows for a delimiter, which is the easiest way to get the word 
     debt in with a space***/
   
 if substr(reverse(strip(city)),3,1) eq '-' then do;  
  /**reverse() reverses character order in the string, but it includes blanks,
    strip removes leading and trailing blanks...
    substring (substr) reads characters from a string: substr(string,start,number-of-characters)***/
   
    postal=reverse(substr(reverse(strip(city)),1,2));
     /**when we reverse the string, without blanks, postal is first two characters, reversed***/
    
    CityName=reverse(substr(reverse(strip(city)),4));
    /**City name is the rest after the dash**/
   
    city=catx(', ',CityName,postal);
 end;
 drop postal CityName;
run;

proc compare base=bookdata.ipums2010basic compare=IPUMS2010Fix2 outbase outcompare outdif outnoeq out=diffs;
 *var City;
run;
