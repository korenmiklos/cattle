forval i=1/3 {
	gen location_contribution`i' =-tau`i'*z_tilde_`i'
	gen land_contribution`i' = ln(L`i'/N`i')*beta`i'
	gen productivity_contribution`i' = a`i'
	egen output_per_worker`i' = rsum(*_contribution`i')
}
