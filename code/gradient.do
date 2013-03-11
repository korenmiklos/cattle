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
egen mean_emp_dens = mean(imputed_density), by(distpct sector)
egen tag = tag(distpct sector)

gen ln_mean_emp_dens = ln(mean_emp_dens)

label var distance "Distance to city center (km)"
label var ln_mean "Imputed employment density (log)"

tw (line ln_mean_emp_dens distance if tag&sector==1&distance<=100, sort) /*
*/ (line ln_mean_emp_dens distance if tag&sector==2&distance<=100, sort) /*
*/ (line ln_mean_emp_dens distance if tag&sector==3&distance<=100, sort) /*
*/, legend(order(1 "Agriculture" 2 "Manufacturing" 3 "Services")) scheme(s2color)
graph export ../text/figures/nonparametric_gradients.png, width(800) replace

preserve
* calculate shares
collapse emp est lndistance distance, by(sector distpct)
reshape wide emp est, i(distpct) j(sector)
egen totalemp = rsum(emp?)
sort distance
forval i=1/`max' {
	gen share`i' = emp`i'/totalemp
	egen meanshare`i' = mean(share`i')
	gen lnshare`i' = ln(emp`i'/totalemp)
	gen share`i'norm = share`i'/meanshare`i'
}

label var distance "Distance to city center (km)"

tw (line share?norm distance if distance<=100, sort), /*
 */ ytitle(Location quotient of sector) /*
 */ legend(order(1 "Agriculture" 2 "Manufacturing" 3 "Services")) scheme(s2color)
graph export ../text/figures/sector_location_quotients.png, width(800) replace

restore

* sector-level regressions
gen lower = 0
gen upper = 500
replace upper = 30 if sector==3
replace lower = 30 if sector==2
* non-overlapping zones for M and S
* we do not care about agri gradient

egen citycode = group(city)

foreach X in emp_density establishment_size imputed_density {
	gen tau_`X' = .
	forval i = 1/`max' {
		xtpoisson `X' distance if sector==`i' & distance>=lower & distance<upper, i(citycode) fe
		replace tau_`X' = _b[distance] if sector==`i'
	}
}
table sector, c(mean tau_emp_density mean tau_establishment_size mean tau_imputed_density)

log close
set more on
