/*	Pollutant Map Drilldown Assignment
 *	==================================
 *	Michael Suggs <mjs3607@uncw.edu>
 *
 *	Before running, make sure to change the htmlpath macro variable to the
 *	location you'd like all the html and png files to be generated into.
 */

/* Change this to set the path to generate files into! */
%let htmlpath=/home/u49577936/531-532/PollutantMap;
filename htmlbase "&htmlpath";

/* Get the state names and abbrs for making macro vars later. */
data states;
	set mapsgfk.US_STATES_ATTR(keep=state statecode idname);
run;

/* Put the states and names together and given them an ISO code.
   Also places the url for each state into a separate column. */
data us;
 merge mapsgfk.us work.states;
 by State;
 ident=catx('-',statecode,segment);
 ord=_n_;
 url=cats("&htmlpath/", statecode, ".html");
 drop State segment;
 rename idname=statename statecode=stateabbr;
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

%mend;
/* options SYMBOLGEN MPRINT; */
/* %StateTotal(AK, Alaska); */

/* Generate tables for all states in the dataset. */
%macro StateTables;
/* Loop through the states_attr dataset and make macro variables for each state's
   name and abbreviation as &statename_i and &stateabbr_i. */
data _null_;
	set work.states;
	call symputx(cats('stateabbr_',_N_),statecode);
	call symputx(cats('statename_',_N_),idname);
run;

/* 50 states, so loop 50 times. */
%do i=1 %to 50;
	%StateTotal(&&stateabbr_&i,&&statename_&i);
%end;
%mend StateTables;