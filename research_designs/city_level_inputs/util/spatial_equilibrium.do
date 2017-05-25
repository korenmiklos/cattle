* estimate land and labor shares
forval i=1/3 {
	* wages are same across sectors. wage shares are constant because of Cobb-Douglas
	gen N`i' = share`i'hat * (1-beta`i')
}
egen N = rsum(N?)
forval i=1/3 {
	replace N`i' = city_employment * N`i'/N
}

gen L = city_area
gen z3 = sqrt(L)/pi

scalar elasticity = 0.5
scalar tolerance = 0.01
scalar dampening = 0.1
drop if missing(N1,N2,N3)
* iteratively solve for (z1,z2)
do util/loop
do util/aggregates

forval i=1/3 {
	replace N`i' = city_employment*N`i'/N
	gen location_contribution`i' =-tau`i'*z_tilde_`i'
	gen land_contribution`i' = ln(L`i'/N`i')*beta`i'
	/** express land contribution relative to Boston
	su land_contribution`i' if METRO_ID=="US048", meanonly
	replace land_contribution`i' = land_contribution`i' - r(mean)*/
}
