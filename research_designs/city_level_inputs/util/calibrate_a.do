confirm numeric variable z z_tilde urban_price rural_price city_employment city_area rural_employment rural_area gdppercapita
confirm scalar tau beta
confirm new variable Ar Ac

tempvar Au_Ar Qu_Qr output_premium urban_employment
gen `Au_Ar' = exp(z * tau)/urban_price*rural_price
* relative output per worker in city vs rural areas
gen `Qu_Qr' = `Au_Ar' * (city_area/rural_area)^beta * (city_employment/rural_employment)^(-beta)

* if rural output per worker = 1, what is GDP per capita at fixed US price?
egen `urban_employment' = sum(city_employment), by(iso3 year)
egen `output_premium' = sum(`Qu_Qr' * city_employment /(`urban_employment'+rural_employment)), by(iso3 year)
* add 1 unit of output for each rural worker
replace `output_premium' = `output_premium' + (rural_employment)/(`urban_employment'+rural_employment)
su `output_premium'

gen Ar = gdppercapita / (rural_area/rural_employment)^beta / `output_premium'
gen Ac = Ar * `Au_Ar'
