local variables share?hat z_tilde* l*contribution* zeta*
foreach X of var `variables' {
	ren `X' est_`X'
}

estimates use output/structural_transformation

gen est_ln_y = ln_y
* what if all city had the income level of Bostom
su ln_y if METRO_ID=="US048", meanonly
replace ln_y = r(mean)
forval i=1/3 {
	replace ln_y__`i' = ln_y^`i' 
}

predict share1hat, eq(#1)
predict share2hat, eq(#2)
gen share3hat = 1-share1hat -share2hat 

drop L? N? L N z? 

do util/spatial_equilibrium
foreach X of var `variables' {
	ren `X' cf_`X'
	gen diff_`X' = cf_`X'-est_`X'
}
su diff*
