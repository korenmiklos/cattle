local input_variables L z3 N1 N2 N3
local input_scalars tolerance elasticity dampening tau1 tau2 tau3 beta1 beta2 beta3

confirm variable `input_variables'
confirm scalar `input_scalars'
foreach X in `input_variables' {
	assert `X'>0
	assert !missing(`X')
}
assert tau1/beta1 > tau2/beta2
assert tau2/beta2 > tau3/beta3

local inner_variables abs_rent ln_R1_R2 ln_R2_R3 zeta1 zeta2 zeta3 L1 L2 L3 z_tilde_1 z_tilde_2 z_tilde_3
local outer_variables z1 z2

foreach X in `inner_variables' {
	confirm new variable `X'
}
foreach X in `outer_variables' {
	tempvar next_`X' logdiff_`X'
	gen `logdiff_`X'' = .
	gen `next_`X'' = .
	tempvar curr_`X'
}

tempname distance
scalar `distance' = 99999

* starting values
gen `curr_z1' = sqrt(N1/(N1+N2+N3))*z3
gen `curr_z2' = sqrt((N1+N2)/(N1+N2+N3))*z3

while `distance' > 2*tolerance {
*forval j=1/20 {
	foreach X in `inner_variables' {
		tempvar `X'
	}
	
	gen `L1' = L * (`curr_z1'/z3)^2
	gen `L2' = L * (`curr_z2'/z3)^2 - `L1'
	gen `L3' = L - `L1' - `L2'
	
	*su `L1' `L2' `L3'
	
	z_to_tilde `z_tilde_1' `curr_z1' tau1/beta1
	z_to_tilde `z_tilde_2' `curr_z2' tau2/beta2 `curr_z1'
	z_to_tilde `z_tilde_3' z3 tau3/beta3 `curr_z2'
	
	su `z_tilde_1' `z_tilde_2' `z_tilde_3'

	forval i=1/3 {
		gen `zeta`i'' = ln(beta`i')-ln(1-beta`i') + ln( N`i'/`L`i'') +`z_tilde_`i''*tau`i'/beta`i'
	}
	
	*su `zeta1' `zeta2' `zeta3'
	
	* log rent difference at the boundary. in eq this should be 0.
	gen `ln_R1_R2' = (`zeta1' - `zeta2') - `curr_z1' * (tau1/beta1 - tau2/beta2)
	gen `ln_R2_R3' = (`zeta2' - `zeta3') - `curr_z2' * (tau2/beta2 - tau3/beta3)
	gen `abs_rent' = abs(`ln_R1_R2')+abs(`ln_R2_R3')
	
	* thresholded step
	replace `next_z1' = `curr_z1' + cond(abs(`ln_R1_R2')>tolerance,elasticity*`ln_R1_R2',0)
	replace `next_z2' = `curr_z2' + cond(abs(`ln_R2_R3')>tolerance,elasticity*`ln_R2_R3',0)
	
	* ensure 0 < z1 < z2 < z3
	replace `next_z2' = 0.999*z3 if `next_z2'>=0.999*z3
	replace `next_z2' = 0.3*z3 if `next_z2'<0.3*z3
	replace `next_z1' = 0.999*`next_z2' if `next_z1'>=0.999*`next_z2'
	replace `next_z1' = 0.3*z3 if `next_z1'<0.3*z3
	
	su `abs_rent', meanonly
	scalar `distance' = r(mean)
	forval i=1/2 {
		* dampening
		replace `curr_z`i'' = dampening*`next_z`i'' + (1-dampening)*`curr_z`i''
	}

	foreach X in `inner_variables' {
		drop ``X''
	}
	di in ye `distance'
}

foreach X in `outer_variables' {
	gen `X' = `curr_`X''
}
