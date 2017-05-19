use input/cities, clear

merge m:1 iso3 year using input/unit_labor_cost
drop if _m==2
drop _m

merge m:1 iso3 year using input/macro_indicators

* estimate structural transformation on macro data
egen country_tag = tag(iso3 year)
gen ln_y = ln(gdppercapita)
nlsur (share1 = exp({a1}+{b1}*ln_y+{c1}*ln_y^2)/(1+exp({a1}+{b1}*ln_y+{c1}*ln_y^2)+exp({a2}+{b2}*ln_y+{c2}*ln_y^2))) /*
   */ (share2 = exp({a2}+{b2}*ln_y+{c2}*ln_y^2)/(1+exp({a1}+{b1}*ln_y+{c1}*ln_y^2)+exp({a2}+{b2}*ln_y+{c2}*ln_y^2))) /*
   */ if !missing(share1,share2,ln_y)&country_tag

* predict at the city level
replace ln_y = ln(gdp_pc)
predict share1hat, eq(#1)
predict share2hat, eq(#2)
gen share3hat = 1-share1hat -share2hat 

drop if _m==2
drop _m

do util/parameters
do util/programs

* estimate land and labor shares
forval i=1/3 {
	* eq 17 from cattle.pdf at commit 6096291
	gen L`i' = share`i'hat * (1-beta`i')^(1-1/beta`i') * ulc`i'^(1/beta`i')
	* eq 8 from cattle.pdf at commit 6096291
	gen N`i' = L`i' * (1-beta`i')^(1/beta`i') * ulc`i'^(-1/beta`i')
}
egen L = rsum(L?)
egen N = rsum(N?)
forval i=1/3 {
	replace L`i' = city_area*L`i'/L
	replace N`i' = city_employment*N`i'/N
}

* testing
gen z1 = sqrt(L1)/pi
gen z2 = sqrt(L1+L2)/pi
gen z3 = sqrt(L1+L2+L3)/pi

z_to_tilde z_tilde_1 z1 tau1/beta1
z_to_tilde z_tilde_2 z2 tau2/beta2 z1
z_to_tilde z_tilde_3 z3 tau3/beta3 z2

forval i=1/3 {
	gen location_contribution`i' =-tau`i'*z_tilde_`i'
	gen land_contribution`i' = ln(L`i'/N`i')*beta`i'
}
