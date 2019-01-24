clear all

use output/calibrated_cities

do util/parameters

gen ln_Pu_Pr = ln(Pu_Pr)
gen ln_Cr = ln(Cr)
gen ln_Cu = ln(Cu)

egen ln_Ac = mean(ln(Ac)), by(iso3 year) 
gen ln_Ar = ln(Ar)
gen ln_L_N = ln(L/N)

tempvar cnt_tag resid
egen `cnt_tag' = tag(iso3 year)

local instruments ln_Ac ln_Ar ln_L_N
regress ln_Cu `instruments' if `cnt_tag', vce(cluster iso3)
eststo
regress ln_Cr `instruments' if `cnt_tag', vce(cluster iso3)
eststo
ivregress 2sls ln_Pu_Pr (ln_Cu ln_Cr = `instruments') if `cnt_tag', first vce(cluster iso3)
scalar sigma_u = -1/_b[ln_Cu]
scalar sigma_r = 1/_b[ln_Cr]

estadd scalar sigma_u = sigma_u
estadd scalar sigma_r = sigma_r
eststo
predict `resid', resid

label var ln_Pu_Pr "$\ln(Pu/Pr)$"
label var ln_Cr "$\ln Cr$"
label var ln_Cu "$\ln Cu$"
label var ln_Ar "$\ln Ar$"
label var ln_Ac "$\ln Ac$ (country average)"
label var ln_L_N "$\ln(L/N)$"


esttab using output/demand_parameters.tex, replace label se star(* 0.10 ** 0.05 *** 0.01) alignment(D{.}{.}{-1}) ///
	scalars("sigma_u $\sigma u$" "sigma_r $\sigma r$") ///
	title(Estimate of utility function parameters\label{tab1}) ///
	addnotes("Instrumental variables regression. ")

gen alpha_u = exp(sigma_u*`resid')

collapse (firstnm) alpha_u, by(iso3 year)
gen sigma_u = sigma_u
gen sigma_r = sigma_r

save output/calibrated_countries, replace
