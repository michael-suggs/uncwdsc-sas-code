proc sgplot data=mapsgfk.us;
 polygon x=x y=y id=state;
 /**can plot polygons, x and y coordinates and a polygon identifier***/
 where statecode eq 'HI';
run;

data us;
 set mapsgfk.us;
 ident=catx('-',statecode,segment);
  /**this identifier is unique for each polygon within each state**/
run;

proc sgplot data=us aspect=.625;
 polygon x=x y=y id=ident;
 /**can plot polygons, x and y coordinates and a polygon identifier***/
 *where statecode eq 'HI';
 xaxis display=none;
 yaxis display=none;
run;

proc means data=sasprg.projects median;
 class stname;
 var jobtotal;
 ods output summary=medians;
run;

data us;
 set us;
 ord=_n_;
run;

proc sql;
 create table mapping as
 select *
 from us full join medians
  on statecode eq stname
 order by ord
 ;
quit;


proc sgplot data=mapping aspect=.625;
 polygon x=x y=y id=ident / colorresponse=jobtotal_median fill outline;
 /**can plot polygons, x and y coordinates and a polygon identifier***/
 *where statecode eq 'HI';
 xaxis display=none;
 yaxis display=none;
run;

proc sgplot data=mapping aspect=.625;
 polygon x=x y=y id=ident / colorresponse=jobtotal_median fill outline
   colormodel=(cxfc8d59 cxffffbf cx91cf60) dataskin=gloss;
 xaxis display=none;
 yaxis display=none;
 gradlegend / position=bottom title='Median Cost';
run;

%let return=%sysfunc(dlgcdir('G:\SeaShare\Shape'));
/**Point this to wherever you unpack the Shape File Set.zip to***/

proc mapimport out=ThisMap infile="tl_2018_23_cousub.shp";
 /***MAPIMPORT points to the .shp file, but needs others to be in the
   same location***/
run;

proc sql noprint;
 select (max(y)-min(y))/(max(x)-min(x)) 
 into :ratio
 from ThisMap
 ;/**Here's a quick way to get a good aspect ratio for any map...**/
quit;

%let return=%sysfunc(dlgcdir('G:\SeaShare\Shape'));
/**I'm not actually changing the working directory here, but if 
 you want to send out the graph, and send it somewhere else, you
 can set that path now...***/

ods listing image_dpi=300;
/***If you don't recall this, ODS LISTING directs graphs/plots to files,
 IMAGE_DPI does what you'd expect***/

ods graphics / reset antialiasmax=10000 imagename='Map1' imagefmt=png;
/***For detailed graphs, you may want to play with the max antialiasing,
  sometimes things can take a while to draw if you don't--or you may run 
  out of resources alltogether**/
proc sgplot data=ThisMap aspect=&ratio;
 polygon x=x y=y id=name;
 xaxis display=none;
 yaxis display=none;
run;/**So it's a county map of Maine...**/

/***fish data is from Maine, can we figure out which county each lake/pond is in?
 Try to use latitude and longitude***/
data fish;
 set sasprg.fish;
 /**turn the three column set for lat and long into single y and x variables***/
 
 y=lat1+lat2/60+lat3/3600;
 x=-1*(long1+long2/60+long3/3600);
 /**make sure you are using the same coordinate systems in both places....
  positive/negative
  degrees/radians
  projected/not projected
 **/
 keep name hg x y;
run;

proc sort data=ThisMap;
 by name;
 /**We will use PROC GINSIDE to locate the lakes/ponds. To get locations with ginside, 
   map data must be sorted on the id variable and this variable name must be unique 
   to the map data set***/
run;

proc ginside data=fish map=ThisMap(rename=(name=county)) out=fish2 includeborder;
 id county;
run;/**now we have a data set that includes the fish data with counties
    where each lake/pond is located**/
   
ods select none;
proc means data=fish2 median;
 class county;
 var hg;
 ods output summary=MedianHG;
run;
/**summarize my data by this constructed id variable***/

data map;
 merge ThisMap(rename=(name=county)) medianHG;
 by county;
run;/***put back together***/

ods select all;
ods listing image_dpi=300;
ods graphics / reset antialiasmax=1000 imagename='Map2';
proc sgplot data=map aspect=&ratio;
 polygon x=x y=y id=county / colorresponse=hg_median fill outline dataskin=matte;
 xaxis display=none;
 yaxis display=none;
run;/**make map like we did before...

this map is in latitude/longitude coordinates (spherical)--
usually not used to draw flat maps

Typically a projection is employed...**/


proc gproject data=map out=map2 degrees eastlong;
 id county;
run;

proc sql noprint;
 select (max(y)-min(y))/(max(x)-min(x)) into :ratio
 from map2
 ;
quit;/**after projecting, will want to compute aspect ratio for the projection***/

ods listing image_dpi=300;
ods graphics /reset antialiasmax=1000 imagename='Map3';
proc sgplot data=map2 aspect=&ratio;
 polygon x=x y=y id=county / colorresponse=hg_median fill outline dataskin=matte;
 xaxis display=none;
 yaxis display=none;
run;

