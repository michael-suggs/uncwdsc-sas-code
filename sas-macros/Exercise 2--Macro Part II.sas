%let return=%sysfunc(dlgcdir('G:\SeaShare\SAS Programming Data\Monthly Data 2'));

%macro ConcatRaw(files=,ext=txt,out=concat,outlib=work);
 %let i=1;
 %let file=%scan(&files,&i,|);
 %do %while(&file ne );
  data nextData;
   infile "&file..&ext" dlm='09'x firstobs=1;
   input City:$10. Department:$25. Personnel Equipment Material Incidental;
  run;
  
  %if(&i eq 1) %then %do;/***Establishes the final data set
    correctly as a new data set containing information
     from the first read only***/
   data &outlib..&out;
    set nextData;
    *length month $?;
    Month="&file";
   run;
  %end;

  %else %do;
   data &outlib..&out;
    set &outlib..&out nextData(in=current);
    if current then Month="&file";/***Only need/want to
     update this for the new records read in on this iteration**/
   run;
  %end;
  
  %let i=%eval(&i+1);
  %let file=%scan(&files,&i,|);
 %end;/***WHILE ends here***/
%mend;
%ConcatRaw(files=month 1| month 2| month 3);
/**this can now read Monthly Data 2***/

%let return=%sysfunc(dlgcdir('G:\SeaShare\SAS Programming Data\Monthly Data 3'));
%ConcatRaw(files=January| February| March);
/***This is fine, except that the lengths of the names (months)
 are not all the same now, so we could (do) get truncation**/


%macro ConcatRawCSV(files=,ext=txt,out=concat,outlib=work);
 %let i=1;
 %let file=%scan(&files,&i,|);
 %do %while(&file ne );
  data nextData;
   infile "&file..&ext" dlm=',' firstobs=2;
   input City:$10. Department:$25. Personnel Equipment Material Incidental;
  run;
  
  %if(&i eq 1) %then %do;/***Establishes the final data set
    correctly as a new data set containing information
     from the first read only***/
   data &outlib..&out;
    set nextData;
    *length month $?;
    Month="&file";
   run;
  %end;

  %else %do;
   data &outlib..&out;
    set &outlib..&out nextData(in=current);
    if current then Month="&file";/***Only need/want to
     update this for the new records read in on this iteration**/
   run;
  %end;
  
  %let i=%eval(&i+1);
  %let file=%scan(&files,&i,|);
 %end;/***WHILE ends here***/
%mend;

%let return=%sysfunc(dlgcdir('G:\SeaShare\SAS Programming Data\Monthly Data 4'));
%ConcatRawCSV(files=January| February| March,ext=csv);

