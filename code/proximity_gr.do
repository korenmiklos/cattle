clear
set memory 25m

xmluse ..\data\census\proximity_2.xml
graph twoway (scatter infl_4706 empshare, mlabel(name) mlabvposition(clockpos)) (lfit infl_4706
>  empshare), legend(off) note("Data source: BEA, Census CBP") xtitle("Employment share in the 10
> 0 most densely populated counties") ytitle("Inflation (VA, 1947-2006)") xlabel(,grid)
