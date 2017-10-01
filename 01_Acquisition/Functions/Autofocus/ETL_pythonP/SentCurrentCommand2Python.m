currentFolder = pwd;
cd('D:\ZT_Matlab\IndivParts\ETL_pythonP')

profile on;
tic
%for i=1:100
    for j=[-200:10:200]
        currentAmp=j%199;
        
[status,cmdout] = dos(['python LDC_general_wArg.py ' num2str(currentAmp)] )
%cd(currentFolder)
    end
%end
a=toc
profile viewer


currentFolder = pwd;
cd('D:\ZT_Matlab\IndivParts\ETL_pythonP')
currentAmp=250;%199;
[~,cmdout] = dos(['python LDC_general_wArg.py ' num2str(currentAmp)] )

kk=0;
erc=0;
for i=-250:0.1:250
    try
    kk=kk+1;
[~,cmdout] = dos(['python LDC_general_wArg.py ' num2str(i)] );
%display([num2str(i) '--->' cmdout])
A(kk,1)=i;
nn=0;
for is=3:2:13
nn=nn+1;
B(kk,nn)=char(hex2dec(cmdout(is:is+1)));
end
display(['ETL_Pos(' num2str(kk) ')=' num2str(i)])
display(['ETL_Message(' num2str(kk) ')=' B(kk,:)])
    catch
       % display('outch');
        erc=erc+1;
    end
end
    
ETL_Positions=A;
ETL_Messages=B;
save('D:\ZT_Matlab\ELT_LUT.mat','ETL_Positions','ETL_Messages');
(appendCRC16(bytearray([65,119,highByte,lowByte])));

