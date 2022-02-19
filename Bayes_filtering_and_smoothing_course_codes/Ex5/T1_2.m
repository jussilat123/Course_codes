%% 


filter_errors = zeros(2000,100);
filter_errors_stationary = zeros(2000,100);
P_values_at_7 = zeros(1,2000);
P_values_at_7_stationary = zeros(1,2000);

for simulation = 1:2000
    
    
    
    %generating 100 step random walk
    nk=100;
    x0=0; Q=1; R=1;
    X=zeros(1,nk); Y=zeros(1,nk);
    x=x0;
    for k=1:nk
        x=x+sqrt(Q)*randn;
        X(k)=x;
        Y(k)=x+sqrt(R)*randn;
    end
    
    %filtering random walk
    M=zeros(1,nk); CI=zeros(2,nk);
    m=x0; P=0;
    
    for k=1:nk
        P=P+Q;
        m=m+P*(Y(k)-m)/(P+R); 
        M(k)=m;
        P=P-P^2/(P+R);
        if(k == 7)
            P_values_at_7(simulation) = P;
        end
        %CI(:,k)=m+1.96*sqrt(P)*[1;-1];
    end
    
    filter_errors(simulation,:) = X-M;
    
    %stationary kalman filtering for random walk
    M=zeros(1,nk); CI=zeros(2,nk);
    m=x0; P=0;
    
    K = (Q/R + sqrt((Q/R)^2+4*Q/R))/(2 + Q/R + sqrt((Q/R)^2+4*Q/R));
    
    for k = 1:nk
        
        m = m + K*(Y(k)-m);
        M(k) = m;
    end
    filter_errors_stationary(simulation,:) = X-M;
end


%plot(0:nk,[x0,X],'r-',1:nk,Y,'k.')
%%

covariances = cov(filter_errors);
task1_result = covariances(7,7)
task1_P7 = mean(P_values_at_7)
tas1_var_of_P7 = var(P_values_at_7)

covariances_stationary = cov(filter_errors_stationary);
task2_result = covariances_stationary(7,7)
mean(P_values_at_7_stationary)
var(P_values_at_7_stationary)

%% 
% nk Q R x0 Y from slide 4





rng(0);

nk=100;
x0=0; Q=1; R=1;
X=zeros(1,nk); Y=zeros(1,nk);
x=x0;
for k=1:nk
    x=x+sqrt(Q)*randn;
    X(k)=x;
    Y(k)=x+sqrt(R)*randn;
end

%filtering
M=zeros(1,nk); CI=zeros(2,nk);
m=x0; P=0;
K = (Q/R + sqrt((Q/R)^2+4*Q/R))/(2 + Q/R + sqrt((Q/R)^2+4*Q/R));

for k=1:nk
 %P=P+Q;
 %m=m+P*(Y(k)-m)/(P+R); M(k)=m;
 %P=P-P^2/(P+R);
 %CI(:,k)=m+1.96*sqrt(P)*[1;-1];
 %XX = P + Q;
 %K = XX/(XX+R);
 %P = XX - XX.^2/(XX+R);
 m = m + K*(Y(k)-m);
 M(k) = m;
end
figure
plot(0:nk,[x0,X],'r-',1:nk,Y,'k.',1:nk,M,'k-')
legend('true','data','est')
%patch([1:nk,nk:-1:1], ...
% [CI(1,:),CI(2,nk:-1:1)], ...
% -ones(1,2*nk),'y','linestyle','none')