clear all
use output/calibrated_cities

local variables productivity land location

* everythin relative to Boston
foreach X in `variables' {
	local graph_`X' "tw "
	forval i=1/3 {
		su `X'_contribution`i' if METRO_ID=="US048", meanonly
		replace `X'_contribution`i' = exp(`X'_contribution`i'-r(mean))
		* build graphing command
		local graph_`X' "`graph_`X'' (lowess `X'_contribution`i' gdp_pc)"
	}
	* execute graphing command
	`graph_`X'', scheme(s2mono) legend(order(1 "Services" 2 "Manufacturing" 3 "Agriculture")) xtitle(GDP per capita) ytitle("Relative `X' contribution (Boston=1)")
	graph export output/`X'.png, width(800) replace
}

