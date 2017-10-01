%% Initialize COM port and Focal Power Mode;
s = serial('COM11');
set(s,'BaudRate',115200);
fopen(s);
fprintf(s,'Start') %Handshake
out = fscanf(s)
pause(0.5);

%profile on
k=0;
for i=1:100000;
  %  i

    k=k+5;
    if k>250;k=5;end      
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
target_current=k %250;%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
callibration_current=293; %mA
xi=round((target_current./callibration_current)*4096);
%xi=1202
Current2sentBytes='0000000000000000';
bits=dec2bin(uint16(xi),2);
Current2sentBytes(1,17-length(bits):16)=bits;%typecast(uint16(xi),'int8');
char(bin2dec(Current2sentBytes(1:8)))
Message=['Aw' char(bin2dec(Current2sentBytes(1:8))) char(bin2dec(Current2sentBytes(9:16))) ];
MessageHEX=dec2hex(Message);
MessageWcrc=[Message crc4Optotune(uint16(Message))];
MessageWcrcHEX=dec2hex(MessageWcrc);
fprintf(s,char(MessageWcrc));
%pause(0.5);
    end
end
%profile viewer
%out = fscanf(s);

fclose(s);

char
XXX=instrfind;
fclose(XXX);
delete(XXX);

%% return to original path
cd(currentFolder)
fclose(s);
