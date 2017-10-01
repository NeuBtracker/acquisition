function void=Delete_NonImportant_Images_Funct(path)
cd(path);
%while 1==1
    try
        mrF=fopen('Most_Recent_FluoroImag','r');mrFnumber=fread(mrF,'uint16');fclose( mrF);
        mrR=fopen('Most_Recent_RefImag','r');mrRnumber=fread(mrR,'uint16');fclose( mrR);
        
        A=dir('I:\');
        
        %delete('/mytests/*.mat')
        length(A)
        for ii=1:length(A)
            if ( ~isempty(strfind(A(ii).name,'F_')) && (str2double(A(ii).name(3:end))<(mrFnumber-100)) ) ...
                    || (~isempty(strfind(A(ii).name,'R_')) && (str2double(A(ii).name(3:end))<(mrRnumber-100)))
                delete(['I:\' A(ii).name]);
                     
            end
        end
    catch
    end
%end