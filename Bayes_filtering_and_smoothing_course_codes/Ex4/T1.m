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
% Generate some simulated data
%
nx=size(A,1); ny=size(H,1);
nk=100;
X=zeros(nx,nk);
Y=zeros(ny,nk);
x=X0;
rng(33,'v5normal')   % use the legacy generator, to replicate Figures 4.5
for k=1:nk
    x=mvnrnd(A*x,Q)';
    y=mvnrnd(H*x,R)';
    X(:,k)=x;
    Y(:,k)=y;
end

%%
% Stationary Kalman filter
%
skf_m = zeros(nx,nk);
m=m0; P=P0;

for k=1:nk
    %stationary KF update step
    XX=dare(A',H',Q,R);
    S=H*XX*H'+R;
    K=XX*H'/S;
    P=XX-K*S*K';
    
    m = A*m;
    m = m + K*(Y(:,k)-H*m);
    
    skf_m(:,k)=m;
 end

%% Kalman filter
%
kf_m=zeros(nx,nk); 
m=m0; P=P0;
for k=1:nk
    % prediction step
    m = A*m;
    P = A*P*A'+Q;
    
    % update step
    v = Y(:,k)-H*m;
    S = H*P*H'+R;
    K = P*H'/S;     % /S is  same as *inv(S) but faster and more accurate
    m = m+K*v;
    P = P-K*S*K';

    kf_m(:,k)=m;
 end

%%
% Output

rmse_raw=sqrt(mean(sum((Y-X(1:2,:)).^2,1)))
%0.7680

rmse_kf=sqrt(mean(sum((kf_m(1:2,:)-X(1:2,:)).^2,1)))
%0.4254

rmse_skf=sqrt(mean(sum((skf_m(1:2,:)-X(1:2,:)).^2,1)))
%0.4248

figure(1), clf
plot(m0(1),m0(2),'ko',X(1,:),X(2,:),'k-',Y(1,:),Y(2,:),'b.',...
    kf_m(1,:),kf_m(2,:),'r-','linewidth',0.1,'markersize',12);
hold on
plot(skf_m(1,:), skf_m(2,:),'g-','linewidth',0.1)
legend('Start','True Trajectory','Measurements','KF','SKF');
xlabel('x_1'); ylabel('x_2','rot',0); axis equal