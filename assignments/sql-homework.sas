/* Michael Suggs (mjs3607@uncw.edu)
 * SQL Homework 02/12/2020
 * DSC 512
 */

/* Instructions:
 *	1. Change `datadir` to point to the directory encapsulating `datafile`.
 *	3. Change `libdir` to point to the desired directory for the library for this code.
 *
 * If filenames need to be changed (for files within datadir and sasdir):
 *	1. Change `datafile` to point to the desired .csv file within `datadir`.
 *	2. Change `sasfile` to point to desired .sas7bdat file within `sasdir`.
 */

%let datadir=/home/u49577936/data/cdc;
%let libdir=/home/u49577936/sql;

libname cdc "&datadir";
libname mylib "&libdir";

ods trace on;



/* Question 1 */
proc format;
	value BMPBMI
		0-<18.5  = "Underweight"
		18.5-<25 = "Normal"
		25-<30	 = "Overweight"
		30-high	 = "Obese"
	;
run;

proc sql;
	title "Average Sodium, Fat, and Cholestrol Levels per Meal";
/* 	create view avgPerMeal as */
	select mean(drpisodi) label="Mean Sodium",
		   median(drpisodi) label="Median Sodium",
		   mean(drpitfat) label="Mean Total Fat",
		   median(drpitfat) label="Median Total Fat",
		   mean(drpichol) label="Mean Cholestrol",
		   median(drpichol) label="Median Cholestrol"
	from cdc.iff
	group by drpmn
	;
quit;

proc sql;
	title "Serum LDL/HDL and Glucose by Person, by BMI";
/* 	create view avgPerPerson as */
	select put(bmpbmi,BMPBMI.) as bmi label = "BMI",
		   mean(lcp) label = "Serum LDL",
		   mean(hdp) label = "Serum HDL",
		   mean(sgp) label = "Glucose"
	from cdc.lab_results as lr
	inner join cdc.exam_results as er
	on lr.seqn eq er.seqn
	group by calculated bmi
	order by case(bmi)
		when 'Underweight' then 1
		when 'Normal' then 2
		when 'Overweight' then 3
		when 'Obese' then 4
		else 5
	end
	;
quit;



/* Question 2 */
proc format;
	value SEX
		1 = "Male"
		2 = "Female"
	;
run;

proc sql;
	create view mcdiff as
		select *
		from cdc.iff
		where drpcomm between 10296 and 10363
		order by seqn
	;
	create view bgkiff as
		select *
		from cdc.iff
		where drpcomm between 10030 and 10080
		order by seqn
	;
	create view kfciff as
		select *
		from cdc.iff
		where drpcomm between 10243 and 10269
		order by seqn
	;
quit;

proc sql;
	create view totSex as
		select put(hssex,SEX.) as sex, count(drpmn) as totalMeals
		from cdc.iff as i
		inner join
		(
			select seqn, hssex
			from cdc.adults_surveyed
		) as a
		on i.seqn eq a.seqn
		group by calculated sex
	;
	create view mcdSex as
		select put(hssex,SEX.) as sex, count(drpmn) as mcdTotal
		from work.mcdiff as m
		inner join
		(
			select seqn, hssex
			from cdc.adults_surveyed
		) as a
		on m.seqn eq a.seqn
		group by calculated sex
	;
	create view bgkSex as
		select put(hssex,SEX.) as sex, count(drpmn) as bgkTotal
		from work.bgkiff as b
		inner join
		(
			select seqn, hssex
			from cdc.adults_surveyed
		) as a
		on b.seqn eq a.seqn
		group by calculated sex
	;
	create view kfcSex as
		select put(hssex,SEX.) as sex, count(drpmn) as kfcTotal
		from work.kfciff as k
		inner join
		(
			select seqn, hssex
			from cdc.adults_surveyed
		) as a
		on k.seqn eq a.seqn
		group by calculated sex
	;
quit;

proc sql;
	create table fastFoodGender as
	select totSex.sex as tsex label="Sex",
		   totalMeals label="Total Meals",
		   mcdTotal   label="McDonald's Meals",
		   bgkTotal   label="Burger King Meals",
		   kfcTotal   label="KFC Meals"
	from totSex
		inner join mcdSex on totSex.sex eq mcdSex.sex
		inner join bgkSex on totSex.sex eq bgkSex.sex
		inner join kfcSex on totSex.sex eq kfcSex.sex
	group by tsex
	;
quit;



/* Question 3 */
proc sql;
	create view noMCD as
		select seqn, hssex
		from cdc.iff as i
		inner join cdc.adults_surveyed as a
		on i.seqn eq a.seqn
		where drpcomm not between 10296 and 10363
		order by i.seqn
	;
	create view mcdMeals as
		select distinct seqn, drpmn as mcdmn
		from cdc.iff
		where drpcomm between 10296 and 10363
		order by seqn, mcdmn
	;
	create view mcdThree as
		select seqn
		from mcdMeals
		group by seqn
		having freq(seqn) ge 3
	;
quit;

proc sql;
	create table noMCDSex as
		select i.hssex as sex label="Sex",
			   i.hdp label="HDL Cholestrol",
			   i.lcp label="LDL Cholestrol"
		from
		(
			select put(m.hssex,SEX.) as sex, mean(l.hdp), mean(l.lcp)
			from work.noMCD as m
			inner join cdc.lab_results as l
			on m.seqn eq l.seqn
			group by calculated sex
		) as i
		group by sex
	;
quit;


proc sql;
	create view bkMeals as
	select distinct seqn, drpmn as bkmn
	from cdc.iff
	where drpcomm between 10030 and 10080
	order by seqn, bkmn
	;
	create view bkThree as
	select seqn
	from bkMeals
	group by seqn
	having freq(seqn) ge 3
	;
quit;

proc sql;
	create view kfcMeals as
	select distinct seqn, drpmn as kfcmn
	from cdc.iff
	where drpcomm between 10243 and 10269
	order by seqn, kfcmn
	;
	create view kfcThree as
	select seqn
	from kfcMeals
	group by seqn
	having freq(seqn) ge 3
	;
quit;
