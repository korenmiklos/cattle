clear
set memory 25m

xmluse ..\data\census\proximity_3.xml
regress inflation lndensity, robust
graph twoway (scatter inflation lndensity) (lfit inflation lndensity)

xmluse ..\data\census\proximity_2.xml, clear
graph twoway (scatter inflation lndensity) (lfit inflation lndensity)
graph twoway (scatter inflation lndensity) (lfit inflation lndensity) if inflation>-0.1 & lndensity>7
