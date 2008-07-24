set memory 25m
xmluse ../data/pwtwdi/wdi2005.xml

regress lnP lnY urban urbanX, robust
regress lnP lnY lndensity densityX, robust
regress lnP lnY pop_lcity pop_lcityX, robust
regress lnP lnY pop_mcity pop_mcityX, robust
regress lnP lnY lnpwdens pwdensX, robust
regress lnrelp lnY urban urbanX, robust
regress lnrelp lnY lndensity densityX, robust
regress lnrelp lnY lnpwdens pwdensX, robust
