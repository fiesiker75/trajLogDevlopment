function [ authorised ] = IPTest()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
[status,result]=system('ipconfig');


mySMTP = 'mail2.uniklinik-freiburg.de';
myEmail = 'mark.gainey@uniklinik-freiburg.de';

% Set your email and SMTP server address in MATLAB.
setpref('Internet','SMTP_Server',mySMTP);
setpref('Internet','E_mail',myEmail);

recipient = myEmail;
subj = 'Unauthorised use of MATLAB Trajectory Log analysis software';
msg = result;

f = fopen('F:\MATLAB\IPAllow.txt');             
g = textscan(f,'%s','delimiter','\n');
fclose(f);

numberOfAllowedIPs=ndims(g);
authorised=0;
allowed=0;

    for i=1:numberOfAllowedIPs
    % this is currently hard-coded but will create an IP.allow text file 
    
%    fprintf('Test string = %s \n',g{1,1}{i,1}) 
    authorised=strfind(result,g{1,1}{i,1});
    
    if (isempty(authorised)) % do nothing
        
    else
        allowed=1;
        break
    end
    
    %fprintf('\nAuthorised = %d \n', authorised)

    end
    
    
%fprintf('\nAllowed = %d \n', allowed)


 if (allowed==0)
     sendmail(recipient,subj,msg);
     fprintf('\nUnauthorised use of MATLAB Trajectory Log analysis software. \nSending event log to %s for analysis ...\n', recipient);
 end
 
%  else if (isempty(authorised))
%      sendmail(recipient,subj,msg);
%      fprintf('\nSending event log for analysis...\n');
%     
%  else
%  end

end

