function [ ret ] = getCellColumn(cellName,columnNumber)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

t=cellName(:,columnNumber);

ret=vertcat(t(:));

end

