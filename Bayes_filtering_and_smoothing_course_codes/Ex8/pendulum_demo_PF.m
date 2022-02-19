function pendulum_demo_PF
% Simulation and estimation of nonlinear pendulum model
% There are some differences from the textbook model (Examples 5.3,7.1,7.2):
%   1. The process noise covariance is [0,0;0,qc*Dt],
%      because I discretise the SDE using the Euler-Maruyama method.
%   2. Measurements are not made at every time step
%   3. Clutter model is a Gaussian mixture

%% Define simulation parameters

g=9.81;        % gravity acceleration constant
qc=1;          % power spectral density of white noise excitation
r=0.1;         % measurement variance
x0=[1.5;0];    % initial state (radian angle and angular velocity)
DT=0.01;       % time step size
nk=500;        % number of steps
mskip=5;       % number of time steps per measurement
noise={ makedist('Normal','sigma',sqrt(r))
    gmdistribution([0;0],cat(3,r,16/3),[0.5,0.5])};

simTitle={'Gaussian noise','Gaussian-mixture noise'};

%% Simulations with different measurement noise
for isim=1:length(noise)
    disp(['Simulation ',num2str(isim)])
    rng('default'); rng(0)      % random number generator's starting value
    
    %% Track
    T=(1:nk)*DT;   % timestamps
    X=zeros(2,nk); % preallocate
    x=x0;
    for k=1:nk
        x=x+DT*[x(2);-g*sin(x(1))]+[0;sqrt(qc*DT)*randn];
        X(:,k)=x;
    end
    
    %% Measurements
    Y=NaN(1,nk);   % preallocate using not-a-number
    for k=1:mskip:nk
        Y(k)=sin(X(1,k))+random(noise{isim});
    end
    
    %% Filter parameters
    m0 = [1.6;0];       % slightly off from x0
    P0 = 0.1*eye(2);
    Q=qc*[DT^3/3 0;0 DT];   % slightly off, nonsingular for PS
    if isim==2
        % variance of univariate gaussian mixture with zero-mean components
        R=(noise{isim}.PComponents)*(squeeze(noise{isim}.Sigma).^2);
    else
        R=var(noise{isim});
    end
    N=1000;              % number of particles
    nbs=4;              % number of PS backward simulations
    M=zeros(3,nk);      % preallocate the array of estimated angles
    
    %%  UKF
    m=m0; P=P0;
    for k=1:nk
        [m,P]=gf_predict(m,P,@pendulum_f,Q,@GaussApproxUKF);
        if ~isnan(Y(k))
            [m,P]=gf_update(m,P,Y(k),@pendulum_h,R,@GaussApproxUKF);
        end
        M(1,k)=m(1);
    end
    rmse=sqrt(mean((X(1,:)-M(1,:)).^2));
    disp(['RMS error for UKF is ' num2str(rmse)])
    
    %% Particle filter
    xx=mvnrnd(repmat(m0,1,N)',P0)';
    xpf=zeros(length(m0),N,nk+1); xpf(:,:,1)=xx;
    for k=1:nk
        xx=mvnrnd(pendulum_f(xx)',Q)';
        if ~isnan(Y(k))
            w=pdf(noise{isim},(repmat(Y(k),1,N)-pendulum_h(xx))')';
            w=w/sum(w);
            xx=xx(:,resamp(w));
        end
        xpf(:,:,k+1)=xx;
        M(2,k)=mean(xx(1,:));
    end
    rmse=sqrt(mean((X(1,:)-M(2,:)).^2));
    disp(['RMS error for PF  is ',num2str(rmse)])
    
    %% Backward-simulation particle smoother
    xs=xpf(:,randi(N,1,nbs),nk+1);
    for k=nk:-1:1
        for j=1:nbs
            w=mvnpdf(repmat(xs(:,j),1,N)',pendulum_f(xpf(:,:,k))',Q)';
            w=w/sum(w);
            [~,J]=histc(rand,[0;cumsum(w(:))]); % a sample from 1:N
            xs(:,j)=xpf(:,J,k);
        end
        M(3,k)=mean(xs(1,:),2);
    end
    rmse=sqrt(mean(([x0(1) X(1,:)]-[M(3,:) M(2,end)]).^2));
    disp(['RMS error for PS  is ',num2str(rmse)])
   
    
    %% Plot the results
    figure(isim),clf
    plot(T,Y,'b.', ...
        [0,T],[x0(1),X(1,:)],'r-',...
        [0,T],[m0(1),M(1,:)],'k-',...
        [0,T],[m0(1),M(2,:)],'b-',...
        [0,T],[ M(2,end) M(3,:) ],'c-',...
        'linewidth',2,'markersize',16);
    
    title(simTitle{isim})
    
    axis([0 5 -3 3])
    xlabel('Time')
    ylabel({'angle';'(rad)'},'rot',0)
    legend('data','true','UKF','PF','PS','location','SW')
    
    
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function fval=pendulum_f(x)
DT=0.01; g=9.81;
fval=x+DT*[ x(2,:)
    -g*sin(x(1,:))];
end

function hval=pendulum_h(x)
hval=sin(x(1,:));
end

function [m,P]=gf_update(m,P,y,h,R,GaussApprox)
if ~isnan(y)
    [mu,S,C]=GaussApprox(m,P,h,R);
    K=C/S;
    P=P-K*S*K';
    m=m+K*(y-mu);
end
end

function [m,P]=gf_predict(m,P,f,Q,GaussApprox)
[m,P]=GaussApprox(m,P,f,Q);
end

function [mu,S,C,X]=GaussApproxUKF(m,P,g,E)
% compute the weights
nx=length(m); alpha=1; beta=0; kappa=max(3-nx,1);
lambda=alpha^2*(nx+kappa)-nx;
WM=repmat(0.5/(nx+lambda),2*nx+1,1);
WM(1)=lambda/(nx+lambda);
WC=WM; WC(1)=lambda/(nx+lambda)+1-alpha^2+beta;
% compute the sigma points and their images
A=chol(P,'lower');
X=[m repmat(m,1,2*nx)+sqrt(lambda+nx)*[A -A]];
Y=g(X);
% compute the Gaussian approximation
ny=size(Y,1);
mu=zeros(ny,1); S=E; C=zeros(nx,ny);
for i=1:length(WM)
    mu=mu+WM(i)*Y(:,i);
end
for i=1:length(WC)
    S=S+WC(i)*(Y(:,i)- mu)*(Y(:,i) - mu)';
    C=C+WC(i)*(X(:,i)-m)*(Y(:,i) - mu)';
end
end

function J=resamp(W)
[~,J]=histc(rand(length(W),1),[0;cumsum(W(:))]);
end