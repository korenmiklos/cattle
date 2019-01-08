clear all

set obs 100

gen z = (_n-1)/10

local z1 = 5.0


* taus calibrated to employment gradients
scalar slope2 = 0/100
scalar slope1 = 30/100

* experiment with suitable intercepts
scalar intercept1 = 1.0

forval i=2/2 {
	local p = `i'-1
	scalar intercept`i' = intercept`p' + (slope`i'- slope`p')*`z`p''
}

forval i=1/2 {
	gen R`i' = exp(intercept`i'-z*slope`i')
}

tw (line R? z), scheme(s2mono) ///
	xtitle("Distance to CBD, z") ytitle("Ri(z)=exp({&zeta}-z{&tau}/{&beta})") ///
	legend(order(1 "Urban" 2 "Rural")) ///
	xline(`z1', lstyle(refline)) ///
	xlabel(`z1' "z1")

graph export figures/bid_rent_curves.png, width(800) replace
