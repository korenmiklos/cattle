clear all
use input/cities

drop if missing(METRO_ID)
drop _*
merge m:1 iso3 year using input/macro_indicators, keep(match) nogen
merge m:1 iso3 using input/sector_price_levels, keep(match) nogen

do util/parameters
do util/programs

* FIXME: get data on rural density
egen urban_population = sum(city_population), by(iso3 year)
gen rural_density = population/area
ren city_area city_area_data
do util/calibrate_z

ren z z_first
* do another round of rural density
egen urban_area = sum(city_area), by(iso3 year)
replace rural_density = (population-urban_population)/(area-urban_area)
drop z_tilde density_premium  city_area  predicted_city_employment diff

do util/calibrate_z
do util/decomposition

save output/calibrated_cities, replace
