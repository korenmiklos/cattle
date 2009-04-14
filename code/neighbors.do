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
local threshold 300
/* which closeness measure we use*/
local closeness close

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

/* weighted average GDP */
replace pop = 0 if missing(pop,rgdpch)
replace rgdpch = rgdpch*pop

/* drop irrelevant countries */
drop if isocode==iso_o
keep if `closeness'

collapse (sum) pop rgdpch, by(iso_o)
replace rgdpch=rgdpch/pop
gen lngdpngb = ln(rgdpch)
drop rgdpch pop

/* now for local variables */
ren iso_o isocode
gen int year=2000
sort isocode year
merge isocode year using `pwt', nokeep
tab _m
drop _m

gen lngdp = ln(rgdpch)
gen lnpc = ln(pc)

reg lnpc lngdp lngdpngb, r
