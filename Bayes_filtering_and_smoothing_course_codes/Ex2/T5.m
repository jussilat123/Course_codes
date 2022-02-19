%% run first for task 5
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
mT = m0 + P0*H'*inv(S)*(y-H*m0);
PT = P0 -P0*H'*inv(S)*H*P0;

%% task 5

sigma = 0.5;
P = sigma^2*PT;
m = m0;

L = chol(P,"lower");
t = 0:pi/50:2*pi;

%50 confidence eplipse
r = sqrt(chi2inv(0.5,2));
contour_stamps = [r.*cos(t);r.*sin(t)];

lines = m + L*contour_stamps;
plot(lines(1,:),lines(2,:))

hold on
triangle = [[0 0];[6 6*sqrt(3)];[12 0];[0 0]];
plot(triangle(:,1),triangle(:,2))
