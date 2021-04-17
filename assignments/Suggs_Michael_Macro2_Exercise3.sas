/* Programming Exercise 3, SAS Macro Language Part II
 * Michael Suggs <mjs3607@uncw.edu>
 *
 * Below, I've included two macros for reading and concatenating
 * files with either comma- or tab-delimination. They each have
 * slightly different parameters, but aside from this macro-parameter
 * handling, each has the same internal function. They're placed in
 * order within the file, so ConcatDirectory comes first followed
 * by ConcatRawCombined.
 *
 * Macros:
 *   `ConcatDirectory`: concatenates all files in a given directory.
 *   `ConcatRawCombined`: takes a list of files and concatenates them.
 *
 * Note: please set the `datapath` macro variable to the parent folder
 * that contains all the `monthly data #` directories--this variable
 * is used with `dlgcdir` to set the temporary working directory.
 */

%let datapath=/home/u49577936/531-532/Macro2Exercises/Monthly Data Folders;

/* ConcatDirectory
 *
 * This macro takes a single parameter--`path`--which denotes the
 * directory that the files to concatenate are contained within.
 * This should be passed as a string variable of the FULLY-QUALIFIED
 * path to said directory. Relative paths did not work on my system,
 * so correctness cannot be guaranteed.
 *
 * Args:
 *   `path`: string; the fully-qualified system path to the directory.
 * 		Chosen as this is the simpliest way to indicate all files in a
 *		a directory to be parsed and combined. Full-qualification was
 * 		determined, as relative-path-parsing almost always causes headaches,
 * 		especially when going between operating systems.
 */
%macro ConcatDirectory(path=,out=concat,outlib=work);
/* Get a fileref to the passed path and open it as a directory. */
%let fileref=datadir;
%let rc=%sysfunc(filename(fileref,&path));
%let did=%sysfunc(dopen(&fileref));

/* `files` is a macro-list of all files in the directory. */
%local files;
/* Iterate through all files in the dir (1 -> dnum) */
%do d=1 %to %sysfunc(dnum(&did));
	/* Get the name (with ext) of the file from DRead */
	%let name=%qsysfunc(dread(&did,&d));
	/* Append this filename to the end of the list */
	%let files=&files | &name;
%end;
/* Close the directory to prevent memory leaks */
%let rc=%sysfunc(dclose(&did));

/* Parse the constructed list of filenames */
%let i=1;
%let file=%scan(&files,&i,|);
%do %while(&file ne );
	/* Break <name>.<ext> on `.` -- do at top of the loop 
	   since `(&file ne )` guards against us trying to get
	   the name/ext of a null file. */
	%let name=%scan(&file,1,.);
	%let ext=%scan(&file,-1,.);
	/* If it's a .csv file, use ',' as the delimiter; else, use '09'x */
	%if (&ext eq csv) %then %do;
		%let delim=',';
	%end;
	%else %do;
		%let delim='09'x;
	%end;

	/* Parse the data from the file with our chosen delimiter. */
	data nextData;
		infile "&name..&ext" dlm=&delim firstobs=2;
		input City:$10. Department:$25. Personnel Equipment Material Incidental;
	run;

	/* Use the file's name (without ext) as the month */
	%if(&i eq 1) %then %do;
		data &outlib..&out;
			set nextData;
			Month="&name";
		run;
	%end;
	%else %do;
		data &outlib..&out;
			set &outlib..&out nextData(in=current);
			if current then Month="&name";
		run;
	%end;
	%let i=%eval(&i+1);
	%let file=%scan(&files,&i,|);
%end;
%mend;

/* If you would like to change the path for the next macro,
 * you can uncomment and change below.
 */
/* %let datapath=/home/u49577936/531-532/Macro2Exercises/Monthly Data Folders; */

/* Run for `monthly data 1` folder */
%let return=%sysfunc(dlgcdir("&datapath/monthly data 1"));
%ConcatDirectory(path="&datapath/monthly data 1");
/* Run for `monthly data 2` folder */
%let return=%sysfunc(dlgcdir("&datapath/monthly data 2"));
%ConcatDirectory(path="&datapath/monthly data 2");
/* Run for `monthly data 3` folder */
%let return=%sysfunc(dlgcdir("&datapath/monthly data 3"));
%ConcatDirectory(path="&datapath/monthly data 3");
/* Run for `Monthly Data 4` folder */
%let return=%sysfunc(dlgcdir("&datapath/Monthly Data 4"));
%ConcatDirectory(path="&datapath/Monthly Data 4");

/* ConcatRawCombined
 *
 * This takes a list of `|`-separated filenames, all of which must
 * be present in the cwd at runtime, and concatenates their data.
 *
 * Args:
 *   `files`: a list of filenames (with extensions) in the form
 * 					file1.ext | file2.ext | file3.ext
 *		Extension was added to these names to allow us to pick
 *		the delimiter based off typical delimiters for these files.
 *		E.g., .csv files will be assigned a delimiter of ','.
 */
%macro ConcatRawCombined(files=,out=concat,outlib=work);
%let i=1;
%let file=%scan(&files,&i,|);
%do %while(&file ne );
	%let name=%scan(&file,1,.);
	%let ext=%scan(&file,-1,.);
	%if (&ext eq csv) %then %do;
		%let delim=',';
	%end;
	%else %do;
		%let delim='09'x;
	%end;
	%put &name -- &ext -- &delim;
	data nextData;
		infile "&name..&ext" dlm=&delim firstobs=2;
		input City:$10. Department:$25. Personnel Equipment Material Incidental;
	run;

	%if(&i eq 1) %then %do;
		data &outlib..&out;
			set nextData;
			*length month $?;
			Month="&name";
		run;
	%end;
	%else %do;
		data &outlib..&out;
			set &outlib..&out nextData(in=current);
			if current then Month="&name";
		run;
	%end;
	%let i=%eval(&i+1);
	%let file=%scan(&files,&i,|);
%end;/***WHILE ends here**/
%mend;

%let return=%sysfunc(dlgcdir("&datapath/monthly data 1"));
%ConcatRawCombined(files=month1.txt| month2.txt| month3.txt);
%let return=%sysfunc(dlgcdir("&datapath/monthly data 2"));
%ConcatRawCombined(files=month 1.txt| month 2.txt| month 3.txt);
%let return=%sysfunc(dlgcdir("&datapath/monthly data 3"));
%ConcatRawCombined(files=April.txt | February.txt | January.txt);
%let return=%sysfunc(dlgcdir("&datapath/Monthly Data 4"));
%ConcatRawCombined(files=April.csv | February.csv | January.csv);

