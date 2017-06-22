clear all

set obs 100

gen z = _n/10

local z1 = 2.5
local z2 = 7.0
local z3 = 9.0


* taus calibrated to employment gradients
scalar slope3 = 5/100
scalar slope2 = 15/100
scalar slope1 = 30/100

* experiment with suitable intercepts
scalar intercept1 = 1.0

forval i=2/3 {
	local p = `i'-1
	scalar intercept`i' = intercept`p' + (slope`i'- slope`p')*`z`p''
}

forval i=1/3 {
	gen R`i' = exp(intercept`i'-z*slope`i')
}

tw (line R? z), scheme(s2mono) ///
	xtitle("Distance to CBD, z") ytitle("Ri(z)=exp({&kappa}-z{&tau}/{&beta})") ///
	legend(order(1 "Services" 2 "Manufacturing" 3 "Agriculture")) ///
	xline(`z1' `z2' `z3', lstyle(refline)) ///
	xlabel(`z1' "z1" `z2' "z2" `z3' "z3")

graph export figures/bid_rent_curves.png, width(800) replace
