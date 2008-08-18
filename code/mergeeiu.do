clear

local datastore ../../../data/Miklos /*~/share/data*/
tempfile pwt

use `datastore'/pwt/pwt
keep isocode year pop xrat rgdpch
sort isocode year
save `pwt', replace

use `datastore'/eiu/cityprices/cityprices

drop if substr(product,1,2)=="SD"
drop if product=="CCPI" | product=="LCHD"
/* these are not price-related vars */

sort city
merge city using `datastore'/wikipedia/cities/cities
tab _m
drop _m

drop country *area

sort isocode year
merge isocode year using `pwt', nokeep

tab _m
drop _m

/* currency conversion episodes
replace xrat = xrat*10000 if isocode=="ARG" & year<=1991

replace xrat = xrat*2750 if isocode=="BRA" & year<=1993
replace xrat = xrat*1000 if isocode=="BRA" & year<=1992

replace xrat = xrat*25000 if isocode=="ECU" & year==1999
replace xrat = xrat*11789 if isocode=="ECU" & year==1998
replace xrat = xrat*5447 if isocode=="ECU" & year==1997
replace xrat = xrat*3988 if isocode=="ECU" & year==1996
replace xrat = xrat*3190 if isocode=="ECU" & year==1995
replace xrat = xrat*2565 if isocode=="ECU" & year==1994
replace xrat = . if isocode=="ECU" & year<1994

replace xrat = xrat*1000 if isocode=="MEX" & year<=1992

replace xrat = xrat/10000 if isocode=="ROM" & year<=2005

replace xrat = xrat*1000 if isocode=="RUS" & year<=1997

replace xrat = xrat/1e+6 if isocode=="TUR"

replace xrat = xrat/5000 if isocode=="AZE"

replace xrat = xrat*1000 if isocode=="URY" & year<=1992

replace xrat = xrat*10000 if isocode=="POL" & year<=1994

replace xrat = . if isocode=="KWT" & year==1990 /* iraq dinar */

/* euro */
replace xrat = xrat/13.7603 if isocode=="AUT" & year<=1998
replace xrat = xrat/40.3399 if isocode=="BEL" & year<=1998
replace xrat = xrat/166.386 if isocode=="ESP" & year<=1998
replace xrat = xrat/5.94573 if isocode=="FIN" & year<=1998
replace xrat = xrat/6.55957 if isocode=="FRA" & year<=1998 /* check */
replace xrat = xrat/1.95583 if isocode=="GER" & year<=1998
replace xrat = xrat/0.787564 if isocode=="IRL" & year<=1998
replace xrat = xrat/1936.27 if isocode=="ITA" & year<=1998
replace xrat = xrat/40.3399 if isocode=="LUX" & year<=1998
replace xrat = xrat/2.20371 if isocode=="NLD" & year<=1998
replace xrat = xrat/200.482 if isocode=="PRT" & year<=1998
replace xrat = xrat/340.750 if isocode=="GRC" & year<=2000 */


/* check relative prices */
egen USAprice = mean(cond(isocode=="USA",price,.)), by(product year)
gen usdprice = price/xrat

gen relprice = usdprice/USAprice

* collapse (mean) relprice, by(isocode year)
