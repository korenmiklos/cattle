clear
set memory 500m

local datastore ../../../data/Miklos /*~/share/data*/
local assembla ../data
tempfile codes eli wdi pwt

/*Reading in product eli codes*/
insheet using `assembla'/eiu/productcodes_sectors.csv, names clear
sort product
save `codes', replace

/*Reading in sector codes*/
insheet using `assembla'/eiu/ELI_code.csv, names clear
sort eli
save `eli', replace


/*Reading in wdi data*/
insheet using `assembla'/wdi/wdi_9007.csv, names clear
sort isocode year
save `wdi', replace

/*Opening cityprices*/
use `datastore'/eiu/cityprices/cityprices, clear

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
/*keep if year==2004*/
drop xrat eli
drop if year<=1996
collapse price citypop metropop pcgdp density population urban, by(city countryname product productname sectorcode)

/*Creating variables*/
gen lny=ln(pcgdp)
gen lndensity=ln(density)
gen lnp=ln(price)
gen lncitypop=ln(citypop)
/*drop pcgdp density price citypop*/
by product, sort: egen meanlny=mean(lny)
by product, sort: egen meanurban=mean(urban)
by product, sort: egen meanlndensity=mean(lndensity)
by product, sort: egen meanlncitypop=mean(lncitypop)
gen urbanX=(urban-meanurban)*(lny-meanlny)
gen densityX=(lndensity-meanlndensity)*(lny-meanlny)
gen citypopX=(lncitypop-meanlncitypop)*(lny-meanlny)
drop mean*

/*Calculating panel regressions by sectors*/
egen prod_no=group(product)
xtset prod_no
xtreg lnp lny urban urbanX if sectorcode==3, fe

save ../../../data/eiu/cityprices, replace
