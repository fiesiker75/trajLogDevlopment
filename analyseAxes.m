function [ret] = analyseAxes(snapShots)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% snapShot(numberOfSnapShots)=struct('colRotationE',[],'colRotationA',[], ...
%                'gantryRotationE',[],'gantryRotationA',[],...
%                 'Y1_E',[],'Y1_A',[],'Y2_E',[],'Y2_A',[],...
%                 'X1_E',[],'X1_A',[],'X2_E',[],'X2_A',[],...
%                 'couchVrtE', [], 'couchVrtA', [],...
%                 'couchLngE', [], 'couchLngA', [],...
%                 'couchLatE',[], 'couchLatA',[],...
%                 'couchRotationE', [], 'couchRotationA', [],...
%                 'MU_E', [], 'MU_A', [],...
%                 'beamHoldE', [], 'beamHoldA', [],...
%                 'controlPointE', [],'controlPointA', [], ...
%                 'CarrA_E', [], 'CarrA_A', [], ...
%                 'CarrB_E', [], 'CarrB_A', [], ...
%                 'MLC_E', {zeros(1,Leaves)}, 'MLC_A', {zeros(1,Leaves)});

[~,numberOfSnapShots]=size(snapShots);

[Leaves,~]=size(snapShots(1).MLC_E);

%[unused,numberOfBeams]=size(beamOn);



colliDiff=double(zeros(1,numberOfSnapShots));
gantryDiff=double(zeros(1,numberOfSnapShots));
MU_Diff=double(zeros(1,numberOfSnapShots));
y1Diff=double(zeros(1,numberOfSnapShots));
y2Diff=double(zeros(1,numberOfSnapShots));
x1Diff=double(zeros(1,numberOfSnapShots));
x2Diff=double(zeros(1,numberOfSnapShots));
MLC_Diff(numberOfSnapShots)=struct('LeafDifference',{double(zeros(Leaves,1))}); 


% for h=1:numberOfBeams
%     startBeam=int32(beamOn(h).On);
%     stopBeam=int32(beamOn(h).Off);
% 
%     for i=startBeam:stopBeam
for i=1:numberOfSnapShots
    % only calculate if the beam is On
%     if (int32(beamOn(i))==1)

        colliDiff(i)=(snapShots(i).colRotationE-snapShots(i).colRotationA);
    
        gantryDiff(i)=(snapShots(i).gantryRotationE-snapShots(i).gantryRotationA);
        
        MU_Diff(i)=(snapShots(i).MU_E-snapShots(i).MU_A);
    
        y1Diff(i)=(snapShots(i).Y1_E-snapShots(i).Y1_A);
    
        y2Diff(i)=(snapShots(i).Y2_E-snapShots(i).Y2_A);
    
        x1Diff(i)=(snapShots(i).X1_E-snapShots(i).X1_A);
    
        x2Diff(i)=(snapShots(i).X2_E-snapShots(i).X2_A);
        
        %express values in millimetres
%         for j=1:Leaves
%         MLC_Diff(i).LeafDifference{j}=10*(snapShots(i).MLC_E(j)-snapShots(i).MLC_A(j));
            MLC_Diff(i).LeafDifference=10*(snapShots(i).MLC_E-snapShots(i).MLC_A);
%         end
    
%     end
    
    
    
 end
%end

ret=struct( 'colliDiff',colliDiff, ...
            'gantryDiff',gantryDiff, ...
            'MU_Diff', MU_Diff, ...
            'y1Diff', y1Diff, ...
            'y2Diff', y2Diff, ...
            'x1Diff', x1Diff, ...
            'x2Diff', x2Diff, ...
            'MLC_Diff', MLC_Diff);

end

