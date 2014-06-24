function [ RMSE ] = rootMeanSquare(diff)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
% diff is y- yhat
tSquared=(diff).^2;
meanSquared=mean(tSquared);

RMSE=sqrt(meanSquared);

end

