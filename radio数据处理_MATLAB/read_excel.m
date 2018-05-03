%% read a excel by auto 
close all;
clear
clc

Path = 'D:\1_Coding\DM程序线程资源\仿真结果';
fileout = 'result_writing.xlsx';
% 读取现有文件中数据个数
if ~exist(fileout,'file')
    sprintf('file not exist:%s',fileout)
else
    column1 = xlsread(fileout,'A:A');
    alreadyd = size(column1,1); %文件中已经有的数据个数
end
tic
filenum = 0;
list = dir(Path);  %不同文件夹
last_file = 0;%上一个文件中又多少行数据
for k = 3:size(list,1)
    sublist = dir([Path '/' list(k).name '/' 'result_*.txt']);
    for l = 1:size(sublist)  % 不同的txt文件
        filenum = filenum+1;
        filepath = [ '仿真结果' '/' list(k).name '/' sublist(l).name];
%         sprintf('this file is: %s',filepath)
        
        indfir = max(strfind(filepath,'result_'));
        numm = strfind(filepath,'.');
        zhanqing = filepath(indfir+7:numm-1);% 获取文件名中的数字
        zhanqing = str2num(zhanqing);
        sprintf('number of file is result_%d.txt',zhanqing)

        fileID = fopen(filepath);
        contain = data_process(fileID);
        if ~isempty(contain) %判断文件内是否是空
            contain(1,1) = zhanqing;
            alreadyd = alreadyd + last_file;
            position = strcat('A',num2str(alreadyd+2));
            last_file = size(contain,1);
            xlswrite(fileout,contain,1,position);
        else
            sprintf('null file is %s',filepath) %此文件中没有数据，可能是被干扰得比较严重
        end
        if contain ==1
            sprintf('*******error file is %s',filepath)
        end
    end
end
alltime = toc
% save alltime %程序运行总时间  约15分钟
