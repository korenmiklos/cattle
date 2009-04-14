clear
set mem 64m
set more off

/* all potential datastores here */
local datastores ../../../data/Miklos ~/share/data /share/datastore
tempfile pwt
local pwtkeep "pop p pc rgdpch"

/* handle different paths */
local currentdir `c(pwd)'
foreach X of any `datastores' {
    capture chdir "`X'"
    if _rc==0 {
        local datastore `X'
    }
}
chdir `currentdir'

local cepii http://cepii.fr/distance/dist_cepii.dta
/* closeness threshold in kms */
local threshold 400
/* which closeness measure we use*/
local closeness contig

use `datastore'/pwt/pwt
keep isocode year `pwtkeep'
sort isocode year
save `pwt', replace

use `cepii', clear
keep iso_o iso_d contig distw

gen byte close = (distw<`threshold')
drop distw

/* merge with PWT */
ren iso_d isocode
gen int year=2000
sort isocode year
merge isocode year using `pwt', nokeep
tab _m
drop _m

/* weighted average variables */
foreach X of var `pwtkeep' {
    drop if missing(`X')
    if "`X'"!="pop" {
        replace `X' = `X'*pop
    }
}

/* drop irrelevant countries */
drop if isocode==iso_o
replace pop=0 if !`closeness'

collapse (sum) `pwtkeep', by(iso_o)
foreach X of var `pwtkeep' {
    if "`X'"!="pop" {
        replace `X' = `X'/pop
    }
    gen ln`X'ngb = ln(`X')
}
drop `pwtkeep'

/* now for local variables */
ren iso_o isocode
gen int year=2000
sort isocode year
merge isocode year using `pwt', nokeep
tab _m
drop _m

foreach X of var `pwtkeep' {
    gen ln`X' = ln(`X')
}
drop `pwtkeep'

reg lnpc lnrgdpch lnrgdpchngb, r
reg lnpc lnrgdpch lnrgdpchngb lnpcngb, r
