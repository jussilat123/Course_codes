filter_errors = zeros(2000,100);
P_values_at_17 = zeros(1,2000);

for simulation = 1:2000
    
    %generate random walk data
    nm = 100;              % number of measurements
    dt = 1;                % time step length
    %rng(21)                % random number generator seed
    u0 = randn;            % initial position ~ N(0,1)
    v0 = randn;            % initial velocity ~ N(0,1)
    e = randn(1,nm);       % random-walk driving noise
    u_true = zeros(1,nm);  % preallocate
    u=u0; v=v0;
    for k = 1:nm
        u = u+dt*v;
        v = v+e(k);
        u_true(k)=u;
    end
    
    ep = 10*randn(1,nm);       % measurement noises ~ N(0,100)
    y = u_true+ep;             % measurements
    
    %kalman filter
    A = [1 dt; 0 1];
    Q = [0 0; 0 1];
    H = [1 0];
    R = 100;
    m0 = [0 0]'; P0 = eye(2);  % state prior mean and covariance
    u_est = zeros(1,nm);      % preallocate 
    u_var = zeros(1,nm);      % preallocate
    m = m0; P = P0;
    for k = 1:nm
        [m,P] = kf_predict(m,P,A,Q);
        [m,P] = kf_update(m,P,y(k),H,R);
        u_est(k) = m(1);
        u_var(k) = P(1,1);
        
    end
    
    filter_errors(simulation,:) = u_true-u_est;
    P_values_at_17(simulation) = u_var(17);
end

%%

covariances = cov(filter_errors);
covariances(17,17)
%36.6562

mean(P_values_at_17)
%36.1085

var(P_values_at_17)
%5.0512e-29 => var = 0

%%
function [m,P] = kf_predict(m,P,A,Q)
    m = A*m;
    P = A*P*A'+Q;
end

function [m,P] = kf_update(m,P,y,H,R)
    v = y-H*m;
    S = H*P*H'+R;
    K = P*H'/S;     % /S is  same as *inv(S) but faster and more accurate
    m = m+K*v;
    P = P-K*S*K';
end