clear
set mem 300m

tempfile densities naics2bea

clear

insheet using ../data/census/naics2bea.csv

sort naics

save `naics2bea'

clear

use ../data/zip_business_patterns_4digit

scalar define weight_type="est"  /*"emp" for employment
				   "est" for establishment*/

compress

* worry about outliers
replace distance = ln(distance)



/* calculate shares */
if weight_type=="emp" {
	egen naicsemp = sum(emp) if !missing(distance), by(sector)
	gen countyshare = emp/naicsemp
	drop *emp
}
else {
	egen naicsest = sum(est) if !missing(distance), by(sector)
	gen countyshare = est/naicsest
	drop *est
}

su countyshare


/* to get rid of unbalanced MVs */
replace distance = . if missing(distance,countyshare)
replace countyshare = . if missing(distance,countyshare)

/* weighting */
replace distance = distance*countyshare

collapse (sum) distance countyshare, by(sector)
su countyshare, d

replace distance = distance/countyshare
drop countyshare


/* go back to levels */

replace distance = exp(distance)

label var distance "Average distance of sector to city center"

sort sector
xmlsave ../data/census/proximity.xml, replace
