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
    dt=0.01; t=0:dt:2; nt=length(t); Qc = 1; 
    npath=5;
    Ak = [[1 (1-exp(-1*alpha*dt))/alpha];[0 exp(-1*alpha*dt)]];
    Q1 = (2*alpha*dt-3+4*exp(-1*alpha*dt)-exp(-2*alpha*dt))/(2*alpha.^3);
    Q2 = (1-2*exp(-1*alpha*dt)+exp(-2*alpha*dt))/(2*alpha.^2);
    Q3 = Q2;
    Q4 = (1-exp(-2*alpha*dt))/(2*alpha);
    Qk = Qc.*[[Q1 Q2];[Q3 Q4]];
    
    for i=1:npath
        x=[0;0];
        for k=2:nt
            x=mvnrnd(Ak*x,Qk)';
            u(i,k)=x(1);
        end
    end
    
    paths = u;
end