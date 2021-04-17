proc report data=sashelp.cars;
run;
/***with no other statements, just prints data to the output**/

proc report data=sashelp.cars;
	column origin mpg_city mpg_highway;
	/***column is like var, but more versatile***/
run;

proc report data=sashelp.cars;
	column mpg_city mpg_highway;
	/***report like summarize stuff,
		 if only numeric variables are given,
		 it produces a single summary***/
run;

proc report data=sashelp.cars;
	column origin mpg_city mpg_highway;
	define origin / 'Country of Origin'
						group;
						/**group behaves like class,
							if the non-grouped are numeric,
							you get a summary (sum)**/
run;

proc report data=sashelp.cars;
	column origin mpg_city mpg_highway;
	define origin / 'Country of Origin'
						group;
	define mpg_city / mean 'Mean City MPG' format=6.1;
	define mpg_highway / median 'Median Hwy MPG' format=6.1;
run;

proc report data=sashelp.cars;
	column origin type mpg_city mpg_highway;
	where type not in ('Hybrid','Truck');
	define origin / 'Country of Origin' group;
	define type / group;
	define mpg_city / mean 'Mean City MPG' format=6.1;
	define mpg_highway / median 'Median Hwy MPG' format=6.1;
run;

proc report data=sashelp.cars;
	column origin type mpg_city mpg_highway;
	where type not in ('Hybrid','Truck');
	define origin / 'Country of Origin' group;
	define type / group;
	define mpg_city / mean 'Mean City MPG' format=6.1;
	define mpg_highway / median 'Median Hwy MPG' format=6.1;
	rbreak after / summarize;
	/**rbreak -> report break line--can go at the top or
		bottom (before or after) 
		summarize says include the same statistic in the columns
			for that row as in the rest of the report***/
run;


proc report data=sashelp.cars;
	column origin type mpg_city mpg_highway;
	where type not in ('Hybrid','Truck');
	define origin / 'Country of Origin' group;
	define type / group;
	define mpg_city / mean 'Mean City MPG' format=6.1;
	define mpg_highway / median 'Median Hwy MPG' format=6.1;
	break after origin / summarize;
	/***break allows you to insert lines before or after
			groups created on a variable using the GROUP option**/
	rbreak after / summarize;
run;


proc report data=sashelp.cars;
	/***what if I want some different stats on the same variable?**/
	column origin type mpg_city=num mpg_city=avg mpg_city=median
											mpg_city=sd;
			/**Any variable can be given an alias....***/
	where type not in ('Hybrid','Truck');
	define origin / 'Country of Origin' group;
	define type / group;
	define num / n 'N';
	define avg / mean 'Mean City MPG' format=6.1;
	define median / median 'Median City MPG' format=6.1;
	define sd / std 'Standard Deviation' format=7.2;
	/***write define statements for each alias***/
	break after origin / summarize;
	rbreak after / summarize;
run;

proc report data=sashelp.cars;
	/***what if I want some different stats on the same variable?**/
	column origin type mpg_city,(n mean median std);
	/**can attach a list of stat keywords to a variable
		with comma and parentheses...***/
	where type not in ('Hybrid','Truck');
	define origin / 'Country of Origin' group;
	define type / group;
	define mpg_city / '';
	define n / 'N';
	define mean / 'Mean City MPG' format=6.1;
	define median / 'Median City MPG' format=6.1;
	define std / 'Standard Deviation' format=7.2;
	/***define based on those keywords***/
	break after origin / summarize;
	rbreak after / summarize;
run;

proc report data=sashelp.cars;
	column origin type (mpg_city mpg_highway),(mean median);
	where type not in ('Hybrid','Truck');
	define origin / 'Country of Origin' group;
	define type / group;
	define mpg_city / 'City';
	define mpg_highway / 'Highway';
	define mean / 'Mean MPG';
	define median / 'Median MPG';
run;

proc report data=sashelp.cars;
	column origin type mpg_city=cityMean mpg_city=cityMedian
				mpg_highway=hwyMean mpg_highway=hwyMedian;
	where type not in ('Hybrid','Truck');
	define origin / 'Country of Origin' group;
	define type / group;
	define cityMean / mean 'Mean City MPG' format=6.1;
	define cityMedian / median 'Median City MPG' format=6.1;
	define hwyMean / mean 'Mean Highway MPG' format=6.1;
	define hwyMedian / median 'Mean Highway MPG' format=6.1;
run;
			

proc report data=sashelp.cars;
	column type mpg_city,origin,(mean median) 
			mpg_city=AllMean mpg_city=AllMedian;
	where type not in ('Hybrid','Truck');
	define origin / ' ' across;
	define type / group;
	define mpg_city / '';
	define mean / 'Mean City MPG' format=6.1;
	define median / 'Median City MPG' format=6.1;
	define AllMean / mean 'Overall City Mean' format=6.1;
	define AllMedian / median 'Overall City Median' format=6.1;
	rbreak after / summarize;
run;
		
