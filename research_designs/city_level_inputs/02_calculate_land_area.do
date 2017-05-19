use input/cities, clear

merge m:1 iso3 year using input/unit_labor_cost
drop if _m==2
drop _m

merge m:1 iso3 year using input/macro_indicators
drop _m
do util/structural_transformation
drop if missing(METRO_ID)

do util/parameters
do util/programs

do util/spatial_equilibrium

