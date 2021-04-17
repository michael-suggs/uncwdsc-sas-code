proc sql;
  title 'Query of All Cars';
  select make, model, origin, mpg_city, mpg_highway
    from sashelp.cars
    ;
  title 'Query of those with MPG City 25 or More';
  select make, model, origin, mpg_city, mpg_highway
    from sashelp.cars
    where mpg_city ge 25
    ;
quit;

proc sql;
  select make, model, origin, mpg_city, mpg_highway
    from sashelp.cars
    where mpg_city ge 25 and origin in ('Asia','Europe') and
      model contains '4dr'
    ;
quit;

proc sql;
  select make, model, origin, mpg_city, mpg_highway
    from sashelp.cars
    where mpg_city ge 25 and origin in ('Asia','Europe') and
      model contains '4dr'
    ;
quit;

title;
proc sql;
  select make, model, origin, mpg_city, mpg_highway
    from sashelp.cars
    where mpg_city ge 25
    order by origin, make desc /**in sort this is BY origin descending make;**/
    ;
quit;


proc sql;
  select mean(mpg_city), avg(mpg_city), n(make), count(model)
  /**these summary functions operate across all records read**/
  from sashelp.cars
  ;
  select mean(mpg_city), avg(mpg_city), n(make), count(cylinders)
  /**operate on non-missing values**/
  from sashelp.cars
  ;
quit;

proc sql;
  select origin, freq(mpg_city) as Count, mean(mpg_city) as AvgMPG
  from sashelp.cars
  group by origin /**group by operates similarly
   to group in report or class in means...**/
  ;
  select origin, type, freq(mpg_city) as Count, mean(mpg_city) as AvgMPG
  from sashelp.cars
  group by origin /**if there are things not summarized and not grouped,
    you get a remerge of summary to data to original data**/
  ;
  select origin, mean(mpg_city) as AvgMPG, mpg_city
  from sashelp.cars
  group by origin
  ;
quit;


proc sql;
  select origin, freq(mpg_city) as Count, mean(mpg_city) as AvgMPG
  from sashelp.cars
  where type not in ('Hybrid','Truck') /**where is after from, before group by**/
  group by origin 
  having AvgMPG ge 19 /**having operates on summary values (and others)***/
  ;
  select origin, freq(mpg_city) as Count, mean(mpg_city) as AvgMPG
  from sashelp.cars
  where type not in ('Hybrid','Truck') 
  group by origin 
  having AvgMPG ge 19 
  order by origin desc /**reordering groups is done with order by
    it goes after the grouping clauses: group by and having***/
  ;
quit;

proc sql;
  select origin, freq(mpg_city) as Count, mean(mpg_city) as AvgMPG
  from sashelp.cars
  where type not in ('Hybrid','Truck') 
  group by origin 
  having origin in ('Asia','Europe') 
  ;
  select origin, freq(mpg_city) as Count, mean(mpg_city) as AvgMPG
  from sashelp.cars
  where type not in ('Hybrid','Truck') and origin in ('Asia','Europe') 
  group by origin 
  ;
quit;

proc sql;
  select origin, freq(mpg_city) as Count, mean(mpg_city) as AvgMPG
  from sashelp.cars
  group by origin 
  having AvgMPG ge 19 and type not in ('Hybrid','Truck') 
  /**In general, the having clause does not need to refer to a variable
     in the summary, but it most likely should**/
  ;
quit;


proc sql;
  select origin, mpg_city, mpg_highway, 0.6*mpg_city+0.4*mpg_highway as MPGCombo
    /**can do computations in the select statement, and name with as**/
  from sashelp.cars
  where origin eq 'Asia' and type eq 'Sedan'
  ;
  select origin, 0.6*mpg_city+0.4*mpg_highway as MPGCombo
    /**can do computations in the select statement, and name with as**/
  from sashelp.cars
  where origin eq 'Asia' and type eq 'Sedan'
  ;
quit;

proc sql noerrorstop;
  select origin, mpg_city, mpg_highway, 0.6*mpg_city+0.4*mpg_highway as MPGCombo
  from sashelp.cars
  where origin eq 'Asia' and type eq 'Sedan' and MPGCombo ge 25
  ;
  select origin, mpg_city, mpg_highway, 0.6*mpg_city+0.4*mpg_highway as MPGCombo
  from sashelp.cars
  where origin eq 'Asia' and type eq 'Sedan' and 0.6*mpg_city+0.4*mpg_highway ge 25
    /***I can put computations in the where clause***/
  ;
  select origin, mpg_city, mpg_highway, 0.6*mpg_city+0.4*mpg_highway as MPGCombo
  from sashelp.cars
  where origin eq 'Asia' and type eq 'Sedan' and calculated MPGCombo ge 25
  /***with calculated, the where looks for the calculation--only does it once***/
  ;
quit;


proc sql noerrorstop;
  select origin, mpg_city, mpg_highway, mpg_highway-mpg_city as MPGDiff, MPGDiff/mpg_highway as ratio
  from sashelp.cars
  where origin eq 'Asia' and type eq 'Sedan'
  ;
  select origin, mpg_city, mpg_highway, mpg_highway-mpg_city as MPGDiff, calculated MPGDiff/mpg_highway as ratio
    /**calculated is necessary anywhere SQL would be looking at the name as something it expects in the table***/
  from sashelp.cars
  where origin eq 'Asia' and type eq 'Sedan'
  ;
quit;

proc sql;
  select origin, 
         make, 
         model,
         case index(model,'4dr')
            when 0 then 'Not'
            else '4dr'
         end
          as ModelType, /***this is one column specification using case-when***/
         case 
            when mpg_city le 15 then 1
            when mpg_city le 20 then 2
            when mpg_city le 25 then 3
            else 4
         end
          as mpgCityLevel,
          mpg_city
  from sashelp.cars
  ;
quit;

proc sql;
  select origin, 
         make, 
         model,
         case index(model,'4dr')
            when 0 then 'Not'
            else '4dr'
         end
          as ModelType, /***this is one column specification using case-when***/
         case 
            when mpg_city le 15 then 1
            when mpg_city le 20 then 2
            when mpg_city le 25 then 3
            else 4
         end
          as mpgCityLevel,
          mpg_city
  from sashelp.cars
  where calculated mpgCityLevel ge 3
  ;
quit;


proc sql;
  create table work.carsMod as /***create table is the statement--name the table and
         can use AS to make the select a clause that determines the data that goes
           into the table***/
  select origin, 
         make, 
         model,
         case index(model,'4dr')
            when 0 then 'Not'
            else '4dr'
         end
          as ModelType, /***when sending to a table, you will want to name columns***/
         case 
            when mpg_city le 15 then 1
            when mpg_city le 20 then 2
            when mpg_city le 25 then 3
            else 4
         end
          as mpgCityLevel label='MPG City Category',
          mpg_city
  from sashelp.cars
  where calculated mpgCityLevel ge 3
  ;
quit;

proc sql;
  create table work.carsMod2 as /***create table is the statement--name the table and
         can use AS to make the select a clause that determines the data that goes
           into the table***/
  select origin, make, mpg_city, mpg_highway, 
        0.6*mpg_city+0.4*mpg_highway as mpgCombo label='EPA Combined MPG',
        mpg_highway/mpg_city as mpgRatio format=percent9.1 label='MPG Ratio Highway:City'
  from sashelp.cars
  ;
  create table work.carsMod3 as /***create table is the statement--name the table and
         can use AS to make the select a clause that determines the data that goes
           into the table***/
  select origin, make, mpg_city, mpg_highway, 
        0.6*mpg_city+0.4*mpg_highway as mpgCombo label='EPA Combined MPG',
        mpg_highway/mpg_city label='MPG Ratio Highway:City' as mpgRatio format=percent9.1 
        /***label= and format= can be specified for any column after the expression that
          defines it. AS defines the name, and those attributes can be listed in any 
           order after the expression that defines the column***/
  from sashelp.cars
  ;
quit;
       
       
proc sql;
  create view work.carsModView as /***Views can be created, still goes to a library...
               cannot have the same name as any data table in the library
               
               stores the instructions for how to build the table--
                 lower storage requirements, but possibly increased processing time***/
  select origin, make, mpg_city, mpg_highway, 
        0.6*mpg_city+0.4*mpg_highway as mpgCombo label='EPA Combined MPG',
        mpg_highway/mpg_city as mpgRatio format=percent9.1 label='MPG Ratio Highway:City'
  from sashelp.cars
  ;
quit;
    
proc print data=work.carsmodview;
run;

