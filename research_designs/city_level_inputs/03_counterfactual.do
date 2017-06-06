clear all

use output/calibrated_cities
* keep only Boston
keep if METRO_ID=="US048"
merge 1:m year using input/macro_indicators, update replace

do util/parameters
do util/programs

local input_variables a? ln_y
local output_variables share?hat z_tilde* land_* location_* productivity_* output_per_worker* zeta* 
foreach X of var `input_variables' `output_variables' {
	ren `X' est_`X'
}

* Change all productivities to match GDP per capita?
gen ln_y = ln(gdppercapita)
foreach X in a1 a2 a3 {
	gen `X' = est_`X' + (ln_y - est_ln_y) 
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

* calculate percentage contribution
foreach X in productivity land location {
	forval i=1/3 {
		reg diff_`X'_contribution`i' diff_output_per_worker`i'
		scalar `X'_contribution`i' = _b[diff_output_per_worker`i']
	}
}
scalar list
