local variables share?hat z_tilde* l*contribution*
foreach X of var `variables' {
	ren `X' est_`X'
}

estimates use output/structural_transformation

gen est_ln_y = ln_y
* what if all city had a low income level
su ln_y if METRO_ID=="MEX75", meanonly
replace ln_y = r(mean)

predict share1hat, eq(#1)
predict share3hat, eq(#2)
gen share2hat = 1-share1hat -share3hat 


do util/spatial_equilibrium
foreach X of var `variables' {
	ren `X' cf_`X'
	gen diff_`X' = cf_`X'-est_`X'
}
su diff*
