* estimate structural transformation on macro data
egen country_tag = tag(iso3 year)
gen ln_y = ln(gdppercapita)
nlsur (share1 = exp({a1}+{b1}*ln_y+{c1}*ln_y^2)/(1+exp({a1}+{b1}*ln_y+{c1}*ln_y^2)+exp({a2}+{b2}*ln_y+{c2}*ln_y^2))) /*
   */ (share2 = exp({a2}+{b2}*ln_y+{c2}*ln_y^2)/(1+exp({a1}+{b1}*ln_y+{c1}*ln_y^2)+exp({a2}+{b2}*ln_y+{c2}*ln_y^2))) /*
   */ if !missing(share1,share2,ln_y)&country_tag

* predict at the city level
replace ln_y = ln(gdp_pc)
predict share1hat, eq(#1)
predict share2hat, eq(#2)
gen share3hat = 1-share1hat -share2hat 
