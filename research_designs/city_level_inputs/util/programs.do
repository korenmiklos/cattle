capture prog drop _all
program define z_to_tilde
	args z_tilde z_bar slope
	
	gen `z_tilde' = 2/(`slope'*`z_bar')^2 * (1-exp(-(`slope')*`z_bar')*(1+(`slope')*`z_bar'))
	replace `z_tilde' = -ln(`z_tilde')/(`slope')
end

