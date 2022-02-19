H = [[0 1];[-sqrt(3)/2 -1/2];[sqrt(3)/2 -1/2]];
R = eye(3);

r = [2 4 6]';
b = [0 6*sqrt(3) 0]';
y = r-b;


PT = inv(H'*inv(R)*H)'
mT = PT*H'*inv(R)*y