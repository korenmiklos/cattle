clear all
use input/cities

* only keep large cities
drop if city_employment<50000

merge m:1 iso3 year using input/macro_indicators, keep(match) nogen
merge m:1 iso3 using input/sector_price_levels, keep(match) nogen

do util/parameters
do util/programs

* FIXME: get country employment data
gen double employment = population

gen double rural_density = employment/area
do util/calibrate_z
ren z z_first

* do another round of rural density
egen double urban_area = sum(city_area), by(iso3 year)
egen double urban_employment = sum(city_employment), by(iso3 year)
gen double rural_employment = max(1, employment - urban_employment)
replace employment = urban_employment + rural_employment
replace rural_density = max(0.77,rural_employment / (area-urban_area))

drop z_tilde city_area 
do util/calibrate_z

* areas have changed, recalculate urban/rural split
drop urban_area
egen double urban_area = sum(city_area), by(iso3 year)
gen double rural_area = area - urban_area

gen Pu_Pr = urban_price/rural_price
gen N = employment
gen L = area

do util/calibrate_a
drop if missing(Ac)
do util/spatial_equilibrium

do util/decomposition
save output/calibrated_cities, replace


