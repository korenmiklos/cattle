clear
set mem 300m

tempfile densities

/* save a tempfile of country densities */
xmluse ../data/census/county_census.xml
ren geo fips
keep fips density
sort fips

save `densities'

clear

/* sorry, but this is over 100mb, not checking in */
insheet using /share/data/CBP/cbp05co.csv

/* keep 3-digit naics */
keep if substr(naics,4,3)=="///"
replace naics = substr(naics,1,3)
destring naics, force replace

keep fips* naics est
compress

/* calculate shares */
egen naicsest = sum(est), by(naics)
gen countyshare = est/naicsest
su countyshare

drop *est
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

collapse (sum) density countyshare, by(naics)
su countyshare, d

replace density = density/countyshare
drop countyshare

label var density "Average population density of sector location"

sort naics
xmlsave ../data/census/proximity.xml, replace
