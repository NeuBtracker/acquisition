%% Initialize COM port and Focal Power Mode;
s = serial('COM32');
set(s,'BaudRate',115200);
set(s,'Databits',8);
set(s,'Stopbits',1);
set(s,'Parity','none');

fopen(s);
fprintf(s,'Start') %Handshake

out = fscanf(s)
pause(0.5);
SetFocalPowerCommandHex=('4d7743415676');
SetFocalPowerCommandChar=char(hex2dec(reshape(SetFocalPowerCommandHex,2,[])'))';
fprintf(s,SetFocalPowerCommandChar) % Set Focal Power mode
%pause(0.5);
%out = fscanf(s);

%% Define FP 
for i=-2:0.01:2
    if i==0
        continue
    end
   
    
fpInDiopt=i; %-3.5:+3.5%Safe range 6:9; Allowed Range:-5 :15 
display([num2str(fpInDiopt) 'correspond to' num2str(1000/(fpInDiopt+0.0001))]);
FocalPower2sent= (fpInDiopt) *200;
%FocalPower2sentBytes=typecast(int16(FocalPower2sent),'uint8');
FocalPower2sentBytes=typecast(int16(FocalPower2sent),'uint8');
FocalPower2sentHex=(dec2hex(fliplr(FocalPower2sentBytes)));
PureMessage2TransmitHex=[('50'); ('77'); ('44'); ('41');... % PwDA
    FocalPower2sentHex(1,:); FocalPower2sentHex(2,:);...  %Focal Power in Hex
    ('00'); ('00')];    %Dummy

PureMessage2TransmitBin=char(hex2dec(PureMessage2TransmitHex)');
PureMessage2TransmitChar=char(PureMessage2TransmitBin);
%[status,cmdout] = dos(['python append_crc16_tobytearray.py "'  char(hex2dec(PureMessage2TransmitHex)') '"' ] ,'-echo' );
%Message2TransmitHex=cmdout(3:end-2);

MessageWcrc=[PureMessage2TransmitChar crc4Optotune(uint16(PureMessage2TransmitChar))];
fprintf(s,MessageWcrc);
    
end

