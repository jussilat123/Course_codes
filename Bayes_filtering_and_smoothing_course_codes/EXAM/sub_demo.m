function sub_demo
% target moving in a plane with range and terrain measurement
%% Define simulation parameters
rng('default'); rng(0);
DT=0.01; nk=200; Qc=1; r=diag([.1,0.1]); x0=[0;0;0;0];

%% Generate the track and the measurements
T=(1:nk)*DT; X=zeros(2,nk); Y=zeros(2,nk);
Ak=kron([1,DT;0,1],eye(2));                     % like in car_demo
Qk=Qc*kron([DT^3/3,DT^2/2;DT^2/2,DT],eye(2));   % like in car_demo
x=x0;
for k=1:nk
    x=mvnrnd(Ak*x,Qk)'; X(:,k)=x(1:2);
    Y(:,k)=mvnrnd(h(x)',r)';
end

%% Define particle filter parameters
m0=zeros(4,1);
P0=diag([.1,.1,.01,.01]);
Qv=Qc*DT*eye(2); U=Qc*DT^3/3*eye(2); Q=blkdiag(U,Qv);  % differs from Qk
R=r;
N=10000;  % number of particles
nbs=4;    % number of backward simulations

%% Particle filter
nx=length(m0);
Mpf=zeros(2,nk); xpf=zeros(nx,N,nk+1);      % preallocation
xx=mvnrnd(repmat(m0,1,N)',P0)';  % filter distribution at time 0
xpf(:,:,1)=xx;
for k=1:nk
    xx=mvnrnd(f(xx)',Q)';
    w=mvnpdf(repmat(Y(:,k),1,N)',h(xx)',R)';
    w=w/sum(w);
    xx=xx(:,resamp(w));
    xpf(:,:,k+1)=xx;             % filter distribution at time k
    Mpf(:,k)=mean(xx(1:2,:),2);
end
rmse=sqrt(mean((X(1,:)-Mpf(1,:)).^2+(X(2,:)-Mpf(2,:)).^2));
disp(['PF RMS error is ' num2str(rmse)])


%% fixed-interval backward-simulation particle smoother
Mps=zeros(2,nk+1);            % preallocate
xs=xpf(:,randi(N,1,nbs),nk+1);
Mps(:,end)=mean(xpf(1:2,:,end),2);
for k=nk:-1:1
    for j=1:nbs
        w=mvnpdf(repmat(xs(:,j),1,N)',f(xpf(:,:,k))',Q)';
        w=w/sum(w);
        [~,J]=histc(rand,[0;cumsum(w(:))]); % a sample from 1:N
        xs(:,j)=xpf(:,J,k);
    end
    Mps(:,k)=mean(xs(1:2,:),2);
end

rmse=sqrt(mean(([x0(1) X(1,:)]-Mps(1,:)).^2+([x0(2) X(2,:)]-Mps(2,:)).^2));
disp(['PS RMS error is ' num2str(rmse)])


%% Plot the results for PF and smoother
figure(1)
plot(1,1,'^',[x0(1),X(1,:)],[x0(2),X(2,:)],'r-',...
    [m0(1),Mpf(1,:)],[m0(1),Mpf(2,:)],'k-',...
    Mps(1,:),Mps(2,:),'b-',...
    'linewidth',2);
axis equal
xlabel('x_1','fontsize',18),ylabel('x_2','rot',0,'fontsize',18)
legend('beacon','true','PF','PS','location','SE')

%% Rao-Blackwellised particle filter (version with H=0)

F=DT*eye(2); frb=@(u) u; Arb=eye(2); 
Nrb=500;
Mrb=nan(2,nk);  % preallocation
u=mvnrnd(repmat(m0(1:2),1,Nrb)',P0(1:2,1:2))'; 
mrb=repmat(m0(3:4),1,Nrb);
Prb=P0(3:4,3:4);    % covariance evolves the same for all particles
w=ones(Nrb,1);
for k=1:nk
    d=mvnrnd((F*mrb)',F*Prb*F'+U)';
    u=frb(u)+d;
    [mrb,Prb]=kf_update(mrb,Prb,d,F,U);    % vectorized in mrb and d
    [mrb,Prb]=kf_predict(mrb,Prb,Arb,Qv);
    w=mvnpdf(Y(:,k)',h(u)',R)';
    w=w/sum(w);
    J=resamp(w); u=u(:,J); mrb=mrb(:,J);
    Mrb(:,k)=mean(u,2);
end
rmse_rb=sqrt(mean((X(1,:)-Mrb(1,:)).^2+(X(2,:)-Mrb(2,:)).^2));
disp(['RBPF RMS error is ' num2str(rmse_rb)])


%% Plot the results for PF and RBPF
figure(2)
plot(1,1,'^',[x0(1),X(1,:)],[x0(2),X(2,:)],'r-',...
    [m0(1),Mpf(1,:)],[m0(1),Mpf(2,:)],'k-',...
    [m0(1),Mrb(1,:)],[m0(2),Mrb(2,:)],'b-',...
    'linewidth',2);
axis equal
xlabel('x_1','fontsize',18),ylabel('x_2','rot',0,'fontsize',18)
legend('beacon','true','PF','RBPF','location','SE')


end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function fval=f(x)
DT=0.02;
Ak=kron([1,DT;0,1],eye(2));
fval=Ak*x;
end

function hval=h(X)
x=X(1,:); y=X(2,:);
bx=1; by=1;                       % beacon coordinates
hval=[10+peaks(x,y)               % seafloor depth
    sqrt((x-bx).^2+(y-by).^2)];   % distance to beacon
end

function J=resamp(W)
[~,J]=histc(rand(length(W),1),[0;cumsum(W(:))]);
end

function [m,P] = kf_update(m,P,y,H,R)
v = y-H*m;
S = H*P*H'+R;
K = P*H'/S;     % /S is mathematically same as *inv(S) but faster & more accurate
m = m+K*v;
P = P-K*S*K';
end

function [m,P] = kf_predict(m,P,A,Q)
m = A*m;
P = A*P*A'+Q;
end


