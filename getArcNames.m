function [arcNames] = getArcNames(subBeams)
%Simple code to return the names of all arcs pertaining to current subBeam
%structure: used to create titles for graphs and /or tables
underscore='_';
%[numberOfSubBeams,unused]=size(subBeams);

[unused,numberOfSubBeams]=size(subBeams);

arcNames(numberOfSubBeams)=struct('Name',[]);

    for i=1:numberOfSubBeams
    beamName=textscan(subBeams(i).name,'%s',1,'delimiter',{':'});
    arcNames(i).Name=strcat(underscore,(beamName{1,1}{1,1}),underscore,num2str(subBeams(i).mu));
    
    %arcNames(i).Name=beamName{1,1}{1,1};
    end

end

