/***Ex 1**/
proc sql;
 select stock, date, high, low, high-low as difference, high/low-1 as pctDifference format=percent9.2
 from sashelp.stocks
 where year(date) eq 2005 /**date between '01JAN2005'd and '31DEC2005'd***/
 order by stock, date
 ;
 select stock, date, high, low, high-low as difference, calculated difference/low as pctDifference format=percent9.2
 from sashelp.stocks
 where year(date) eq 2005
 order by stock, date
 ;
quit;

/***Ex 2**/
proc sql;
 select stock, date, high, low, high-low as difference, high/low-1 as pctDifference format=percent9.2
 from sashelp.stocks
 where year(date) eq 2005 and (calculated difference ge 5 or calculated pctDifference ge .10)
 order by stock, date
 ;
quit;

/***Ex 3**/
proc sql;
 select stock, mean(high) as HighMean format=dollar12.2, avg(low) format=dollar12.2 as LowMean
 from sashelp.stocks
 group by stock
 ;
quit;

/***Ex 4**/
proc sql;
 select stock, mean(high) as HighMean format=dollar12.2, avg(low) format=dollar12.2 as LowMean,
    calculated HighMean - calculated LowMean as difference format=dollar12.2
 from sashelp.stocks
 group by stock
 ;
quit;

/***Ex 5**/
proc sql;
 select stock, 
        year(date) as year, 
        mean(high) as HighMean format=dollar12.2, 
        avg(low) format=dollar12.2 as LowMean,
        calculated HighMean - calculated LowMean as difference format=dollar12.2
 from sashelp.stocks
 where calculated year between 2000 and 2005
 group by stock, year
 having difference ge 10
 order by stock, year desc
 ;
quit;

proc sql;
 select stock, 
        year(date) as year, 
        mean(high) as HighMean format=dollar12.2, 
        avg(low) format=dollar12.2 as LowMean,
        calculated HighMean - calculated LowMean as difference format=dollar12.2
 from sashelp.stocks
 where calculated year between 2000 and 2005 and calculated difference ge 10
                          /***values of summary functions can only be conditioned on
                            in HAVING***/
 group by stock, year
 order by stock, year desc
 ;
quit;


