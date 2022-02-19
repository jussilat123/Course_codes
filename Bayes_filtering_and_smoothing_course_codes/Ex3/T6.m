dt=1; t_end=100;               % time step and time span
sd=10;                         % measurement std dev
%omega=pi;                       % sinusoid radian frequency 

t=1:dt:t_end; nt=length(t);     % time values
%X=sin(omega*t);                 % sine signal
%Y=X(2:end)+sd*randn(1,nt-1);    % noisy signal
rng(42)                         % random number generator seed

% Plot some discrete-random-walk-velocity (DRWV) process paths
q=1;                           % random-walk step variance
m0=[0;0]; P0=diag([1,1]);       % state prior mean and covariance
A=[1 dt;0 1]; Q=diag([0,q*dt]); % process model
n=length(m0);                   % state dimension
npath=10;
figure(1), clf
for ipath=1:npath
    x=zeros(n,nt);
    x(:,1)= mvnrnd(m0,P0)';
    y(:,1) = x(1,1);
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

%% task 5 estimate u_k based on y_k

% Use the DRWV model to filter the noisy signal
Y = y;
PP = zeros(size(P0,1),size(P0,1),length(y));
H=[1 0]; R=sd^2;         % measurement model
M=m0; P=P0;              % state prior mean and covariance
m=zeros(1,nt);
m(1)=M(1); 
for k=2:nt
    [M,P]=kf_predict(M,P,A,Q);
    [M,P]=kf_update(M,P,Y(k-1),H,R);
    m(k)=M(1);
    PP(:,:,k) = P;
end

%%
var_y = zeros(100,1);
for i = 1:100
    var_y(i) = PP(1,1,i);
end

%variances
figure
plot(t,var_y,'b-')
legend('Variances')

CT95 = 1.96*sqrt(var_y(17))
% 11.7699