clear all
use input/cities

merge m:1 iso3 year using input/macro_indicators
drop _m
do util/structural_transformation
drop if missing(METRO_ID)

do util/parameters
do util/programs

do util/spatial_equilibrium

* recover productivities
pw_to_a price ln_y a
do util/decomposition

save output/calibrated_cities, replace
