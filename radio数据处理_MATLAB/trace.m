function [ dist_p, fangwei_p, fuyang_p ] = trace( datai )
%TRACE Summary of this function goes here
%   Detailed explanation goes here

%ȥ��datai�ķ��ȶ�����   ȡ��0���㺽��1����ʱ2��ʧ��4

i0=find(datai(:,12)==0);
i1=find(datai(:,12)==1);
i2=find(datai(:,12)==2);
i4=find(datai(:,12)==4);

del_list = [i0 ; i1 ; i2 ; i4]; %׼��ɾ����Ԫ������

for i = size(del_list,1):-1:1
    datai(del_list(i),:)=[];
end

% sprintf('datai size is %d,%d',size(datai,1),size(datai,2))
if size(datai,1)<1
    sprintf('*******there has a null datai which should not happen**********')
end
    
dist_p = junfangcha(datai,3); % �ڶ�������Ϊ�����ݵĵ�һ�����ڵ�����
fangwei_p = junfangcha(datai,5);
fuyang_p = junfangcha(datai,7);

end

function [result] = junfangcha(datai,x)
    d_num = size(datai,1);
    dis_x = datai(:,x) - datai(:,x+1);
%     sprintf('************************')
% %     100000*dis_x
%     sprintf('----mean----mean---:')
    dis_mean_x = mean(dis_x);
    
    dis_sd_x = std(dis_x); % ��ʽһ�����д���֤������֤matlab�Ĺ�ʽ����Ŀ��ʽһ�£�
    result = sqrt(  (d_num-1)/d_num*(dis_sd_x^2) + sum( (dis_x-dis_mean_x).^2 )  );

end