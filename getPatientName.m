function [lastName,firstName] = getPatientName(PIZ)
%this function returns patientName from Mosaiq database
% PIZ is used as primary key

logintimeout(5);

% format returned data as cell array
setdbprefs('DataReturnFormat','cellarray');

% database name
host='st00018';
db='Mosaiq'; %this needs to be edited

[password,user]=SQLPasswordUserName;




% http://www.mathworks.de/de/help/database/ug/microsoft-sql-server-jdbc-windows.html
% => step 3

patientNameQuery=database(db,user,password,'Vendor','Microsoft SQL Server','Server',host,'AuthType','Server','portnumber',1433);

[status]=ping(patientNameQuery);

%check connection status is valid
validConnection=isconnection(patientNameQuery);

% if connection is valid
if (validConnection==1)

% return patientName using PIZ as primary key
queryString=sprintf('SELECT LAST_NAME, FIRST_NAME FROM vw_Patient WHERE IDA=''%d''\n',PIZ); % this needs to be edited
%fprintf(queryString);
patientName=exec(patientNameQuery,queryString);
patientName = fetch(patientName);

temp=patientName.Data;
% check whether valid PIZ

validData=strcmp(temp{1,1}(:)','No Data');

sprintf('validData = %d\n',validData);


    if (~validData)

    lastName=(temp{1,1}(:))';
    firstName=(temp{1,2}(:))';
    
    else
    lastName='Invalid';
    firstName='Invalid';
    fprintf('Invalid query string ''%s'' or PIZ %d. Please ensure that PIZ is correct!\n', queryString,PIZ);
    end
else
    sprintf('No connection to DB ''%s''\n', db);
    
end



close(patientNameQuery);

end

