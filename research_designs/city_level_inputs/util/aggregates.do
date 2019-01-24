* total urban vs rural land use
egen Lu = sum(Lc), by(iso3 year)
egen Lu_bar = sum(Lc * exp((z-z_tilde)*tau/beta)), by(iso3 year)
gen Lr = L - Lu
gen L_bar = Lr + Lu_bar

* consumption per capita
gen Cr = Ar * (L_bar/N)^beta * Lr/L_bar
gen Cu = Ar * (L_bar/N)^beta * Lu_bar/L_bar / Pu_Pr

* output per worker
gen Qr = Ar * (L_bar/N)^beta
gen Qc = Ac * (L_bar/N)^beta * exp(-z_tilde * tau)
gen Qu = Ar * (L_bar/N)^beta / Pu_Pr

* fixed-price GDP
gen Y = Cr + Cu
