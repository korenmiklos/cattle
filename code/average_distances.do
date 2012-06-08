clear all
set more off
capture log close
log using ../doc/average_distances, text replace

use ../data/zip_business_patterns

replace distance = . if missing(emp,pop)
replace emp = . if missing(distance,pop)
replace pop = . if missing(distance,emp)

foreach X of var emp pop est {
	gen `X'distance = `X'*distance
}

collapse (sum) ???distance emp est pop, by(sector msa)
foreach X of var emp pop est {
	replace `X'distance = `X'distance/`X'
}
gen lnpopdistance = ln(popdistance)

poisson empdistance lnpopdistance i.sector

log close
set more on
