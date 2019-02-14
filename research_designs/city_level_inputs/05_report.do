clear all

use output/calibrated_cities
merge m:1 iso3 year using output/calibrated_countries, keep(match) nogen

do util/parameters
do util/programs

* only report country-level decomposition
egen country_tag = tag(iso)
keep if country_tag

local variables Qc Y rural_output_per_worker urbanization_premium urbanization_contribution relative_price_effect
foreach X of var `variables' {
	gen ln_`X' = ln(`X')
	su ln_`X' if iso=="USA", meanonly
	replace ln_`X' = ln_`X' - r(mean)
}

local X ln_Y
label var ln_Y "GDP per capita (log, USA=0)"
tw 	(scatter ln_rural_output_per_worker `X', msize(tiny)) ///
	(lowess ln_rural_output_per_worker `X') ///
	(lowess ln_urbanization_contribution `X'), ///
	legend(order(2 "Rural output per worker" 3 "Urbanization contribution")) ///
	scheme(s2mono)  ytitle("Contribution to GDP per worker (log, USA=0)")
graph export output/rural_urban_contributions.pdf, replace

local X ln_urbanization_contribution
label var ln_urbanization_contribution "Relative urban/rural output per worker (log, USA=0)"
tw 	(scatter ln_urbanization_premium `X', msize(tiny)) ///
	(lowess ln_urbanization_premium `X') ///
	(lowess ln_relative_price_effect `X') ///
	, legend(order(2 "Urbanization premium" 3 "Relative price effect")) ///
	scheme(s2mono)   ytitle("Contribution to GDP per worker (log, USA=0)")
graph export output/urban_contributions.pdf, replace

tempfile scenarios
use output/scenario_0, clear
* not to mix up with variables save in scenario 3
ren iso3 iso
local scenario0 : char _dta[note1]
save `scenarios', replace emptyok

forval i=1/4 {
	use output/scenario_`i', clear
	* not to mix up with variables save in scenario 3
	ren iso3 iso
	local scenario`i' : char _dta[note1]
	
	merge 1:1 city_code using `scenarios', keep(match) nogen
	
	ren *0 *`i'0
	foreach X of var *`i' {
		replace `X' = `X' / `X'0
	}
	ren *`i'0 *0
	save `scenarios', replace
}
local lbl ""
forval i=0/4 {
	local lbl `lbl' `i' "`scenario`i''"
}

egen tag = tag(iso)
keep if tag
keep city_code iso year Pu_Pr* Ar* Lu* Lr* Qr* Qu* Y* Nr* Nu*

local variables Pu_Pr Lu Lr Nu Nr Qu Qr Y
reshape long `variables', i(city_code iso year) j(scenario)

label def scenario `lbl'
label value scenario scenario
label var Pu_Pr "Urban relative price"
label var Lu "Urban land"
label var Lr "Rural land"
label var Nu "Urban employment"
label var Nr "Rural employment"
label var Qr "Rural output per worker"
label var Qu "Urban output per worker"
label var Y "Constant-price GDP"

drop if scenario==0 | scenario==3 | scenario==2
bys scenario: eststo: quietly estpost summarize `variables', listwise
esttab using output/counterfactuals.tex, replace cells("mean(fmt(3))") label nodepvar noobs
