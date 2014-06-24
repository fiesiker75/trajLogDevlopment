function [fieldE,fieldA] = trajGap(snapShotCurrent,fieldWidth,fieldHeight)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
[leaves,~]=size(snapShotCurrent.MLC_E);

fieldA=zeros(fieldWidth,fieldHeight);
fieldE=zeros(fieldWidth,fieldHeight);

leafPairs=0.5*leaves;

% according to Varian specification leaves 1-60 are right "A" leaf bank bottom (1) to
% top(60)
% leaves 61-120 are left "B" leaf bank bottom(61) to top(120)

offsetX=0.5*fieldWidth;

leafBoundary=leafBoundariesHD-110;

% first identify upper and lower Y Jaw positions: all open leafs must lie
% between Y1 and Y2

% Y2=10*snapShotCurrent.Y2_E;
% Y1=10*snapShotCurrent.Y1_E;
% 
% if (Y2<=-45)||(Y2>=35) upperLeaf=Y2

for i=1:leafPairs

    
    
    %first calculate only inside of Y-Jaw
    % factor 10 to convert from cm to mm
    if ((leafBoundary(i)>=10*snapShotCurrent.Y1_E) && (leafBoundary(i)<=10*snapShotCurrent.Y2_E))
        
        % now set values between left and right leaf to 1
        for j=10*snapShotCurrent.MLC_E(i):10*snapShotCurrent.MLC_E(i+leafPairs)
            fieldE(i,j+offsetX)=1;    
        end
        
        % now do the same for the actual positions
        for j=10*snapShotCurrent.MLC_A(i):10*snapShotCurrent.MLC_A(i+leafPairs)
            fieldA(i,j+offsetX)=1;
        end
        
        % copy to the remaining rows of current leaf i
        for k=leafBoundary(i):leafBoundary(i)+(2*varianLeafWidth(i))
            
            fieldA(i+k,:)=fieldA(i,:);
            fieldE(i+k,:)=fieldE(i,:);
        end
        
        
    end
        


end


end

