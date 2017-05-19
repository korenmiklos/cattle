* estimate structural transformation on macro data
egen country_tag = tag(iso3 year)
gen ln_y = ln(gdppercapita)

* use eq 4 from Herrendorf et al AER 2013 with sigma=1, https://paperpile.com/view/d5a5586d-5160-0ec7-bcdd-23d5853fdb95

nlsur (share1 = {omega1}*(1+({shifter1}+{shifter3})/exp(ln_y)) - {shifter1}/exp(ln_y)) /*
   */ (share3 = {omega3}*(1+({shifter1}+{shifter3})/exp(ln_y)) - {shifter3}/exp(ln_y)) /*
   */ if !missing(share1,share3,ln_y)&country_tag

* predict at the city level
replace ln_y = ln(gdp_pc)
predict share1hat, eq(#1)
predict share3hat, eq(#2)
gen share2hat = 1-share1hat -share3hat 
