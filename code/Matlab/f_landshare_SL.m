function [diff]=f_landshare_SL(lambda,A,N_over_L,theta,weights,sigma)
%       %Calculates the equilibrium landshare for the single location case

%Inputs:    lambda:     labor share
%           A:          technology parameter
%           N_over_L:   population density
%           theta:      elasticity of substitution in the production function
%           weights:    1 x n vector of weights in the production function
%           sigma:      elasticity of substitution in the utility function

%Calculating F_L(N/L,1-lambda)
switch theta
    case 1
        F_L     =   dF_CD(2,[N_over_L (1-lambda)], weights);
    otherwise
        F_L     =   dF_CES(2,theta,[N_over_L (1-lambda)], weights);
end;

%Calculating F(N/L,1-lambda)
switch theta
    case 1
        F     =   F_CD([N_over_L (1-lambda)], weights);
    otherwise
        F     =   F_CES(theta,[N_over_L (1-lambda)], weights);
end;

diff    =   A^sigma*lambda*F_L^sigma-A*F;