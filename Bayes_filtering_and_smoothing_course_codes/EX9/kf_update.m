function [M,P] = kf_update(M,P,Y,H,R)
    % updates M and P given old M, old P, data Y,H and R
    S = H*P*H' + R;
    K = P*H'*inv(S);
    M = M + K*[Y-H*M];
    P = P-K*S*K';
end

