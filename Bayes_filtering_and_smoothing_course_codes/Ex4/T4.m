syms dt Qc positive
F=sym([0,1;0,0]);
L=sym([0;1]);
[A,Q]=lti_disc(F,L,Qc,dt)

%%

syms dt positive
F=sym(0);L=sym(1);Qc=sym(1);
[A,Q]=lti_disc(F,L,Qc,dt)

%%

alphas = [0.01 1 100 10000 1000000 100000000]
figure
for k = 1:length(alphas)
    [t,paths] = compute_paths(alphas(k));
    subplot(length(alphas),1,k)
    plot(t,paths)
    
    txt = ['alpha = ',num2str(alphas(k))];
    title(txt)
end

%we can see that when alpha grows, variance of paths gets smaller
function [t,paths] = compute_paths(alpha)
    dt=0.01; t=0:dt:2; nt=length(t); Qc = 1; Ak=1; 
    npath=5;
    x=zeros(npath,nt);
    Qk=Qc*(1-exp(-2*alpha*dt))/(2*alpha);
    for k=2:nt
        x(:,k)=Ak*x(:,k-1)+sqrt(Qk)*randn(npath,1);
    end
    paths = x;
end