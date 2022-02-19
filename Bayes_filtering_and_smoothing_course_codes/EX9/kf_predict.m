function [M,P] = kf_predict(M,P,A,Q)
    %updates kalman filter M and P.
    M = A*M;
    P = A*P*A'+Q;
end

