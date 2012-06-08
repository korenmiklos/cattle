clear all
set more off
capture log close
log using ../doc/zip_level_gradients, text replace

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
gen sectorgroup = sector
recode sectorgroup 11 = 1 21 31 = 2 * =3
collapse (sum) emp est, by(zip sectorgroup)

* merge distances and areas
csvmerge zip using ../data/census/cbp/zip.csv
tab _m
tab _m [fw=est]
* nonmatched zips are only 1.54% of establishments, drop them

keep if _m==3
drop _m

* are is in m2, convert to km2
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

egen msacode = group(msa)

su sectorgroup
local max `r(max)'

* nonparametric gradients
local K 33
egen distpct = cut(distance), group(`K')
egen mean_emp_dens = mean(emp_dens), by(distpct sectorgroup)
egen tag = tag(distpct sectorgroup)

gen ln_mean_emp_dens = ln(mean_emp_dens)

tw (line ln_mean_emp_dens distance if tag&sectorgroup==1&distance<=100, sort) /*
*/ (line ln_mean_emp_dens distance if tag&sectorgroup==2&distance<=100, sort) /*
*/ (line ln_mean_emp_dens distance if tag&sectorgroup==3&distance<=100, sort) /*
*/, legend(order(1 "Agriculture" 2 "Manufacturing" 3 "Services")) scheme(s2color)

preserve
* calculate shares
collapse emp est lndistance distance, by(sectorgroup distpct)
reshape wide emp est, i(distpct) j(sectorgroup)
egen totalemp = rsum(emp?)
sort distance
forval i=1/`max' {
	gen share`i' = emp`i'/totalemp
	gen lnshare`i' = ln(emp`i'/totalemp)
	gen share`i'norm = ln(share`i'/share`i'[1])
}
tw (line share?norm lndistance, sort), legend(order(1 "Agriculture" 2 "Manufacturing" 3 "Services")) scheme(s2color)

restore


* sector-level regressions
gen lower = 0
gen upper = 500
replace upper = 20 if sectorgroup==3
replace lower = 20 if sectorgroup==2
replace upper = 100 if sectorgroup==2
replace lower = 100 if sectorgroup==1

gen establishment_size = emp/est
gen imputed_density = emp/imputed_area

foreach X in emp_density establishment_size imputed_density {
	gen tau_`X' = .
	forval i = 1/`max' {
		xtpoisson `X' distance if sectorgroup==`i' & distance>=lower & distance<upper, i(msacode) fe
		replace tau_`X' = _b[distance] if sectorgroup==`i'
	}
}
table sectorgroup, c(mean tau_emp_density mean tau_establishment_size mean tau_imputed_density)

log close
set more on
