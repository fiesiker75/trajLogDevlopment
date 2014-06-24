function [actualFluence,plannedFluence,CPindex,x,y] = generateFluenceMaps(snapShotData, scaleFactor, subBeams)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
% scaleFactor is number of pixels per mm

% this is for TrueBeam: 400 x 220 mm

collimatorY=220;
collimatorX=400;

fieldWidth=2*collimatorX*scaleFactor;

% factor 2 required for TrueBeam HD120 since leaves 15-46 are 2.5mm high;
% 1-14 and 47-60 are 5mm high
% otherwise cannot represent fluence map properly

fieldHeight=2*collimatorY*scaleFactor;

x = -200:0.5:200-0.5;
y = 109.5:-0.5:-110;

[X,Y] = meshgrid(x,y);

actualFluence=zeros(fieldHeight,fieldWidth);
plannedFluence=zeros(fieldHeight,fieldWidth);

centrePosX=fieldWidth/2;
centrePosY=fieldHeight/2;


[~,numberOfSnapShots]=size(snapShotData);

epsilon=0.04;
%currentCP=0;
%Physical control point
newCP=1;

% need to keep track of i indices as well as current CP
previousCP=1;
CP=0;
CPindexlist={};

%in principle need to calculate fluence map for both actual and expected
%values
% => identify all CPs: calculate field opening for current CP and multiply by differential CP
% i.e. Fluence= \Sigma_{i=1}^{CP} MU_{i} \Sigma_{j,A/E} o_{i,j,A/E} \cdot

% h_{j}

% first we need to identify the local minima in snapshotData (i.e. control
% points
% abs(CP-round(CP))

numberOfControlPoints=round(snapShotData(numberOfSnapShots).controlPointE);

CPList = imregionalmin(abs(cat(1,snapShotData.controlPointE)-round(cat(1,snapShotData.controlPointE))));
CPindex = find(CPList & cat(1,snapShotData.controlPointE)>0);
[~,LastCP] = min(diff(cat(1,snapShotData(CPindex).controlPointE)));                 %first Arc only

%get MUs per CP
MU_E = cat(1,snapShotData([1; CPindex(1:LastCP)]).MU_E);
MU_CP_E = diff(MU_E);
MU_A = cat(1,snapShotData([1; CPindex(1:LastCP)]).MU_A);
MU_CP_A = diff(MU_A);


for i=1:20%LastCP
    fprintf('Control point %d \n',i);
    % due to rounding error use epsilon
%     if abs(snapShotData(i).controlPointE-newCP) <= epsilon
%         CP=i;
%         CPindexlist{newCP}=i;
    
    %first calculate field opening from leaves_ leaf gap per leaf pair
    [fieldE,fieldA]=trajFluence(snapShotData(CPindex(i)),fieldWidth,fieldHeight,X,Y);

    %then mulitply by MU per snapshot
    plannedFluence=plannedFluence+(fieldE*MU_CP_E(i));
    actualFluence=actualFluence+(fieldA*MU_CP_A(i));

%     % increment CP indices to find next CP
%     newCP=1+newCP;
%     %currentCP=1+currentCP
% 
%     % update i index: current =new
%     previousCP=CP;
%     end
    %
%     fprintf('\n');
end

% MLC_E = reshape(cat(1,snapShotData(CPindex(1:LastCP)).MLC_E),120,[]);
% JawX1_E = min(min(-10*MLC_E(61:120,:)));
% JawX2_E = max(max(10*MLC_E(1:60,:)));

JawX1_E = min(-10*cat(1,snapShotData(CPindex(1:LastCP)).X1_E));
JawX2_E = max(10*cat(1,snapShotData(CPindex(1:LastCP)).X2_E));
JawY1_E = min(-10*cat(1,snapShotData(CPindex(1:LastCP)).Y1_E));
JawY2_E = max(10*cat(1,snapShotData(CPindex(1:LastCP)).Y2_E));

% imagesc(x,y,(plannedFluence-actualFluence)/max(plannedFluence(:))*100);
% imagesc(x,y,(plannedFluence-actualFluence)./(plannedFluence)*100);
% imagesc(x,y,(actualFluence./plannedFluence)*100);
% set(gca,'YDir','normal','Xlim',[min(x) max(x)],'Ylim',[min(y) max(y)]);
[~,fh]= contourf(X,Y,(plannedFluence-actualFluence)./(plannedFluence)*100);
set(fh,'LineStyle','none','LevelStep',2);
set(gca,'CLim',[-1 1]*30);
axis equal;
set(gca,'Xlim',[-100 100],'Ylim',[-100 100]);%,'XTick',-200:50:200,'YTick',-100:50:100);
line([JawX1_E JawX1_E],[y(1) y(end)],'linewidth',1,'color','k','Linestyle','--')
line([JawX2_E JawX2_E],[y(1) y(end)],'linewidth',1,'color','k','Linestyle','--')
line([x(1) x(end)],[JawY1_E JawY1_E],'linewidth',1,'color','k','Linestyle','--')
line([x(1) x(end)],[JawY2_E JawY2_E],'linewidth',1,'color','k','Linestyle','--')

xlabel('mm');
ylabel('mm');

cb = colorbar;

end

