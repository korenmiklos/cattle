capture log close
log using ../doc/calibrate_sector_locations, text replace
set more off

clear all

use ../data/wdi/wdi_2007
ren countrycode iso

merge 1:1 iso using ../data/maxmind/cities, keep(match)
drop _m

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

gen beta1 = 0.13
gen beta2 = 0.10
gen beta3 = 0.23

reshape long P A share beta, i(iso) j(sector)
replace share = share/100

* calculate unit labor cost relative to USA
* approximate wages with GDP per capita
egen USAwage = mean(cond(iso=="USA",wage,.))
gen ULC = wage/USAwage/(P*A)

* ULC in USA is calibrate to match land demand
gen ULCUSA = 2.052 if sector==3
replace ULCUSA = 0.799 if sector==2
replace ULCUSA = 0.7915 if sector==1

* taus calibrated to employment gradients
gen tau = 0.008142 if sector==3
replace tau = 0.00515 if sector==2
replace tau = 0.017 if sector==1

* eq from cattle.pdf
gen land_demand = share*(1-beta)^(1-1/beta)*(ULC*ULCUSA)^(1/beta)
egen sum_land_demand = sum(land_demand), by(iso)
replace land_demand = land_demand/sum_land_demand
drop sum_land_demand

l iso sector A ULC land_demand if !missing(ULC)

sort iso sector
* cumulative area demand by first n sectors
by iso: gen cumlandshare = sum(land_demand)
replace cumlandshare = . if cumlandshare==0

* calculate z_3
* convert from hectares to square kms
replace arable = arable/100
* divide by number of cities to get average area of city
gen city_area = area/cities
* pretend cities are circular
scalar pi = 3.14159265
gen z = sqrt(city_area/pi) if sector==3

* distribute land to other sectors according to demand - ignore rent gradient
by iso: replace z = sqrt(cumlandshare)*z[3] if _n<3

* the maximum bias arises if the sector is located on the edge
gen max_bias = exp(-tau*z)

gen A_corrected = A/max_bias
egen A_USA = mean(cond(iso=="USA",A_corrected,.)), by(sector)
replace A_corrected = A_corrected/A_USA

gen atilde = ln(A)
gen a = ln(A_corrected)
gen y = ln(gdppercap)

label var y "GDP per capita (PPP, log)"
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



set more on
log close
