clear

xmluse ../data/census/rooms

reg  lnRoomPerCapita lnY , robust
reg  lnRoomPerCapita lnY lnPopDens , robust
reg  lnRoomPerCapita lnY lnPopDens lnL, robust
