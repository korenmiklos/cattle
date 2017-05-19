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

nlsur (share1 = {omega1}*(1+({shifter1}*price1+{shifter2}*price2+{shifter3}*price3)/exp(ln_y)) - {shifter1}*price1/exp(ln_y)) /*
   */ (share2 = {omega2}*(1+({shifter1}*price1+{shifter2}*price2+{shifter3}*price3)/exp(ln_y)) - {shifter2}*price2/exp(ln_y)) /*
   */ (share3 = 1*(1+({shifter1}*price1+{shifter2}*price2+{shifter3}*price3)/exp(ln_y)) - {shifter3}*price3/exp(ln_y)) /*
   */ if !missing(share1,share3,ln_y)&country_tag
   
* save params for future use
estimates save output/structural_transformation, replace

* predict at the city level
replace ln_y = ln(gdp_pc)
predict share1hat, eq(#1)
predict share2hat, eq(#2)
gen share3hat = 1-share1hat -share2hat 
