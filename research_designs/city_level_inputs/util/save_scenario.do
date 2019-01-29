local variables N L Ac Ar Pu_Pr Lu Lr Lu_bar L_bar Cr Cu Qr Qc Qu Y Nu Nr
keep iso3 year city_code `variables'

foreach X of var `variables' {
	ren `X' `X'`1'
}
notes : `2'

save output/scenario_`1', replace
