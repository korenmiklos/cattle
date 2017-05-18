clear
set mem 750m

use ../data/maxmind/iso_fips.dta
sort fips
save ../data/maxmind/iso_fips.dta, replace

insheet using ../data/maxmind/worldcitiespop.txt, names
gen dum_city50t=1 if population>50000 & population!=.
gen dum_pop=1 if population!=.
gen ones=1
save ../data/maxmind/worldcitiespop.dta, replace
preserve
collapse (count) dum_city50t dum_pop ones (sum) population, by(country)
gen fips=upper(country)
drop country
sort fips
merge fips using ../data/maxmind/iso_fips.dta, nokeep
drop if _merge==1
drop _merge
rename ones NGIA
label variable NGIA "Number of elemens in National Geospatial-Intelligence Agency"
rename dum_pop WG
label variable WG "www.world-gazetteer.com cities"
rename dum_city50t cities
label variable cities "# 50t+ cities" 
save ../data/maxmind/cities.dta, replace
