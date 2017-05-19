* city data from OECD
use  ../../data/oecd/cities/consistent/cities, clear
keep METRO_ID Metro year gdp_pc pop emp labour_ surf_* iso3
keep if year==2007

ren Metro city_name
ren pop city_population
ren emp city_employment
gen city_area = surf_core+surf_hinter

* impute employment for Switzerland
reg city_employment city_population if year==2007, nocons
tempvar hat
predict `hat'
replace city_employment = `hat' if missing(city_employment)

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

gen share1 = serviceshare/100
gen share2 = industryshare/100
gen share3 = agrishare/100

save input/macro_indicators, replace

* prices from ICP
use ../../data/ICP/2005/sector-price-levels, clear

ren iso iso3
ren priceserv price1
ren pricemanu price2
ren priceagri price3

save input/sector_price_levels, replace
