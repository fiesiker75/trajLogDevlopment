function [headerInfo,subBeam,snapShot,beamOn,beamCP] = parseTrajectoryLogData(fileName)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


%X=10.221.25.91\va_transfer - this needs to be edited locally
%pathName='X:\TDS\1076\TrajectoryLog\Treatment\';
%pathName = 'F:\';
%[fileName,pathName] = uigetfile(pathName, 'Pick TrajectoryLog File','*.bin');
% hard-coded for testing/development purposes

%fileName='28408200_4DC Treatment_1ARC1_TX_20140304122006.bin';

%fileName='30812352_4DC Treatment_1ARC1_TX_20140312142957.bin';

%fid=fopen(strcat(pathName,fileName));

fid=fopen(fileName);
%
% File specification from Varian - header is fixed 1024 bytes long
% Groups\Gainey\MATLAB\TrueBeam 1.5 Trajectory Log File Specification.pdf

% see tables on pages 7-13 for more details


signature=char(fread(fid,16));

%fprintf('\nEnd of signature found at position %d\n',ftell(fid) )

version=char(fread(fid,16));

%fprintf('\nEnd of version found at position %d\n',ftell(fid) )
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
   %fprintf('\nStart of subBeam %d, position= %d\n',i,ftell(fid))
   
   subBeam(i).cp=(fread(fid,1,'*int32'));
   
   %fprintf('subBeam %d cp=%d\n',i,subBeam(i).cp)

   subBeam(i).mu=(fread(fid,1,'*single'));
   
   subBeam(i).radTime =fread(fid,1,'*single');
    
   %temp3=fread(fid,4,'uint8');
   %subBeam(i).seq=typecast(uint8(temp3),'int32');
   
   subBeam(i).seq=(fread(fid,1,'*int32'));
   
   subBeam(i).name = char(fread(fid,32));
   %fprintf('\nEnd of .name position in subBeam %d, = %d\n',i,ftell(fid));
   
   %skip over Varian reserved data (32 bytes) at end of subBeam structure
   
   %varianReserve=char(fread(fid,32));
   % this line needs to edited for version 2.0 (bytes shift = 560bytes) not
   % 80 bytes
   fseek(fid,1024+(i*80),'bof'); % skip over reserved 32 bytes i.e. count 80 bytes from end of header (1024) of current subBeam 1024+i*80
   %fseek(fid,1024+(i*560),'bof'); uncommment this line for version 2.0
   %i.e. skip 560 bytes per subBeam from end of header (1024)
end

% snapShot structure consists of paired values: expected (E) and actual (A) as
% described in Varian specification
% axisEnumeration yields the following 
% [0;1;2;3;4;5;6;7;8;9;40;41;42;50] corresponding to

% 0 - Coll Rtn
% 1 - Gantry Rtn
% 2 - Y1
% 3 - Y2
% 4 - X1
% 5 - X2
% 6 - Couch Vrt
% 7 - Couch Lng
% 8 - Couch Lat
% 9 - Couch Rtn
% 40 - MU
% 41 - Beam Hold
% 42 - Control Point
% 50 - MLC

Leaves=samplesPerAxis(numberOfAxesSampled)-2;

snapShot(numberOfSnapShots)=struct('colRotationE',[],'colRotationA',[], ...
               'gantryRotationE',[],'gantryRotationA',[],...
                'Y1_E',[],'Y1_A',[],'Y2_E',[],'Y2_A',[],...
                'X1_E',[],'X1_A',[],'X2_E',[],'X2_A',[],...
                'couchVrtE', [], 'couchVrtA', [],...
                'couchLngE', [], 'couchLngA', [],...
                'couchLatE',[], 'couchLatA',[],...
                'couchRotationE', [], 'couchRotationA', [],...
                'MU_E', [], 'MU_A', [],...
                'beamHoldE', [], 'beamHoldA', [],...
                'controlPointE', [],'controlPointA', [], ...
                'CarrA_E', [], 'CarrA_A', [], ...
                'CarrB_E', [], 'CarrB_A', [], ...
                'MLC_E', {zeros(1,Leaves)}, 'MLC_A', {zeros(1,Leaves)});

%Now comes the hard bit, reading in all the snapshots for each axis
%(samplesPerAxis), Actual and Expected values

totalNumberOfSamples=sum(samplesPerAxis); % summation over all axes

% first read in all float arrays, and then split into respective snapShots
% initialise temp unstructured array to store data

% fieldNames={'colRotationE','colRotationA', ...
%                'gantryRotationE','gantryRotationA',...
%                 'Y1_E','Y1_A',...
%                 'Y2_E','Y2_A',...
%                 'X1_E','X1_A',...
%                 'X2_E','X2_A',...
%                 'couchVrtE', 'couchVrtA',...
%                 'couchLngE', 'couchLngA',...
%                 'couchLatE', 'couchLatA',...
%                 'couchRotationE', 'couchRotationA',...
%                 'MU_E', 'MU_A',...
%                 'beamHoldE', 'beamHoldA',...
%                 'controlPointE','controlPointA', ...
%                 'MLC_E', 'MLC_A' };
            
% here we just grab all axis data for current (i) snapshot into temporary
% cellNum array temp5. After we have all information we can assign data to a
% structured array (snapShot)

%temp6=zeros(1,2*totalNumberOfSamples);

% temp5={zeros(1,2*totalNumberOfSamples)};
 
beamOn=zeros(1,numberOfSnapShots);


%lastCPArc(numberOfSubBeams)=subBeam(numberOfSubBeams-1).cp+subBeam(numberOfSubBeams).cp;


% b(numberOfSubBeams)=struct('On',[],'Off',[]);
beamCP(numberOfSubBeams)=struct('On',[],'Off',[]);

j=2;
%endOfBeam(numberOfSubBeams)=0;

for i=1:numberOfSnapShots
    % actual_(1,j,a1),expected_(1,j,a1),actual_(1,j,a2),expected_(1,j,a2),....
    % see figure on page 11 of Specification

      temp5{i}= single(fread(fid,2*totalNumberOfSamples,'*single'));
      
      
      % need to convert angles (colli, gantry, couch) from intrinsic Varian scale (+1°) to IEC 61217 scale (+179°)
 
%       snapShot(i).colRotationE=single(temp5{i}(1));
      snapShot(i).colRotationE=Varian2IEC(single(temp5{i}(1)));
      
      snapShot(i).colRotationA=Varian2IEC(single(temp5{i}(2)));
    
      snapShot(i).gantryRotationE=Varian2IEC(single(temp5{i}(3)));
      
      snapShot(i).gantryRotationA=Varian2IEC(single(temp5{i}(4)));
      
      snapShot(i).Y1_E=single(temp5{i}(5));
      
      snapShot(i).Y1_A=single(temp5{i}(6));
      
      snapShot(i).Y2_E=single(temp5{i}(7));
      
      snapShot(i).Y2_A=single(temp5{i}(8));
      
      snapShot(i).X1_E=single(temp5{i}(9));
      
      snapShot(i).X1_A=single(temp5{i}(10));
      
      snapShot(i).X2_E=single(temp5{i}(11));
      
      snapShot(i).X2_A=single(temp5{i}(12));
      
      snapShot(i).couchVrtE=single(temp5{i}(13));
      
      snapShot(i).couchVrtA=single(temp5{i}(14));
      
      snapShot(i).couchLngE=single(temp5{i}(15));
      
      snapShot(i).couchLngA=single(temp5{i}(16));
      
      snapShot(i).couchLatE=single(temp5{i}(17));
      
      snapShot(i).couchLatA=single(temp5{i}(18));
      
      snapShot(i).couchRotationE=Varian2IEC(single(temp5{i}(19)));
      
      snapShot(i).couchRotationA=Varian2IEC(single(temp5{i}(20)));
      
      snapShot(i).MU_E=single(temp5{i}(21));
      
      snapShot(i).MU_A=single(temp5{i}(22));
      
      snapShot(i).beamHoldE=single(temp5{i}(23));
      
      snapShot(i).beamHoldA=single(temp5{i}(24));
      
      % test whether beam is on : look at beamHoldA if equals zero (dose servo enabled) beam is
      % switched on
      % beamHold ==1 0> dose servo disabled, beam on but dose rate is
      % constant
      % beamHoldA = 2 beam is switched off 
      if (snapShot(i).beamHoldA==0) beamOn(i)=1;
      end
      
      snapShot(i).controlPointE=single(temp5{i}(25));
      
      snapShot(i).controlPointA=single(temp5{i}(26));
      
      if (numberOfSubBeams > 1)
     % now let's locate the start
         if (snapShot(i).controlPointA==subBeam(j).cp)
             beamCP(j-1).Off=i;
          % now increment j
              if (j<numberOfSubBeams)
                j=j+1;
              end
         end
      end
      
      snapShot(i).CarrA_E = single(temp5{i}(27));
      
      snapShot(i).CarrA_A = single(temp5{i}(28));
      
      snapShot(i).CarrB_E = single(temp5{i}(29));
      
      snapShot(i).CarrB_A= single(temp5{i}(30));
      
      %last but not least comes the MLC
      
      snapShot(i).MLC_E=single(temp5{i}(31:2:end-1));
      snapShot(i).MLC_A=single(temp5{i}(32:2:end));
            
      
      
end

% beamOnShift=beamOn+1;
% 
ind=find(beamOn,1,'first');
beamCP(1).On=ind;
% t=beamOnShift(ind:end);
%

if (numberOfSubBeams > 1)
    for j=1:numberOfSubBeams-1
    %fprintf('\n j = %d, b(%d).Off = %d\n', j,j,b(j).Off);
    % put shift of at least 5 snapshots (0.100 seconds)
         t=beamOn((beamCP(j).Off+5):end);
%          size(t);
         indOn=find(t,1,'first')+beamCP(j).Off;
         beamCP(j+1).On=indOn;
    end
    
    indOff=0;
    t2=fliplr(t);
    indOff=find(t2,1,'first');

% 
    beamCP(numberOfSubBeams).Off=int32(numberOfSnapShots)-int32(indOff);
    
end
%     
%     t=beamOnShift(indOff:end);
%     
%     indOn=find(t,1,'first');
%     b(j).On=indOn;
%     
%     
%     
% end
%





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
  
% subBeams =struct ('subBeams',subBeam,'beamOn',b);


% axisData=snapShot;

% beamOn=beamOn;

%beamCP=b;

fclose(fid);


end

