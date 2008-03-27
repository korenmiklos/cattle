function [dF]=dF_CD(j,factors,weights)
%       Calculating the first derivative of Cobb-Douglas aggregation of factors

%Inputs:    j: the derivative is wrt this factor 
%           factors: 1 x n vector of factors
%           weights: 1 x n vector of weights in the function

NN   =  length(factors);

if nargin==2
    weights=(1/NN)*ones(1,NN);
end;

F   =   prod(factors.^weights);

dF  =   weights(j)*(F/factors(j));