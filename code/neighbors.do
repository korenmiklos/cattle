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

/* merge with PWT */
ren iso_d isocode
gen int year=2000
sort isocode year
merge isocode year using `pwt', nokeep
tab _m
drop _m

foreach X of var `pwtkeep' {
    drop if missing(`X')
    gen ln`X'1 = ln(`X')
}
drop `pwtkeep'

/* drop irrelevant countries */
drop if isocode==iso_o

ren isocode iso1

/* now for local variables */
ren iso_o isocode
sort isocode year
merge isocode year using `pwt', nokeep
tab _m
drop _m

foreach X of var `pwtkeep' {
    drop if missing(`X')
    gen ln`X'2 = ln(`X')
}
drop `pwtkeep'
ren isocode iso2

gen distance = distw
recode distance min/200=200 200/400=400 400/600=600 600/1000=1000 1000/max=9999

xi: reg  lnp1 lnrgdpch1 i.distance*lnrgdpch2, cluster(iso1)
