clear all
set more off
capture log close
log using ../doc/merge_zips_2digit, text replace

local CBP ~/SparkleShare/County-Business-Patterns

* read zip-level population
tempfile zippop
insheet using `CBP'/population/zcta_county_rel_10.txt
collapse (mean) zpop zhu zarealand, by(zcta5)
ren zcta5 zip
replace zarealand = zarealand/1e+6
ren zarealand ziparea
ren zpop pop
ren zhu homes
sort zip 
save `zippop', replace

clear
insheet using `CBP'/2007/zbp07detail.txt

* drop sector totals, no new info
drop if naics=="------"

* keep only 6-digit NAICS
drop if substr(naics,6,1)=="-"

* estimate employment
gen emp = n1_4*2.5 + n5_9*7 + n10_19*15 + n20_49*35 + n50_99*75 + n100_249*175 + n250_499*375 + n500_999*750 + n1000*2000

gen sector = real(substr(naics,1,3))
drop n*

* merge different sectors
collapse (sum) emp est, by(zip sector)

* fill in all sectors
reshape wide est emp, i(zip) j(sector)
reshape long
replace est=0 if missing(est)
replace emp=0 if missing(emp)

* merge distances and areas
csvmerge zip using ../data/census/cbp/zip.csv
tab _m
tab _m [fw=est]
* nonmatched zips are only 1.54% of establishments, drop them

keep if _m==3
drop _m

* use distance to urban area, not MSA
ren citydistance distance
ren city city

* area is in m2, convert to km2
replace area = area/1e+6

* merge population data
merge m:1 zip using `zippop', keep(match)
drop _m

corr area ziparea


* calculate densities
gen emp_density = emp/area
gen est_density = est/area
gen lndistance = ln(distance)
label var lndistance "Distance to city center (log)"

* split up area between activities
egen people = sum(emp), by(zip)
* people living or working in this zip code all take up space
replace people = people+pop
gen share = emp/people
su share, d
reg share lndistance

* area of zip is split across sectors and homeowners
gen imputed_area = share*area

gen establishment_size = emp/est
gen imputed_density = emp/imputed_area

saveold ../data/zip_business_patterns_3digit, replace

log close
set more on
