proc sql;
 create table ColaSummarySouth as
 select StateFIPS, ProductName,  
        sum(UnitsSold) as TotalSold format=comma12.
 from Business.ColaNCSCGA
 where ProductName in ('Cola','Diet Cola') and Size eq '12 oz'
       and UnitSize eq 1
 group by StateFIPS, ProductName
 ;
 create table ColaSummaryNorth as
 select StateFIPS, 
        case scan(code,2,'-')
          when '1' then 'Cola'
          when '2' then 'Diet Cola'
        end
          as ProductName,  
        sum(UnitsSold) as TotalSold format=comma12.
 from Business.ColaDCMDVA
 where scan(code,2,'-') in ('1','2') and scan(code,3,'-') eq '12 oz'
       and scan(code,4,'-') eq '1'
 group by StateFIPS, ProductName
 ;
quit;

proc sql;
 select *
 from ColaSummarySouth
 union /***UNION goes between queries***/
 select *
 from ColaSummaryNorth
 ;
 select 'South' as Region, *
 from ColaSummarySouth
 union 
 select 'North' as Region, *
 from ColaSummaryNorth
 ;
quit;

proc sql;
 select *
 from ColaSummarySouth
 union 
 select *
 from ColaSummarySouth
 ;/***set operators remove duplicates by default***/
 select *
 from ColaSummarySouth
 union all
 select *
 from ColaSummarySouth
 ; /***all leaves duplicates in***/
quit;

proc sql;
 create table ColaSummarySouth as
 select ProductName, StateFIPS,   
        sum(UnitsSold) as TotalSold format=comma12.
 from Business.ColaNCSCGA
 where ProductName in ('Cola','Diet Cola') and Size eq '12 oz'
       and UnitSize eq 1
 group by StateFIPS, ProductName
 ;
 create table ColaSummaryNorth as
 select StateFIPS, 
        case scan(code,2,'-')
          when '1' then 'Cola'
          when '2' then 'Diet Cola'
        end
          as ProductName,  
        sum(UnitsSold) as TotalSold format=comma12.
 from Business.ColaDCMDVA
 where scan(code,2,'-') in ('1','2') and scan(code,3,'-') eq '12 oz'
       and scan(code,4,'-') eq '1'
 group by StateFIPS, ProductName
 ;
quit;

proc sql feedback;
 select *
 from ColaSummarySouth
 union 
 select *
 from ColaSummaryNorth
 ;
quit;

proc sql;
 create table ColaSummarySouth as
 select StateFIPS, ProductName,   
        count(UnitsSold) as Number,
        sum(UnitsSold) as TotalSold format=comma12.
 from Business.ColaNCSCGA
 where ProductName in ('Cola','Diet Cola') and Size eq '12 oz'
       and UnitSize eq 1
 group by StateFIPS, ProductName
 ;
 create table ColaSummaryNorth as
 select StateFIPS, 
        case scan(code,2,'-')
          when '1' then 'Cola'
          when '2' then 'Diet Cola'
        end
          as ProductName,  
        sum(UnitsSold) as TotalSold format=comma12.,
        count(UnitsSold) as Number
 from Business.ColaDCMDVA
 where scan(code,2,'-') in ('1','2') and scan(code,3,'-') eq '12 oz'
       and scan(code,4,'-') eq '1'
 group by StateFIPS, ProductName
 ;
quit;


proc sql feedback;
 select *
 from ColaSummarySouth
 union 
 select *
 from ColaSummaryNorth
 ;
quit;/***column alignment for set operators is
 positional...***/


proc sql feedback;
 select *
 from ColaSummarySouth
 union corresponding /**corresponding says align on names***/
 select *
 from ColaSummaryNorth
 ;
quit;

proc sql;
 create table ColaSummarySouth as
 select StateFIPS, ProductName,   
        count(UnitsSold) as Count,
        sum(UnitsSold) as TotalSold format=comma12.
 from Business.ColaNCSCGA
 where ProductName in ('Cola','Diet Cola') and Size eq '12 oz'
       and UnitSize eq 1
 group by StateFIPS, ProductName
 ;
 create table ColaSummaryNorth as
 select StateFIPS, 
        case scan(code,2,'-')
          when '1' then 'Cola'
          when '2' then 'Diet Cola'
        end
          as ProductName,  
        sum(UnitsSold) as TotSold format=comma12.,
        count(UnitsSold) as Number
 from Business.ColaDCMDVA
 where scan(code,2,'-') in ('1','2') and scan(code,3,'-') eq '12 oz'
       and scan(code,4,'-') eq '1'
 group by StateFIPS, ProductName
 ;
quit;

proc sql feedback;
 select *
 from ColaSummarySouth
 union corresponding /**corresponding says align on names--but
    only keeps ones with matching names***/
 select *
 from ColaSummaryNorth
 ;
 select StateFIPS, ProductName, Count, TotalSold
 from ColaSummarySouth
 union  /**You can always pick your columns and their alignment***/
 select StateFIPS, ProductName, Number, TotSold
 from ColaSummaryNorth
 ;
quit;

proc sql;
 create table ColaSummarySouth as
 select StateFIPS, ProductName,  
        sum(UnitsSold) as TotalSold format=comma12.
 from Business.ColaNCSCGA
 where ProductName in ('Cola','Diet Cola') and Size eq '12 oz'
       and UnitSize eq 1
 group by StateFIPS, ProductName
 ;
 create table ColaSummaryNorth as
 select StateFIPS, 
        case scan(code,2,'-')
          when '1' then 'Cola'
          when '2' then 'Diet Cola'
        end
          as ProductName,  
        sum(UnitsSold) as TotalSold format=comma12.
 from Business.ColaDCMDVA
 where scan(code,2,'-') in ('1','2') and scan(code,3,'-') eq '12 oz'
       and scan(code,4,'-') eq '1'
 group by StateFIPS, ProductName
 ;
 create table ColaSummaryAll as
 select *
 from ColaSummarySouth
 union 
 select *
 from ColaSummaryNorth
 ;
quit;

proc sql;
 select * 
 from ColaSummaryAll
 intersect  /**rows (on chosen variables) that are the same in both tables***/
 select *
 from ColaSummarySouth
 ;
 select * 
 from ColaSummarySouth
 intersect  /**rows (on chosen variables) that are the same in both tables***/
 select *
 from ColaSummaryAll 
 ;
 select * 
 from ColaSummaryNorth
 intersect  /**rows (on chosen variables) that are the same in both tables***/
 select *
 from ColaSummarySouth
 ;
quit;

proc sql;
 select * 
 from ColaSummaryAll
 except  /**rows (on chosen variables) that are in the first table
          and NOT in the second***/
 select *
 from ColaSummarySouth
 ;
 select * 
 from ColaSummarySouth 
 except  /**rows (on chosen variables) that are in the first table
          and NOT in the second***/
 select *
 from ColaSummaryAll
 ;
quit;

proc sql;
 create table Population as
 select StateFIPS, StateName, 
        sum(PopEstimate2016) as Population format=comma14.
 from Business.Counties
 group by StateFIPS, StateName
 ;
quit;

proc sql;
 select * 
 from ColaSummaryNorth join Population
  on ColaSummaryNorth.StateFIPS eq Population.StateFIPS
 union
 select * 
 from ColaSummarySouth join Population
  on ColaSummarySouth.StateFIPS eq Population.StateFIPS
  ;
quit;
