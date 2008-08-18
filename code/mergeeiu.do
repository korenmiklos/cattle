clear

local datastore ../../../data/Miklos /*~/share/data*/
tempfile pwt

use `datastore'/pwt/pwt
keep isocode year pop xrat rgdpch
sort isocode year
save `pwt', replace

use `datastore'/eiu/cityprices/cityprices

drop if substr(product,1,2)=="SD"
drop if product=="CCPI" | product=="LCHD" | product=="ROLT"
/* these are not price-related vars */

drop if substr(product,1,2)=="IS"
/* school prices are notoriously off in some cases */

sort city
merge city using `datastore'/wikipedia/cities/cities
tab _m
drop _m

drop country 

sort isocode year
merge isocode year using `pwt', nokeep

tab _m
drop _m

/* check relative prices */
egen USAprice = mean(cond(isocode=="USA",price,.)), by(product year)
gen relprice = price/USAprice

/* derivative variables */
gen logprice = log(price)
gen loggdp = log(rgdpch)
gen logcity = log(citypop)
gen logdensity = logcity-log(cityarea)


