gen location_contribution =-tau * z_tilde
gen land_contribution = (ln(city_area/city_employment)+ln(rural_density))*beta
gen rel_productivity_contribution = z * tau - ln(urban_price) + ln(rural_price)
egen rel_output_per_worker = rsum(*_contribution)

* if rural output per worker = 1, what is GDP per capita at fixed US price?
* FIXME: use employment or population?
egen output_premium = sum(exp(rel_output_per_worker)*city_employment/population), by(iso3 year)
* add 1 unit of output for each rural worker
replace output_premium = output_premium+(population-urban_population)/population

gen rural_land_contribution = -ln(rural_density)*beta
gen rural_productivity_contribution = ln(gdppercapita/output_premium) - rural_land_contribution
egen output_per_worker = rowtotal(*_contribution), missing
