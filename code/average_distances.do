clear all
set more off
capture log close
log using ../doc/average_distances, text replace

use ../data/zip_business_patterns

* calculate the urban fringe
collapse (sum) emp est (mean) area pop homes, by(city msa distance zip)
sort city distance
foreach X of var area emp est pop homes {
	by city: gen cum`X' = sum(`X')
	by city: egen sum`X' = max(cum`X')
	replace cum`X' = cum`X'/sum`X'
	
	egen `X'fringe = max(cond(cum`X'<.9,distance,.)), by(city)
}

gen lnpop = ln(sumpop)
gen lnarea = ln(sumarea)
gen byte urban = city==msa

table city, c(mean empfringe mean popfringe mean homesfringe)
poisson empfringe urban lnpop lnarea

egen distrank = rank(distance), by(city)
egen maxrank = max(distrank), by(city)
replace distrank = int(20*(distrank-1)/maxrank)

* shape of cities
replace cumarea = cumarea*sumarea
collapse (mean) cumarea distance, by(city distrank)
egen citycode = group(city)
gen lndistance = ln(distance)
gen lncumarea = ln(cumarea)
egen maxdistance = max(distance), by(city)

gen lncircular = ln(distance^2*3.14159)

label var lncumarea "Cumulated area from city center (log)"
label var lndistance "Distance to city center (log)"
label var lncircular "Circular area (log)"

* shape of area distance relationship, should be quadratic in plain
xtpoisson cumarea lndistance, i(citycode) fe
xtpoisson cumarea lndistance if distance<100, i(citycode) fe

* nonparametric
tw (scatter lncumarea lndistance) (line lncircular lndistance), scheme(s2color)
graph export ../text/figures/circular_city_in_data.png, replace width(800)


use ../data/zip_business_patterns, clear

* convert population into sector 0
expand 1+(sector==1), gen(expanded)
replace sector=0 if expanded
replace emp = pop if expanded

* nonzero number of establishments
gen byte are = area if est>0 & !missing(est)
replace lndistance = . if missing(emp,pop)
replace emp = . if missing(lndistance,pop)
replace pop = . if missing(lndistance,emp)

local weight imputed_area

sort sector distance
by sector: gen cumsum = sum(`weight')
egen maxcumsum = max(cond(distance<=100,cumsum,.)), by(sector)
replace cumsum = cumsum/maxcumsum
label var cumsum "Cumulative share of `weight'"

gen byte sample = (distance<=100)

* empirical CDF of weighted distances in the three sectors
tw (line cumsum distance if sector==1&sample, sort) /*
*/ (line cumsum distance if sector==2&sample, sort) /*
*/ (line cumsum distance if sector==3&sample, sort) /*
*/, scheme(s2color) legend(order(1 "Agriculture" 2 "Industry" 3 "Services"))
graph export ../text/figures/sector_distance_cdfs.png, replace width(800)

* median weighted distances
table sector if cumsum<=.5, c(max distance)

* 90th pect weighted distances
table sector if cumsum<=.9, c(max distance)

foreach X of var emp pop est are {
	gen `X'distance = `X'*lndistance
}

collapse (sum) ???distance emp est pop are, by(sector)
foreach X of var emp pop est are {
	replace `X'distance = exp(`X'distance/`X')
}
l sector ???distance

log close
set more on
