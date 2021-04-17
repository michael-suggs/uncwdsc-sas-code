data try;
 Input Age 2. Weight 3. Height 3.;
 input age 1-2 weight 3-5 height 6-8;
datalines;
16 110 601
;
run;

data try2;
*input Name $9. +1 Latitude 7. Longitude 7.; 
input @1 Name $9. @11 Latitude 7. @18 Longitude 7.; 
datalines;
Kabul     +034.53+069.17
Tirana    +041.33+019.82
Algiers   +036.75+003.04
Pago Pago -014.28-170.70 
;
run;

data try3;
 value='LOS    Alam9s,   NM';
 fix=tranwrd(compbl(value),'9','o');
 check=substr(fix,4,3);
 check2=scan(fix,2,',');
 check3=scan(fix,2);
 output;
run;


data try4;
 value='LOS    Alam9s,   NM';
 fix1=tranwrd(compbl(propcase(scan(value,1,','))),'9','o');
 fix=catx(', ',fix1,scan(upcase(value),2,','));
 output;
run;