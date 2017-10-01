function [error_message]=set_ETL_current(etl_device, target_current,type_of_command)

warning off MATLAB:serial:fread:unsuccessfulRead


fprintf(etl_device,char([Message crc4Optotune(uint16(Message))]));
%pause(0.05);
%error_message = fscanf(etl_device);
%if ~isempty(error_message);
%display([error_message 'for' num2str(target_current) ' ' num2str(xi)]);
%end




%%


