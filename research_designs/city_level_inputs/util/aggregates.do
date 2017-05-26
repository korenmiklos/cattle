local input_variables L z1 z2 z3 N1 N2 N3
confirm variable `input_variables'
confirm new variable L1 L2 L3 z_tilde_1 z_tilde_2 z_tilde_3 zeta1 zeta2 zeta3 p1 p2 p3

foreach X in `input_variables' {
	assert `X'>0 & !missing(`X')
}

gen L1 = L * (z1/z3)^2
gen L2 = L * (z2/z3)^2 - L1
gen L3 = L - L1 - L2


z_to_tilde z_tilde_1 z1 tau1/beta1
z_to_tilde z_tilde_2 z2 tau2/beta2 z1
z_to_tilde z_tilde_3 z3 tau3/beta3 z2

forval i=1/3 {
	gen zeta`i' = ln(beta`i')-ln(1-beta`i') + ln( N`i'/L`i') +z_tilde_`i'*tau`i'/beta`i'
}
