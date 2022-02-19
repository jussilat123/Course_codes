%% generate data

figure; set(gcf,'position',[0 0 1000 300])
rng('default'); 
seeds=[144 7 32 12 43 42 11 5 90 86 21 40 95 344 4000 123];
for ir=1:length(seeds)
   rng(seeds(ir));
   DT=0.1; nk=100; Qc=1; r=0.1; x0=[4;0];
   T=(1:nk)*DT; X=zeros(1,nk); Y=zeros(1,nk);
   Ak=[1,DT;0,1]; Qk=Qc*[DT^3/3,DT^2/2;DT^2/2,DT];
   x=x0;
   for k=1:nk
      x=mvnrnd(Ak*x,Qk)'; X(k)=x(1);
      Y(k)=norm([0.5-x(1);0.1])+sqrt(r)*randn;
   end
   m0=[4;0];    
   P0=0.01*eye(2);
   GA={@GaussApproxUKF,@GaussApproxGHKF};
   M=zeros(2,nk);
   for jf=1:2   % loop for different filters
       m=m0; P=P0;
       for k=1:nk   % filter
           [m,P]=gf_predict(m,P,@tracking_f,Qk,GA{jf});
           [m,P]=gf_update(m,P,Y(k),@tracking_h,r,GA{jf});
           M(jf,k)=m(1);
       end
   end
   subplot(4,4,ir)
   plot(T,X,'r-',T,M(1,:),'b-',T,M(2,:),'k-')
   axis([0 T(end) -25 25]), box off,  xlabel('k')
   legend('true','UKF','GHKF','location','SW','FontSize',2)
end

% seems that all 16 generations diverged into correct result. Based on this
% experimentation I would say that UKF and GHKF are more prone to diverge
% than EKF and EKF2.

%% functions

function [mu,S,C,X]=GaussApproxUKF(m,P,g,E)
nx=length(m);
alpha=1; beta=0; kappa=max(3-nx,1);
lambda=alpha^2*(nx+kappa)-nx;
WM=repmat(0.5/(nx+lambda),2*nx+1,1);
WM(1)=lambda/(nx+lambda);
WC=WM; WC(1)=lambda/(nx+lambda)+1-alpha^2+beta;
A=schol(P); % from EKFUKF toolbox
X=[m repmat(m,1,2*nx)+sqrt(lambda+nx)*[A -A]];
Y=g(X); % g must be vectorised
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

function [mu,S,C,X]=GaussApproxGHKF(m,P,g,E)
W1=[8/15,0.011257411327721*[1,1],0.222075922005612*[1,1]];
xi1=[0,2.856970013872804*[-1,1],1.355626179974266*[-1,1]];
n=length(m); p=length(xi1);
num=0:(p^n-1); ind=zeros(n,p^n);
for i=1:n, ind(i,:)=rem(num,p)+1; num=floor(num/p); end
XI=xi1(ind); W=prod(W1(ind),1);
X=repmat(m,1,p^n)+schol(P)*XI;
Y=g(X); ny=size(Y,1);
mu=zeros(ny,1); S=E; C=zeros(n,ny);
for i=1:length(W), mu=mu+W(i)*Y(:,i); end
for i=1:length(W)
 S=S+W(i)*(Y(:,i)-mu)*(Y(:,i) - mu)';
 C=C+W(i)*(X(:,i)-m)*(Y(:,i) - mu)';
end
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

function [fval,Fx,Fxx]=tracking_f(x)
DT = 0.1;
Fx = [1 DT; 0 1];
fval = Fx*x;
Fxx{1} = zeros(2,2);
Fxx{2} = zeros(2,2);
end

function [hval,Hx,Hxx]=tracking_h(x)
    
hval = zeros(1,length(x));
size = length(x);
for x_index = 1:size
    hval(x_index) = norm([0.5-x(1,x_index);0.1]);
end
% not using => not needed
Hx = 0;
Hxx{1} = 0; 
end

