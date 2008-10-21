clear
set memory 500m

/* all potential datastores here */
local datastores ../../../data/Miklos ~/share/data /share/datastore
local assembla ../data
local proxmeasure density
local fixedeffectstransformation no
tempfile codes wdi prox nber

/* handle different paths */
local currentdir `c(pwd)'
foreach X of any `datastores' {
    capture chdir "`X'"
    if _rc==0 {
        local datastore `X'
    }
}
chdir `currentdir'

/*Reading in product eli codes*/
insheet using `assembla'/eiu/productcodes_sectors.csv, names clear
sort product
save `codes', replace

/* filter nber data */
clear
use `datastore'/nber/industry/bbg96_87
keep if year==96
gen labor = pay/vadd
gen unskilled = prodw/vadd
keep sic labor *skilled
ren sic sic87
sort sic87
save `nber', replace

/*Reading in wdi data*/
insheet using `assembla'/wdi/WDI_9007.csv, names clear
sort isocode year
save `wdi', replace

/*Reading in proximity codes*/
xmluse `assembla'/census/proximity.xml, clear
rename sector naics
rename `proxmeasure' proximity
sort naics
save `prox', replace

/*Opening cityprices*/
use `datastore'/eiu/cityprices/cityprices, clear

drop if substr(product,1,2)=="SD"
drop if product=="CCPI" | product=="LCHD"  | product=="ROLT"
/* these are not price-related vars */

sort city
merge city using `datastore'/wikipedia/cities/cities
tab _m
drop _m

drop country *area

sort isocode year
merge isocode year using `wdi', nokeep
tab _m
drop _m

/*Calculating 10 year averages 1997-2006*/
/*keep if year==2004*/
drop xrat
drop if year<=1996
collapse price citypop metropop pcgdp density population urban, by(city countryname product isocode)

sort product
merge product using `codes', keep(eli naics productname sector sic87) nokeep
tabulate _merge
drop _merge

sort naics
merge naics using `prox', nokeep
tabulate _merge
drop _merge

/* merge with nber */
sort sic87
merge sic87 using `nber', nokeep
tabulate _merge
drop _merge


/*Creating variables*/
gen lngdp=ln(pcgdp)
gen lndensity=ln(density)
gen lnprice=ln(price)
gen lncitypop=ln(citypop)
if "`proxmeasure'"=="density" {
    replace proximity=ln(proximity)
}

if "`fixedeffectstransformation'"=="yes" {
    local vars_demean lnprice lngdp urban lndensity lncitypop
    foreach X of var `vars_demean' {
        by product, sort: egen meanbyp`X' = mean(`X')
    }
    foreach X of var `vars_demean' {
        replace `X' = `X'-meanbyp`X'
    }
drop meanbyp*
}

local vars lngdp urban lndensity lncitypop proximity labor unskilled

foreach X of var `vars' {
    egen mean`X' = mean(`X')
}
foreach X of var `vars' {
    gen gdpX`X' = (lngdp-meanlngdp)*(`X'-mean`X')
*    gen cityX`X' = (lncitypop-meanlncitypop)*(`X'-mean`X')
}

drop mean*

saveold ../data/cityprices_prepared, replace
