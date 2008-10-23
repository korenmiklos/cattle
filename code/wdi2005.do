clear
set memory 25m
xmluse ../data/pwtwdi/wdi2005.xml

egen urban_medcat=cut(urban), group(2)
by urban_medcat, sort: regress lnP lnY if iso!="MMR" & iso!="SLV", robust
graph twoway (scatter lnP lnY) (lfit lnP lnY) if iso!="MMR" & iso!="SLV", by(urban_medcat,  legend(off) note("Data source: Penn World Table, World Development Indicators") ) xtitle("GDP (per capita, PPP, logarithm)") ytitle("Price levels (PPP, logarithm)") xlabel(,grid)

regress lnP lnY urban urbanX if iso!="MMR" & iso!="SLV", robust
regress lnP lnY lndensity densityX if iso!="MMR" & iso!="SLV", robust
/*regress lnP lnY pop_lcity pop_lcityX, robust
regress lnP lnY pop_mcity pop_mcityX, robust
regress lnP lnY lnpwdens pwdensX, robust
regress lnrelp lnY urban urbanX, robust
regress lnrelp lnY lndensity densityX, robust
regress lnrelp lnY lnpwdens pwdensX, robust*/
