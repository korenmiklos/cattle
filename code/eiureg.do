clear
set memory 500m

local before "areg lnprice"
local after ", a(product) cluster(iso)"
local whereto "../text/eiureg.xls"
local format "bracket bdec(3)"

use ../data/cityprices_prepared

`before' lngdp `after'
outreg2 using `whereto', `format' replace

/*`before' lngdp lncitypop `after'
`before' lngdp lncitypop gdpXlncitypop `after'
`before' lngdp lncitypop gdpXlncitypop gdpXprox `after'

`before' lngdp urban `after'
`before' lngdp urban gdpXurban `after'
`before' lngdp urban gdpXurban gdpXprox `after'

`before' lngdp lndensity `after'
`before' lngdp lndensity gdpXlndensity `after'
`before' lngdp lndensity gdpXlndensity gdpXprox `after'*/

`before' lngdp lncitypop `after'
`before' lngdp gdpXprox `after'
outreg2 using `whereto', `format' append

/* add sector splits */
gen gdpXagri = (lngdp)*(sector=="agri")
gen gdpXmanuf = (lngdp)*(sector=="manuf")
gen gdpXserv = (lngdp)*(sector=="serv")

`before' gdpXagri gdpXmanuf gdpXserv `after'
outreg2 using `whereto', `format' append

`before' gdpXprox gdpXagri gdpXmanuf gdpXserv `after'
outreg2 using `whereto', `format' append

`before' lngdp gdpXprox if !missing(labor,gdpXunskilled) `after'
outreg2 using `whereto', `format' append
`before' lngdp gdpXlabor `after'
outreg2 using `whereto', `format' append
`before' lngdp gdpXunskilled `after'
outreg2 using `whereto', `format' append
`before' lngdp gdpXprox gdpXlabor `after'
outreg2 using `whereto', `format' append
`before' lngdp gdpXprox gdpXunskilled `after'
outreg2 using `whereto', `format' append
