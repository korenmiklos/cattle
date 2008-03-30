clear
set mem 300m

tempfile densities naics2bea

/* save a tempfile of country densities */
xmluse ..\data\census\county_census.xml
ren geo fips
keep fips density
sort fips

save `densities'

/* save a tempfile of naics codes */

clear

insheet using ..\data\census\naics22bea.txt

sort naics

save `naics2bea'

clear

/* sorry, but this is over 100mb, not checking in */
insheet using ..\data\census\CBP\cbp05co.txt

scalar define sector_type="TNT"  /*"TNT" for traded/non-traded or 
				   "AMS" for agriculture/manufcaturing/services*/
scalar define weight_type="est"  /*"emp" for employment
				   "est" for establishment*/

/* keep 2-digit naics */
keep if substr(naics,3,4)=="----"
drop if naics=="------"
gen naics_r = real(substr(naics,1,2))
drop naics
gen naics=naics_r
drop naics_r

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
	gen I_T=0
	gen I_NT=0
	replace I_T=1 if bea<=6 | bea==12 | bea==34
	replace I_NT=1 if I_T==0
	gen sector=I_T+2*I_NT
	label define sectorname 1 "traded" 2 "non-traded"
}
else {
	gen I_agricult=0
	gen I_manuf=0
	gen I_serv=0
	replace I_agricult=1 if bea==3
	replace I_manuf=1 if bea==12
	replace I_serv=1 if bea>=34
	gen sector=I_agricult+2*I_manuf+3*I_serv
	label define sectorname 0 "others" 1 "agriculture" 2 "manufacturing" 3 "services"
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

label var density "Average population density of sector location"

sort sector
xmlsave ../data/census/proximity.xml, replace
