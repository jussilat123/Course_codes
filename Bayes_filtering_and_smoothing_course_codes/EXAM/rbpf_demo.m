function rbpf_demo % Random-Walk-with-Clutter problem

% problem parameters
nk=100;             % number of time steps
up=[0.9,0.1];       % up(i) = Prob(u=i-1)
x0=0;               % initial value of state
A=1; Q=1;           % x_{k+1} ~ N(A*x_k,Q)
H={1,0};R={1,100};  % y_k ~ N(H{u_k+1}*x_k,R{u_k+1})
m0=0; P0=0;         % x_0 ~ N(m0,P0)

% generate data and plot it
rng('default'); rng(0)
X=zeros(length(x0),nk); Y=zeros(1,nk); U=zeros(1,nk); % preallocate
x=x0;
for k=1:nk
    u=rand<up(2);    % sample from {0,1} with prob [up(1),up(2)]
    x=mvnrnd((A*x)',Q)';
    Y(k)=mvnrnd(H{u+1}*x,R{u+1});
    X(:,k)=x; U(k)=u;
end
figure(1), subplot(211)
kk=1:nk; Uis1=find(U==1); nUis1=length(Uis1);
plot(kk(Uis1),repmat(-25,1,nUis1),'go',...
    0:nk,[x0(1),X(1,:)],'r',1:nk,Y,'b','linewidth',2)
axis([0 nk -30 30])
legend('u_k=1','x_k','y_k')

%% Particle filter
N=100;  % number of particles
nx=length(x0);
Mpf=zeros(nx,nk); w=zeros(1,N); % preallocate
xu=[mvnrnd(repmat(m0,1,N)',P0)'
    rand(1,N)<up(2)           ];
for k=1:nk
    % propagate particles
    u=rand(1,N)<up(2);
    xu(end,:)=u;
    for i=1:N
        xu(1:nx,i)=mvnrnd((A*xu(1:nx,i))',Q)';
    end
    % compute weights
    for i=1:N
        w(i)=normpdf(Y(k),(H{u(i)+1}*xu(1:nx,i))',sqrt(R{u(i)+1}))';
    end
    J=resamp(w/sum(w)); xu=xu(:,J);
    % posterior mean
    Mpf(:,k)=mean(xu(1:nx,:),2);
end
RMSEpf=sqrt(mean((X(1,:)-Mpf(1,:)).^2,2))

%% RB-Particle filter
Mrbpf=zeros(nx,nk);   % preallocate
m=repmat(m0,1,N);
P=zeros(nx,nx,N); for i=1:N, P(:,:,i)=P0; end
for k=1:nk
    u=rand(1,N)<up(2);
    for i=1:N
        [m(:,i),P(:,:,i)]=kf_predict(m(:,i),P(:,:,i),A,Q);
        RR=H{u(i)+1}*P(:,:,i)*H{u(i)+1}'+R{u(i)+1};
        w(i)=normpdf(Y(k),(H{u(i)+1}*m(:,i))',sqrt(RR));
    end
    J=resamp(w/sum(w)); u=u(J); m=m(:,J); P=P(:,:,J);
    for i=1:N
        [m(:,i),P(:,:,i)]=kf_update(m(:,i),P(:,:,i),Y(k),H{u(i)+1},R{u(i)+1});
    end
    Mrbpf(:,k)=mean(m,2);
end
RMSErbpf=sqrt(mean((X(1,:)-Mrbpf(1,:)).^2,2))

subplot(212)
plot(1:nk,X(1,:)-Mpf(1,:),'r',1:nk,X(1,:)-Mrbpf(1,:),'b','linewidth',2)
legend('PF error','RBPF error')

end  % of function

function J=resamp(W)
[~,J]=histc(rand(length(W),1),[0;cumsum(W(:))]);
end

function [m,P] = kf_update(m,P,y,H,R)
v = y-H*m;
S = H*P*H'+R;
K = P*H'/S;    
m = m+K*v;
P = P-K*S*K';
end

function [m,P] = kf_predict(m,P,A,Q)
m = A*m;
P = A*P*A'+Q;
end