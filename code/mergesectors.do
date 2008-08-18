clear
set memory 500m

local datastore ../../../data/Miklos
local assembla ../data
tempfile codes eli

/*Reading in product eli codes*/
insheet using `assembla'/EIU/productcodes_sectors.csv, names clear
sort product
save `codes', replace

/*Reading in sector codes*/
insheet using `assembla'/EIU/ELI_code.csv, names clear
sort eli
save `eli', replace

use `datastore'/EIU/cityprices/cityprices, clear
drop if substr(product,1,2)=="SD"
drop if product=="CCPI" | product=="LCHD"
sort product
merge product using `codes', keep(eli) nokeep
tabulate _merge
drop _merge
sort eli
merge eli using `eli', keep(sectorcode) nokeep
tabulate _merge
drop _merge

label define sectors 1 "Non-durables" 2 "Durables" 3 "Personal services" 4 "Business Services" 5 "Rents"
label values sectorcode sectors

/*save cityprices, replace*/
