function [diff]=f_z(z,A,H,gamma,taus)
%       %Calculates the equilibrium landshare for the single location case

%Inputs:    lambda:     labor share
%           A:          technology parameter
%           H:          house size
%           gamma:      share of manufacturing within production
%           taus>1:     trade cost


%diff    =   ((1-gamma)/gamma)^(1-gamma) * A*H* (1-z)^gamma*(1+z)*(1-taus*z)^(1-gamma) - z^2 + (1-gamma)/gamma*(1+z)*(1-taus*z);
diff1 = z(2)^2-z(1)^2 - (1-gamma)/gamma * (1+z(2))*(1-taus*z(2));
diff2 = A*H * (1-z(2)^2)^gamma * (z(2)^2-z(1)^2)^(1-gamma) - z(1)^2;

[diff] = [diff1; diff2];
