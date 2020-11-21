function Shortest_Length = ant2(Data)
clc;
%% ��ʼ������
N=50;                   %% m ���ϸ���
alpha=1;                %% ��Ϣ����Ҫ�̶�
beta=5;                 %% ����ʽ������Ҫ�̶�
rho=0.1;                %% ��Ϣ������ϵ��
max_iter=200;           %%����������
Q=100;                  %%��Ϣ����ǿϵ��
n=size(Data,1);
road_length=zeros(n,n); %D��ʾ��ȫͼ�ĸ�Ȩ�ڽӾ���

for i=1:n
    for j=1:n
        if i~=j
            road_length(i,j)=Distance(Data(i,1),Data(i,2),Data(j,1),Data(j,2));
        else
            road_length(i,j)=eps;
        end
        road_length(j,i)=road_length(i,j);   
    end
end

%% ��ʼ��·�ߺ���Ϣ�ؾ���
heu=1./road_length;         
pheromoneMatrix=ones(n,n);    
path=zeros(N,n);   
iter=1;               
path_best=zeros(max_iter,n);      
length_best=inf.*ones(max_iter,1);   
length_mean=zeros(max_iter,1);       

%% ����ѭ����ֹͣ�������ﵽ���ĵ�������
dots = 0;
while iter<=max_iter        
    positionInit=[];
    for i=1:(ceil(N/n))
        positionInit = [positionInit,randperm(n)];
    end
    path(:,1)=(positionInit(1,1:N))';  
    
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
    
    L=zeros(N,1);
    for i=1:N
        R=path(i,:);
        for j=1:(n-1)
            L(i)=L(i)+road_length(R(j),R(j+1));
        end
        L(i)=L(i)+road_length(R(1),R(n));
    end
    length_best(iter)=min(L);
    pos=find(L==length_best(iter));
    path_best(iter,:)=path(pos(1),:);
    length_mean(iter)=mean(L);
    delta_pheromone=zeros(n,n);
    for i=1:N
        for j=1:(n-1)
            delta_pheromone(path(i,j),path(i,j+1))=delta_pheromone(path(i,j),path(i,j+1))+Q/L(i);
        end
        
        delta_pheromone(path(i,n),path(i,1))=delta_pheromone(path(i,n),path(i,1))+Q/L(i);
    end
    pheromoneMatrix=(1-rho).*pheromoneMatrix+delta_pheromone;
    path=zeros(N,n);
    
    iter = iter+1;
end
fprintf('Done!shortest=');
%% ����·��
Pos=find(length_best==min(length_best)); 
Shortest_Length=length_best(Pos(1));