clear
set mem 64m
set more off

/* all potential datastores here */
local datastores ../../../data/Miklos ~/share/data /share/datastore
tempfile pwt
local pwtkeep "pop p pc rgdpch"
local destination ../data/neighbors

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

drop if missing(pop)
*replace pop=1

/* weighted average variables */
foreach X of var `pwtkeep' {
    drop if missing(`X')
    if "`X'"!="pop" {
        replace `X' = `X'*pop
    }
}

/* drop irrelevant countries */
drop if isocode==iso_o

collapse (sum) `pwtkeep', by(iso_o `closeness')
keep if `closeness'
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

sort isocode
saveold `destination', replace

reg lnpc lnrgdpch lnrgdpchngb, r
reg lnpc lnrgdpch lnrgdpchngb lnpcngb, r

/*
Unweighted average of neighboring countries:
. reg lnpc lnrgdpch lnrgdpchngb, r

Linear regression                                      Number of obs =     146
                                                       F(  2,   143) =   42.06
                                                       Prob > F      =  0.0000
                                                       R-squared     =  0.3658
                                                       Root MSE      =  .47262

------------------------------------------------------------------------------
             |               Robust
        lnpc |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
    lnrgdpch |   .2053626   .0544508     3.77   0.000     .0977301    .3129951
 lnrgdpchngb |   .1402334   .0639837     2.19   0.030     .0137575    .2667094
       _cons |   .6194392   .3448004     1.80   0.075     -.062125    1.301003
------------------------------------------------------------------------------




Unweighted avg of countries closer than 600kms:
. reg lnpc lnrgdpch lnrgdpchngb, r

Linear regression                                      Number of obs =     121
                                                       F(  2,   118) =   72.00
                                                       Prob > F      =  0.0000
                                                       R-squared     =  0.4923
                                                       Root MSE      =  .44163

------------------------------------------------------------------------------
             |               Robust
        lnpc |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
    lnrgdpch |    .245732   .0476299     5.16   0.000     .1514118    .3400522
 lnrgdpchngb |   .1518464   .0480251     3.16   0.002     .0567436    .2469493
       _cons |   .2082911    .294942     0.71   0.481    -.3757743    .7923565
------------------------------------------------------------------------------






Weighted avg of countries closer than 600kms:
. reg lnpc lnrgdpch lnrgdpchngb, r

Linear regression                                      Number of obs =     121
                                                       F(  2,   118) =   61.78
                                                       Prob > F      =  0.0000
                                                       R-squared     =  0.4806
                                                       Root MSE      =  .44667

------------------------------------------------------------------------------
             |               Robust
        lnpc |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
    lnrgdpch |   .2676803   .0437367     6.12   0.000     .1810698    .3542909
 lnrgdpchngb |   .1230139   .0477089     2.58   0.011     .0285373    .2174904
       _cons |   .2745803   .3238379     0.85   0.398    -.3667069    .9158676
------------------------------------------------------------------------------


This is all coming from price spillovers as opposed to productivity spillovers:
. reg lnpc lnrgdpch lnrgdpchngb lnpcngb, r

Linear regression                                      Number of obs =     121
                                                       F(  3,   117) =   43.10
                                                       Prob > F      =  0.0000
                                                       R-squared     =  0.5322
                                                       Root MSE      =   .4257

------------------------------------------------------------------------------
             |               Robust
        lnpc |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
    lnrgdpch |   .2267317   .0461717     4.91   0.000      .135291    .3181724
 lnrgdpchngb |  -.0000683   .0621282    -0.00   0.999      -.12311    .1229735
     lnpcngb |   .4077141   .1195118     3.41   0.001     .1710272     .644401
       _cons |   .1956379    .326802     0.60   0.551    -.4515764    .8428522
------------------------------------------------------------------------------



*/
