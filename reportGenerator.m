function latexFileName = reportGenerator(difference,PIZ,timeString,pathName,subBeams)
%This function takes the difference data and generates figures and
%statistics for MLC,gantry,collimator and MU snapshot data
%   Detailed explanation goes here

underscore='_';
%backslash='\';

%cd(pathName);

% lets start with the MLC
figure('visible', 'off');
		
clf();

[tempMLC]=collapse2vector(difference.MLC_Diff);
[numberOfSamples,rows]=size(tempMLC);

% generate strings to correctly label figures

[a]=getArcNames(subBeams);

%[numberOfArcs,unused]=size(subBeams);
[~,numberOfArcs]=size(subBeams);

temp=a(1).Name;
temp2='';

% maximum of 5 arcs in a plan: generate the name of arcs e.g.
% 1Arc1_100_1Arc2_100 ...


if (numberOfArcs > 1)
    if (numberOfArcs==2) temp2=strcat(temp,a(2).Name);
    end
    elseif (numberOfArcs==3) 
        temp2=strcat(temp,a(2).Name,a(3).Name);
    elseif (numberOfArcs==4) 
        temp2=strcat(temp,a(2).Name,a(3).Name,a(4).Name);
    elseif(numberOfArcs==5)
        temp2=strcat(temp,a(2).Name,a(3).Name,a(4).Name,a(5).Name);

else temp2=temp;
    
end


arcName_MU_String=temp2;

binRange=-0.2:0.01:0.2;
t=histc(tempMLC, binRange);

hist(tempMLC,binRange);
%hist(tempMLC);
title(strcat('Leaf position errors: ', PIZ,arcName_MU_String,underscore,timeString), 'Interpreter','none');
xlabel('\DeltaPosition (mm)');

plusMinus0_01mm=100*sum(t(20:22))/numberOfSamples;
plusMinus0_02mm=100*sum(t(19:23))/numberOfSamples;
plusMinus0_05mm=100*sum(t(16:26))/numberOfSamples;
plusMinus0_10mm=100*sum(t(11:31))/numberOfSamples;

meanMLC=mean(tempMLC);
stdDevMLC=std(tempMLC);

dpi=500;% 500dpi => filesize ~ 200kB default 96dpi somewhat grainy ~26kB
StatisticsFileName.resolution=dpi;


figureResolution=strcat('-r',num2str(dpi)); 

MLC_stats=struct('pm0_01mm',plusMinus0_01mm,'pm0_02mm',plusMinus0_02mm,'pm0_05mm',plusMinus0_05mm,'pm0_10mm',plusMinus0_10mm,'mean',meanMLC,'stdDev',stdDevMLC, 'samples', numberOfSamples);

StatisticsFileName.MLC=strcat(PIZ,arcName_MU_String,'MLC_Deviations','.png');
%StatisticsFileName.MLC=strcat(PIZ,arcName_MU_String,'MLC_Deviations');
% now print the figure directly to file (png)
print (strcat(pathName,StatisticsFileName.MLC), figureResolution,'-dpng');




% gantry statistics
% wrap gantry angles to -180 < gantry +180
wrapGantry=wrapTo180(difference.gantryDiff(:));

figure('visible', 'off');
clf();

hist(wrapGantry);
title(strcat('Gantry angle errors: ', PIZ,arcName_MU_String,underscore,timeString), 'Interpreter','none');
xlabel('\Delta\theta_{G} (degrees)');

StatisticsFileName.Gantry=strcat(PIZ,arcName_MU_String,'gantryAngle_Deviations','.png');
%StatisticsFileName.Gantry=strcat(PIZ,arcName_MU_String,'gantryAngle_Deviations');
print (strcat(pathName,StatisticsFileName.Gantry), figureResolution, '-dpng');

meanGantry=mean(wrapGantry);
stdDevGantry=std(wrapGantry);
gantry_stats=struct('mean',meanGantry,'stdDev',stdDevGantry);


% collimator statistics
wrapColli=wrapTo180(difference.colliDiff(:));

figure('visible', 'off');
clf();

hist(wrapColli);
title(strcat('Collimator angle errors: ', PIZ,arcName_MU_String,underscore,timeString), 'Interpreter','none');
xlabel('\Delta\theta_{C} (degrees)');
meanColli=mean(wrapColli);
stdDevColli=std(wrapColli);
colli_stats=struct('mean',meanColli,'stdDev',stdDevColli);


StatisticsFileName.collimator=strcat(PIZ,arcName_MU_String,'collimatorAngle_Deviations','.png');
%StatisticsFileName.collimator=strcat(PIZ,arcName_MU_String,'collimatorAngle_Deviations');
print (strcat(pathName,StatisticsFileName.collimator), figureResolution, '-dpng');




%MU statistics
figure('visible', 'off');
clf();


diffMU=difference.MU_Diff(:);
hist(diffMU);



title(strcat('MU differences: ', PIZ,arcName_MU_String,underscore,timeString), 'Interpreter','none');
xlabel('\DeltaMU (MU)');



meanMU=mean(diffMU);
stdDevMU=std(diffMU);

MU_stats=struct('mean',meanMU,'stdDev',stdDevMU);

StatisticsFileName.MU=strcat(PIZ,arcName_MU_String,'MU_Deviations','.png');
%StatisticsFileName.MU=strcat(PIZ,arcName_MU_String,'MU_Deviations');
print (strcat(pathName,StatisticsFileName.MU), figureResolution, '-dpng');

% blankline=' ';
% patientInfo={['PatientID: ',num2str(PIZ)];blankline;
%              ['Patient Name: ',patientName];blankline;
%              ['Comment : ', arcName_MU_String];blankline;
%             };
patientInfo.Name='X_Physics X_Test';
patientInfo.PIZ=PIZ;
patientInfo.Comment=arcName_MU_String;

%patientInfo=struc('PIZ',PIZ,'Name',patientName,'Comment',arcName_MU_String);

latexReport=ltxReport(MLC_stats,gantry_stats,colli_stats,MU_stats,StatisticsFileName,patientInfo);

latexFileName=strcat(pathName,PIZ,arcName_MU_String,'_report.tex');


%write .tex file for subsequent compilation
dlmcell(latexFileName,latexReport);

% save stats to excel file
excelFileName=strcat(pathName,'SummaryStats.xls');

MUstats='MU_Stats.txt';
MLCstats='MLC_Stats.txt';
GantryStats='Gantry_Stats.txt';
ColliStats='Colli_Stats.txt';

% write raw data to file for MLC, Gantry, Collimator and MU using dlmcell
% to increase speed 
% writing to excel spreadsheet is inefficient and problematic since must
% write each sheet separately. There is no easy way to rename sheets during
% writing => write to sheet number xlswrite(fileName,cellData,sheetNumber)
 columnHeader={'MLC Statistics'};
 rowHeader=fieldnames(MLC_stats);
 output=[{' '} columnHeader; rowHeader struct2cell(MLC_stats)];
%  [~,message]=xlswrite(excelFileName,output,1);

 dlmcell(strcat(pathName,MLCstats),output);



 columnHeader={'Gantry Statistics'};
 rowHeader=fieldnames(gantry_stats);
 output=[{' '} columnHeader; rowHeader struct2cell(gantry_stats)];
%  [~,message]=xlswrite(excelFileName,output,2);


 dlmcell(strcat(pathName,GantryStats),output);


 columnHeader={'Collimator Statistics'};
 rowHeader=fieldnames(colli_stats);
 output=[{' '} columnHeader; rowHeader struct2cell(colli_stats)];
%  [~,message]=xlswrite(excelFileName,output,3);

 dlmcell(strcat(pathName,ColliStats),output);

 columnHeader={'MU Statistics'};
 rowHeader=fieldnames(MU_stats);
 output=[{' '} columnHeader; rowHeader struct2cell(MU_stats)];
%  [~,message]=xlswrite(excelFileName,output,4);

dlmcell(strcat(pathName,MUstats),output);





