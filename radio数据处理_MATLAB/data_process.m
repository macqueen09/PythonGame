function [ result ] = data_process( fileID )
%input file and out out the result matrix
%   Detailed explanation goes here

% ���濪ʼʱ�� ( ����Ҫ³���ԿɴӺ����⴫��ò���)
begin_time = 1347;

Csousuo = textscan(fileID,'%s%f',1,'delimiter','	');
Cgenzong = textscan(fileID,'%s%f',1,'delimiter','	');
Ctext3 = textscan(fileID,'%s%f',1,'delimiter','	');
Ctext4 = textscan(fileID,'%s%f',1,'delimiter','	');
Ctexthead = textscan(fileID,'%s',12,'delimiter','	');
Cdata=textscan(fileID,'%f%f%f%f%f%f%f%f%f%f%f%s');
fclose(fileID);
data_num = size(Cdata{1},1);
% ������״̬����Ϊ����
temp12 = strrep(Cdata{12},'ȡ��','0');
temp12 = strrep(temp12,'�㺽��','1');
temp12 = strrep(temp12,'��ʱ����','2');
temp12 = strrep(temp12,'�ȶ�����','3');
temp12 = strrep(temp12,'ʧ��','4');
if isempty(temp12) % û���κ����ݣ�ֻ�б�ͷ����������ҲҪд�������ˣ�
    result = zeros(1,14);
    result(1,14) = Csousuo{2}+Cgenzong{2};
    result(1,11)=35.2*result(1,14)-6*0.017;
    result(1,12)=result(1,11)/35.2;
    return 
end
tempr = cell2mat(temp12);
tempr = str2num(tempr);
% dataΪ12�е��������ݣ�float��
data = [Cdata{1} Cdata{2} Cdata{3} Cdata{4} Cdata{5} Cdata{6} Cdata{7} Cdata{8} Cdata{9} Cdata{10} Cdata{11} tempr];

%����һ�����ݵĽ��
% time = data(1,1)

% ��һ�ֺ����ŵļ��������ҳ���
hangji = data(:,2); 
% ��ʼ�������ŵĳ���,��hj_list�����Ϊ�����ţ�1�����ż�����2��Сʱ�䣬3���ʱ��
hj_list=zeros( max(hangji)+1 ,3); % ��󺽼���Ϊ5 ����hj_list�����С��6,3��
for i = 1:data_num
    temphangji = hangji(i)+1;
    hj_list(temphangji,1) = hj_list(temphangji,1) + 1; % �����ż���
    if hj_list(temphangji,1) == 1
        hj_list(temphangji,2) = data(i,1);
        hj_list(temphangji,3) = data(i,1);
    else
        hj_list(temphangji,2) = min(hj_list(temphangji,2),data(i,1));
        hj_list(temphangji,3) = max(hj_list(temphangji,3),data(i,1));
    end
end

%% ����һЩ������� 
% �ѻ�� Ŀ��ػ�ʱ�䣨hj_list(x,2)�� ������ʱ��duration
duration = (hj_list(:,3)-hj_list(:,2)); % ��Ŀ�����ʱ��
result = zeros(1,14);

result_num=0; % result���ۼ�
for i = 1:size(hj_list,1) %1-4���ÿ����⵽��Ŀ��  ������Ϊi-1  dataiΪ�ú���������
    % i�ź����п�����������������д��
    if hj_list(i,1) >7
        %������Ӧ��С�ı������洢������
        result_num = result_num+1;
        datai = zeros(hj_list(i,1),size(data,2));
        hj_num = 0;
        for j = 1:data_num
            if data(j,2) == i-1 %�����к������Ƕ�Ӧ��i-1��
                hj_num = hj_num+1;
                datai(hj_num,:) = data(j,:);  %��data�ж�Ӧ��һ�����ݸ��Ƶ� i-1 �ź����ľ���datai��
            end
        end
        [dist_p, fangwei_p, fuyang_p] = trace(datai);%���㡢�������

        %����[���]"��"Ŀ��ʱ����Դ,�п����Ǹ���Ŀ�꣬���Ǻ����ɸѡ����������һ�������Ŀ��
        %������Ŀ��ĵ㼣��Ŀ   ֻȥ�㺽�����ȶ���������Ҫ��ʱ������ʧ����ȡ��
        i0=find(datai(:,12)==0);
        i1=find(datai(:,12)==1);
        i4=find(datai(:,12)==4);
        del_list = [i0 ; i1 ; i4]; %׼��ɾ����Ԫ������
        
        time_res=0.034*(hj_list(i,1)- size(del_list,1));

        time_ganrao = 0; %���趨Ϊ0 ����Ϊ���桯Ŀ�껹û��ɸѡ����������ⲿ��û��������
        result(result_num,:) = [0,(hj_list(i,2)-begin_time),duration(i,1),dist_p,(dist_p/2.4)...
            ,fangwei_p,fuyang_p,hj_list(i,1),time_res,time_res/35.2,(time_ganrao),...
            time_ganrao/35.2,0,Csousuo{2}+Cgenzong{2}];
    end
end
% ���������ڴӶ�Ŀ����ѡȡ�ȷ����ΪĿ�꣬�޳�����Ŀ�꣬ѡ�����桱Ŀ��
[~ , index] = min(result(:,2));
xj_hangji = 0;
[hj_num,~] = size(result);
for i=1:hj_num
    if i ~= hj_num %���ȶ�����ٺ���
        if (result(i,3)>3) && (result(i,8)>=5) && result(i,4)>45
            xj_hangji = xj_hangji+1;
        end
    end
end
result = result(index , :);
result(:,13) = xj_hangji;
%���Ų������¸�ֵ
% sprintf('%s',result(:,9))
time_ganrao= 35.2 * (Csousuo{2}+Cgenzong{2}) - result(:,9) - 6*0.017  ;%�������ĵ�ʱ����Դ
result(:,11) = time_ganrao;
result(:,12) = time_ganrao/35.2;

%14������
% sprintf('this files result is ;',result)
if result(:,8) == 0 %ֻ���������ź���û���溽�������(���������Ӧ�÷�����������䰴��˵��Ӧ�ñ�ִ��)
    sprintf('***************still has something none result why??********************************');
%     result = zero(1,14);
%     result(1,14) = Csousuo{2}+Cgenzong{2};
%     result(1,11)=3502*result(1,14)-6*0.017;
%     result(1,12)=result(1,11)/35.2;
    return 
end
% keyboard
end
