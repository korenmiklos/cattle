clear all
set more off
capture log close
log using ../doc/merge_zips, text replace

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

* keep only 2-digit NAICS
keep if substr(naics,3,4)=="----"

* estimate employment
gen emp = n1_4*2.5 + n5_9*7 + n10_19*15 + n20_49*35 + n50_99*75 + n100_249*175 + n250_499*375 + n500_999*750 + n1000*2000

gen sector = real(substr(naics,1,2))
drop n*

* fill in all sectors
reshape wide est emp, i(zip) j(sector)
reshape long
replace est=0 if missing(est)
replace emp=0 if missing(emp)

* merge different sectors
recode sector 11 = 1 21 22 23 31 = 2 * =3
collapse (sum) emp est, by(zip sector)

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


* merge naics land and labor shares
gen laborshare = 0.46
replace laborshare = 0.67 if sector==2
replace laborshare = 0.66 if sector==3

gen landshare = 0.18
replace landshare = 0.03 if sector==2
replace landshare = 0.06 if sector==3

* calculate densities
gen emp_density = emp/area
gen est_density = est/area
gen lndistance = ln(distance)
label var lndistance "Distance to city center (log)"

* split up area between activities
egen people = sum(emp), by(zip)
egen landdemand = sum(emp/laborshare*landshare), by(zip)
* people living or working in this zip code all take up space
* population has land share 0.3*0.36
replace landdemand = landdemand+pop*0.3*0.36

* allocate area of ZIP to sectors based on their direct need 
gen share = emp/laborshare*landshare/landdemand
su share, d
xi: reg share i.sector*lndistance


* area of zip is split across sectors and homeowners
gen imputed_area = share*area
gen residential_area = pop*0.3*0.36/landdemand*area

gen establishment_size = emp/est
gen imputed_density = emp/imputed_area

saveold ../data/zip_business_patterns, replace

* calculate total areas
collapse (sum) emp imputed_area residential_area (mean) landshare laborshare, by(sector)
egen sumemp = sum(emp)
gen indirect_land = emp/sumemp*residential_area

l sector imputed_area indirect_land

residential_area

l

log close
set more on
