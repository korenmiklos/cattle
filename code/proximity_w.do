clear
set mem 300m

tempfile densities naics2bea

/* save a tempfile of country densities */
xmluse ../data/census/county_census.xml
ren geo fips
keep fips density

/* worry about skewed densities */
replace density = log(density)
sort fips

save `densities'

/* save a tempfile of naics codes */

clear

insheet using ../data/census/naics22bea.txt

sort naics

save `naics2bea'

clear

/* sorry, but this is over 100mb, not checking in */
insheet using ~/share/data/CBP/cbp05co.csv

scalar define sector_type="BEA"  /*"TNT" for traded/non-traded or 
				   "AMS" for agriculture/manufcaturing/services
				   "BEA" for BEA codes */
scalar define weight_type="emp"  /*"emp" for employment
				   "est" for establishment*/

/* keep 2-digit naics */
keep if substr(naics,3,4)=="----"
drop if naics=="------"
gen naics_r = real(substr(naics,1,2))
drop naics
ren naics_r naics

if weight_type=="emp" {
	keep fips* naics emp*
	gen empclass=0
	replace empclass=10 	if empflag=="A"
	replace empclass=60 	if empflag=="B"
	replace empclass=175 	if empflag=="C"
	replace empclass=375 	if empflag=="E"
	replace empclass=750 	if empflag=="F"
	replace empclass=1750 	if empflag=="G"
	replace empclass=3750 	if empflag=="H"
	replace empclass=7500 	if empflag=="I"
	replace empclass=17500 	if empflag=="J"
	replace empclass=37500 	if empflag=="K"
	replace empclass=75000 	if empflag=="L"
	replace empclass=100000 if empflag=="M"

	replace emp=emp+empclass
	drop empclass
}
else {
	keep fips* naics est
}
compress



/* switch to bea codes */

sort naics
merge naics using `naics2bea', nokeep
tab _m
drop _m



/* collapse by sectors */

drop if missing(bea)


/* generating indicator variables */
if sector_type=="TNT" {
	gen sector = bea
	recode sector min/6 12 34 = 1 * = 2
	label define sectorname 1 "traded" 2 "non-traded"
}
else if sector_type=="AMS" {
	gen sector = bea
	recode sector 3=1 12=2 34/max=3 *=0
	label define sectorname 0 "others" 1 "agriculture" 2 "manufacturing" 3 "services"
}
else {
	gen sector = bea
}
scalar drop sector_type
label values sector sectorname
if weight_type=="emp" collapse (sum) emp, by(sector fipstate fipscty)

else collapse (sum) est, by(sector fipstate fipscty)


/* calculate shares */
if weight_type=="emp" {
	egen naicsemp = sum(emp), by(sector)
	gen countyshare = emp/naicsemp
	drop *emp
}
else {
	egen naicsest = sum(est), by(sector)
	gen countyshare = est/naicsest
	drop *est
}

su countyshare

gen fips = fipstate*1000+fipscty
drop fipstate fipscty

/* now merge with densities */
sort fips
merge fips using `densities'
tab _merge
drop _merge
su

/* to get rid of unbalanced MVs */
replace density = . if missing(density,countyshare)
replace countyshare = . if missing(density,countyshare)

/* weighting */
replace density = density*countyshare

collapse (sum) density countyshare, by(sector)
su countyshare, d

replace density = density/countyshare
drop countyshare

/* go back to levels */
replace density = exp(density)

label var density "Average population density of sector location"

sort sector
xmlsave ../data/census/proximity.xml, replace
