clear all

use output/calibrated_cities
merge m:1 iso3 year using output/calibrated_countries, keep(match) nogen

do util/parameters
do util/programs

preserve
	do util/save_scenario 0 Actual
restore 

preserve
	* increase productivity to check the effect of non-homotheticity
	replace Ac = 1.1*Ac
	replace Ar = 1.1*Ar

	do util/demand_loop
	do util/save_scenario 1 "10% increase in productivity"
restore

preserve
	* increase demand for urban goods
	replace alpha_u = 1.1*alpha_u

	do util/demand_loop
	do util/save_scenario 2 "10% increase in demand for urban goods"
restore
