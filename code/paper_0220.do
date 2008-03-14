clear
set memory 25m

xmluse ..\data\pwtwdi\pwtwdi.xml
by urban_medcat, sort: regress lnP_pwt lnY_pwt if year==2000, robust
graph twoway (scatter lnP_pwt lnY_pwt) (lfit lnP_pwt lnY_pwt) if year==2000, by(urban_medcat,  legend(off) note("Data source: Penn World Table, World Developmen Indicators") ) xtitle("GDP (per capita, PPP, logarithm)") ytitle("Price levels (PPP, logarithm)") xlabel(,grid)

regress lnP_pwt lnY_pwt urban urbanX if year==2000, robust
regress lnP_pwt lnY_pwt lndens densX if year==2000, robust
regress lnP_pwt lnY_pwt lnpwdens pwdensX if year==2000, robust
regress lnP_pwt lnY_pwt urban urbanX if year==1996 & benchm_96, robust
regress lnP_pwt lnY_pwt lnpwdens pwdensX if year==1996 & benchm_96, robust
regress relp_C lnY_pwt urban urbanX if year==1996, robust
regress relp_C lnY_pwt lndens densX if year==1996, robust
regress relp_C lnY_pwt lnpwdens pwdensX if year==1996, robust

regress rel_empl_stan urban if year==2000
regress rel_empl_stan dens if year==2000

xmluse ..\data\census\states_census.xml
regress lnrel_empl urban, robust
regress lnrel_empl lndensity, robust
twoway (scatter rel_empl urban, mlabel(state_abbr) mlabposition(0) m(i)) (line rel_empl_hat urban), ytitle("Relative non-traded/traded employment") yscale(log) legend(off) note("Data source: US census") xlabel(,grid)

xmluse ..\data\census\county_census
regress lnrel_empl urban lnincome, robust
regress lnrel_empl lndensity lnincome, robust
graph twoway (scatter lnrel_empl urban) (lfit lnrel_empl urban),  legend(off) note("Data source: US Census") xtitle("Urban population (%)") ytitle("Relative NT/T employment (logarithm)") xlabel(,grid)

xmluse ..\data\davis\davis
regress lnhomevalue lnpci_nom lndensity if year==2000, robust
regress lnstructurecost lnpci_nom lndensity if year==2000, robust
regress lnlandvalue lnpci_nom lndensity if year==2000, robust
graph twoway (scatter lnlandvalue lnpci_nom, mlabel(city_dp) mlabvposition(clockpos)) (lfit lnlandvalue lnpci_nom) if year==2000, legend(off) note("Data source: Davis-Palumbo (2007), BEA") xtitle("Per capita income (logarithm)") ytitle("Land value (logarithm)") xlabel(,grid)
