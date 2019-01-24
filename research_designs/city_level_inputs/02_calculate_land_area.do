clear all
use input/cities

drop if missing(METRO_ID)
drop _*
merge m:1 iso3 year using input/macro_indicators, keep(match) nogen
merge m:1 iso3 using input/sector_price_levels, keep(match) nogen

do util/parameters
do util/programs

* FIXME: get country employment data
gen employment = population

gen rural_density = employment/area
ren city_area city_area_data
do util/calibrate_z
ren z z_first

* do another round of rural density
egen urban_area = sum(city_area), by(iso3 year)
egen urban_employment = sum(city_employment), by(iso3 year)
gen rural_employment = employment - urban_employment
replace rural_density = rural_employment / (area-urban_area)

drop z_tilde city_area 
do util/calibrate_z

* areas have changed, recalculate urban/rural split
drop urban_area
egen urban_area = sum(city_area), by(iso3 year)
gen rural_area = area - urban_area

do util/calibrate_a
do util/decomposition

save output/calibrated_cities, replace
