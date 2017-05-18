* city data from OECD
use  ../../data/oecd/cities/consistent/cities, clear
keep METRO_ID year gdp_pc pop labour_ surf_* iso3
keep if year==2007

ren pop city_population
gen city_area = surf_core+surf_hinter

save input/cities, replace

* unit labor cost data from OECD
use  ../../data/oecd/productivity/consistent/unit_labor_cost, clear

* no data on agricultura, use aggregate ULC
recode sector 1=3 7=1 2=2 *=.
drop if missing(sector)
reshape wide ulc, i(iso3 year) j(sector)

foreach X in ulc1 ulc2 {
	replace `X' = ulc3 if missing(`X')
}

save input/unit_labor_cost, replace

* macro indicators from WDI
use ../../data/wdi/wdi_2007, clear
keep year countrycode agrishare gdppercapita industryshare manufshare serviceshare urbanization area population arable
ren countrycode iso3 

gen share1 = serviceshare
gen share2 = industryshare
gen share3 = agrishare

save input/macro_indicators, replace
