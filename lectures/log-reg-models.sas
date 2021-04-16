/* Modeling Car/Truck categories */
proc format;
	value $type
		'Sedan','Wagon'='Car'
		'Truck','SUV'='Truck'
	;
run;

proc logistic data=sashelp.cars;
	where type not in ('Sports','Hybrid');
	model type = weight enginesize;
	format type $type.;
run;
