ods graphics off;
ods trace on;
proc reg data=statdata.realestate;
	model price = sq_ft;
	ods select ParameterEstimates;
	/***form of model statement: model response = predictor(s);***/
run;
/**Estimate is:
	price = -81,433 + 159.0*sqFt ***/

proc glm data=statdata.realestate;
	model price = sq_ft;
	ods select ParameterEstimates;
	/***GLM has the same form for the model 
	statement***/
run;/**estimation method (least-squares)
	is the same, so then is the result**/
	
/**price = -81,433 + 159.0*sqFt
		159 -> the price increases $159, on average,
			for a 1 sq. foot increase in size
			
		-81,443 -> we should not interpret 
			(average value of a 0 sq foot home is
				-$81,443)
				***/

proc reg data=statdata.realestate;
	model price = bedrooms;
	ods select ParameterEstimates;
run;

/***estimate: price = 82,809 + 56,200*bedrooms
	price increases on average by $56,200 per bedroom
	
	82,809 average price for empty lot?**/
	
proc reg data=statdata.realestate;
	model price = bedrooms sq_ft ;
	ods select ParameterEstimates;
	/***form of model statement: model response = predictor(s);***/
run;

/**estimate:
	price = -66,972 + 165.83*sqFt - 8647.51*beds
	
	the price increases, on average, by $165.83 per
	unit increase in sq footage, for a fixed number
	of bedrooms
	
	the price decreases, on average, by $8647.51
		for each additional bedroom, for fixed 
		square footage ***/
		
proc sgplot data=statdata.realestate;
	scatter y=sq_ft x=bedrooms / jitter jitterwidth=.8 
			markerattrs=(symbol=circlefilled) colorresponse=price
			colormodel=(red orange yellow green blue);
run;
	
	
proc glm data=statdata.realestate;
	model price = bedrooms sq_ft bedrooms*sq_ft;
	ods select ParameterEstimates;
run;
/**estimate:
price = -203K + 27541*beds + 228*sqFt 
				-15.76*beds*sqFt
				
	228 is not the average increase in price
	 per sq foot for a fixed number of bedrooms

	average change in price for a unit change
	in sq footage is 228-15.76*beds
	***/
				