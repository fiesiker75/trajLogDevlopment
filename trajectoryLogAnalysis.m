% Script to analyse trajectory files
trajConstants


k=IPTest();

if k==0
    error('IP check: You are currently not authorised to use this code: license file has not been found! Sending event log for analysis!(c) 2014  Dr. Mark Gainey +49 761 27095220 <mark.gainey@uniklinik-freiburg.de>')
end



% this needs to be edited va_transfer 10.221.25.91 
trajectoryLogDirectory='X:\TDS\1076\TrajectoryLog\Treatment\';

localDirectory='Q:\STK-T-Physik\TrajectoryLogAnalysis\';

%cd(trajectoryLogDirectory);
    
cd(localDirectory);    
    
	%Define global constants
	%dynConstants
			
	%Output CSV filename saved locally
	outfile = 'AnalysisLog.csv';
    
    latexLogfile='LatexLogfile.txt';
    fid2 = fopen(latexLogfile,'w');

    fileSearchString=strcat(trajectoryLogDirectory,'*ARC*.bin');
    
	%Get list of trajectory log files in current directory
	listing = dir(fileSearchString);
	
	%Sort files by date
	[unused, order] = sort([listing(:).datenum] , 'descend');
	sortedListing = listing(order); 
	numFiles = 	size(sortedListing,1);
	
	%Open output file and print headers
	fid = fopen(outfile,'w');
	fprintf(fid, '\r\nTrajectoryLog Analysis\r\n');
    
    underscore='_';
    slash='\';
    
    analysisDirectory='Analysis';
    archiveDirectory=strcat(localDirectory,'Archiv',slash);
    
    
    numFiles=2;
    
    for i = 1:numFiles
      
        % extract PID (PIZ) 
        tokenisedFileName = textscan(sortedListing(i).name,'%s',5,'delimiter',{'_'});
        PIZ=tokenisedFileName{1,1}{1,1};
        
        
        % get ArcName
        arcName=tokenisedFileName{1,1}{3,1};
        temp=tokenisedFileName{1,1}{5,1};
        
        tS=(textscan(temp,'%s',1,'delimiter',{'.'}));
        
        timeStamp=tS{1,1}{1,1};
        
        year=timeStamp(1:4);
        month=timeStamp(5:6);
        date=timeStamp(7:8);
        hh=timeStamp(9:10);
        mm=timeStamp(11:12);
        ss=timeStamp(13:14);
        
        timeString=strcat(date,underscore,month,underscore,year,underscore,hh,mm,underscore,ss);
        
        % generate patientDirectory, patientSubDirectory strings
        patientDirectory=strcat(localDirectory,analysisDirectory,slash,PIZ,underscore,arcName);
        
        patientSubDirectory=strcat(localDirectory,analysisDirectory,slash,PIZ,underscore,arcName,slash,timeStamp,slash);
        
        fprintf(fid,'%s, %s, %s\n',PIZ,arcName,timeStamp);
        
        folderExists=exist(patientDirectory,'dir');
        
        %check whether patientDirectory exist based on the PIZ
        if (folderExists~=7) 
            mkdir(patientDirectory);
        end
        
        %check whether patientSubDirectory exist based on the PIZ
        subFolderExists=exist(patientSubDirectory,'dir');
        
        if (subFolderExists~=7) 
            mkdir(patientSubDirectory);
        end
        
        % first parse each file identified on the sorted list
        
%         fprintf('How far does it execute?\n');
        
         [headerInfo,subBeams,axisData,beamOn,b] = parseTrajectoryLogData(strcat(trajectoryLogDirectory,sortedListing(i).name));
         
         fprintf('Now processing file %d of %d: %s\n',i,numFiles,sortedListing(i).name);
        
 %       [headerInfo,subBeams,axisData,beamOn,b] = parseTrajectoryLogData(sortedListing(i).name);
        
        % now collate data from all snapShots into single difference
        % structure
        % difference = expected - actual
        [difference]=analyseAxes(axisData);
        
       % [Fluence_actual,Fluence_planned]=generateFluenceMaps(axisData,1);
        
        
        % finally generate tabular statistics and PDF files of the
        % histogram distribution for MLC, gantry, collimator and MU
        latexFileName=reportGenerator(difference,PIZ,timeString,patientSubDirectory,subBeams);
        fprintf(fid2,'%s \n',latexFileName);
        
        
        % now execute system command to compile *.tex file using pdflatex
        
        %cd(patientSubDirectory);
        %pdflatex='pdflatex';
        %command=strcat(pdflatex,' Q ',latexFileName);
        
        %[status,cmdout] = system(command,'-echo')
 
        
        % clean up by deleting the following variables
        % clearvars headerInfo subBeams axisData beamOn b difference  latexFileName;
       
       
       % move trajectory log file to archive subdirectory after successfully completing
       % analysis
        movefile(strcat(trajectoryLogDirectory,sortedListing(i).name),strcat(archiveDirectory,sortedListing(i).name));
        
    end
    
    %Close the CSV file
	fclose(fid);
    fclose(fid2);