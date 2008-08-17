clear

local datastore ~/share/data
tempfile pwt

use `datastore'/pwt/pwt
keep isocode year pop xrat rgdpch
sort isocode year
save `pwt', replace

use `datastore'/eiu/cityprices/cityprices

drop if substr(product,1,2)=="SD"
/* these are not price-related vars */

sort city
merge city using ~/share/data/wikipedia/cities/cities
tab _m
drop _m

drop country *area 

sort isocode year
merge isocode year using `pwt', nokeep

tab _m
drop _m


/* euro conversion rates */
replace xrat = xrat*13.7603 if isocode=="AUT" & year<=1998
replace xrat = xrat*40.3399 if isocode=="BEL" & year<=1998
replace xrat = xrat*166.386 if isocode=="ESP" & year<=1998
replace xrat = xrat*5.94573 if isocode=="FIN" & year<=1998
replace xrat = xrat*6.55957 if isocode=="FRA" & year<=1998
replace xrat = xrat*1.95583 if isocode=="GER" & year<=1998
replace xrat = xrat*0.787564 if isocode=="IRL" & year<=1998
replace xrat = xrat*1936.27 if isocode=="ITA" & year<=1998
replace xrat = xrat*40.3399 if isocode=="LUX" & year<=1998
replace xrat = xrat*2.20371 if isocode=="NLD" & year<=1998
replace xrat = xrat*200.482 if isocode=="PRT" & year<=1998
replace xrat = xrat*340.750 if isocode=="GRC" & year<=2000


/* check relative prices */
egen USAprice = mean(cond(isocode=="USA",price,.)), by(product year)
gen usdprice = price/xrat

gen relprice = usdprice/USAprice

collapse (mean) relprice, by(isocode year)

