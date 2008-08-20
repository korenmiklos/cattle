clear
set memory 500m

local before "areg lnprice"
local after ", a(product) cluster(iso)"
local whereto "../text/eiureg.xls"
local format "bracket bdec(3)"

use ../data/cityprices_prepared

`before' lngdp `after'
outreg2 using `whereto', `format' replace

`before' lngdp lncitypop `after'
`before' lngdp gdpXprox `after'
outreg2 using `whereto', `format' append

`before' lngdp gdpXprox lncity cityXprox `after'

/* add sector splits */
gen gdpXagri = (lngdp)*(sector=="agri")
gen gdpXmanuf = (lngdp)*(sector=="manuf")
gen gdpXserv = (lngdp)*(sector=="serv")

`before' gdpXagri gdpXmanuf gdpXserv `after'
outreg2 using `whereto', `format' append

`before' gdpXprox gdpXagri gdpXmanuf gdpXserv `after'
outreg2 using `whereto', `format' append

