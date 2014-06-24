function [fieldE,fieldA] = trajFluence(snapShotCurrent,fieldWidth,fieldHeight,X,Y)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
[leaves,~]=size(snapShotCurrent.MLC_E);

leafPairs=0.5*leaves;

fieldA=zeros(fieldHeight,fieldWidth,leafPairs);
fieldE=zeros(fieldHeight,fieldWidth,leafPairs);
% fieldA=zeros(60,fieldWidth);
% fieldE=zeros(60,fieldWidth);

% according to Varian specification leaves 1-60 are right "A" leaf bank bottom (1) to
% top(60)
% leaves 61-120 are left "B" leaf bank bottom(61) to top(120)



% absolute leaf boundary

leafBoundary = [-110:5:-45, -40:2.5:40, 45:5:110];
% fprintf('Inside trajFluence, found %d leaf pairs\n', leafPairs);

for i=1:leafPairs

%     fprintf('leafNumber=%d \n',i);
    
    %first calculate only inside of Y-Jaw
    % factor 10 to convert from cm to mm
    % and convert relative position (reltive to x=0 line) into absolute
    % position within collimator boundary
    
    fieldE(:,:,i) = (X>=-10*snapShotCurrent.MLC_E(i+leafPairs)) & (X<10*snapShotCurrent.MLC_E(i)) & ...
        X >=-10*snapShotCurrent.X1_E & X<10*snapShotCurrent.X2_E & ...
        Y >=leafBoundary(i) & Y<leafBoundary(i+1) & Y >=-10*snapShotCurrent.Y1_E & Y<10*snapShotCurrent.Y2_E;
    fieldA(:,:,i) = (X>=-10*snapShotCurrent.MLC_A(i+leafPairs)) & (X<10*snapShotCurrent.MLC_A(i)) & ...
        X >=-10*snapShotCurrent.X1_A & X<10*snapShotCurrent.X2_A & ...
        Y >=leafBoundary(i) & Y<leafBoundary(i+1) & Y >=-10*snapShotCurrent.Y1_E & Y<10*snapShotCurrent.Y2_E;
    
end

fieldE = any(fieldE,3);
fieldA = any(fieldA,3);
end


