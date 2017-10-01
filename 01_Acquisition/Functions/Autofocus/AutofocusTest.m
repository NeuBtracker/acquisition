%autofocus_test

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

cd('I:\20160809\1405\RAW');
pFM=0;
mov_factor=+1;
prev_cur=100;
direction=1;
k=0;
clear LOGnFM LOGnew_cur;
while 1==1
    
[Fimage,~]=read_most_recent_fluoroANDreflection;
nFM=fmeasure(Fimage, 'BREN');
if nFM>=pFM
direction=direction.*(+1);
else
direction=direction.*(-1);
end
pFM=nFM;

step=2.5;
new_cur=prev_cur+(direction.*step);

if new_cur>190; new_cur=190;
elseif new_cur<5; new_cur=5;
end

set_ETL_current(s_etl, new_cur)
prev_cur=new_cur;

k=k+1;
LOGnFM(k)=nFM;
LOGnew_cur(k)=new_cur;
subplot(1,2,1);plot(LOGnFM);
subplot(1,2,2);plot(LOGnew_cur);
drawnow;
end



