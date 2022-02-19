
dt=1; t_end=100;               % time step and time span
sd=0.1;                         % measurement std dev
omega=pi;                       % sinusoid radian frequency 

t=1:dt:t_end; nt=length(t);     % time values
rng(42)                         % random number generator seed

%% Plot some discrete-random-walk-velocity (DRWV) process paths
q=1;                           % random-walk step variance
m0=[0;0]; P0=diag([1,1]);       % state prior mean and covariance
A=[1 dt;0 1]; Q=diag([0,q*dt]); % process model
n=length(m0);                   % state dimension
npath=10;
figure(1), clf
for ipath=1:npath
    x=zeros(n,nt);
    
    %initial step
    x(:,1)= mvnrnd(m0,P0)';
    y(:,1) = x(1,1);
    
    %update next random walk steps
    for k=2:nt
        x(:,k)=A*x(:,k-1) +mvnrnd([0;0],Q)'; 
        y(:,k) = x(1,k) + normrnd(0,100);
    end
    subplot(311),plot(t,x(1,:)),hold on
    subplot(312),plot(t,x(2,:)),hold on
    subplot(313),plot(t,y(1,:)),hold on
end
subplot(311),ylabel('x_1','rot',0)
subplot(312),xlabel('t'),ylabel('x_2','rot',0)
subplot(313),xlabel('t'),ylabel('y','Rotation',0)