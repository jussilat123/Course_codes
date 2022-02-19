% linreg_mcmc
% Lecture 11 demo: fit a line using MCMC and gradient-free optimisation

%% generate the data
rng('default'); rng(12);
dt=0.01; t=(0:dt:1)'; sd=0.1;
x=1+0.5*t;                   % true signal, theta=[1;0.5]
y=x+sd*randn(size(x));       % generate the noisy data

%% compute parameters of exact Gaussian posterior
m0=[0;0]; P0=eye(2);   % prior mean and covariance
H =[ones(size(t)) t]; R=sd^2*eye(length(t));
disp('Exact solution')
PT=inv(inv(P0) + H'/R*H)
mT=PT*(H'*(R\y)+P0\m0)

%% Gradient-free optimisation
logmvnpdf=@(x,m,P) -0.5*(x-m)'/P*(x-m)-trace(log(chol(2*pi*P)));
phiT=@(th) -logmvnpdf(y,H*th,R)-logmvnpdf(th,m0,P0);
theta_MAP=fminsearch(phiT,[0;0]);


%% Metropolis algorithm
N=5000; 
Sigma=eye(2)*0.002; 
Nburnin=500;
theta=zeros(2,N);
accept_count=0;
theta_prev=mvnrnd(m0,P0)';
phi_prev=phiT(theta_prev);
for i=1:N
    theta_prop=mvnrnd(theta_prev,Sigma)';
    phi_prop=phiT(theta_prop);
    alpha=min(1,exp(phi_prev-phi_prop));
    if alpha>=rand
        accept_count=accept_count+1;
        theta(:,i)=theta_prop;
        theta_prev=theta_prop;
        phi_prev=phi_prop;
    else
        theta(:,i)=theta_prev;
    end
end
disp('Random-walk Metropolis')
mMCMC=mean(theta(:,Nburnin:end),2)
Pmcmc=cov(theta(:,Nburnin:end)')
accept_rate=accept_count/N

figure(1)
subplot(221)
plot(1:N,theta,'.','markersize',1)
axis([0 N 0 1.5])

subplot(223)
plot(theta(1,:),theta(2,:),'.','markersize',1)
axis([.9 1.1 0.4 0.6]), axis square

%% Robust Adaptive Metropolis algorithm
gamma=0.9; 
alpha_target=0.234;
theta=zeros(2,N);
accept_count=0;
theta_prev=mvnrnd(m0,P0)';
phi_prev=phiT(theta_prev);
S=chol(Sigma,'lower');
for i=1:N
    r=randn(size(m0));
    theta_prop=theta_prev+S*r;
    phi_prop=phiT(theta_prop);
    alpha=min(1,exp(phi_prev-phi_prop));
    if alpha>=rand
        accept_count=accept_count+1;
        theta(:,i)=theta_prop;
        theta_prev=theta_prop;
        phi_prev=phi_prop;
    else
        theta(:,i)=theta_prev;
    end
    if i>Nburnin
        eta=1/(i-Nburnin)^gamma;
        u=r/norm(r);
        SS=S*(eye(size(S))+eta*(alpha-alpha_target)*(u*u'))*S';
        S=chol(SS,'lower');
    end
end
disp('Robust Adaptive Random-walk Metropolis')
mMCMC=mean(theta(:,Nburnin:end),2)
Pmcmc=cov(theta(:,Nburnin:end)')
accept_rate=accept_count/N
subplot(222)
plot(1:N,theta,'.','markersize',1)
axis([0 N 0 1.5])
subplot(224)
plot(theta(1,:),theta(2,:),'.','markersize',1)
axis([.9 1.1 0.4 0.6]), axis square
