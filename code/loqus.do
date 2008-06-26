xmluse ../data/census/county_census, clear

egen traded = rsum( agriculture mining manufacture)

/* calculate national shares */
egen USAtraded = sum(traded)
egen USAtotal = sum(total_empl)
gen USAshare = USAtraded/USAtotal

/* calculate locational quotients for traded */
gen LQ_traded = traded/total_empl/USAshare
label var LQ_traded "Locational quotient (traded sectors)"
label var lnincome "Median income (log)"
label var lndens "Population density (log)"

tw (scatter LQ lndens) (lfitci LQ lndens), scheme(s2color)

outsheet geo LQ using LQ.csv, comma replace
