tempfile countries
* use a specific version of country concordance
import delimited "https://raw.githubusercontent.com/ceumicrodata/concordance/568b51/country/country-iso-codes.csv", clear  case(preserve) encoding(utf-8)
save `countries', replace

import delimited raw/CITIES_02052017083259614.csv, clear case(preserve) encoding(utf-8)

drop Variables TIME Unit* Power* Reference* Flag*

replace VAR = lower(VAR)
ren Year year

reshape wide Value, i(METRO_ID year) j(VAR) string
ren Value* *

* keep only cities
keep if length(METRO_ID)==5

* add iso3 codes
gen str iso2 = substr(METRO_ID,1,2)
* official iso code for UK is GB
replace iso2 = "GB" if iso2=="UK"

merge m:1 iso2 using `countries'
drop if _m==2
drop _m

save consistent/cities, replace
