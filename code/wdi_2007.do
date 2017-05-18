clear 
set mem 25m

* creating arable land data for merging with wdi data
insheet using ../data/wdi/arable_land_2007.csv, names
sort countrycode
save ../data/wdi/arable_2007.dta, replace

* reading wdi data and merging with arable land
clear
insheet using ../data/wdi/wdi_2007.csv, names
sort countrycode
merge countrycode using ../data/wdi/arable_2007.dta, keep(arable) 
tabulate _merge
drop _merge
save ../data/wdi/wdi_2007.dta, replace

* reading EU Klems data
* XR euro conversion rates
clear
insheet using ../data/EUKLEMS/XR_eur_1999.csv, names
rename unitsof~ eur_conv
sort countrycode
save ../data/EUKLEMS/XR_eur_1999.dta, replace

* XR
clear
insheet using ../data/EUKLEMS/XR_1997.csv, names
destring xr, replace
sort countrycode
merge countrycode using ../data/EUKLEMS/XR_eur_1999.dta, keep(eur_conv eur_usd)
tabulate _merge
drop _merge
* using the euro conversion rates
replace xr=eur_conv if eur_conv!=.
* using euros
gen xr_eur=xr
replace xr_eur=eur_usd if eur_usd!=.
sort countrycode
save ../data/EUKLEMS/XR.dta, replace

* Value-added for weighting
clear
insheet using ../data/EUKLEMS/VA.csv
drop if sector==.
* renaming country variables for reshaping
renvars aus-eu25ex, prefix(va)
reshape long va, i(industry industryid sector) string
rename _j countrycode
sort industryid sector countrycode
save ../data/EUKLEMS/va.dta, replace

* multifactor productivity data
clear
insheet using ../data/EUKLEMS/MFP_VADD.csv
drop if sector==.

* renaming country variables for reshaping
renvars aus-eu25ex, prefix(mfp)
reshape long mfp, i(industry industryid sector) string
rename _j countrycode
sort industryid sector countrycode
save ../data/EUKLEMS/MFP.dta, replace

* labor productivity data
clear
insheet using ../data/EUKLEMS/LP_VADD.csv
drop if sector==.

* renaming country variables for reshaping
renvars aus-eu25ex, prefix(lp)
reshape long lp, i(industry industryid sector) string
rename _j countrycode
sort industryid sector countrycode
save ../data/EUKLEMS/LP.dta, replace

* ppp data
clear
insheet using ../data/EUKLEMS/PPP_VA.csv
drop if sector==.

* renaming country variables for reshaping
renvars aus-eu25ex, prefix(ppp)
reshape long ppp, i(industry industryid sector) string
rename _j countrycode

sort industryid sector countrycode
merge industryid sector countrycode using ../data/EUKLEMS/va.dta
tabulate _merge
drop _merge

sort industryid sector countrycode
merge industryid sector countrycode using ../data/EUKLEMS/mfp.dta
tabulate _merge
drop _merge

sort industryid sector countrycode
merge industryid sector countrycode using ../data/EUKLEMS/lp.dta
tabulate _merge
drop _merge

collapse ppp mfp lp [aweight=va], by(countrycode sector)
reshape wide ppp mfp lp, i(countrycode) j(sector)

* adding exchange rate
replace countrycode=upper(countrycode)
sort countrycode
merge countrycode using ../data/EUKLEMS/xr.dta, keep(xr xr_eur) nokeep
tabulate _merge
drop _merge
replace ppp1=ppp1/xr_eur
replace ppp2=ppp2/xr_eur
replace ppp3=ppp3/xr_eur
sort countrycode
save ../data/EUKLEMS/ppp.dta, replace

clear
insheet using ../data/EUKLEMS/wage.csv, names
gen wage=lab/hours
sort countrycode
save ../data/EUKLEMS/wage.dta, replace

* putting ppp variables into wdi dataset
use ../data/wdi/wdi_2007.dta
sort countrycode

merge countrycode using ../data/EUKLEMS/xr.dta, keep(xr xr_eur) nokeep
tabulate _merge
drop _merge

sort countrycode
merge countrycode using ../data/EUKLEMS/wage.dta, nokeep
tabulate _merge
drop _merge
replace wage=wage/xr_eur

sort countrycode
merge countrycode using ../data/EUKLEMS/ppp.dta, nokeep
tabulate _merge
drop _merge


rename ppp1 agriprice
rename ppp2 industryprice
rename ppp3 serviceprice
rename lp1 agri_laborprod
rename lp2 ind_laborprod
rename lp3 serv_laborprod
rename mfp1 agri_mfprod
rename mfp2 ind_mfprod
rename mfp3 serv_mfprod
save ../data/wdi/wdi_2007.dta, replace
