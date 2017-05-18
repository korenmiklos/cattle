capture log close
log using ../doc/descriptives, text replace
set more off

clear all

use ../data/wdi/wdi_2007
ren countrycode iso

* save some descriptive graphs first
gen y = ln(gdppercap)
label var y "GDP per capita (log)"
label var agrishare "Share of agriculture"
label var industryshare "Share of industry"
label var serviceshare "Share of services"
foreach X of var *share {
	lowess `X' y, mlabel(iso) msize(tiny) scheme(s2color)
	graph export ../text/figures/`X'.png, width(800) replace
}

* population density
gen lndensity = ln(population/area)
label var lndensity "Population density (log)"
lowess lndensity y, mlabel(iso) msize(tiny) scheme(s2color)
graph export ../text/figures/population-density.png, width(800) replace

* sector prices
merge 1:1 iso using ../data/ICP/2005/sector-price-levels, keep(master match)
drop _m
label var priceagri "Price of agriculture"
label var pricemanu "Price of manufacturing"
label var priceserv "Price of services"

foreach X of var price???? {
	gen ln`X' = ln(`X')
	local lbl : var label `X'
	label var ln`X' "`lbl' (log)"
	lowess ln`X' y, mlabel(iso) msize(tiny) scheme(s2color)
	graph export ../text/figures/`X'.png, width(800) replace
}

* merge 1:1 iso using ../data/maxmind/cities, keep(match)
gen iso3 = iso
merge 1:m iso3 year using ../data/oecd/cities/consistent/cities, 
drop if _m==2
drop _m

* create some citygraphs
egen urban = sum(pop), by(iso)
replace urban = urban/population
gen logcitypop = log(pop)
label var urban "Fraction of people in metropolitan areas"
label var logcitypop "Population of largest city (log)"
label var gdp_pc "GDP per capita"

egen rank = rank(-pop), by(iso)
local top 5

lowess urban y if rank==1, mlabel(iso) msize(tiny) scheme(s2color)
graph export ../text/figures/urbanization.png, width(800) replace

lowess logcitypop gdp_pc if rank<=`top', mlabel(Metropolitan) msize(tiny) scheme(s2color)
graph export ../text/figures/largest-cities.png, width(800) replace

* estimate city boundaries with circular area formula
gen z3 = sqrt(surf_core+surf_hinter)/3.1416
label var z3 "City boundary (km)"
lowess z3 gdp_pc if rank<=`top', mlabel(Metropolitan) msize(tiny) scheme(s2color)
graph export ../text/figures/z3.png, width(800) replace

set more on
log close
