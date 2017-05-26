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

