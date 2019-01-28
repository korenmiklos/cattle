* city data from OECD
use  ../../data/un/table-pop-240/city-population-2005-2011, clear
keep if year==2005

* FIXME: employment rates can be adjusted at the country level
gen city_employment = city_population
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

* express relative to USA
foreach X of var price* {
	su `X' if iso3=="USA", meanonly
	scalar USA = r(mean)
	replace `X' = `X'/USA
}

gen urban_price = sqrt(price1*price2)
gen rural_price = price3

save input/sector_price_levels, replace
