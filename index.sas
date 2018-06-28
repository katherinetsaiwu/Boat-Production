We started proc import out = boatcomplete 
/* data saved in WORK*/
datafile = "\\itfs1\cnwendt\Desktop\BoatProduction.xls"
        DBMS=xls REPLACE;
RUN;
proc print data = boatcomplete;

* BASIC REGRESSION WITH BOTH VARIABLES;

proc reg data = boatcomplete;
model Number_of_Boats = Units Workers;
title 'Basic Regression w/ Both Variables';
run; quit;

* BASIC REGRESSION WITH UNITS VARIABLE;

proc reg data = boatcomplete;
model Number_of_Boats = Units;
title 'Basic Regression w/ Units Variable';
run; quit;

* BASIC REGRESSION WITH WORKERS VARIABLE;

proc reg data = boatcomplete;
model Number_of_Boats = Workers;
title 'Basic Regression w/ Workers Variable';
run; quit;

*CP METHOD ONLY;

proc reg data = boatcomplete;
model Number_of_Boats = Units Workers/selection = cp;
run;

*CP & ADJ R^2 METHOD;

proc reg data = boatcomplete;
model Number_of_Boats = Units Workers/selection = cp adjrsq;
run;

*CP & ADJ R^2 & RMSE METHOD;

proc reg data = boatcomplete;
model Number_of_Boats = Units Workers/selection = cp adjrsq rmse;
run;

*BEST SUBSET METHOD (TOP 1);

proc reg data = boatcomplete;
model Number_of_Boats = Units Workers/selection = rsquare rmse cp best = 1;
run;

* BACKWARD ELIMINATION (P = 0.15);

proc reg data = boatcomplete;
model Number_of_Boats = Units Workers/selection = backward sls = 0.15;
run;

* FORWARD SELECTION (P = 0.15);

proc reg data = boatcomplete;
model Number_of_Boats = Units Workers/selection = forward sle = 0.15;
run;

* STEPWISE REGRESSION;

proc reg data = boatcomplete;
model Number_of_Boats = Units Workers/selection = stepwise sle = 0.15 sls = 0.10;
run;

quit;

* LACK OF FIT TESTS;

proc reg data = boatcomplete;
model Number_of_Boats = Units/lackfit;
title 'Lack of Fit - Units';
run;quit; *this says that Units are not linear, does that mean the units has to be thrown out?; *transpose the variable?;

proc reg data = boatcomplete;
model Number_of_Boats = Workers/lackfit;
title 'Lack of Fit - Workers';
run;quit;

* Transform the Units variable via a polynomial transformation;

data boatcomplete1;
set boatcomplete;
Units2 = Units * Units;
Units3 = log(Units);
Workers2 = Workers * Workers;
Workers3 = log(Workers);
Number_of_Boats2 = log(Number_of_Boats);
run;

* POLYNOMIAL TRANSFORMATION;

proc reg data = boatcomplete1;
model Number_of_Boats = Units2/lackfit;
title 'Lack of Fit - Units^2';
run;quit;

* LINEAR-LOG TRANSFORMATION;

proc reg data = boatcomplete1;
model Number_of_Boats = Units3/lackfit;
title 'Lack of Fit - Linear-Log';
run;quit;

* LOG-LINEAR TRANSFORMATION;

proc reg data = boatcomplete1;
model Number_of_Boats2 = Units/lackfit;
title 'Lack of Fit - Log-Linear';
run;quit;

* DOUBLE-LOG TRANSFORMATION;

proc reg data = boatcomplete1;
model Number_of_Boats2 = Units3/lackfit;
title 'Lack of Fit - Double-Log';
run;quit;

* FINAL REGRESSION;

proc reg data = boatcomplete1;
model Number_of_Boats2 = Workers Units3;
title 'Final Regression';
run;quit;

* QUADRATIC TERMS TO BOTH VARIABLES;

proc reg data = boatcomplete1;
model Number_of_Boats = Units2 Workers2;
title 'Quadratic Equation for Both Variables';
run; quit;

* CLASSICAL ASSUMPTION II & VII - MODEL OUT THE RESIDUALS;

proc reg data = boatcomplete1;
model Number_of_Boats2 = Workers Units3;
output out = residuals1 
r = yresid zresid;run;
run;

proc univariate data = residuals1;
var yresid;
histogram yresid/normal;
run;

* CLASSICAL ASSUMPTION III - EXPLANATORY VARIABLES NOT CORRELATED WITH THE ERROR TERM;

proc corr data = residuals1;
run;

* CLASSICAL ASSUMPTION V - TESTING FOR HETEROSKETASTICITY; 

proc reg data = boatcomplete1;
model Number_of_Boats2 = Workers Units3/spec; run;

* CLASSICAL ASSUMPTION VI - TESTING FOR MULTICOLLINEARITY;

proc reg data = boatcomplete1;
model Number_of_Boats2 = Workers Units3/vif; run;

* CLASICAL ASSUMPTION VII - TESTING FOR A NORMAL DISTRIBUTION OF THE RESIDUALS (WE CAN DISREGARD THIS CODE, NO?);

proc transreg data = boatcomplete1 test;
model BoxCox(Number_of_Boats2) = identity(Units3);
run;

proc transreg data = boatcomplete1 detail
plots = (transformation (dependent) obp);
model boxcox (Number_of_Boats2/ convenient lambda = -1 to 2 y 0.05) = 
gpoint (Units3);
run;
quit;

* COBB-DOUGLAS ATTEMPT;

data boatcomplete2;
set boatcomplete1;
yhat = 3.69948*Units**0.0575*Workers**0.9425;
run;

symbol c=blue v= star i=r;
proc gplot data = boatcomplete2;
plot Number_of_Boats*yhat;
run;

data boatcomplete2;
set boatcomplete1;
yhat = 3.69948*Units**0.0575*Workers**0.9425;
run;

symbol c=blue v= star i=r;
proc gplot data = boatcomplete2;
plot Number_of_Boats*yhat;
run;

