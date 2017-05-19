drop __*

* estimate structural transformation on macro data
egen country_tag = tag(iso3 year)
gen ln_y = ln(gdppercapita)

* aggregate price index
merge m:1 iso3 using input/sector_price_levels
drop if _m==2
gen price = price1^share1 * price2^share2 * price3^share3
forval i=1/3 {
	replace price`i' = price`i'/price
}
* interpolate missing price data
forval i=1/3 {
	gen ln_y__`i' = ln_y^`i' 
}
forval i=1/3 {
	tempvar hat
	reg price`i' ln_y__*
	predict `hat'
	replace price`i' = `hat' if missing(price`i') 
}
drop _m

* use eq 4 from Herrendorf et al AER 2013 with sigma=1, https://paperpile.com/view/d5a5586d-5160-0ec7-bcdd-23d5853fdb95
local sigma (1-exp({logsigma}))
local price_index ({omega1}*price1^`sigma' + {omega2}*price2^`sigma' + price3^`sigma') 
local committed_budget ({shifter1}*price1+{shifter2}*price2+{shifter3}*price3)
local C exp(ln_y)
nlsur /*
   */ (share1 = {omega1}*price1^`sigma'/`price_index' * (1+`committed_budget'/`C') - {shifter1}*price1/`C') /*
   */ (share2 = {omega2}*price2^`sigma'/`price_index' * (1+`committed_budget'/`C') - {shifter2}*price2/`C') /*
   */ (share3 =        1*price3^`sigma'/`price_index' * (1+`committed_budget'/`C') - {shifter3}*price3/`C') /*
   */ if !missing(share1,share3,ln_y)&country_tag
   
* save params for future use
estimates save output/structural_transformation, replace

* predict at the city level
replace ln_y = ln(gdp_pc)
predict share1hat, eq(#1)
predict share2hat, eq(#2)
gen share3hat = 1-share1hat -share2hat 
