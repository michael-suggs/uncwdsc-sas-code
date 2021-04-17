proc sql;
	create table one as
	select *
	from business.colaNCSCGA(obs=10), business.Counties(obs=9)
	;
	/**default behavior with more than one table is a 
		Cartesian Product--every row in the first is matched
		with every row in the second***/
quit;

proc sql feedback;
	create table one as
	select *
	from business.colaNCSCGA, business.Counties
	where colaNCSCGA.StateFIPS eq Counties.StateFIPS
				and colaNCSCGA.CountyFIPS eq Counties.CountyFIPS
	;/***put matching criteria into a WHERE clause
			prefixing is required for any ambiguities***/
quit;
/**with WHERE, only matches are preserved--this is 
	an inner join.
	We don't get this by default in a DATA step match merge,
		all records (mismatches) are preserved
	
	We can use IN= variables and subsetting IF to
		get only matches***/

proc freq data=business.counties;
	table stateFIPS stateNAME;
run;
proc freq data=one;
	table stateFIPS stateName;
run;
			
proc sql feedback;
	create table two as
	select *
	from business.colaNCSCGA inner join business.Counties
	 on colaNCSCGA.StateFIPS eq Counties.StateFIPS
				and colaNCSCGA.CountyFIPS eq Counties.CountyFIPS
	;
	/***from A inner join B on --matching criterion--***/
quit;

proc sql feedback;
	create table three as
	select *
	from business.colaNCSCGA inner join business.Counties
	 on colaNCSCGA.StateFIPS eq Counties.StateFIPS
				and colaNCSCGA.CountyFIPS eq Counties.CountyFIPS
	where unitsSold ge 2000
	;
	/***additional conditions can still be provided in WHERE***/
quit;

/***the three other joins are:
  RIGHT JOIN
  LEFT JOIN
  FULL JOIN
  these all preserve records/mismatches***/
proc sql feedback;
	create table three as
	select *
	from business.colaNCSCGA right join business.Counties
	 on colaNCSCGA.StateFIPS eq Counties.StateFIPS
				and colaNCSCGA.CountyFIPS eq Counties.CountyFIPS
	;
	/***All records from the right table -- second listed
		are preserved***/
quit;

proc sql feedback;
	create table four as
	select *
	from business.colaNCSCGA left join business.Counties
	 on colaNCSCGA.StateFIPS eq Counties.StateFIPS
				and colaNCSCGA.CountyFIPS eq Counties.CountyFIPS
	;
	/***All records from the left table -- first listed
		are preserved
		
		this one is the same as the inner join since there
			are no records in ColaNCSCGA that fail to have 
			a match***/
quit;

proc sql feedback;
	create table five as
	select *
	from business.colaNCSCGA full join business.Counties
	 on colaNCSCGA.StateFIPS eq Counties.StateFIPS
				and colaNCSCGA.CountyFIPS eq Counties.CountyFIPS
	;
	/***All records from both tables are preserved
			this is the same as the DATA step match-merge
			default behavior***/
quit;

proc sql feedback;
	create table six as
	select *
	from business.colaNCSCGA full join business.colaDCMDVA
	 on colaNCSCGA.StateFIPS eq colaDCMDVA.StateFIPS
				and colaNCSCGA.CountyFIPS eq colaDCMDVA.CountyFIPS
	;
	/***All records are preseved with lots of missing stuff***/
	create table seven as
	select *
	from business.colaNCSCGA inner join business.colaDCMDVA
	 on colaNCSCGA.StateFIPS eq colaDCMDVA.StateFIPS
				and colaNCSCGA.CountyFIPS eq colaDCMDVA.CountyFIPS
	;
quit;

proc sql;
	create table NC as
	select productName, sum(UnitsSold) as TotalSoldNC
	from business.colaNCSCGA
	where stateFIPS eq 37
	group by productName
	;
	create table SC as
	select productName, sum(UnitsSold) as TotalSoldSC
	from business.colaNCSCGA
	where stateFIPS eq 45
	group by productName
	;
	create table GA as
	select productName, sum(UnitsSold) as TotalSoldGA
	from business.colaNCSCGA
	where stateFIPS eq 13
	group by productName
	;
quit;

proc sql;
	select nc.productName, totalSoldNC, totalSoldSC, totalSoldGA
	from NC,SC,GA
	where NC.productName eq SC.productName eq GA.productName
	;
quit;

proc sql;
	select nc.productName, totalSoldNC, totalSoldSC, totalSoldGA
	from (NC inner join SC on NC.productName eq SC.productName)
				inner join GA on NC.productName eq GA.productName
	;
quit;
	