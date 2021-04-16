data cars;
	set sashelp.cars;
	Asia=0; Europe=0; USA=0;
	select(origin);
		when('Asia')   Asia=1;
		when('Europe') Europe=1;
		when('USA')    USA=1;
	end;
run;

ods graphics off;
ods select none;
proc glm data=cars;
	model Asia Europe USA = horsepower weight mpg_city msrp length;
	output out=predictions predicted=PAsia PEurope PUSA;
	where type ne 'Hybrid';
run;

ods select all;
proc sgplot data=predictions;
	scatter y=origin x=PAsia /
			jitter
			legendlabel='PAsia'
			markerattrs=(symbol=circle color=blue);
	scatter y=origin x=PEurope /
			jitter
			legendlabel='PEurope'
			markerattrs=(symbol=square color=red);
	scatter y=origin x=PUSA /
			jitter
			legendlabel='PUSA'
			markerattrs=(symbol=triangle color=green);
	xaxis label='Predicted';
	keylegend / across=1 position=topright location=inside;
run;