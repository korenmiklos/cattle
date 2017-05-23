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

* use eq 2 from Fieler Ecta 2011, approximate lambda with polynomial of income, https://paperpile.com/view/93de0f52-d1df-05d9-aca1-3724d0d8cd73
local sigma1 exp({logsigma1})
local sigma2 exp({logsigma2})
local sigma3 exp({logsigma3})
local lambda exp({xb: ln_y__*})
local numerator1 (`lambda'^(-`sigma1') * {alpha1} * price1^(1-`sigma1'))
local numerator2 (`lambda'^(-`sigma2') * {alpha2} * price2^(1-`sigma2'))
local numerator3 (`lambda'^(-`sigma3') *      1   * price3^(1-`sigma3'))
local denominator (`numerator1'+`numerator2'+`numerator3') 
nlsur /*
   */ (share1 = `numerator1'/`denominator') /*
   */ (share2 = `numerator2'/`denominator') /*
   */ (share3 = `numerator3'/`denominator') /*
   */ if !missing(share1,share2,share3,ln_y)&country_tag
   
* save params for future use
estimates save output/structural_transformation, replace

* predict at the city level
replace ln_y = ln(gdp_pc)
forval i=1/3 {
	replace ln_y__`i' = ln_y^`i' 
}
predict share1hat, eq(#1)
predict share2hat, eq(#2)
gen share3hat = 1-share1hat -share2hat 
