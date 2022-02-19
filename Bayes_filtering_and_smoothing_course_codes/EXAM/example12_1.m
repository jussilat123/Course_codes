function example12_1
% example 12.1, estimation of noise covariance for Gaussian random walk

%% generate the data
rng('default'); rng(0);
nk=100;
x0=0; Q=1; R=1;
X=zeros(1,nk);Y=zeros(1,nk);
x=x0;
for k=1:nk
    x=x+sqrt(Q)*randn; X(k)=x;
    Y(k)=x+sqrt(R)*randn;
end
figure(1)
subplot(211)
plot(0:nk,[x0,X],'r-',1:nk,Y,'k.')
phiT=@(theta) phi(theta,Y);

%% Maximum A-posteriori (MAP) estimate using optimisation
R_MAP=fminsearch(phiT,0.5)   % incorrect initial guess
R_MAP1=fminunc(phiT,0.5)
R_MAP2=fminbnd(phiT,0.1,10)

%% Robust Adaptive Metropolis algorithm
N=1000;                              % number of samples
Nburnin=100;                         % how many initial samples to discard
theta_prev=1;                        % initialise the sample path
Sigma=0.5*eye(length(theta_prev));   % variance of Metropolis step
gamma=0.75; alpha_target=0.234;      % RAM adaptation parameters
accept_count=0;                      % initialise the counter
theta=zeros(length(theta_prev),N);   % preallocation
phi_prev=phiT(theta_prev);
S=chol(Sigma,'lower');
for i=1:N
    r=randn(size(x0));
    theta_prop=theta_prev+S*r;       % proposed sample
    phi_prop=phiT(theta_prop);
    alpha=min(1,exp(phi_prev-phi_prop));
    if alpha>=rand                   % accept proposal
        accept_count=accept_count+1;
        theta(:,i)=theta_prop;
        theta_prev=theta_prop;
        phi_prev=phi_prop;
    else
        theta(:,i)=theta_prev;
    end
    if i>Nburnin                    % adjust the step covariance
        eta=1/(i-Nburnin)^gamma;
        u=r/norm(r);
        SS=S*(eye(size(S))+eta*(alpha-alpha_target)*(u*u'))*S';
        S=chol(SS,'lower');
    end
end
mMCMC=mean(theta(:,Nburnin:end),2)
Pmcmc=cov(theta(:,Nburnin:end)')
accept_rate=accept_count/N

subplot(223)
plot(1:N,theta,'.','markersize',1)

%% Plot the posterior pdf

subplot(224)
[Rpdf,Rvals]=ksdensity(theta);  % convert RAM histogram to pdf
pp=zeros(size(Rvals));
for iR=1:length(Rvals)
    pp(iR)=exp(-phiT(Rvals(iR)));
end
pp=pp/sum(pp)/diff(Rvals(1:2));   % normalise
plot(Rvals,pp,'--',Rvals,Rpdf,'linewidth',2);
legend('true','RAM')

%% EM algorithm
N_EM=20;           % number of EM iterations
theta_EM=0.5;      % starting guess for R
A=1; H=1; Q=1;     % known model values
theta_EM_iterands=repmat(theta_EM,1,N_EM+1);   % preallocate 
for i=1:N_EM
    [Sigma,Phi,B,C,D]=EMQ_params(theta_EM,Y);
    theta_EM(1)=D-H*B'-B*H'+H*Sigma*H';
    theta_EM_iterands(:,i+1)=theta_EM;
end
theta_EM

figure(2)
subplot(221)
plot(0:N_EM,theta_EM_iterands(1,:),'-o')
axis([0 N_EM 0 1.1])
xlabel('EM iteration'), ylabel('R','rot',0,'horiz','r')

end

function val=phi(theta,Y)
if theta<=0, val=inf; return, end  % because R must be positive
A=1; Q=1; H=1; R=theta; m=0; P=0;
val=0;  % flat prior; any constant will do
for k=1:size(Y,2)
    m=A*m; P=A*P*A'+Q;  % KF prediction
    v=Y(:,k)-H*m; S=H*P*H'+R;
    val=val+0.5*v'/S*v+sum(log(diag(chol(2*pi*S))));
    K=P*H'/S; m=m+K*v; P=P-K*S*K';  % KF update
end
end

function [Sigma,Phi,B,C,D]=EMQ_params(theta,Y)
A=1; Q=1; H=1; R=theta; m0=0; P0=0;
nk=size(Y,2);
kf_m=zeros(1,nk); kf_P=zeros(1,1,nk); % preallocate
m=m0; P=P0;
for k=1:nk % Kalman filter
    kf_m(:,k)=m; kf_P(:,:,k)=P;  % save m & P at time k-1
    m=A*m; P=A*P*A'+Q;
    S=H*P*H'+R;
    K=P*H'/S;
    m=m+K*(Y(:,k)-H*m);
    P=P-K*S*K';
end
Sigma=P+m*m'; Phi=zeros(size(P)); C=zeros(size(P));
B=zeros(size(R)); D=zeros(size(R));
for k=nk-1:-1:0    % RTS smoother
    mp=A*kf_m(:,k+1);
    Pp=A*kf_P(:,:,k+1)*A'+Q;
    G=kf_P(:,:,k+1)*A'/Pp;
    mm=m; PP=P; 
    m=kf_m(:,k+1)+G*(m-mp);
    P=kf_P(:,:,k+1)+G*(P-Pp)*G';
    Phi=Phi+P+m*m';
    B=B+Y(:,k+1)*mm';
    C=C+PP*G'+mm*m';
    D=D+Y(:,k+1)*Y(:,k+1)';
    if k>0, Sigma=Sigma+P+m*m'; end
end
Sigma=Sigma/nk; Phi=Phi/nk; B=B/nk; C=C/nk; D=D/nk;
end



