clear all 
close all 

addpath('ecgiddb');

%% Only run the below code if want to re-extract all the features and save them to a csv
% !rm features.csv
% search_dirs = dir('ecgiddb'); 
% person = 0;
% for i = 1:length(search_dirs)
%     path = strcat('ecgiddb/', search_dirs(i).name, '/');
%     disp(path)
%     files = dir([path,'*.dat']);
%     file_names = {files.name}'; 
%     if( length(file_names) > 0 )
%         person = person+1;
%     end
%     for j = 1:length(file_names)
%         file_path = strcat(path, file_names(j));
%         try 
%             [tm,sig]=rdsamp(char(file_path),1);
%             [tm2,sig_denoise_paper]=rdsamp(char(file_path),2);
% 
%             [x,chunks] = full_process(tm,sig,tm2,sig_denoise_paper);
%             chunks = transpose(chunks); 
%             p_col = ones(length(chunks(:,1)),1) * person; 
%             data = [p_col chunks];
%             dlmwrite('features.csv',data,'delimiter',',','-append');
%         catch e
%             disp(e)
%         end
%     end 
% end

%% Test code to view pipeline with one sample 
[tm,sig]=rdsamp('ecgiddb/Person_11/rec_1.dat',1);
[tm2,sig_denoise_paper]=rdsamp('ecgiddb/Person_11/rec_1.dat',2);

[x,chunks] = full_process(tm,sig,tm2,sig_denoise_paper);

figure; 
plot(chunks);
title('Chunked features');
hold on; grid on; 