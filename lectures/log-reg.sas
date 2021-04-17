

/* Binary responses */
data cars;
	set sashelp.cars;
	select(type);
		when('Sedan','Wagon') car=1;
		when('Truck','SUV')   car=0;
		otherwise delete;
	end;
run;

proc standard data=cars out=carsSTD mean=0;
	var weight enginesize;
run;

ods graphics off;
proc glm data=carsSTD;
	model car = weight enginesize / solution;
	ods select ParameterEstimates;
	output out=pred predicted=Pcar;
run;

proc sgplot data=pred;
	scatter x=weight y=enginesize /
			markerattrs=(symbol=circlefilled)
			colorresponse=Pcar;
run;

data class;
	set pred;
	length PredType $5;
	if Pcar gt 0.5 then PredType='Car';
		else PredType='Truck';
run;

proc format;
	value $type
		'Sedan','Wagon'='Car'
		'Truck','SUV'='Truck'
	;
run;

proc freq data=class order=formatted;
	table type*PredType / nopercent nocol;
	format type $type;
run;

proc sgplot data=class;
	scatter x=weight y=enginesize /
			markerattrs=(symbol=circlefilled)
			group=PredType
			name='Scatter';
	lineparm x=0 y=%sysevalf((0.5-0.7766)/0.099159)
			 slope=%sysevalf(0.000402/0.099159);
	yaxis values=(-2 to 4 by 1);
	keylegend 'Scatter' / 
			  position=topleft
			  location=inside
			  title=''
			  across=1;
run;