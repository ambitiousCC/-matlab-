function [Shortest_Length,answer] = ant(Data,flag)
clc ;
%% ��ʼ������
N=11;    %% m ���ϸ���
alpha=1; %% ��Ϣ����Ҫ�̶�
beta=5;  %% ����ʽ������Ҫ�̶�
rho=0.1; %% ��Ϣ������ϵ��
max_iter=200; %%����������
Q=100;        %%��Ϣ����ǿϵ��
n=size(Data,1);
road_length=zeros(n,n);%D��ʾ��ȫͼ�ĸ�Ȩ�ڽӾ���

for i=1:n
    for j=1:n
        if i~=j
            road_length(i,j)=Distance(Data(i,1),Data(i,2),Data(j,1),Data(j,2));
        else��ȫ��13   ��32
            road_length(i,j)=eps;% ȡ����ʱʹ��
        end
        road_length(j,i)=road_length(i,j);   %�Գƾ���
    end
end

%% ��ʼ��·�ߺ���Ϣ�ؾ���
heu=1./road_length;                 %Ϊ��������
pheromoneMatrix=ones(n,n);          %��Ϣ�ؾ���
path=zeros(N,n);   
iter=1;                             %��������
path_best=zeros(max_iter,n);        %�����е����·��
length_best=inf.*ones(max_iter,1);  %�����е����·�ߵĳ���
length_mean=zeros(max_iter,1);      %�����е�·�ߵ�ƽ������

%% ����ѭ����ֹͣ�������ﵽ���ĵ�������
dots = 0;
while iter<=max_iter        
    % ���������
    positionInit=[];
    for i=1:(ceil(N/n))
        positionInit = [positionInit,randperm(n)];
    end
    path(:,1)=(positionInit(1,1:N))';  
    
    % �������ѡ��Ŀ�ĵ�
    for j=2:n     
        for i=1:N
            visited=path(i,1:(j-1));  
            pos=zeros(1,(n-j+1));
            P=pos;
            pass_cities=1;
            for k=1:n
                if isempty(find(visited==k, 1))
                    pos(pass_cities)=k;
                    pass_cities=pass_cities+1;
                end
            end
            for k=1:length(pos)
                P(k)=(pheromoneMatrix(visited(end),pos(k))^alpha)*(heu(visited(end),pos(k))^beta);
            end
            P=P/(sum(P));
            Psum=cumsum(P);
            Select=find(Psum>=rand);
            to_visit=pos(Select(1));
            path(i,j)=to_visit;
        end
    end
    if iter>=2
        path(1,:)=path_best(iter-1,:);
    end
    
    % ��ʼ���ܾ������
    L=zeros(N,1);
    for i=1:N
        P=path(i,:);
        for j=1:(n-1)
            % �����ۺ�
            L(i)=L(i)+road_length(P(j),P(j+1));
        end
        % �ܾ���
        L(i)=L(i)+road_length(P(1),P(n));
    end
    length_best(iter)=min(L);
    pos=find(L==length_best(iter));
    path_best(iter,:)=path(pos(1),:);
    length_mean(iter)=mean(L);
    delta_pheromone=zeros(n,n);
    fprintf('.');
    dots = dots + 1;
    for i=1:N
        for j=1:(n-1)
            delta_pheromone(path(i,j),path(i,j+1))=delta_pheromone(path(i,j),path(i,j+1))+Q/L(i);
        end
        
        delta_pheromone(path(i,n),path(i,1))=delta_pheromone(path(i,n),path(i,1))+Q/L(i);
    end
    % ��Ϣ�ظ���
    pheromoneMatrix=(1-rho).*pheromoneMatrix+delta_pheromone;
    path=zeros(N,n);
    
    iter = iter+1;
    if dots>78
        dots = 0;
        fprintf('\n');
    end
end
fprintf('Done!\n');
%% ����·��
Pos=find(length_best==min(length_best)); 
Shortest_Route=path_best(Pos(1),:);
Shortest_Length=length_best(Pos(1));

%% ����չʾ
disp('����·��Ϊ');
Shortest_Route = Shortest_Route(1:end,:)-1;
for i=1:length(Shortest_Route)
    if flag==1 && Shortest_Route(i)==0 
            fprintf('��������');
            if i~=length(Shortest_Route)
                fprintf('->');
            else
                fprintf('\n');
            end
    else
        fprintf('վ��%d',Shortest_Route(i));
        if i~=length(Shortest_Route)
            fprintf('->');
        else
            fprintf('\n');
        end
    end
end
fprintf('����Ϊ %d/m\n',Shortest_Length);


%% ���ӻ�
figure(1);
plot(length_best,'k');
xlabel('��������');
ylabel('Ŀ�꺯��ֵ');
title('��Ӧ�ȵĽ�������');


figure(2)
N=length(P);
scatter(Data(:,1),Data(:,2),'r');
if flag==1
    for i = 1:length(Data)
        if i==1 
            text(Data(i,1),Data(i,2),'(��������)');
        else
            text(Data(i,1),Data(i,2),['(վ��' num2str(i-1) ')']);
        end
    end
else
    for i = 1:length(Data)
        text(Data(i,1),Data(i,2),['(վ��' num2str(i) ')']);
    end
end
 hold on
 plot([Data(P(1),1),Data(P(N),1)],[Data(P(1),2),Data(P(N),2)],'k:')
 hold on
 
 answer = path_best(end,:);
 % ��ͼ�ǵ�ȥ����������
for i=1:N
    j=i+1;
    if(i+1>N)
        j=1;
    end
    plot([Data(answer(i),1),Data(answer(j),1)],[Data(answer(i),2),Data(answer(j),2)],'k:')
end
save best_route.mat path_best;
hold on
xlabel('����');
ylabel('γ��');
title('����·�߹滮 ')
grid on
figure(3)
plot(length_best,'b')
hold on                         %����ͼ��
plot(length_mean,'k')
title('ƽ���������̾���')     %����
save length_mean.mat length_mean;
save length_best.mat length_best;
