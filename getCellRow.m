function [ ret ] = getCellRow(cellName,rowNumber)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

t=cellName(rowNumber,:);

ret=[t{:}];

end

