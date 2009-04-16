clear
set mem 64m
set more off

/* all potential datastores here */
local datastores ../data
tempfile wdi
local wdikeep "pop lnY lnP"
local destination ../data/neighbors_wdi

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
local threshold 600
/* which closeness measure we use*/
local closeness close

xmluse `datastore'/wdi/icp2005
ren iso isocode
keep isocode `wdikeep'
sort isocode
save `wdi', replace

use `cepii', clear
keep iso_o iso_d contig distw

gen byte close = (distw<`threshold')
drop distw

/* merge with WDI */
ren iso_d isocode
sort isocode
merge isocode using `wdi', nokeep
tab _m
drop _m

drop if missing(pop)
*replace pop=1

/* weighted average variables */
foreach X of var `wdikeep' {
    drop if missing(`X')
    if "`X'"!="pop" {
        replace `X' = exp(`X')*pop
    }
}

/* drop irrelevant countries */
drop if isocode==iso_o

* collapse (sum) `wdikeep', by(iso_o)
collapse (sum) `wdikeep', by(iso_o `closeness')
keep if `closeness'
foreach X of var `wdikeep' {
    if "`X'"!="pop" {
        replace `X' = ln(`X'/pop)
    }
    gen `X'ngb = `X'
}
drop `wdikeep'

/* now for local variables */
ren iso_o isocode
sort isocode
merge isocode using `wdi', nokeep
tab _m
drop _m

sort isocode
xmlsave `destination', replace

reg lnP lnY lnYngb, r
reg lnP lnY lnYngb lnPngb, r

/*
Weighted avg of countries closer than 600kms:
. reg lnpc lnrgdpch lnrgdpchngb, r

reg lnP lnY lnYngb, r

Linear regression                                      Number of obs =     110
                                                       F(  2,   107) =   63.68
                                                       Prob > F      =  0.0000
                                                       R-squared     =  0.5025
                                                       Root MSE      =  .33882

------------------------------------------------------------------------------
             |               Robust
         lnP |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
         lnY |   .2367061    .032344     7.32   0.000     .1725878    .3008244
      lnYngb |   .0179095   .0316677     0.57   0.573     -.044868     .080687
       _cons |  -2.875415   .2109027   -13.63   0.000    -3.293505   -2.457325
------------------------------------------------------------------------------


 reg lnP lnY lnYngb lnPngb, r

Linear regression                                      Number of obs =     110
                                                       F(  3,   106) =   72.10
                                                       Prob > F      =  0.0000
                                                       R-squared     =  0.5682
                                                       Root MSE      =  .31714

------------------------------------------------------------------------------
             |               Robust
         lnP |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
         lnY |   .2199354   .0358412     6.14   0.000     .1488768    .2909941
      lnYngb |  -.0992594   .0352346    -2.82   0.006    -.1691154   -.0294034
      lnPngb |   .5078361   .1027973     4.94   0.000     .3040306    .7116417
       _cons |  -1.380814   .3298288    -4.19   0.000    -2.034731   -.7268958
------------------------------------------------------------------------------



*/
