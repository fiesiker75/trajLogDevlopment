function patientName = getPatientName(PIZ)
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

else
    patientName=fprintf('Invalid query: PIZ %d\n', PIZ);
end

patientName = fetch(patientName);

patientName.Data

close(patientNameQuery);

end

