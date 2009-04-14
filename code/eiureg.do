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
`before' lngdp1 gdp1Xprox `after'
outreg2 using `whereto', `format' append
`before' lngdp2 gdp2Xprox `after'
outreg2 using `whereto', `format' append

BREAK

/* add sector splits */
gen gdpXagri = (lngdp)*(sector=="agri")
gen gdpXmanuf = (lngdp)*(sector=="manuf")
gen gdpXserv = (lngdp)*(sector=="serv")

`before' gdpXagri gdpXmanuf gdpXserv `after'
outreg2 using `whereto', `format' append

`before' gdpXprox gdpXagri gdpXmanuf gdpXserv `after'
outreg2 using `whereto', `format' append

/*
`before' lngdp gdpXprox if !missing(lbrshr) `after'
`before' lngdp gdpXlbrshr if !missing(lbrshr) `after'
`before' lngdp gdpXprox gdpXlbrshr if !missing(lbrshr) `after'
`before' lngdp gdpXprox gdpXlbrshr gdpXagri gdpXmanuf gdpXserv if !missing(lbrshr) `after'

BREAK*/

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

/*proximity and labor share*/
graph twoway (scatter labor proximity) (lfitci labor proximity) if city=="NEW YORK" & labor!=.
graph twoway (scatter unskilled proximity) (lfitci unskilled proximity) if city=="NEW YORK" & unskilled!=.
regress labor proximity if city=="NEW YORK" & labor!=.
regress unskilled proximity if city=="NEW YORK" & unskilled!=.
