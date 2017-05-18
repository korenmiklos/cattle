capture prog drop _all
program define z_to_tilde
	args z_tilde z_bar slope hollow
	
	if ("`hollow'"=="") {
		local hollow 0
	}
	
	tempvar upper lower area
	gen `upper' = exp(-(`slope')*`z_bar')*(1+(`slope')*`z_bar')
	gen `lower' = exp(-(`slope')*`hollow')*(1+(`slope')*`hollow')
	gen `area' = `z_bar'^2-`hollow'^2
	
	gen `z_tilde' = -2/(`slope')^2 * (`upper'-`lower')/`area'
	replace `z_tilde' = -ln(`z_tilde')/(`slope')
end

