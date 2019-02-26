clear all
set more off
capture log close
log using ../doc/zip_level_gradients, text replace

use ../data/zip_business_patterns

* nonparametric gradients
local K 33
egen distpct = cut(distance), group(`K')
egen sum_area = sum(area), by(distpct)
egen sum_pop = sum(pop), by(distpct)
egen sum_emp = sum(emp), by(distpct)

egen tag = tag(distpct)
gen ln_mean_emp_dens = ln(sum_emp/sum_area)
gen mean_urban_share = 100*sum_emp/sum_pop

label var distance "Distance to city center (km)"
label var ln_mean "Employment density (log)"
label var mean_urban_share "Urban employment per population (%)"

tw (line ln_mean_emp_dens distance if tag&distance<=100, sort), legend(order(1 "Urban sectors")) scheme(s2mono)
graph export ../text/figures/nonparametric_gradients.pdf, replace

tw (line mean_urban_share distance if tag&distance<=200, sort), legend(order(1 "")) scheme(s2mono)
graph export ../text/figures/urban_share.pdf, replace

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
