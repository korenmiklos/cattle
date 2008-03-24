function [diff]=f_landshare_TL(X,A,N1,N2,L,theta,weights,sigma)
%       %Calculates the equilibrium landshare for the single location case

%Inputs:    X           1 x 2 vector of labor share and city manufacturing
%                       consumption
%           A:          technology parameter
%           N1,N2:      labor in the village and city
%           L:          land
%           theta:      elasticity of substitution in the production function
%           weights:    1 x n vector of weights in the production function
%           sigma:      elasticity of substitution in the utility function

lambda      =   X(1);
x2          =   X(2);
alpha       =   N2/(N1+N2);

%Calculating F_L(N/L,1-lambda)
switch theta
    case 1
        F1_L    =   dF_CD(2,[N1/L (1-lambda)], weights);
        F1      =   F_CD([N1 L*(1-lambda)], weights);
    otherwise
        F1_L    =   dF_CES(2,theta,[N1/L (1-lambda)], weights);
        F1      =   F_CES(theta,[N1 L*(1-lambda)], weights);
end;

diff    =   zeros(2,1);
diff(1) =   x2/L-A*F1/L+lambda*(A*F1_L)^sigma;
diff(2) =   x2/L-alpha*(A*F1_L)^sigma+(1-alpha)*(x2/L)^(1/sigma);