local variables N L Ac Ar Pu_Pr Lr Lu_bar L_bar Cr Cu Qr Qc Qu
keep iso3 year METRO_ID city_name `variables'

foreach X of var `variables' {
	ren `X' `X'`1'
}
notes : `2'

save output/scenario_`1', replace
