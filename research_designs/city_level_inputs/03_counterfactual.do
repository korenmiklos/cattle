clear all

use output/calibrated_cities

do util/parameters
do util/programs


local input_variables a? ln_y
local output_variables share?hat z_tilde* land_* location_* productivity_* output_per_worker* zeta* 
foreach X of var `input_variables' `output_variables' {
	ren `X' est_`X'
}

* what if all cities had the productivity of Boston?
foreach X in ln_y a1 a2 a3 {
	su est_`X' if METRO_ID=="US048", meanonly
	gen `X' = r(mean)
}

* counterfactual expenditure shares
estimates use output/structural_transformation
predict share1hat, eq(#1)
predict share2hat, eq(#2)
gen share3hat = 1-share1hat -share2hat 

drop L? N? L N z? 

do util/spatial_equilibrium
do util/decomposition

* given productivities, calculate new prices
ren price? est_price?
aw_to_p a ln_y price

* do one more iteration with new prices
drop `output_variables'
predict share1hat, eq(#1)
predict share2hat, eq(#2)
gen share3hat = 1-share1hat -share2hat 

drop L? N? L N z? 

do util/spatial_equilibrium
do util/decomposition
* given productivities, calculate new prices
drop price?
aw_to_p a ln_y price

foreach X of var `input_variables' `output_variables' price? {
	ren `X' cf_`X'
	gen diff_`X' = cf_`X'-est_`X'
}
su diff*
