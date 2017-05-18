clear all
set more off
capture log close
log using ../doc/internal_val.log, text replace

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

* variable to use for fringe distance (z3)
local fringe_var emp

gen z3_dist = `fringe_var'fringe

local pi=3.14159265359

* alternative calculation: using area assuming circular cities
egen `fringe_var'fringe_area = max(cond(cum`fringe_var'<.9,sumarea,.)), by (city)

gen z3_area = sqrt(`fringe_var'fringe_area/`pi')

regress z3_dist z3_area if z3_dist<100 & z3_area<100
scatter z3_dist z3_area if z3_dist<100 & z3_area<100 || lfit z3_dist z3_area if z3_dist<100  & z3_area<100

* Calculating z3 from the area measure
gen z3=z3_area

collapse (mean) z3_area z3_dist, by(city)
sort city
save ../data/z3.dta, replace

* calculate employment weighted sectoral distances

use ../data/zip_business_patterns
collapse (mean) distance [iw=emp], by(city sector)
rename distance empwdistance
sort city sector
save ../data/wdist.dta, replace

* Calculate city level sectoral land demand
use ../data/zip_business_patterns, clear

collapse (sum) imputed_area emp est area residential_area, by(city sector)

* Calculating land employment and establishment shares
gen land=imputed_area
foreach X of var emp est land {
    by city: gen cum`X' = sum(`X')
	by city: egen sum`X' = max(cum`X')
    by city: gen `X'_share = `X'/sum`X'
}

sort city sector
merge city sector using ../data/wdist.dta
tabulate _merge
drop _merge

sort city
merge city using ../data/z3.dta
tabulate _merge
drop _merge

egen city_id = group(city)

* change the ordering of the sectors
replace sector=4 if sector==3
replace sector=3 if sector==1
replace sector=1 if sector==4
sort city sector

outsheet city_id sector land_share z3_area z3_dist emp_share est_share empwdistance using ../data/internal_val.txt, delimiter(" ") replace nonames
