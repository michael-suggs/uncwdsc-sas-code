proc sql;
 create view NC as
 select productName, sum(UnitsSold) as TotalSoldNC
 from business.colaNCSCGA
 where stateFIPS eq 37
 group by productName
 ;
 create view SC as
 select productName, sum(UnitsSold) as TotalSoldSC
 from business.colaNCSCGA
 where stateFIPS eq 45
 group by productName
 ;
 create view GA as
 select productName, sum(UnitsSold) as TotalSoldGA
 from business.colaNCSCGA
 where stateFIPS eq 13
 group by productName
 ;
 select nc.productName, totalSoldNC, totalSoldSC, totalSoldGA
 from (NC inner join SC on NC.productName eq SC.productName)
    inner join GA on NC.productName eq GA.productName
 ;
quit;

proc sql;
 select nc.productName, totalSoldNC, totalSoldSC, totalSoldGA
 from NC,SC,GA
 where NC.productName eq SC.productName eq GA.productName
 ;/***you can reference views just like tables in a SQL query***/
quit;

proc sql;
 select nc.productName, totalSoldNC, totalSoldSC, totalSoldGA
 from (NC inner join SC on NC.productName eq SC.productName)
    inner join GA on NC.productName eq GA.productName
 ;
quit;


proc sql;
 select nc.productName, totalSoldNC, totalSoldSC
 from (select productName, sum(UnitsSold) as TotalSoldNC
       from business.colaNCSCGA
       where stateFIPS eq 37
       group by productName
       ) 
       as NC
      inner join 
      (select productName, sum(UnitsSold) as TotalSoldSC
       from business.colaNCSCGA
       where stateFIPS eq 45
       group by productName
       ) 
       as SC
       on NC.productName eq SC.productName
 ;
quit;


proc sql;
 select nc.productName, totalSoldNC, totalSoldSC, totalSoldGA
 from (
       (select productName, sum(UnitsSold) as TotalSoldNC
       from business.colaNCSCGA
       where stateFIPS eq 37
       group by productName
       ) 
       as NC
      inner join 
      (select productName, sum(UnitsSold) as TotalSoldSC
       from business.colaNCSCGA
       where stateFIPS eq 45
       group by productName
       ) 
       as SC
       on NC.productName eq SC.productName
      )
      inner join
      (select productName, sum(UnitsSold) as TotalSoldGA
       from business.colaNCSCGA
       where stateFIPS eq 13
       group by productName
       )
       as GA
       on NC.productName eq GA.productName
 ;
quit;

proc sql;
 select countyFIPS, sum(UnitsSold) as TotalSold
 from business.colaNCSCGA
 where stateFIPS eq 37 and unitsize eq 1 and size eq '12 oz'
       and productName eq 'Cola'
 group by countyFIPS
 ;
 select mean(TotalSold)
 from (select countyFIPS, sum(UnitsSold) as TotalSold
       from business.colaNCSCGA
       where stateFIPS eq 37 and unitsize eq 1 and size eq '12 oz'
        and productName eq 'Cola'
       group by countyFIPS)
  ;
 select countyFIPS, sum(UnitsSold) as TotalSold
 from business.colaNCSCGA
 where stateFIPS eq 37 and unitsize eq 1 and size eq '12 oz'
       and productName eq 'Cola'
 group by countyFIPS
 having TotalSold ge (select mean(TotalSold)
                      from (select countyFIPS, sum(UnitsSold) as TotalSold
                         from business.colaNCSCGA
                         where stateFIPS eq 37 and unitsize eq 1 and size eq '12 oz'
                          and productName eq 'Cola'
                         group by countyFIPS)
                         )
                         /**this is usually a place where an expression
                           of a single value is placed---
                           any query that returns a single column and value
                           will work here***/
 ;
quit;


proc sql;
 select distinct countyFIPS
 from business.colaNCSCGA
 where stateFIPS eq 37 and unitsize eq 1 and size eq '12 oz'
       and productName eq 'Cola' and UnitsSold ge 3500
 ;
quit;

proc sql;
 select CountyName
 from business.counties 
 where CountyFIPS in (select distinct countyFIPS
                      from business.colaNCSCGA
                      where stateFIPS eq 37 and unitsize eq 1 
                           and size eq '12 oz'
                            and productName eq 'Cola' 
                            and UnitsSold ge 3500)
                   and stateFIPS eq 37
  ;
quit;

proc sql;
 select distinct stateFIPS, countyFIPS
 from business.colaNCSCGA
 where unitsize eq 1 and size eq '12 oz'
       and productName eq 'Cola' and UnitsSold ge 3500
 ;
 select distinct catx('-',stateFIPS,countyFIPS)
 from business.colaNCSCGA
 where unitsize eq 1 and size eq '12 oz'
       and productName eq 'Cola' and UnitsSold ge 3500
 ;
quit;

proc sql;
 select StateName, CountyName
 from business.counties 
 where catx('-',stateFIPS,countyFIPS) in 
                     (select distinct catx('-',stateFIPS,countyFIPS)
                      from business.colaNCSCGA
                      where unitsize eq 1 and size eq '12 oz'
                            and productName eq 'Cola' and UnitsSold ge 3500
                      )
  ;
quit;
