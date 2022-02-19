t = [1 2 3 4 5 6 7 8 9 10]';
y = [-0.083 0.028 0.285 0.780 0.757 1.076 1.173 1.409 1.521 1.773]';

sd=0.1;

m0=[0;0]; P0=100*eye(2); % prior mean and covariance
H =[ones(size(t)) t];
PT=inv(inv(P0) + 1/sd^2*(H'*H));
mT=PT*(1/sd^2*(H'*y)+P0\m0);
plot(t,y,'.',t,mT(1)+mT(2)*t,'-');
legend('Measurement','Estimate');

%computed mean for posterior
mT % (-0.2705, 0.2077)

%computed covariance matrix for posterior
PT 
% [(0.0047, -0.0007),
% (-0.0007,0.0001)]
