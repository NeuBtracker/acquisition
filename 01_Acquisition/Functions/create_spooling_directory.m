function path4saving=create_spooling_directory;
t=fix(clock); 
namefold_YYYYMMDD=[num2str(t(1),'%04i'), num2str(t(2),'%02i'), num2str(t(3),'%02i')];
namefold_HHMM=[num2str(t(4),'%02i'), num2str(t(5),'%02i')];
path4saving=['K:\' namefold_YYYYMMDD '\' namefold_HHMM '\RAW'];
mkdir(path4saving);
fileID = fopen('K:\Path2SaveNextExperiment','w');fprintf(fileID,'%s',path4saving);fclose(fileID);
cd(path4saving);
end
