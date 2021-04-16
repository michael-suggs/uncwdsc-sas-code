/* Pollutant Map Drilldown Assignment
 * ==================================
 * Michael Suggs <mjs3607@uncw.edu>
 *
 * Before running, make sure to change the htmlpath macro variable to the
 * location you'd like all the html and png files to be generated into.
 */

/* Change this to set the path to generate files into! */
%let htmlpath=/home/u49577936/531-532/PollutantMap;

%macro CreateMap;
filename htmlbase "&htmlpath";
%PreprocessMappingData;
%StateTotals;
%PlotMap;
%mend CreateMap;

%macro PreprocessMappingData;
/* Put the states and names together and given them an ISO code.
   Also places the url for each state into a separate column. */
data us;
 merge mapsgfk.us(keep=x y state statecode)
 	   mapsgfk.us_states_attr(keep=state statecode idname);
 by state;
 if first.state then call symputx(statecode, idname, 'G');
 ident=catx('-',statecode,segment);
 ord=_n_;
 url=cats("&htmlpath/", statecode, ".html");
 rename idname=statename statecode=stateabbr;
 drop state;
run;

/* Get the stats we'll use for our hover-over tooltips. */
proc means data=sasprg.projects mean;
	class stname;
	var jobtotal;
	ods output summary=jobmeans(rename=(STNAME=State NObs=Jobs JOBTOTAL_Mean=Mean));
run;

/* Put all the data together so we can make a map with clickable elements. */
proc sql;
	CREATE TABLE mapping AS
	SELECT *
	FROM us FULL JOIN jobmeans
		 ON stateabbr eq state
	GROUP BY stateabbr
	ORDER BY ord;
quit;
%mend PreprocessMappingData;

%macro PlotMap;
/* Actually generate the map, putting all html and png files in htmlbase */
ods graphics on / reset=all imagename="us_jobmeans" imagefmt=png imagemap;
ods html file="index.html" gpath=htmlbase path=htmlbase;
proc sgplot data=mapping aspect=.625;
	title "Average Total Cost for all Pollutants";
	/* Use tips for hover-over stats, and give each poly its associated url. */
	polygon x=x y=y id=ident / colormodel=(lightgoldenrodyellow liyg bibg bigb vigb)
							   colorresponse=Mean fill outline
							   tip=(ident mean) tipformat=(best8. dollar10.2)
							   tiplabel=("ISO States Code" "Mean")
							   url=url;
	/* Move the gradient legend from the side to the bottom. */
	gradlegend / position=bottom title="Average Job Cost";
	xaxis display=none;
	yaxis display=none;
run;
ods html close;
%mend PlotMap;

/***Why did you choose to start defining macros here, and not include the
 prior code inside a macro definition?
 
 	I didn't include the above code within a macro as it was only ever
 	being run a single time--however, putting it inside a macro would 
 	not only increase end-user usability (only having to run a single
 	line to invoke the macro) as well as its portability (as inside a
 	macro, it can be reused in different codebases or other source files).
 	
 	As such, I have reformatted the code above into two separate macros,
 	one for generating the mapping data, and another for actually plotting
 	the data via `sgplot`.
 ***/
/* Macro generating the tables for each individual state.
   These are output into html files names with the state's abbreviation,
   and can be accessed through the main map by clicking each state. */
%macro StateTotal(stateabbr, statename);
/* Use SQL to summarize the variables we want for each table. */
proc sql;
 CREATE TABLE &stateabbr.total AS
 SELECT POL_TYPE LABEL="Pollutant",
     COUNT(JOBID) AS NJOBS LABEL="Number of Jobs" FORMAT=10.,
     SUM(PERSONEL) AS PCOST LABEL="Personnel Costs" FORMAT=dollar10.,
     SUM(EQUIPMNT) AS ECOST LABEL="Equipment Costs" FORMAT=dollar10.,
     SUM(JOBTOTAL) AS TCOST LABEL="Total Costs" FORMAT=dollar10.
 FROM sasprg.projects
 /* Only get stats for the current state. */
 WHERE STNAME="&stateabbr"
 /* Summarize each cost and number of jobs by the type of pollutant. */
 GROUP BY POL_TYPE;
quit;

/* Send the generated table to a html file. */
ods html file="&stateabbr..html" path=htmlbase;
proc report data=work.&stateabbr.total;
 /* Summarize each statistic for each pollution type for the entire state at the end. */
 rbreak after / summarize;
 /* Give it a title at the top of the inside the report. */
 compute before _page_;
  line "Totals for &state";
 endcomp;
 /* Place a backlink to the map at the bottom of the report. */
 compute after;
  line "<a href='index.html' >Return to Map</a>";
 endcomp;
run;
ods html close;
/***Can you make this more efficient?

	Absolutely. Creating this many entirely temporary 1-observation 
	tables is horrid, and this can instead be replaced with a datastep
	computing all totals within. This can then be used to generate
	the html files with `where` subsetting on the passed-in dataset
	to proc report, instead of a different table for each state.
	
	My intended solution would ideally look like the following:
	
	%macro StateTotals;
	proc sort data=sasprg.projects;
		by stname pol_type;
	run;
	
	%let stidx=0;
	data statetotals(keep=stname pol_type njobs pcost ecost tcost);
		set sasprg.projects end=eof;
		by stname pol_type;
		format njobs 10. pcost dollar10. ecost dollar10. tcost dollar10.;
		label njobs="Number of Jobs" pcost="Personel Costs"
			  ecost="Equipment Costs" tcost="Total Costs"
			  pol_type="Pollutant";
		if first.stname then do;
			%let stidx=%eval(&stidx + 1);
			call symputx(cats("stateabbr",&stidx),stname,'G');
			call symputx(cats("statename",&stidx),symget(stname),'G');
		end;
		if first.pol_type then do;
			njobs = 0; pcost = 0; ecost = 0; tcost = 0;
		end;
		njobs + 1; pcost + personel; ecost + equipmnt; tcost + jobtotal;
		if last.pol_type;
	run;
	
	%do i=1 %to 51;
		ods html file="&&stateabbr&i..html" path=htmlbase;
		proc report data=work.statetotals(where=(stname="&&statename&i"));
			rbreak after / summarize;
			compute before _page_;
				line "Totals for &&statename&i";
			endcomp;
			compute after;
				line "<a href='index.html' >Return to Map</a>";
			endcomp;
		run;
		ods html close;
	%end;
	%mend StateTotals;
	
	The above is not presently functional, but very close to it. I
	believe the issue I'm having with it stems from one of a few
	possible locations--either the updating of the loop index `stidx`
	is not occurring in the data step (since macro commands are processed
	first), or there are scoping issues with my symputx/symget calls,
	or I am not correctly using first/last for nested by-grouping.
	
	Instead of generating all HTML files, the best I was able to get is
	a single file--WY, which happens to be the last state on the list.
	This, and looking through symbolgen and mlogic led me to the above.
***/
%mend;
/* options SYMBOLGEN MPRINT; */
/* %StateTotal(AK, Alaska); */

/* Generate tables for all states in the dataset. */
%macro StateTables;
/* Loop through the states_attr dataset and make macro variables for each state's
   name and abbreviation as &statename_i and &stateabbr_i. */
data _null_;
 set mapsgfk.us_states_attr;
 call symputx(cats('stateabbr_',_N_),statecode);
 call symputx(cats('statename_',_N_),idname);
run;

/* 50 states, so loop 50 times. */
/***Which data set has 50 states?

	This was indeed an oversight. The data set I originally had in mind
	was the us_state_attr, though after returning to this I realize that
	I actually intended to get the number of levels for `stname` from
	sasprg.projects, which ends up being 48 instead of 50/51.
***/
%do i=1 %to 48;
 %StateTotal(&&stateabbr_&i,&&statename_&i);
%end;
%mend StateTables;