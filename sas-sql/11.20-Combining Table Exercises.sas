proc format;
 value METRO
   0 = "Not Identifiable"
   1 = "Not in Metro Area"
   2 = "Metro, Inside City"
   3 = "Metro, Outside City"
   4 = "Metro, Unknown Type"
  ;
run;

proc sql;
 create table NCSCVA2005 as
 select state,
        put(metro,metro.) as MetroStatus label='Metro Status',
        mean(HomeValue) as AvgHomeValue label='Average Home Value',
        mean(HHIncome) as MeanIncome label='Mean Household Income'
 from bookdata.ipums2005basic
 where state in ('North Carolina','South Carolina','Virginia') and metro ge 2
       and MortgageStatus contains 'Yes'
 group by state, MetroStatus
 ;
 create table NCSCVA2010 as
 select put(metro,metro.) as MetroStatus label='Metro Status',
        state,
        mean(HomeValue) as AvgHomeValue label='Average Home Value',
        mean(HHIncome) as MeanIncome label='Mean Household Income'
 from bookdata.ipums2010basic
 where state in ('North Carolina','South Carolina','Virginia') and metro ge 2
       and MortgageStatus contains 'Yes'
 group by MetroStatus, state
 ;
 create table NCSCVA2015 as
 select put(metro,metro.) as MetroStatus label='Metro Status',
        state,
        mean(HomeValue) as AvgValue label='Average Home Value',
        mean(HHIncome) as AvgIncome label='Mean Household Income',
        mean(MortgagePayment) as AvgPayment label='Mean Mortgage Payment'
 from bookdata.ipums2015basic
 where state in ('North Carolina','South Carolina','Virginia') and metro ge 2
       and MortgageStatus contains 'Yes'
 group by MetroStatus, state
 ;
 create table FLGA2005 as
 select state,
        put(metro,metro.) as MetroStatus label='Metro Status',
        mean(HomeValue) as AvgHomeValue label='Average Home Value',
        mean(MortgagePayment) as MeanPayment label='Mean Mortgage Payment'
 from bookdata.ipums2005basic
 where state in ('Florida','Georgia') 
       and MortgageStatus contains 'Yes'
 group by state, MetroStatus
 ;
 create table FLGA2010 as
 select state,
        put(metro,metro.) as MetroStatus label='Metro Status',
        mean(HomeValue) as AvgHomeValue label='Average Home Value',
        mean(MortgagePayment) as MeanPayment label='Mean Mortgage Payment'
 from bookdata.ipums2010basic
 where state in ('Florida','Georgia')
       and MortgageStatus contains 'Yes'
 group by state, MetroStatus
 ;
quit;

/***Exercise 1***/

proc sql;
  select five.MetroStatus, five.state, 
         five.AvgHomeValue as HV2005 label='2005 Value' format=dollar12., 
         ten.AvgHomeValue as HV2010 label='2010 Value' format=dollar12.,
         HV2010-HV2005 as Difference format=dollar12.
  from NCSCVA2005 as five inner join NCSCVA2010 as ten
    on five.state eq ten.state 
       and five.MetroStatus eq ten.MetroStatus
  order by MetroStatus, State
   ;
quit;


/***Exercise 2***/
proc sql;
  select five.MetroStatus, five.state, 
         five.AvgHomeValue as HV2005 label='2005 Value' format=dollar12., 
         ten.AvgHomeValue as HV2010 label='2010 Value' format=dollar12.,
         fifteen.AvgValue as HV2015 label='2015 Value' format=dollar12.,
         HV2010/HV2005-1 as Pct10_05 label='% Chg. 2005 to 2010' format=percentn8.1,
         HV2015/HV2005-1 as Pct15_05 label='% Chg. 2005 to 2015' format=percentn8.1
  from (NCSCVA2005 as five inner join NCSCVA2010 as ten
         on five.state eq ten.state 
           and five.MetroStatus eq ten.MetroStatus)
        inner join NCSCVA2015 as fifteen
          on five.state eq fifteen.state 
            and five.MetroStatus eq fifteen.MetroStatus
  order by MetroStatus, State
   ;
quit;


/***Exercise 3***/
proc sql;
  select 2005 as year, state, MetroStatus, 
         AvgHomeValue format=dollar12., MeanIncome format=dollar12.,
         AvgHomeValue/MeanIncome as ValueToIncome format=4.1 label='Value to Income Ratio'
  from NCSCVA2005
  union 
  select 2010 as year, state, MetroStatus, 
         AvgHomeValue format=dollar12., MeanIncome format=dollar12.,
         AvgHomeValue/MeanIncome
  from NCSCVA2010
  order by year, MetroStatus, state /***ordering for the entire union can be done
    with one clause at the end (not part of the actual exercise***/
  ;
quit;

/***Exercise 4***/
proc sql;
  select 2005 as year, state, MetroStatus, 
         AvgHomeValue format=dollar12., MeanIncome format=dollar12.,
         AvgHomeValue/MeanIncome as ValueToIncome format=4.1 label='Value to Income Ratio'
  from NCSCVA2005
  union 
  select 2010 as year, state, MetroStatus, 
         AvgHomeValue format=dollar12., MeanIncome format=dollar12.,
         AvgHomeValue/MeanIncome
  from NCSCVA2010
  union 
  select 2015 as year, state, MetroStatus, 
         AvgValue format=dollar12., AvgIncome format=dollar12.,
         AvgValue/AvgIncome
  from NCSCVA2015  
  order by year, MetroStatus, state /***ordering for the entire union can be done
    with one clause at the end (not part of the actual exercise)***/
  ;
quit;


/***Exercise 5***/
proc sql;
  select five.MetroStatus, five.state, 
         five.AvgHomeValue label='2005 Value' format=dollar12., 
         ten.AvgHomeValue label='2010 Value' format=dollar12.,
         ten.AvgHomeValue-five.AvgHomeValue as Difference format=dollar12.
  from NCSCVA2005 as five inner join NCSCVA2010 as ten
       on five.state eq ten.state 
         and five.MetroStatus eq ten.MetroStatus
  union /**similar thing on the other states...***/
  select five.MetroStatus, five.state, 
         five.AvgHomeValue, 
         ten.AvgHomeValue,
         ten.AvgHomeValue-five.AvgHomeValue
  from FLGA2005 as five inner join FLGA2010 as ten
       on five.state eq ten.state 
         and five.MetroStatus eq ten.MetroStatus
  order by MetroStatus, State 
   ;
quit;



proc sql;
 create view NCSCVA2005View as
 select state,
        put(metro,metro.) as MetroStatus label='Metro Status',
        mean(HomeValue) as AvgHomeValue label='Average Home Value',
        mean(HHIncome) as MeanIncome label='Mean Household Income'
 from bookdata.ipums2005basic
 where state in ('North Carolina','South Carolina','Virginia') and metro ge 2
       and MortgageStatus contains 'Yes'
 group by state, MetroStatus
 ;
 create view NCSCVA2010View as
 select put(metro,metro.) as MetroStatus label='Metro Status',
        state,
        mean(HomeValue) as AvgHomeValue label='Average Home Value',
        mean(HHIncome) as MeanIncome label='Mean Household Income'
 from bookdata.ipums2010basic
 where state in ('North Carolina','South Carolina','Virginia') and metro ge 2
       and MortgageStatus contains 'Yes'
 group by MetroStatus, state
 ;
quit;


proc sql;
  select five.MetroStatus, five.state, 
         five.AvgHomeValue as HV2005 label='2005 Value' format=dollar12., 
         ten.AvgHomeValue as HV2010 label='2010 Value' format=dollar12.,
         HV2010-HV2005 as Difference format=dollar12.
  from NCSCVA2005View as five inner join NCSCVA2010View as ten
    on five.state eq ten.state 
       and five.MetroStatus eq ten.MetroStatus
  order by MetroStatus, State
   ;
quit;