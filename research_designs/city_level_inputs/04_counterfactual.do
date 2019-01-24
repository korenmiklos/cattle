clear all

use output/calibrated_cities
merge m:1 iso3 year using output/calibrated_countries, keep(match) nogen

do util/parameters
do util/programs

* double productivity to check the effect of non-homotheticity
replace Ac = 2*Ac
replace Ar = 2*Ar

do util/demand_loop
