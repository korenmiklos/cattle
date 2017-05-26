capture log close
log using ../doc/calibrate_sector_locations, text replace
set more off

clear all

use ../data/wdi/wdi_2007
ren countrycode iso


* merge 1:1 iso using ../data/maxmind/cities, keep(match)
sort iso
merge iso using ../data/maxmind/all_cities, nokeep
drop _m

* estimate city boundaries with constant population density
gen z3 = sqrt(area/population*citypopulation)/3.1416
* only do counterfactual with largest city
keep if rank==1

* reshape sectors into long
ren agrishare share3
ren industryshare share2
ren serviceshare share1

loca prod laborprod
ren agri_`prod' A3
ren ind_`prod' A2
ren serv_`prod' A1

ren agriprice P3
ren industryprice P2
ren serviceprice P1

*land shares
gen beta1 = 0.13
gen beta2 = 0.10
gen beta3 = 0.23

* taus calibrated to employment gradients
gen tau3 = 0.008142
gen tau2 = 0.00515
gen tau1 = 0.017

scalar R1pR2 = 5
scalar R1pR3 = 10

* approximate sector cutoffs
gen z2pz1 = sqrt(1+R1pR2*share2*beta2/share1/beta1)
gen z3pz1 = sqrt(z2pz1^2+R1pR3*share3*beta3/share1/beta1)

gen z1 = z3/z3pz1
gen z2 = z1*z2pz1


scalar pi = 3.1416

* create representative sector locations (ztilde) 
local previous 0
forval i=1/3 {
	gen ztilde`i' = -beta`i'/tau`i'*log(1/(z`i'^2*pi-`previous'^2*pi)*2*pi*((-beta`i'/tau`i'*z`i'*exp(-tau`i'/beta`i'*z`i')+beta`i'/tau`i'*`previous'*exp(-tau`i'/beta`i'*`previous'))-((beta`i'/tau`i')^2*exp(-tau`i'/beta`i'*z`i')-(beta`i'/tau`i')^2*exp(-tau`i'/beta`i'*`previous')))) 
	local previous ztilde`i'
}
edit iso z? ztilde?

gen y = ln(gdppercap)

label var y "GDP per capita (PPP, log)"

BRK

label var atilde "Measured productivity"
label var a "Location-corrected productivity"

gen coef_measured = .
gen coef_true = .
forval i=1/3 {
	local options "scheme(s2color) ytitle(Productivity relative to U.S. (log))"
	tw (scatter a y if sector==`i' & !missing(a), mlabel(iso)) (lfit a y if sector==`i' & !missing(a)),  `options'
	graph export ../text/figures/true_prod_`i'.png, width(800) replace
	tw (scatter atilde y if sector==`i' & !missing(a), mlabel(iso)) (lfit atilde y if sector==`i' & !missing(a)), `options'
	graph export ../text/figures/measured_prod_`i'.png, width(800) replace
	
	reg atilde y if sector==`i' & !missing(a,atilde)
	replace coef_measured = _b[y] if sector==`i'
	reg a y if sector==`i'& !missing(a,atilde)
	replace coef_true = _b[y] if sector==`i'
}

table sector, c(mean coef_measured mean coef_true)

preserve

reshape wide atilde a z z_min bias ztilde max_bias share P A beta ULC ULCUSA tau land_demand cumlandshare A_corrected A_USA coef_measured coef_true, i(countryname) j(sector)
list countryname A3 A_corrected3 A2 A_corrected2 A1 A_corrected1 if !missing(A_corrected3), noobs clean
list countryname share1 share2 share3 z1 z2 z3 if !missing(A_corrected3), noobs clean
list countryname ULC1 ULC2 ULC3 if !missing(A_corrected3), noobs clean

restore 

set more on
log close
