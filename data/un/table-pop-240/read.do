clear all

* read country codes from datahub
import delimited using "https://datahub.io/core/country-codes/r/country-codes.csv", encoding("utf-8") varnames(1) case(preserve)
keep ISO31661Alpha3 ISO31661numeric
ren ISO31661Alpha3 iso3
ren ISO31661numeric iso_numeric
drop if missing(iso_numeric)
tempfile cc
save `cc'

import delimited using "UNdata_Export_20190128_113905166.csv", encoding("utf-8") varnames(1) case(preserve) rowrange(1:3282) clear

* save best estimate for each city type
egen N_entries = count(TableCode ), by(CodeofCity CodeofCitytype Year )
tab RecordTypeCode N_entries

drop if N_entries==2 & RecordTypeCode==10

* save best estimate for each city
drop N_entries
egen N_entries = count(TableCode ), by(CodeofCity Year )
tab CodeofCitytype N_entries

* add urban agglomeration if possible

keep CountryorAreaCode CountryorArea Year CodeofCity City CodeofCitytype Value
ren CountryorAreaCode iso_numeric
ren CountryorArea country_name
ren Year year
ren CodeofCity city_code 
ren City city_name
ren CodeofCitytype agglomeration
ren Value city_population

collapse (sum) city_population (count) agglomeration = city_population, by(iso_numeric country_name year city_code city_name)
replace agglomeration = agglomeration - 1

merge m:1 iso_numeric using `cc', keep(match) nogen

duplicates report city_code year
assert r(N)==r(unique_value)

save city-population-2005-2011, replace
