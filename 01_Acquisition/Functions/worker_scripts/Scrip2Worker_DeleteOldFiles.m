cd('I:\');
fileID = fopen('Path2SaveNextExperiment','r');path=fscanf(fileID,'%s');fclose(fileID);
cd(path);

while 1==1
    try
        current_timestamp=str2num(datestr(datetime('now'),'yymmddHHMMSSFFF'));
        mrF=fopen('Most_Recent_FluoroImag','r');mrFnumber=fread(mrF,'double');fclose( mrF);
        mrR=fopen('Most_Recent_RefImag','r');mrRnumber=fread(mrR,'double');fclose( mrR);
        %  display(['R:' num2str(mrRnumber)  'F:'  num2str(mrFnumber)]);
        A=dir;
        for ii=3:length(A)
            if ( ~isempty(strfind(A(ii).name,'F_')) && ...
                    isempty(strfind(A(ii).name,'F_r'))&& ...
                    (current_timestamp-str2num(A(ii).name(end-14:end))>10*10^3)) ...% Old line: (str2double(A(ii).name(end-8:end))<(mrFnumber-100)) ) ...
                    || ( ~isempty(strfind(A(ii).name,'R_')) && ...
                    isempty(strfind(A(ii).name,'R_r')) &&...
                    (current_timestamp-str2num(A(ii).name(end-14:end))>10*10^3))% Old line: (str2double(A(ii).name(end-8:end))<(mrRnumber-100)))
                    delete([A(ii).name]);
            end
        end
        %  if length(A)>250; display('not deleting!');end
        %  if length(A)<150; display('deleting too much!!!'); end
    catch
        display('Deleting function is :(');
    end
    
end

%% Comment
% In the past frame number rather than timestamps were used, in that case
% the 3rth argument of the comparison was: str2double(A(ii).name(end-8:end))<(mrFnumber-100)) )
% to delete all but 100 frame before the current on.