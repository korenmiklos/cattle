clear all
set more off
capture log close
log using ../doc/zip_level_gradients, text replace

use ../data/zip_business_patterns

su sector
local max `r(max)'

* nonparametric gradients
local K 33
egen distpct = cut(distance), group(`K')
egen mean_emp_dens = mean(emp_dens), by(distpct sector)
egen tag = tag(distpct sector)

gen ln_mean_emp_dens = ln(mean_emp_dens)

tw (line ln_mean_emp_dens distance if tag&sector==1&distance<=100, sort) /*
*/ (line ln_mean_emp_dens distance if tag&sector==2&distance<=100, sort) /*
*/ (line ln_mean_emp_dens distance if tag&sector==3&distance<=100, sort) /*
*/, legend(order(1 "Agriculture" 2 "Manufacturing" 3 "Services")) scheme(s2color)

preserve
* calculate shares
collapse emp est lndistance distance, by(sector distpct)
reshape wide emp est, i(distpct) j(sector)
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
replace upper = 20 if sector==3
replace lower = 20 if sector==2
replace upper = 100 if sector==2
replace lower = 100 if sector==1

egen msacode = group(msa)

foreach X in emp_density establishment_size imputed_density {
	gen tau_`X' = .
	forval i = 1/`max' {
		xtpoisson `X' distance if sector==`i' & distance>=lower & distance<upper, i(msacode) fe
		replace tau_`X' = _b[distance] if sector==`i'
	}
}
table sector, c(mean tau_emp_density mean tau_establishment_size mean tau_imputed_density)

log close
set more on
