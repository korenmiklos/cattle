gen location_contribution = -tau * z_tilde
gen land_contribution = (ln(city_area/city_employment)-ln(L_bar/N))*beta
gen rel_productivity_contribution = ln(Ac/Ar)
egen rel_output_per_worker = rsum(*_contribution)

gen rural_land_contribution = ln(L_bar/N)*beta
gen rural_productivity_contribution = ln(Ar)
egen output_per_worker = rowtotal(*_contribution), missing

gen rural_output_per_worker = Ar * (L_bar/N)^beta
