function [ vector ] = collapse2vector(subStructureVector)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

s=subStructureVector;

% Convert structure to array using struct2array.m

c = struct2array(s);

% collapse matrix to single vector
vector=c(:);


end

