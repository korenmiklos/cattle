clear
set mem 10m

tempfile wage_prox

xmluse ../data/census/proximity.xml
save `wage_prox'

xmluse ../data/bls/wages.xml, clear
sort sector
merge sector using `wage_prox'
tabulate _merge

gen lnwages=ln(wages)
gen lndensity=ln(density)

regress lnwages urban, robust
regress lnwages lndensity, robust
scatter lnwages urban, mlabel(sector)
