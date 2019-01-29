clear all

use output/calibrated_cities
merge m:1 iso3 year using output/calibrated_countries, keep(match) nogen

do util/parameters
do util/programs

gen ln_Qc = ln(Qc)
gen ln_Y = ln(gdppercapita)

gen city_share = city_employment/urban_employment
* everything relative to New York
foreach X of var ln_Qc ln_Y *_contribution {
	su `X' if city_code=="USA-1", meanonly
	replace `X' = city_share * exp(`X' - r(mean))
}

collapse (sum) city_share ln_Qc ln_Y rural_productivity_contribution rural_land_contribution rel_productivity_contribution land_contribution location_contribution, by(iso3 year)
foreach X of var ln_Qc ln_Y *_contribution {
	replace `X' = ln(`X'/city_share)
}


local X ln_Y
label var ln_Qc "City output per worker (log, New York=0)"
label var ln_Y "GDP per capita (log, USA=0)"
* execute graphing command

tw 	(scatter rural_productivity_contribution `X', msize(tiny)) ///
	(lowess rural_productivity_contribution `X') ///
	(lowess rural_land_contribution `X'), ///
	legend(order(2 "Rural productivity" 3 "Rural land use")) ///
	scheme(s2mono)  ytitle("Relative contribution (log, New York=0)")
graph export output/rural_contributions.pdf, replace

tw 	(scatter rel_productivity_contribution `X', msize(tiny)) ///
	(lowess rel_productivity_contribution `X') ///
	(lowess land_contribution `X') ///
	(lowess location_contribution `X'), ///
	legend(order(2 "Urban/rural productivity" 3 "Urban/rural land use" 4 "Location")) ///
	scheme(s2mono)   ytitle("Relative contribution (log, New York=0)")
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
