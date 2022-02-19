%SINE_DEMO Kalman filtering of noisy sine signal

dt=0.02; t_end=2;               % time step and time span
sd=0.1;                         % measurement std dev
omega=pi;                       % sinusoid radian frequency 

t=0:dt:t_end; nt=length(t);     % time values
X=sin(omega*t);                 % sine signal
Y=X(2:end)+sd*randn(1,nt-1);    % noisy signal
rng(42)                         % random number generator seed

%% Plot some discrete-random-walk-velocity (DRWV) process paths
q=0.01;                           % random-walk step variance
m0=[0;0]; P0=diag([2,2]);       % state prior mean and covariance
A=[1 dt;0 1]; Q=diag([0,q*dt]); % process model
n=length(m0);                   % state dimension
npath=10;
figure(1), clf
for ipath=1:npath
    x=zeros(n,nt);
    x(:,1)=mvnrnd(m0,P0)';
    for k=2:nt,x(:,k)=A*x(:,k-1)+mvnrnd([0;0],Q)'; end
    subplot(221),plot(t,x(1,:)),hold on
    subplot(223),plot(t,x(2,:)),hold on
end
subplot(221),ylabel('x_1','rot',0)
subplot(223),xlabel('t'),ylabel('x_2','rot',0)

%% Use the DRWV model to filter the noisy signal
H=[1 0]; R=sd^2;         % measurement model
M=m0; P=P0;              % state prior mean and covariance
m=zeros(1,nt);
m(1)=M(1); 
for k=2:nt
    [M,P]=kf_predict(M,P,A,Q);
    [M,P]=kf_update(M,P,Y(k-1),H,R);
    m(k)=M(1);
end

subplot(222),plot(t,m,'r-',t,X,'k-',t(2:end),Y,'b.')
subplot(224),plot(t,m-X,'r-',t(2:end),Y-X(2:end),'b.')
ylabel('error','rot',0),xlabel('t')

%% answers and my analysis

% q = 1
% q = 10
% I found that velocity and position varies a lot more with q = 10 than q =
% 1. Also increasing to q = 100 makes bigger differences in velocity and
% position. In those cases filtering and estimation results didn't
% differ(in my opinion)

% for q = 0.01 and q = 0.1 estimation results got worse and error was
% bigger. With q = 10000 the estimation "follows" almost exactly
% measurement points, so this can't be good estimation.

% so q = 10 is best result in my opinion for this case. Too small q gives
% too little effect on simulation and too big q gives too much effect on
% simulation


