* total urban vs rural land use
tempvar Lu
egen `Lu' = sum(Lc), by(iso3 year)
egen Lu_bar = sum(Lc * exp((z-z_tilde)*tau/beta)), by(iso3 year)
gen Lr = L - `Lu'
gen L_bar = Lr + Lu_bar

gen Cr = Ar * (L_bar/N)^beta * Lr/L
gen Cu = Ar * (L_bar/N)^beta * Lu_bar/L / Pu_Pr
