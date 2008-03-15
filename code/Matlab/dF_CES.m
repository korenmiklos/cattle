function [dF]=dF_CES(j,theta, factors, weights)
%       Calculating the first derivative of a weighted CES aggregation of factors with parameter theta

%Inputs:    theta: 1 x 1 parameter of elasticity of substitution
%           factors: 1 x n vector of factors
%           weights: 1 x n vector of weights in the function

NN   =  length(factors);

if nargin==3
    weights=(1/NN)*ones(1,NN);
end;

F   =   (sum(weights.^(1/theta).*factors.^((theta-1)/theta))^(theta/(theta-1)));

dF  =   (weights(j)*F/factors(j))^(1/theta);