clear all

use output/calibrated_cities
merge m:1 iso3 year using output/calibrated_countries, keep(match) nogen

do util/parameters
do util/programs

gen ln_Qc = ln(Qc)

* everything relative to New York
foreach X of var ln_Qc *_contribution {
	su `X' if METRO_ID=="US084", meanonly
	replace `X' = exp(`X' - r(mean))
}


local X ln_Qc
label var ln_Qc "City output per worker (New York=1)"
* execute graphing command
tw 	(lowess rural_productivity_contribution `X') ///
	(lowess rural_land_contribution `X'), ///
	legend(order(1 "Rural productivity" 2 "Rural land use")) ///
	scheme(s2mono)  ytitle("Relative contribution (New York=1)")
graph export output/rural_contributions.pdf, replace

tw 	(lowess rel_productivity_contribution `X') ///
	(lowess land_contribution `X') ///
	(lowess location_contribution `X'), ///
	legend(order(1 "Urban/rural productivity" 2 "Urban/rural land use" 3 "Location")) ///
	scheme(s2mono)   ytitle("Relative contribution (New York=1)")
graph export output/urban_contributions.pdf, replace

