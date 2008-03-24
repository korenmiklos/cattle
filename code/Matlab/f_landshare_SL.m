function [diff]=f_landshare_SL(lambda,A,N,L,theta,weights,sigma)
%       %Calculates the equilibrium landshare for the single location case

%Inputs:    lambda:     labor share
%           A:          technology parameter
%           N:          labor
%           L:          land
%           theta:      elasticity of substitution in the production function
%           weights:    1 x n vector of weights in the production function
%           sigma:      elasticity of substitution in the utility function

%Calculating F_L(N/L,1-lambda)
switch theta
    case 1
        F_L     =   dF_CD(2,[N/L (1-lambda)], weights);
        F       =   F_CD([N L*(1-lambda)], weights);
    otherwise
        F_L     =   dF_CES(2,theta,[N/L (1-lambda)], weights);
        F       =   F_CES(theta,[N L*(1-lambda)], weights);
end;

diff    =   A^sigma*lambda*F_L^sigma-A*F/L;