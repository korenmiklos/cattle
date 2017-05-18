use input/cities, clear

merge m:1 iso3 year using input/unit_labor_cost
drop if _m==2
drop _m

merge m:1 iso3 year using input/macro_indicators
drop if _m==2
drop _m

do util/parameters
do util/programs

forval i=1/3 {
	gen L`i' = share`i'*(1-beta`i')^(1-1/beta`i')*ulc`i'^(1/beta`i')
}
egen L = rsum(L?)
forval i=1/3 {
	replace L`i' = city_area*L`i'/L
}

* testing
gen z1 = sqrt(L1)/pi
z_to_tilde z_tilde_1 z1 tau1/beta1

gen contribution = exp(-tau1*z_tilde_1)*100-100
