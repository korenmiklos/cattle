clear
set memory 500m

local datastore ../../../data/Miklos /*~/share/data*/
local assembla ../data
tempfile codes eli wdi

/*Reading in product eli codes*/
insheet using `assembla'/EIU/productcodes_sectors.csv, names clear
sort product
save `codes', replace

/*Reading in sector codes*/
insheet using `assembla'/EIU/ELI_code.csv, names clear
sort eli
save `eli', replace

/*Reading in wdi data*/
insheet using `assembla'/wdi/wdi_9007.csv, names clear
sort isocode year
save `wdi', replace

/*Opening cityprices*/
use `datastore'/EIU/cityprices/cityprices, clear

drop if substr(product,1,2)=="SD"
drop if product=="CCPI" | product=="LCHD"
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

sort product
merge product using `codes', keep(eli productname) nokeep
tabulate _merge
drop _merge

sort eli
merge eli using `eli', keep(sectorcode) nokeep
tabulate _merge
drop _merge

label define sectors 1 "Non-durables" 2 "Durables" 3 "Personal services" 4 "Business Services" 5 "Rents"
label values sectorcode sectors

/*Calculating 10 year averages 1997-2006*/
drop if year<=1996
drop xrat eli
collapse price citypop metropop pcgdp density population urban, by(city countryname product productname sectorcode)

/*Creating variables*/
gen lny=ln(pcgdp)
gen lndensity=ln(density)
gen lnp=ln(price)
drop pcgdp density price
by product, sort: egen meanlny=mean(lny)
by product, sort: egen meanurban=mean(urban)
by product, sort: egen meanlndensity=mean(lndensity)
gen urbanX=(urban-meanurban)*(lny-meanlny)
gen densityX=(lndensity-meanlndensity)*(lny-meanlny)
drop mean*

/*Calculating panel regressions by sectors*/
egen prod_no=group(product)
xtset prod_no
xtreg lnp lny urban urbanX if sectorcode==3, fe

save ../../../data/EIU/cityprices, replace
