clear
set memory 500m

local datastore ../../../data/Miklos /*~/share/data*/
local assembla ../data
tempfile codes eli wdi pwt prox


/*Reading in product eli codes*/
insheet using `assembla'/eiu/productcodes_sectors.csv, names clear
sort product
save `codes', replace

/*Reading in sector codes
insheet using `assembla'/eiu/ELI_code.csv, names clear
sort eli
save `eli', replace*/


/*Reading in wdi data*/
insheet using `assembla'/wdi/wdi_9007.csv, names clear
sort isocode year
save `wdi', replace

/*Reading in proximity codes*/
xmluse `assembla'/census/proximity.xml, clear
rename sector naics
rename urban prox_urban
rename density prox_density
sort naics
save `prox', replace

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

/*Calculating 10 year averages 1997-2006*/
/*keep if year==2004*/
drop xrat
drop if year<=1996
collapse price citypop metropop pcgdp density population urban, by(city countryname product isocode)

sort product
merge product using `codes', keep(eli naics productname sector) nokeep
tabulate _merge
drop _merge

/*sort eli
merge eli using `eli', keep(sectorcode) nokeep
tabulate _merge
drop _merge*/

sort naics
merge naics using `prox', nokeep
tabulate _merge
drop _merge

/*label define sectors 1 "Non-durables" 2 "Durables" 3 "Personal services" 4 "Business Services" 5 "Rents"
label values sectorcode sectors*/

/*Creating variables*/
gen lny=ln(pcgdp)
gen lndensity=ln(density)
gen lnp=ln(price)
gen lncitypop=ln(citypop)
gen lnprox_density=ln(prox_density)
drop pcgdp density price citypop prox_density

/*
egen meanlny=mean(lny)
egen meanurban=mean(urban)
egen meanlndensity=mean(lndensity)
egen meanlncitypop=mean(lncitypop)
egen meanlnprox_density=mean(lnprox_density)
egen meanprox_urban=mean(prox_urban)
gen urbanX=(urban-meanurban)*(lny-meanlny)
gen densityX=(lndensity-meanlndensity)*(lny-meanlny)
gen citypopX=(lncitypop-meanlncitypop)*(lny-meanlny)
gen prox_urbanX=(prox_urban-meanprox_urban)*(lny-meanlny)
gen prox_densityX=(lnprox_density-meanlnprox_density)*(lny-meanlny)
drop mean*
*/

by sector, sort: egen meanlny=mean(lny)
by sector, sort: egen meanurban=mean(urban)
by sector, sort: egen meanlndensity=mean(lndensity)
by sector, sort: egen meanlncitypop=mean(lncitypop)
gen urbanX=(urban-meanurban)*(lny-meanlny)
gen densityX=(lndensity-meanlndensity)*(lny-meanlny)
gen citypopX=(lncitypop-meanlncitypop)* (lny-meanlny)
gen prox_urbanX=(prox_urban-meanprox_urban)*(lny-meanlny)
gen prox_densityX=(lnprox_density-meanlnprox_density)*(lny-meanlny)
drop mean*

egen sectorcode=group(sector)
egen quartile=cut(lnprox_density), group(4)
xi: regress lnp i.sector*lny i.sector*lnprox_density i.sector*prox_densityX, robust cluster

/*Calculating panel regressions by sectors
by product, sort: egen meanlny=mean(lny)
by product, sort: egen meanurban=mean(urban)
by product, sort: egen meanlndensity=mean(lndensity)
by product, sort: egen meanlncitypop=mean(lncitypop)
gen urbanX=(urban-meanurban)*(lny-meanlny)
gen densityX=(lndensity-meanlndensity)*(lny-meanlny)
gen citypopX=(lncitypop-meanlncitypop)*(lny-meanlny)
gen prox_urbanX=(prox_urban-meanprox_urban)*(lny-meanlny)
gen prox_densityX=(lnprox_density-meanlnprox_density)*(lny-meanlny)
egen prod_no=group(product)
xtset prod_no
xtreg lnp lny urban urbanX if sectorcode==3, fe

regress lnp lny prox_urban prox_urbanX, robust
regress lnp lny lnprox_density prox_densityX, robust*/


save ../../../data/eiu/cityprices, replace
