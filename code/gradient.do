clear all
set more off
capture log close
log using ../doc/zip_level_gradients, text replace

use ../data/zip_business_patterns

* nonparametric gradients
local K 33
egen distpct = cut(distance), group(`K')
egen mean_emp_dens = mean(imputed_density), by(distpct)
egen tag = tag(distpct)

gen ln_mean_emp_dens = ln(mean_emp_dens)

label var distance "Distance to city center (km)"
label var ln_mean "Imputed employment density (log)"

tw (line ln_mean_emp_dens distance if tag&distance<=100, sort), legend(order(1 "Urban sectors")) scheme(s2mono)
graph export ../text/figures/nonparametric_gradients.pdf, replace

* sector-level regressions
gen lower = 0
gen upper = 60

egen citycode = group(city)

foreach X in emp_density establishment_size imputed_density {
	gen tau_`X' = .
	xtpoisson `X' distance if  distance>=lower & distance<upper, i(citycode) fe
	replace tau_`X' = _b[distance]
}
gen sector=1
table sector, c(mean tau_emp_density mean tau_establishment_size mean tau_imputed_density)

log close
set more on
