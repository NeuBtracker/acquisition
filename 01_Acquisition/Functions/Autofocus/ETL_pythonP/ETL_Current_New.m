s = serial('COM32');
set(s,'BaudRate',3840);
set(s,'Databits',8);
set(s,'Stopbits',1);
set(s,'Parity','none');

fopen(s);
fprintf(s,'Start') %Handshake
out = fscanf(s)
pause(0.5);


for ii=-200:3:200
    
target_current=ii

callibration_current=293; %mA
xi=int16(round((target_current./callibration_current)*4096));
%for testing:
%xi=int16(1202)
%bin2dec('0000010010110010')
 
%Current2sentBytes='0000000000000000';
%bits=dec2bin(uint16(xi),2);

Current2sentBytes=reshape(dec2bin(typecast(xi,'uint16'),16).',1,[]);


Message=['Aw' char(bin2dec(Current2sentBytes(1:8))) char(bin2dec(Current2sentBytes(9:16))) ];
%MessageHEX=dec2hex(Message);
MessageWcrc=[Message crc4Optotune(uint16(Message))];
%MessageWcrcHEX=dec2hex(MessageWcrc);
fprintf(s,char(MessageWcrc));
pause(0.05);
end
%error_message = fscanf(s);

fclose(s)