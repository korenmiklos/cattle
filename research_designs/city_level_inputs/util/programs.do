capture prog drop _all
program define z_to_tilde
	args z_tilde z_bar slope hollow
	
	if ("`hollow'"=="") {
		local hollow 0
	}
	
	tempvar upper lower area
	gen double `upper' = exp(-(`slope')*`z_bar')*(1+(`slope')*`z_bar')
	gen double `lower' = exp(-(`slope')*`hollow')*(1+(`slope')*`hollow')
	gen double `area' = `z_bar'^2-`hollow'^2
	
	gen double `z_tilde' = -2/(`slope')^2 * (`upper'-`lower')/`area'
	replace `z_tilde' = -ln(`z_tilde')/(`slope')
end

program define pw_to_a
	args p w a
	
	forval i=1/3 {
		gen `a'`i' = `w' - `p'`i' + (zeta`i'-ln(beta`i')+ln(1-beta`i'))*beta`i' - ln(1-beta`i')
	}
end

program define aw_to_p
	args a w p
	
	forval i=1/3 {
		gen `p'`i' = `w' - `a'`i' + (zeta`i'-ln(beta`i')+ln(1-beta`i'))*beta`i' - ln(1-beta`i')
	}
end

