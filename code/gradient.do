clear all
set more off
log using ../doc/zip_level_gradients, text replace

local CBP ~/SparkleShare/County-Business-Patterns

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

* merge distances and areas
csvmerge zip using ../data/census/cbp/zip.csv
tab _m
tab _m [fw=est]
* nonmatched zips are only 1.54% of establishments, drop them

keep if _m==3
drop _m

* calculate densities
gen emp_density = emp/area
gen est_density = est/area
gen distance100 = distance/100

egen msacode = group(msa)

* regressions
*poisson est_density distance100 i.msacode i.sector
*poisson emp_density distance100 i.msacode i.sector

gen sectorgroup = sector
recode sectorgroup 11 = 1 21 31 = 2 * =3
su sectorgroup
local max `r(max)'

egen citysector = group(msa sector)

* sector-level regressions
gen tau = .
forval i = 1/`max' {
	xtpoisson emp_density distance100 if sectorgroup==`i', i(citysector) fe
	replace tau = _b[distance100] if sectorgroup==`i'
}

table sectorgroup, c(mean tau)

log close
set more on
