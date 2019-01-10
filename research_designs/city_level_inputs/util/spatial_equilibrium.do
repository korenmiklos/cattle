gen N1 = city_employment

gen L = city_area
* boundary of circular city
gen z1 = sqrt(L)/pi

* average distance to CBD in such a city
z_to_tilde z_tilde z1 tau/beta

* relative attractiveness of cities
gen Agamma = (N1/L)^beta * exp(z_tilde*tau)

* relative amenities. normalize average amenity to 1
gen gamma =  (N1/L) * exp(-(z1-z_tilde)*tau/beta)
egen mean_gamma = mean(gamma), by(iso)
replace gamma = gamma/mean_gamma

* relative productivities
gen A = Agamma/gamma

* urban value productivity relative to rural
gen PA = (L/N1)^(1-beta) * exp((z1-(1-beta)*z_tilde)*tau/beta) / beta

* relative to rural rent
gen city_GDP = exp((z1-z_tilde)*tau/beta) * L / beta
egen total_urban_GDP = sum(city_GDP), by(iso)
* FIXME: check units of land
egen total_urban_area = sum(L), by(iso)
gen total_GDP = total_urban_GDP + area-total_urban_area
gen urban_GDP_share = total_urban_GDP / total_GDP

* recover units of rural rent
gen rural_rent = gdppercapita*population/total_GDP

gen city_GDP_per_capita = city_GDP/N*rural_rent


