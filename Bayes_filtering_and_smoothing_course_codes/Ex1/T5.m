figure
circle(2,3,sqrt(15))

%create 200 random values for y
mu = [2;3];
sigma = 1/2*[[1 -1];[-1 2]];
y_200 = mvnrnd(mu,sigma,200);
plot(y_200(:,1),y_200(:,2),'r.')

mean(y_200)

function h = circle(x,y,r)
th = 0:pi/50:2*pi;
xunit = r * cos(th) + x;
yunit = r * sin(th) + y;
h = plot(xunit, yunit);
hold on
%axis([-10 10 -10 10])
axis equal
end