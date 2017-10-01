

s_etl = serial('COM30');
set(s_etl,'BaudRate',115200);
fopen(s_etl);
fprintf(s_etl,'Start')
out = fscanf(s_etl)
Message='TA';
MessageBinarySTR=(dec2bin(cast(Message,'uint8'),8));
MessageBinary = logical(MessageBinarySTR(:)'-'0');
%[CRC16Binary] = crc16(MessageBinary);



fprintf(s_etl,'Tw00')
out = fscanf(s_etl)

while 1==1
for i=20:180
set_ETL_current(s_etl, i)
pause(0.01);
end
end

fclose(s_etl);
clear s_etl