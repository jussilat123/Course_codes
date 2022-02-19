%CAR_DEMO Examples 4.3 and 8.2

%%
% Set the parameters
%
q=1;
dt=0.1;
s=0.5;
m0=[0;0;1;-1];
P0=eye(4);
A=kron([1,dt;0,1],eye(2));
Q=q*kron([dt^3/3,dt^2/2;dt^2/2,dt],eye(2));
H=kron([1,0],eye(2));
R=s^2*eye(2);
X0=m0;           % true initial state

%%
% Generate a track and measurements
%
nx=size(Q,1); ny=size(R,1);
nk=100;
X=zeros(nx,nk);
Y=zeros(ny,nk);
x=X0;
rng(33,'v5normal')   % use the legacy generator to replicate Figure 4.5
for k=1:nk
    x=mvnrnd(A*x,Q)';
    y=mvnrnd(H*x,R)';
    X(:,k)=x;
    Y(:,k)=y;
end

%%
% Kalman filter
%
kf_m=zeros(nx,nk); 
m=m0; P=P0;
for k=1:nk
    [m,P]=kf_predict(m,P,A,Q);
    [m,P]=kf_update(m,P,Y(:,k),H,R);
    kf_m(:,k)=m;
 end

%%
% RTS fixed-interval smoother
%
rts_m=zeros(nx,nk); 
rts_e=zeros(1,nk);
kf_e=zeros(1,nk);
kf_m=zeros(nx,nk);
kf_P=zeros(nx,nx,nk);
m=m0; P=P0;
for k=1:nk % forward pass, Kalman filter (same as above)
    [m,P]=kf_predict(m,P,A,Q);
    [m,P]=kf_update(m,P,Y(:,k),H,R);
    kf_m(:,k)=m;
    kf_P(:,:,k)=P;
    kf_e(k)=trace(P);
end
% backward pass
rts_m(:,end)=m; rts_e(end)=trace(P);
for k=nk-1:-1:1
    [mp,Pp]=kf_predict(kf_m(:,k),kf_P(:,:,k),A,Q);
    D=kf_P(:,:,k)*A';
    G=D/Pp;
    m=kf_m(:,k)+G*(m-mp);
    P=kf_P(:,:,k)+G*(P-Pp)*G'; 
    rts_m(:,k)=m;
    rts_e(k)=trace(P); 
end

%%
% Fixed-lag smoother
%
nlag=3;   % number of lags
fls_m=zeros(nx,nk-nlag+1);  % fls_m(:,k+1) = the mean of x_k | y_{1:k+nlag}
mStack=zeros(nx,nlag); mpStack=zeros(nx,nlag); Gstack=zeros(nx,nx,nlag);
m=m0; P=P0;
[mp,Pp]=kf_predict(m,P,A,Q); D=P*A';
mStack(:,1)=m; mpStack(:,1)=mp; Gstack(:,:,1)=D/Pp;
for k=1:nk
    [m,P]=kf_update(mp,Pp,Y(:,k),H,R);
    if k>=nlag  % process the stack with RTSS 
        mm=m;
        for j=1:nlag
            mm=mStack(:,j)+Gstack(:,:,j)*(mm-mpStack(:,j));
        end
        fls_m(:,k-nlag+1)=mm;
    end
    [mp,Pp]=kf_predict(m,P,A,Q); D=P*A'; 
    % update the stacks
    mStack(:,2:nlag)=mStack(:,1:nlag-1); mStack(:,1)=m;
    mpStack(:,2:nlag)=mpStack(:,1:nlag-1); mpStack(:,1)=mp;
    Gstack(:,:,2:nlag)=Gstack(:,:,1:nlag-1); Gstack(:,:,1)=D/Pp;
end

%%
% Output

rmse_raw=sqrt(mean(sum((Y-X(1:2,:)).^2,1)))
rmse_kf=sqrt(mean(sum((kf_m(1:2,:)-X(1:2,:)).^2,1)))
rmse_rts=sqrt(mean(sum((rts_m(1:2,:)-X(1:2,:)).^2,1)))
rmse_fls=sqrt(mean(sum((fls_m(1:2,:)-[X0(1:2) X(1:2,1:nk-nlag)]).^2,1)))

figure(1), clf
plot(m0(1),m0(2),'ko',X(1,:),X(2,:),'k-',Y(1,:),Y(2,:),'b.',...
    kf_m(1,:),kf_m(2,:),'r-','linewidth',2,'markersize',12);
legend('Start','True Trajectory','Measurements','KF');
xlabel('x_1'); ylabel('x_2','rot',0); axis equal


figure(2), clf
plot(m0(1),m0(2),'ko',X(1,:),X(2,:),'k-',Y(1,:),Y(2,:),'b.',...
    kf_m(1,:),kf_m(2,:),'r-',rts_m(1,:),rts_m(2,:),'b-',...
    'linewidth',2,'markersize',12);
legend('Start','True Trajectory','Measurements','KF','RTSS');
xlabel('x_1'); ylabel('x_2','rot',0); axis equal

figure(3), clf
subplot(221)
plot(1:nk,kf_e,'r-',1:nk,rts_e,'b-','linewidth',2);
legend('KF','RTSS');
xlabel('k'); ylabel('tr(P) ','rot',0); 


figure(4), clf
plot(m0(1),m0(2),'ko',X(1,:),X(2,:),'k-',Y(1,:),Y(2,:),'b.',...
    kf_m(1,:),kf_m(2,:),'r-',fls_m(1,:),fls_m(2,:),'b-',...
    'linewidth',2,'markersize',12);
legend('Start','True Trajectory','Measurements','Filter','Fixed-lag smoother');
xlabel('x_1'); ylabel('x_2','rot',0); axis equal
