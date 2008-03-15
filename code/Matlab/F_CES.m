function [F]=F_CES(theta, factors, weights)
%       Calculating the weighted CES aggregation of factors with parameter theta

%Inputs:    theta: 1 x 1 parameter of elasticity of substitution
%           factors: 1 x n vector of factors
%           weights: 1 x n vector of weights in the function

NN   =  length(factors);

if nargin==2
    weights=(1/NN)*ones(1,NN);
end;

F   =   (sum(weights.^(1/theta).*factors.^((theta-1)/theta)).^(theta/(theta-1)));