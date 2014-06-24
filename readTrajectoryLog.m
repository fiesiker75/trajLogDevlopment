function [headerInfo,subBeams,axisData] = getTrajectoryLogData()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


%X=10.221.25.91\va_transfer - this needs to be edited locally
pathName='X:\TDS\1076\TrajectoryLog\Treatment\';

%[fileName,pathName] = uigetfile(pathName, 'Pick TrajectoryLog File','*.bin');
% hard-coded for development purposes

fileName='28408200_4DC Treatment_1ARC1_TX_20140304122006.bin';

fid=fopen(strcat(pathName,fileName));
%
% File specification from Varian - header is fixed 1024 bytes long
% Groups\Gainey\MATLAB\TrueBeam 2.0 Trajectory Log File Specification.pdf

% see tables on pages 7-13 for more details


signature=char(fread(fid,16));

fprintf('\nEnd of signature found at position %d\n',ftell(fid) )

version=char(fread(fid,16));

fprintf('\nEnd of version found at position %d\n',ftell(fid) )
%headerSize=uint32(fread(fid,4,'integer*4')); % integer fixed 1024 bytes

 headerSize=uint32(fread(fid,1,'int32')); % integer fixed 1024 bytes
 samplingInterval=uint32(fread(fid,1,'int32')); % integer milliseconds
 numberOfAxesSampled=uint32(fread(fid,1,'int32')); % integer
 

% Axis enumeration - table page 8

axisEnumeration=uint32(fread(fid,numberOfAxesSampled,'int32'));

%samplesPerAxis

samplesPerAxis=uint32(fread(fid,numberOfAxesSampled,'int32'));
axisScale=uint32(fread(fid,1,'int32'));

%numberOfSubbeams
numberOfSubBeams=uint32(fread(fid,1,'int32'));

% isTruncated
isTruncated=uint32(fread(fid,1,'int32'));

%numberOfSnapshots
numberOfSnapShots=uint32(fread(fid,1,'int32'));

%MLC model
mlcModel=uint32(fread(fid,1,'int32'));
if (mlcModel==2) MLC='NDS 120';
else if (mlcModel==3) MLC='NDS 120 HD';
    end
end


%reserved - Varian specific data stored here, lets skip over it to start of
%subbeam data (position 1024)


% now skip over first 1024 bytes of header: second argument is offset value
    
fseek(fid,headerSize,'bof'); % move pointer 1024 from beginning of file 'bof' http://www.mathworks.de/de/help/matlab/ref/fseek.html

subBeam(numberOfSubBeams)=struct('cp',[],'mu',[],'radTime',[],'seq',[],'name',[]); 
% now read in all subBeams- each subBeam is currently fixed to 560 bytes
% (Varian specification)

for i=1:numberOfSubBeams
   fprintf('\nStart of subBeam %d, position= %d\n',i,ftell(fid))
   
   subBeam(i).cp=(fread(fid,1,'*int32'));
   
   fprintf('subBeam %d cp=%d\n',i,subBeam(i).cp)

   subBeam(i).mu=(fread(fid,1,'*single'));
   
   subBeam(i).radTime =fread(fid,1,'*single');
    
   %temp3=fread(fid,4,'uint8');
   %subBeam(i).seq=typecast(uint8(temp3),'int32');
   
   subBeam(i).seq=(fread(fid,1,'*int32'));
   
   subBeam(i).name = char(fread(fid,512));
   fprintf('\nEnd of .name position in subBeam %d, = %d',i,ftell(fid));
   
   %skip over Varian reserved data (32 bytes) at end of subBeam structure
   
   varianReserve=char(fread(fid,32));
   
end

% snapShot structure consist of paired values: actual (A) and expected (E) as
% described in Varian specification

snapShot(numberOfSnapShots)=struct('colRotationA',[],'colRotationE',[], ...
               'gantryRotationA',[],'gantryRotationE',[],...
                'Y1_A',[],'Y1_E',[],'Y2_A',[],'Y2_E',[],...
                'X1_A',[],'X1_E',[],'X2_A',[],'X2_E',[],...
                'couchVrtA', [], 'couchVrtE', [],...
                'couchLngA', [], 'couchLngE', [],...
                'couchLatA',[], 'couchLatE',[],...
                'couchRotationA', [], 'couchRotationE', [],...
                'MU_A', [], 'MU_E', [],...
                'beamHoldA', [], 'beamHoldA', [],...
                'controlPointA', [],'controlPointE', [], ...
                'MLC_A', [], 'MLC_E', []);

%Now comes the hard bit, reading in all the snapshots for each axis
%(samplesPerAxis), Actual and Expected values

totalNumberOfSamples=sum(samplesPerAxis); % summation over all axes

% first read in all float arrays, and then split into respective snapShots
% initialise temp unstructured array to store data


% here we just grab all axis data for current (i) snapshot into temporary
% cell array temp5. After we have all information we can assign data to a
% structured array (snapShot)
for i=1:numberOfSnapShots
    % actual_(1,j,a1),expected_(1,j,a1),actual_(1,j,a2),expected_(1,j,a2),....
    % see figure on page 11 of Specification
    temp5{i}= single(fread(fid,2*totalNumberOfSamples,'*single'));
        
    
end

%rawData=fread(fid);

headerInfo = struct('signature', signature, ...
            'version', version, ...
            'headerSize', headerSize, ...
            'samplingInterval', samplingInterval, ...
            'numberOfAxesSampled',numberOfAxesSampled,...
            'axisEnumeration',axisEnumeration, ...
            'samplesPerAxis',samplesPerAxis,...
            'axisScale', axisScale, ...
            'numberOfSubBeams', numberOfSubBeams, ...
            'isTruncated',isTruncated, ...
            'numberOfSnapShots', numberOfSnapShots, ...
            'MLC', MLC,'totalSamples', totalNumberOfSamples );
  
subBeams =struct ('subBeams',subBeam);

axisData=temp5;

fclose(fid);


end

