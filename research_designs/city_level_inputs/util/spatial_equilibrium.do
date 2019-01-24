confirm numeric variable Ac Ar Pu_Pr N L
confirm scalar tau beta

foreach X in z z_tilde Lc Lu_bar Lr L_bar Cr Cu Qr Qc Qu {
	capture drop `X'
}

* city boundary
gen z = ln(Pu_Pr * Ac / Ar) / tau
* representative location
z_to_tilde z_tilde z tau/beta
gen Lc = z^2 * pi

do util/aggregates
