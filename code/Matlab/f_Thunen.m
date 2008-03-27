function [diff]=f_Thunen(Z,gamma,tau_s,H,A)

z1  =   (pi/2+atan(Z(1)))/pi;
z2  =   (pi/2+atan(Z(2)))/pi;

diff        =   zeros(2,1);
diff(1)     =   gamma/(1-gamma)*(1-z2)/(1-tau_s*z2)-(1-z2^2)/(z2^2-z1^2);
diff(2)     =   A*(1-z2^2)^gamma*(z2^2-z1^2)^(1-gamma)-z1^2/H;