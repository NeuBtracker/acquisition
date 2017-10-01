cd('I:\');
fileID = fopen('F.txt','w');
fclose(fileID);
oldname='F.txt'
for i=1:500000
    i
    newname=['F' num2str(i) '.txt']; 
    dos(['rename "' oldname '" "' newname '"']); % (1)
    pause(0.05);
    oldname=newname;
end


