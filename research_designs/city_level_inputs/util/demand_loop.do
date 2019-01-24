
tempvar predicted_price diff
tempname tolerance gap step_size

gen `predicted_price' = .
gen `diff' = .

scalar `tolerance' = .01
scalar `gap' = 999
scalar `step_size' = 0.25

scalar i = 1
while `gap'>`tolerance' {

	do util/spatial_equilibrium
	
	* shadow price equals MRS
	qui replace `predicted_price' = Cu^(-1/sigma_u) * Cr^(1/sigma_r) * alpha_u^(1/sigma_u)

	qui replace `diff' = abs(ln(`predicted_price')-ln(Pu_Pr))
	su `diff'
	scalar `gap' = r(max)

	qui replace Pu_Pr = Pu_Pr^(1-`step_size') * `predicted_price'^`step_size'
	di i
	scalar i = i+1
}
