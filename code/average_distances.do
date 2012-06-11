clear all
set more off
capture log close
log using ../doc/average_distances, text replace

use ../data/zip_business_patterns

* convert population into sector 0
expand 1+(sector==1), gen(expanded)
replace sector=0 if expanded
replace emp = pop if expanded

* nonzero number of establishments
gen byte are = area if est>0 & !missing(est)
replace lndistance = . if missing(emp,pop)
replace emp = . if missing(lndistance,pop)
replace pop = . if missing(lndistance,emp)

sort sector distance
by sector: gen cumsum = sum(emp)
egen maxcumsum = max(cumsum), by(sector)
replace cumsum = cumsum/maxcumsum
label var cumsum "Cumulative share of employment"

* empirical CDF of weighted distances in the three sectors
tw (line cumsum lndistance if sector==1, sort) /*
*/ (line cumsum lndistance if sector==2, sort) /*
*/ (line cumsum lndistance if sector==3, sort) /*
*/ (line cumsum lndistance if sector==0, sort) /*
*/, scheme(s2color) legend(order(1 "Agriculture" 2 "Industry" 3 "Services" 4 "Housing"))

* median weighted distances
table sector if cumsum<=.5, c(max distance)

* 90th pect weighted distances
table sector if cumsum<=.9, c(max distance)

foreach X of var emp pop est are {
	gen `X'distance = `X'*lndistance
}

collapse (sum) ???distance emp est pop are, by(sector)
foreach X of var emp pop est are {
	replace `X'distance = exp(`X'distance/`X')
}
l sector ???distance

log close
set more on
