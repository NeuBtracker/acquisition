function [error_message]=set_ETL_current(etl_device, target_current,type_of_command)

warning off MATLAB:serial:fread:unsuccessfulRead

%% Sending Current
if type_of_command==0;    
error_message=[];
if target_current>200;
    target_current=200;
elseif target_current<-200;
    target_current=-200;
end

callibration_current=293; %mA
xi=int16(round((target_current./callibration_current)*4096));
%for testing:
%xi=int16(1202)
%bin2dec('0000010010110010')
 
xi=0;
%Current2sentBytes='0000000000000000';
%bits=dec2bin(uint16(xi),2);
Current2sentBytes=reshape(dec2bin(typecast(xi,'uint16'),16).',1,[]);
Message=['Aw' char(bin2dec(Current2sentBytes(1:8))) char(bin2dec(Current2sentBytes(9:16))) ];
%MessageHEX=dec2hex(Message);
%MessageWcrc=[Message crc4Optotune(uint16(Message))];
%MessageWcrcHEX=dec2hex(MessageWcrc);
fprintf(etl_device,char([Message crc4Optotune(uint16(Message))]));
%pause(0.05);
%error_message = fscanf(etl_device);
%if ~isempty(error_message);
%display([error_message 'for' num2str(target_current) ' ' num2str(xi)]);
%end

%% Sending Focus;

elseif type_of_command==1;    
    error_message=[];
    fp=target_current;
if fp>4;
    fp=4;
elseif fp<-4;
    fp=-4;
end

xi=int16(round(fp.*200));
%for testing:
%xi=int16(1202)
%bin2dec('0000010010110010')
 
%Current2sentBytes='0000000000000000';
%bits=dec2bin(uint16(xi),2);
Current2sentBytes=reshape(dec2bin(typecast(xi,'uint16'),16).',1,[]);
Message=['PwDA'...
    char(bin2dec(Current2sentBytes(1:8))) char(bin2dec(Current2sentBytes(9:16)))...
    char(bin2dec('00000000')) char(bin2dec('00000000'))];
%MessageHEX=dec2hex(Message);
%MessageWcrc=[Message crc4Optotune(uint16(Message))];
%MessageWcrcHEX=dec2hex(MessageWcrc);
fprintf(etl_device,char([Message crc4Optotune(uint16(Message))]));
pause(0.01);
% error_message = fscanf(etl_device);
% if ~isempty(error_message);
% display([error_message 'for' num2str(fp) ' ' num2str(xi)]);
% end

end

