function [err]=writeValue4ETL(current)
err=0;
if isnan(current)
    current=0;    
end

try
    fileID = fopen('I:\Next_ETL_Value.txt','w');
    fwrite(fileID,num2str(current));
    fclose(fileID);    
catch
    err=0;
end
end