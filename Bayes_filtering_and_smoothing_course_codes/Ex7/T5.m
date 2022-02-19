
for n = 1:11
    m = zeros(n,1);
    P = eye(n);
    E = 0;
    [mu,S] = GaussApproxGHKF(m,P,@task5,E)
end

% n = 1 => mu = 1, S = 2
% n = 2 => mu = 2, S = 4
% n = 3 => mu = 3, S = 6
% n = 4 => mu = 4, S = 8
% n = 5 => mu = 5, S = 10

% so, this approach gives correct solution

%%
function [mu,S,C,X]=GaussApproxGHKF(m,P,g,E)
W1=[8/15,0.011257411327721*[1,1],0.222075922005612*[1,1]];
xi1=[0,2.856970013872804*[-1,1],1.355626179974266*[-1,1]];
n=length(m); p=length(xi1);
num=0:(p^n-1); ind=zeros(n,p^n);
for i=1:n
    ind(i,:)=rem(num,p)+1; 
    num=floor(num/p); 
end
XI=xi1(ind); W=prod(W1(ind),1);
X=repmat(m,1,p^n)+schol(P)*XI;
Y=g(X); ny=size(Y,1);
mu=zeros(ny,1); S=E; C=zeros(n,ny);
for i=1:length(W)
    mu=mu+W(i)*Y(:,i); 
end
for i=1:length(W)
 S=S+W(i)*(Y(:,i)-mu)*(Y(:,i) - mu)';
 C=C+W(i)*(X(:,i)-m)*(Y(:,i) - mu)';
end
end

function g = task5(x)
    sizes = size(x);
    g = zeros(1,sizes(2));
    for i = 1:sizes(2)
        g(i) = x(:,i)'*x(:,i);
    end
end