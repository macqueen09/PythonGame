function [ result ] = data_process( fileID )
%input file and out out the result matrix
%   Detailed explanation goes here

% 仿真开始时间 ( 若需要鲁棒性可从函数外传入该参数)
begin_time = 1347;

Csousuo = textscan(fileID,'%s%f',1,'delimiter','	');
Cgenzong = textscan(fileID,'%s%f',1,'delimiter','	');
Ctext3 = textscan(fileID,'%s%f',1,'delimiter','	');
Ctext4 = textscan(fileID,'%s%f',1,'delimiter','	');
Ctexthead = textscan(fileID,'%s',12,'delimiter','	');
Cdata=textscan(fileID,'%f%f%f%f%f%f%f%f%f%f%f%s');
fclose(fileID);
data_num = size(Cdata{1},1);
% 将航迹状态量化为数字
temp12 = strrep(Cdata{12},'取消','0');
temp12 = strrep(temp12,'点航迹','1');
temp12 = strrep(temp12,'临时航迹','2');
temp12 = strrep(temp12,'稳定航迹','3');
temp12 = strrep(temp12,'失跟','4');
if isempty(temp12) % 没有任何数据，只有表头（这种数据也要写入表格中了）
    result = zeros(1,14);
    result(1,14) = Csousuo{2}+Cgenzong{2};
    result(1,11)=35.2*result(1,14)-6*0.017;
    result(1,12)=result(1,11)/35.2;
    return 
end
tempr = cell2mat(temp12);
tempr = str2num(tempr);
% data为12列的所有数据，float型
data = [Cdata{1} Cdata{2} Cdata{3} Cdata{4} Cdata{5} Cdata{6} Cdata{7} Cdata{8} Cdata{9} Cdata{10} Cdata{11} tempr];

%计算一个数据的结果
% time = data(1,1)

% 把一种航迹号的几行数据找出来
hangji = data(:,2); 
% 初始化航迹号的长度,，hj_list序号数为航迹号；1航迹号计数，2最小时间，3最大时间
hj_list=zeros( max(hangji)+1 ,3); % 最大航迹号为5 ，则hj_list矩阵大小（6,3）
for i = 1:data_num
    temphangji = hangji(i)+1;
    hj_list(temphangji,1) = hj_list(temphangji,1) + 1; % 航迹号计数
    if hj_list(temphangji,1) == 1
        hj_list(temphangji,2) = data(i,1);
        hj_list(temphangji,3) = data(i,1);
    else
        hj_list(temphangji,2) = min(hj_list(temphangji,2),data(i,1));
        hj_list(temphangji,3) = max(hj_list(temphangji,3),data(i,1));
    end
end

%% 计算一些结果数据 
% 已获得 目标截获时间（hj_list(x,2)） 最大跟踪时长duration
duration = (hj_list(:,3)-hj_list(:,2)); % 该目标跟踪时间
result = zeros(1,14);

result_num=0; % result的累加
for i = 1:size(hj_list,1) %1-4针对每个检测到的目标  航迹号为i-1  datai为该航迹的数据
    % i号航迹有可能数量不够，不被写入
    if hj_list(i,1) >7
        %申请相应大小的变量，存储其数据
        result_num = result_num+1;
        datai = zeros(hj_list(i,1),size(data,2));
        hj_num = 0;
        for j = 1:data_num
            if data(j,2) == i-1 %数据中航迹号是对应的i-1号
                hj_num = hj_num+1;
                datai(hj_num,:) = data(j,:);  %将data中对应的一行数据复制到 i-1 号航迹的矩阵datai中
            end
        end
        [dist_p, fangwei_p, fuyang_p] = trace(datai);%计算、保存参数

        %跟踪[这个]"真"目标时间资源,有可能是干扰目标，但是后面会筛选，留下来的一组就是真目标
        %跟踪真目标的点迹数目   只去点航迹，稳定航迹，不要临时航迹，失跟，取消
        i0=find(datai(:,12)==0);
        i1=find(datai(:,12)==1);
        i4=find(datai(:,12)==4);
        del_list = [i0 ; i1 ; i4]; %准备删除的元素索引
        
        time_res=0.034*(hj_list(i,1)- size(del_list,1));

        time_ganrao = 0; %先设定为0 ，因为‘真’目标还没有筛选出来，因而这部分没法填数字
        result(result_num,:) = [0,(hj_list(i,2)-begin_time),duration(i,1),dist_p,(dist_p/2.4)...
            ,fangwei_p,fuyang_p,hj_list(i,1),time_res,time_res/35.2,(time_ganrao),...
            time_ganrao/35.2,0,Csousuo{2}+Cgenzong{2}];
    end
end
% 这两行用于从多目标中选取最精确的最为目标，剔除干扰目标，选出“真”目标
[~ , index] = min(result(:,2));
xj_hangji = 0;
[hj_num,~] = size(result);
for i=1:hj_num
    if i ~= hj_num %即稳定的虚假航迹
        if (result(i,3)>3) && (result(i,8)>=5) && result(i,4)>45
            xj_hangji = xj_hangji+1;
        end
    end
end
result = result(index , :);
result(:,13) = xj_hangji;
%干扰部分重新赋值
% sprintf('%s',result(:,9))
time_ganrao= 35.2 * (Csousuo{2}+Cgenzong{2}) - result(:,9) - 6*0.017  ;%干扰消耗的时间资源
result(:,11) = time_ganrao;
result(:,12) = time_ganrao/35.2;

%14个数据
% sprintf('this files result is ;',result)
if result(:,8) == 0 %只有少数干扰航迹没有真航迹的情况(这种情况不应该发生，下列语句按理说不应该被执行)
    sprintf('***************still has something none result why??********************************');
%     result = zero(1,14);
%     result(1,14) = Csousuo{2}+Cgenzong{2};
%     result(1,11)=3502*result(1,14)-6*0.017;
%     result(1,12)=result(1,11)/35.2;
    return 
end
% keyboard
end
