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
* for missing price data, use relative price of 1
mvencode price?, mv(1) override
su price?
drop _m

* use eq 4 from Herrendorf et al AER 2013 with sigma=1, https://paperpile.com/view/d5a5586d-5160-0ec7-bcdd-23d5853fdb95

nlsur (share1 = {omega1}*(1+({shifter1}*price1+{shifter3}*price3)/exp(ln_y)) - {shifter1}*price1/exp(ln_y)) /*
   */ (share3 = {omega3}*(1+({shifter1}*price1+{shifter3}*price3)/exp(ln_y)) - {shifter3}*price3/exp(ln_y)) /*
   */ if !missing(share1,share3,ln_y)&country_tag
   
* save params for future use
estimates save output/structural_transformation, replace
foreach X in omega1 omega3 shifter1 shifter3 { 
	scalar `X' = _b[`X':_cons]
}

* predict at the city level
replace ln_y = ln(gdp_pc)
predict share1hat, eq(#1)
predict share3hat, eq(#2)
gen share2hat = 1-share1hat -share3hat 
