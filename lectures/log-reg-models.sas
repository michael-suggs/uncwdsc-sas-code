/* Binary Logistic GLM */
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

/* model with GLM */
proc genmod data=sashelp.cars;
	where type not in ('Sports','Hybrid');
	format type $type.;
	/* binomial distribution since binary outcomes */
	/* default is logit, but specify to be sure */
	model type = weight enginesize /
		  dist=binomial
		  link=logit;
run;

/* Categorical predictor in logistic and genmod */
proc logistic data = sashelp.cars;
	where type not in ('Sports','Hybrid');
	class origin;
	model type = origin weight enginesize;
	format type $type.;
	ods select ParameterEstimates CumulativeModelTest;
run;

proc genmod data=sashelp.cars;
	where type not in ('Sports','Hybrid');
	format type $type.;
	class origin;
	model type = origin weight enginesize
		/ dist=binomial link=logit;
	ods select ParameterEstimates;
run;



/* Multi-Category Responses */
/* Modeling origin categories (5.2.1) */
proc logistic data=sashelp.cars;
	model origin = horsepower weight mpg_city msrp length
		/ link=glogit;
	ods exclude ModelInfo Nobs ConvergenceStatus GlobalTests FitStatistics;
run;

/* Modeling blood pressure status (5.2.2) */
proc logistic data=sashelp.heart;
	model bp_status = AgeAtStart Weight
		/ link=logit;
	ods select ResponseProfile
			   FitStatistics
			   CumulativeModelTest
			   ParameterEstimates
			   OddsRatios;
run;

proc logistic data=sashelp.heart;
	model bp_status = AgeAtStart Weight
		/ link=alogit;
	ods select ResponseProfile
			   ParameterEstimates
			   OddsRatios;
run;

/* Modeling cholestrol pressure status */
proc format;
	value $CholReOrder
		'Desirable'='1. Desirable'
		'Borderline'='2. Borderline'
		'High'='3. High'
	;
run;

proc logistic data=sashelp.heart;
	format chol_status $CholReOrder.;
	model chol_status = AgeAtStart Weight
		/ link=logit;
	ods select ResponseProfile
			   FitStatistics
			   CumulativeModelTest
			   ParameterEstimates
			   OddsRatios;
run;