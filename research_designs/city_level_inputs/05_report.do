clear all

use output/calibrated_cities
merge m:1 iso3 year using output/calibrated_countries, keep(match) nogen

do util/parameters
do util/programs

* report actual vs estimated area
gen ln_area_data = ln(city_area_data) 
gen ln_area_model = ln(city_area)
scatter ln_area_model ln_area_data, scheme(s2mono) msize(small) xtitle("City area (data, log)") ytitle("City area (model, log)") 
graph export output/area_model_data.pdf, replace

corr ln_area_model ln_area_data

gen ln_Qc = ln(Qc)

* everything relative to New York
foreach X of var ln_Qc *_contribution {
	su `X' if METRO_ID=="US084", meanonly
	replace `X' = exp(`X' - r(mean))
}


local X ln_Qc
label var ln_Qc "City output per worker (New York=1)"
* execute graphing command
tw 	(lowess rural_productivity_contribution `X') ///
	(lowess rural_land_contribution `X'), ///
	legend(order(1 "Rural productivity" 2 "Rural land use")) ///
	scheme(s2mono)  ytitle("Relative contribution (New York=1)")
graph export output/rural_contributions.pdf, replace

tw 	(lowess rel_productivity_contribution `X') ///
	(lowess land_contribution `X') ///
	(lowess location_contribution `X'), ///
	legend(order(1 "Urban/rural productivity" 2 "Urban/rural land use" 3 "Location")) ///
	scheme(s2mono)   ytitle("Relative contribution (New York=1)")
graph export output/urban_contributions.pdf, replace

tempfile scenarios
use output/scenario_0, clear
* not to mix up with variables save in scenario 3
ren iso3 iso
local scenario0 : char _dta[note1]
save `scenarios', replace emptyok

forval i=1/3 {
	use output/scenario_`i', clear
	* not to mix up with variables save in scenario 3
	ren iso3 iso
	local scenario`i' : char _dta[note1]
	
	merge 1:1 METRO_ID using `scenarios', keep(match) nogen
	
	ren *0 *`i'0
	foreach X of var *`i' {
		replace `X' = `X' / `X'0
	}
	ren *`i'0 *0
	save `scenarios', replace
}
local lbl ""
forval i=0/3 {
	local lbl `lbl' `i' "`scenario`i''"
}

egen tag = tag(iso)
keep if tag
keep METRO_ID iso year Pu_Pr* Ar* Lu* Lr* Qr* Qu* Y*

local variables Pu_Pr Lu Lr Qu Qr Y
reshape long `variables', i(METRO_ID iso year) j(scenario)

label def scenario `lbl'
label value scenario scenario
label var Pu_Pr "Urban relative price"
label var Lu "Urban land"
label var Lr "Rural land"
label var Qr "Rural output per worker"
label var Qu "Urba output per worker"
label var Y "Constant-price GDP"

drop if scenario==0 | scenario==3
bys scenario: eststo: quietly estpost summarize `variables', listwise
esttab using output/counterfactuals.tex, replace cells("mean(fmt(3))") label nodepvar noobs
