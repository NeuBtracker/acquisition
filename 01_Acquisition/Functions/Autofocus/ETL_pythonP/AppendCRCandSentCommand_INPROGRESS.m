currentFolder = pwd;
cd('D:\ZT_Matlab\IndivParts\ETL_pythonP')
currentAmp=60;


% #--> Call using argument of the from:  bytearray([65,119,highByte,lowByte] 
% #current_conv =  (int) (current / max_cur * 4095)  
% # highByte = np.uint8(np.int16(current_conv) >>8)
% # lowByte = np.uint8(np.int16(current_conv) & 0xFF)
% # ser.write(appendCRC16(bytearray([65,119,highByte,lowByte]))) 

Current=290;
Max_Current=290;

current_conv =  (Current./Max_Current .* 4095);
[Amp2bytes]=typecast(int16(current_conv),'uint8'); %swapbytes

fpInDiopt=3;
FocalPower2sent= (fpInDiopt +5) *200;
FocalPower2sentBytes=typecast(int16(FocalPower2sent),'uint8');



Message= [65,119,Amp2bytes(1),Amp2bytes(2)];
Message1=[hex2dec('50'), hex2dec('77'), hex2dec('44'), hex2dec('41'),...
    hex2dec('03'), hex2dec('e8'), hex2dec('01'), hex2dec('01')];
Message2=[hex2dec('50'), hex2dec('77'), hex2dec('44'), hex2dec('41'),...
    hex2dec('06'), hex2dec('40'), hex2dec('01'), hex2dec('01')];
Message3=[hex2dec('50'), hex2dec('77'), hex2dec('44'), hex2dec('41'),...
    FocalPower2sentBytes(1), FocalPower2sentBytes(2), hex2dec('01'), hex2dec('01')]

[status,cmdout] = dos(['python append_crc16_tobytearray.py "'  char(Message1) '"' ] ,'-echo' );
[status,cmdout] = dos(['python append_crc16_tobytearray.py "'  char(Message2) '"' ] ,'-echo' );
[status,cmdout] = dos(['python append_crc16_tobytearray.py "'  char(Message3) '"' ] ,'-echo' );

%[status,cmdout] = dos(['python append_crc16_tobytearray.py ' str2num(strjoin(Message4))] ,'-echo' )

%[status,cmdout] = dos(['python append_crc16_tobytearray.py ' str2num(strjoin(Message4(1:4))) ' ' str2num(strjoin(Message4(5:8))) ] ,'-echo' )
