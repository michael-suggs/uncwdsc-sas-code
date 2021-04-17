proc format;
 value METRO
   0 = "Not Identifiable"
   1 = "Not in Metro Area"
   2 = "Metro, Inside City"
   3 = "Metro, Outside City"
   4 = "Metro, Unknown Type"
  ;
run;

/***Exercise 1***/
/***Part I***/

proc sql;
  select five.MetroStatus, five.state, 
         five.AvgHomeValue as HV2005 label='2005 Value' format=dollar12., 
         ten.AvgHomeValue as HV2010 label='2010 Value' format=dollar12.,
         calculated HV2010 - calculated HV2005 as Difference format=dollar12.
  from (select state,
               put(metro,metro.) as MetroStatus label='Metro Status',
               mean(HomeValue) as AvgHomeValue
        from bookdata.ipums2005basic
        where state in ('North Carolina','South Carolina','Virginia') 
              and metro ge 2
              and MortgageStatus contains 'Yes'
        group by state, MetroStatus
        ) as five 
        inner join 
        (select put(metro,metro.) as MetroStatus,
                state,
                mean(HomeValue) as AvgHomeValue
      from bookdata.ipums2010basic
      where state in ('North Carolina','South Carolina','Virginia') 
            and metro ge 2
               and MortgageStatus contains 'Yes'
      group by MetroStatus, state
      ) as ten
         on five.state eq ten.state 
             and five.MetroStatus eq ten.MetroStatus
   order by MetroStatus, State
   ;
quit;

/***Part II***/
proc sql;
  select five.MetroStatus, five.state, 
         five.AvgHomeValue as HV2005 label='2005 Value' format=dollar12., 
         ten.AvgHomeValue as HV2010 label='2010 Value' format=dollar12.,
         fifteen.AvgValue as HV2015 label='2015 Value' format=dollar12.,
         calculated HV2010/calculated HV2005-1 as Pct10_05 label='% Chg. 2005 to 2010' format=percentn8.1,
         calculated HV2015/calculated HV2005-1 as Pct15_05 label='% Chg. 2005 to 2015' format=percentn8.1
  from (
     (select state,
                put(metro,metro.) as MetroStatus label='Metro Status',
                mean(HomeValue) as AvgHomeValue
        from bookdata.ipums2005basic
        where state in ('North Carolina','South Carolina','Virginia') 
              and metro ge 2
              and MortgageStatus contains 'Yes'
        group by state, MetroStatus
        ) as five 
     inner join 
     (select put(metro,metro.) as MetroStatus,
                state,
                mean(HomeValue) as AvgHomeValue
      from bookdata.ipums2010basic
      where state in ('North Carolina','South Carolina','Virginia') 
            and metro ge 2
               and MortgageStatus contains 'Yes'
      group by MetroStatus, state
      ) as ten
          on five.state eq ten.state 
             and five.MetroStatus eq ten.MetroStatus
        )
        inner join 
        (select put(metro,metro.) as MetroStatus label='Metro Status',
                state,
                mean(HomeValue) as AvgValue
         from bookdata.ipums2015basic
         where state in ('North Carolina','South Carolina','Virginia') 
               and metro ge 2
               and MortgageStatus contains 'Yes'
         group by MetroStatus, state
          ) as fifteen
           on five.state eq fifteen.state 
              and five.MetroStatus eq fifteen.MetroStatus
  order by MetroStatus, State
   ;
quit;

/***Part III***/
proc sql;
  select 2005 as year, state, MetroStatus, 
         AvgHomeValue format=dollar12., MeanIncome format=dollar12.,
         AvgHomeValue/MeanIncome as ValueToIncome format=4.1 label='Value to Income Ratio'
  from (select state,
                put(metro,metro.) as MetroStatus label='Metro Status',
                mean(HomeValue) as AvgHomeValue,
                mean(HHIncome) as MeanIncome
        from bookdata.ipums2005basic
        where state in ('North Carolina','South Carolina','Virginia') 
              and metro ge 2
              and MortgageStatus contains 'Yes'
        group by state, MetroStatus
        )
  union 
  select 2010 as year, state, MetroStatus, 
         AvgHomeValue format=dollar12., MeanIncome format=dollar12.,
         AvgHomeValue/MeanIncome
  from (select put(metro,metro.) as MetroStatus,
                state,
                mean(HomeValue) as AvgHomeValue,
                mean(HHIncome) as MeanIncome
      from bookdata.ipums2010basic
      where state in ('North Carolina','South Carolina','Virginia') 
            and metro ge 2
               and MortgageStatus contains 'Yes'
      group by MetroStatus, state
      )
  ;
quit;

/***Part IV***/
proc sql;
  select 2005 as year, state, MetroStatus, 
         AvgHomeValue format=dollar12., MeanIncome format=dollar12.,
         AvgHomeValue/MeanIncome as ValueToIncome format=4.1 label='Value to Income Ratio'
  from (select state,
                put(metro,metro.) as MetroStatus label='Metro Status',
                mean(HomeValue) as AvgHomeValue,
                mean(HHIncome) as MeanIncome
        from bookdata.ipums2005basic
        where state in ('North Carolina','South Carolina','Virginia') 
              and metro ge 2
              and MortgageStatus contains 'Yes'
        group by state, MetroStatus
        )
  union 
  select 2010 as year, state, MetroStatus, 
         AvgHomeValue, MeanIncome,
         AvgHomeValue/MeanIncome
  from (select put(metro,metro.) as MetroStatus,
                state,
                mean(HomeValue) as AvgHomeValue,
                mean(HHIncome) as MeanIncome
      from bookdata.ipums2010basic
      where state in ('North Carolina','South Carolina','Virginia') 
            and metro ge 2
               and MortgageStatus contains 'Yes'
      group by MetroStatus, state
      )
  union
  select 2015 as year, state, MetroStatus, 
         AvgValue, AvgIncome,
         AvgValue/AvgIncome
  from (select put(metro,metro.) as MetroStatus,
               state,
               mean(HomeValue) as AvgValue,
               mean(HHIncome) as AvgIncome
        from bookdata.ipums2015basic
        where state in ('North Carolina','South Carolina','Virginia') 
              and metro ge 2
              and MortgageStatus contains 'Yes'
        group by MetroStatus, state
      )
  ;
quit;

/**Part V***/
proc sql;
  select five.MetroStatus, five.state, 
         five.AvgHomeValue label='2005 Value' format=dollar12., 
         ten.AvgHomeValue label='2010 Value' format=dollar12.,
         ten.AvgHomeValue-five.AvgHomeValue as Difference format=dollar12.
  from (select state,
                put(metro,metro.) as MetroStatus label='Metro Status',
                mean(HomeValue) as AvgHomeValue,
                mean(HHIncome) as MeanIncome
        from bookdata.ipums2005basic
        where state in ('North Carolina','South Carolina','Virginia') 
              and metro ge 2
              and MortgageStatus contains 'Yes'
        group by state, MetroStatus
        ) as five
        inner join (select put(metro,metro.) as MetroStatus,
                state,
                mean(HomeValue) as AvgHomeValue,
                mean(HHIncome) as MeanIncome
      from bookdata.ipums2010basic
      where state in ('North Carolina','South Carolina','Virginia') 
            and metro ge 2
               and MortgageStatus contains 'Yes'
      group by MetroStatus, state
      ) as ten
              on five.state eq ten.state 
                 and five.MetroStatus eq ten.MetroStatus
  union 
  select five.MetroStatus, five.state, 
         five.AvgHomeValue, 
         ten.AvgHomeValue,
         ten.AvgHomeValue-five.AvgHomeValue
  from (select state,
               put(metro,metro.) as MetroStatus,
               mean(HomeValue) as AvgHomeValue
        from bookdata.ipums2005basic
        where state in ('Florida','Georgia') 
              and MortgageStatus contains 'Yes'
        group by state, MetroStatus
        ) as five
        inner join
        (select state,
                put(metro,metro.) as MetroStatus,
                mean(HomeValue) as AvgHomeValue
         from bookdata.ipums2010basic
         where state in ('Florida','Georgia')
               and MortgageStatus contains 'Yes'
         group by state, MetroStatus
         ) as ten
           on five.state eq ten.state 
              and five.MetroStatus eq ten.MetroStatus
  order by MetroStatus, State 
   ;
quit;

/**Exercise 2**/
proc univariate data=bookdata.ipums2005basic;
 var HHIncome;
 where state in ('North Carolina','South Carolina','Virginia') and metro ge 2;
 ods select quantiles;
run;

proc sql;
  select mean(HHIncome) as MeanIncome label='Mean Household Income'
   from bookdata.ipums2005basic
   where state in ('North Carolina','South Carolina','Virginia') and metro ge 2
   ; 
   select state
   from bookdata.ipums2005basic
   where state in ('North Carolina','South Carolina','Virginia') and metro ge 2
   group by state
   having mean(HHIncome) ge 
         (select mean(HHIncome) as MeanIncome label='Mean Household Income'
          from bookdata.ipums2005basic
          where state in ('North Carolina','South Carolina','Virginia') 
            and metro ge 2
       )
   ;
quit;


proc sql;
  select five.MetroStatus, five.state, 
         five.AvgHomeValue as HV2005 label='2005 Value' format=dollar12., 
         ten.AvgHomeValue as HV2010 label='2010 Value' format=dollar12.,
         calculated HV2010 - calculated HV2005 as Difference format=dollar12.
  from (select state,
               put(metro,metro.) as MetroStatus label='Metro Status',
               mean(HomeValue) as AvgHomeValue
        from bookdata.ipums2005basic
        where state in ('North Carolina','South Carolina','Virginia') 
              and metro ge 2
              and MortgageStatus contains 'Yes'
        group by state, MetroStatus
        ) as five 
        inner join 
        (select put(metro,metro.) as MetroStatus,
                state,
                mean(HomeValue) as AvgHomeValue
      from bookdata.ipums2010basic
      where state in ('North Carolina','South Carolina','Virginia') 
            and metro ge 2
               and MortgageStatus contains 'Yes'
      group by MetroStatus, state
      ) as ten
         on five.state eq ten.state 
             and five.MetroStatus eq ten.MetroStatus
   group by five.State
   having five.State in 
          (select state
           from bookdata.ipums2005basic
           where state in ('North Carolina','South Carolina','Virginia') and metro ge 2
           group by state
           having mean(HHIncome) ge 
                 (select mean(HHIncome) as MeanIncome label='Mean Household Income'
                  from bookdata.ipums2005basic
                  where state in ('North Carolina','South Carolina','Virginia') 
                    and metro ge 2
                 )
          )
   order by MetroStatus, State
   ;
quit;

proc sql;
  select mean(HHIncome) as MeanIncome label='Mean Household Income'
   from bookdata.ipums2005basic
   where metro ge 2
   ; 
   select state
   from bookdata.ipums2005basic
   where state in ('North Carolina','South Carolina','Virginia') and metro ge 2
   group by state
   having mean(HHIncome) ge 
         (select mean(HHIncome) as MeanIncome label='Mean Household Income'
          from bookdata.ipums2005basic
          where metro ge 2
         )
   ;
quit;

proc sql;
  select five.MetroStatus, five.state, 
         five.AvgHomeValue as HV2005 label='2005 Value' format=dollar12., 
         ten.AvgHomeValue as HV2010 label='2010 Value' format=dollar12.,
         calculated HV2010 - calculated HV2005 as Difference format=dollar12.
  from (select state,
               put(metro,metro.) as MetroStatus label='Metro Status',
               mean(HomeValue) as AvgHomeValue
        from bookdata.ipums2005basic
        where state in ('North Carolina','South Carolina','Virginia') 
              and metro ge 2
              and MortgageStatus contains 'Yes'
        group by state, MetroStatus
        ) as five 
        inner join 
        (select put(metro,metro.) as MetroStatus,
                state,
                mean(HomeValue) as AvgHomeValue
      from bookdata.ipums2010basic
      where state in ('North Carolina','South Carolina','Virginia') 
            and metro ge 2
               and MortgageStatus contains 'Yes'
      group by MetroStatus, state
      ) as ten
         on five.state eq ten.state 
             and five.MetroStatus eq ten.MetroStatus
   group by five.State
   having five.State in 
          (select state
           from bookdata.ipums2005basic
           where state in ('North Carolina','South Carolina','Virginia') and metro ge 2
           group by state
           having mean(HHIncome) ge 
                 (select mean(HHIncome) as MeanIncome label='Mean Household Income'
                  from bookdata.ipums2005basic
                  where metro ge 2
                  )
           )
   order by MetroStatus, State
   ;
quit;

proc univariate data=bookdata.ipums2010basic;
 var HHIncome;
 where metro ge 2;
 ods select quantiles;
run;

proc sql;
  select mean(HHIncome) as MeanIncome label='Mean Household Income'
   from bookdata.ipums2005basic
   where metro ge 2
   ; 
   select mean(HHIncome) as MeanIncome label='Mean Household Income'
   from bookdata.ipums2010basic
   where metro ge 2 and HHIncome lt 9999999
   ; 
   select state
   from bookdata.ipums2005basic
   where state in ('North Carolina','South Carolina','Virginia') and metro ge 2
   group by state
   having mean(HHIncome) ge 
         (select mean(HHIncome) as MeanIncome label='Mean Household Income'
          from bookdata.ipums2005basic
          where metro ge 2
       )
   ;
   select state
   from bookdata.ipums2010basic
   where state in ('North Carolina','South Carolina','Virginia') 
         and metro ge 2 and HHIncome lt 9999999
   group by state
   having mean(HHIncome) ge 
         (select mean(HHIncome) as MeanIncome label='Mean Household Income'
          from bookdata.ipums2010basic
          where metro ge 2 and HHIncome lt 9999999
       )
   ;
quit;

proc sql;
  select five.MetroStatus, five.state, 
         five.AvgHomeValue as HV2005 label='2005 Value' format=dollar12., 
         ten.AvgHomeValue as HV2010 label='2010 Value' format=dollar12.,
         calculated HV2010 - calculated HV2005 as Difference format=dollar12.
  from (select state,
               put(metro,metro.) as MetroStatus label='Metro Status',
               mean(HomeValue) as AvgHomeValue
        from bookdata.ipums2005basic
        where state in ('North Carolina','South Carolina','Virginia') 
              and metro ge 2
              and MortgageStatus contains 'Yes'
        group by state, MetroStatus
        ) as five 
        inner join 
        (select put(metro,metro.) as MetroStatus,
                state,
                mean(HomeValue) as AvgHomeValue
      from bookdata.ipums2010basic
      where state in ('North Carolina','South Carolina','Virginia') 
            and metro ge 2
               and MortgageStatus contains 'Yes'
      group by MetroStatus, state
      ) as ten
         on five.state eq ten.state 
             and five.MetroStatus eq ten.MetroStatus
   group by five.State
   having five.State in 
                (select state
                 from bookdata.ipums2005basic
                 where state in ('North Carolina','South Carolina','Virginia') and metro ge 2
                 group by state
                 having mean(HHIncome) ge 
                       (select mean(HHIncome) as MeanIncome label='Mean Household Income'
                        from bookdata.ipums2005basic
                        where metro ge 2
                     )
                 union
                 select state
                 from bookdata.ipums2010basic
                 where state in ('North Carolina','South Carolina','Virginia') 
                       and metro ge 2 and HHIncome lt 9999999
                 group by state
                 having mean(HHIncome) ge 
                       (select mean(HHIncome) as MeanIncome label='Mean Household Income'
                        from bookdata.ipums2010basic
                        where metro ge 2 and HHIncome lt 9999999
                     )
                 )
    order by MetroStatus, State
   ;
quit;


proc sql;
  select mean(HHIncome) as MeanIncome label='Mean Household Income'
   from bookdata.ipums2005basic
   where metro ge 2
   ; 
   select mean(HHIncome) as MeanIncome label='Mean Household Income'
   from bookdata.ipums2010basic
   where metro ge 2 and HHIncome lt 9999999
   ; 
   select state
   from bookdata.ipums2005basic
   where metro ge 2
   group by state
   having mean(HHIncome) ge 
         (select mean(HHIncome) as MeanIncome label='Mean Household Income'
          from bookdata.ipums2005basic
          where metro ge 2
       )
   ;
   select state
   from bookdata.ipums2010basic
   where metro ge 2 and HHIncome lt 9999999
   group by state
   having mean(HHIncome) ge 
         (select mean(HHIncome) as MeanIncome label='Mean Household Income'
          from bookdata.ipums2010basic
          where metro ge 2 and HHIncome lt 9999999
       )
   ;
   select state
   from bookdata.ipums2005basic
   where metro ge 2
   group by state
   having mean(HHIncome) ge 
         (select mean(HHIncome) as MeanIncome label='Mean Household Income'
          from bookdata.ipums2005basic
          where metro ge 2
       )
   union
   select state
   from bookdata.ipums2010basic
   where metro ge 2 and HHIncome lt 9999999
   group by state
   having mean(HHIncome) ge 
         (select mean(HHIncome) as MeanIncome label='Mean Household Income'
          from bookdata.ipums2010basic
          where metro ge 2 and HHIncome lt 9999999
       )
   ;
quit;
