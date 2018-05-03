%% read a excel by auto 
close all;
clear
clc

Path = 'D:\1_Coding\DM�����߳���Դ\������';
fileout = 'result_writing.xlsx';
% ��ȡ�����ļ������ݸ���
if ~exist(fileout,'file')
    sprintf('file not exist:%s',fileout)
else
    column1 = xlsread(fileout,'A:A');
    alreadyd = size(column1,1); %�ļ����Ѿ��е����ݸ���
end
tic
filenum = 0;
list = dir(Path);  %��ͬ�ļ���
last_file = 0;%��һ���ļ����ֶ���������
for k = 3:size(list,1)
    sublist = dir([Path '/' list(k).name '/' 'result_*.txt']);
    for l = 1:size(sublist)  % ��ͬ��txt�ļ�
        filenum = filenum+1;
        filepath = [ '������' '/' list(k).name '/' sublist(l).name];
%         sprintf('this file is: %s',filepath)
        
        indfir = max(strfind(filepath,'result_'));
        numm = strfind(filepath,'.');
        zhanqing = filepath(indfir+7:numm-1);% ��ȡ�ļ����е�����
        zhanqing = str2num(zhanqing);
        sprintf('number of file is result_%d.txt',zhanqing)

        fileID = fopen(filepath);
        contain = data_process(fileID);
        if ~isempty(contain) %�ж��ļ����Ƿ��ǿ�
            contain(1,1) = zhanqing;
            alreadyd = alreadyd + last_file;
            position = strcat('A',num2str(alreadyd+2));
            last_file = size(contain,1);
            xlswrite(fileout,contain,1,position);
        else
            sprintf('null file is %s',filepath) %���ļ���û�����ݣ������Ǳ����ŵñȽ�����
        end
        if contain ==1
            sprintf('*******error file is %s',filepath)
        end
    end
end
alltime = toc
% save alltime %����������ʱ��  Լ15����
