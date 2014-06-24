function gMapStats = gammaMapStats(gammaMap)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% [minR,minC]=find(min(min(gammaMap)));
% [maxR,maxC]=find(max(max(gammaMap)));

minVal=(min(min(gammaMap)));
maxVal=(max(max(gammaMap)));

meanVal=mean(gammaMap);
stdDev=std(gammaMap);

[minR,minC]=find(gammaMap==minVal);
[maxR,maxC]=find(gammaMap==maxVal);

% determine the number of non zero elements
evaluated=nnz(gammaMap);

gMapStats=struct('minR',minR,'minC',minC,'minVal',minVal,'maxR',maxR,'maxC',maxC,'maxVal',maxVal,'mean',meanVal,'stdDev',stdDev,'evaluated',evaluated);

end

