H = [[0 1];[-sqrt(3)/2 -1/2];[sqrt(3)/2 -1/2]];
R = eye(3);

r = [2 4 6]';
b = [0 6*sqrt(3) 0]';
y = r-b;



PT = inv(H'*inv(R)*H)';
mT = PT*H'*inv(R)*y;

P0 = PT;
m0 = mT;

H = [sqrt(3)/2 -1/2];
R = 1;
y = 5.5;

S = H*P0*H'+R;
mT = m0 + P0*H'*inv(S)*(y-H*m0)
PT = P0 -P0*H'*inv(S)*H*P0

%PT = inv(P0 + H'*inv(R)*H)
%mT = PT*(inv(P0)*m0 + H'*inv(R)*y)