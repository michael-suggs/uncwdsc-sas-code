filename RawData ('C:\Users\blumj\Documents\Book Files\Data\Raw Data Sets');

data try1;
 infile RawData('FlightsMiss03.txt');
 /***FLOWOVER is in effect***/
 input FlightNum Destination$ Passengers;
run;

data tryMiss;
 infile RawData('FlightsMiss03.txt') Missover;
 /******/
 input FlightNum Destination$ Passengers;
run;

data tryTrunc;
 infile RawData('FlightsMiss03.txt') Truncover;
 /***For delimited files, or list/modified list input, there's no
   difference between missover and truncover***/
 input FlightNum Destination$ Passengers;
run;


data tryMiss2;
 infile RawData('FlightsMiss03.txt') Missover;
 input FlightNum 1-2 Destination$ 4-6 Passengers 8-10;
run;

data tryTrunc2;
 infile RawData('FlightsMiss03.txt') Truncover;
 input FlightNum 1-2 Destination$ 4-6 Passengers 8-10;
 /**they only differ for fixed-position stuff, and then
  only when a specific set of columns referenced in input
   is incomplete--truncover tries to work with what is there
   missover just makes it missing**/
run;