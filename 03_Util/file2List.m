function [LIST] = file2List(Path, Name_str)
%This function generates a list of the names of the file (specified by 'Name_str')
%in the folder specified by 'Path'. The names of the file are sorted
%accordingly to the number in the file names.

fprintf('Reading file names in the folder...')

LIST = dir([Path, Name_str]);
n_frame = size(LIST,1);
Image_num = zeros(n_frame, 1);
progressbar('N frame')
for i=1:n_frame   
    Image_num(i) = str2num(cell2mat(regexp(LIST(i).name,'\d+','match')));
    progressbar(i/n_frame)
end 

progressbar(1)
[~,id] = sort(Image_num);
LIST=LIST(id);

fprintf(' OK \n')
fprintf([num2str(length(LIST)),' files found\n'])

end

