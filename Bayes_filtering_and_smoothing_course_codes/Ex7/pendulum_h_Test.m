function [h,Hx,Hxx]=pendulum_h_Test(x)
h=[sin(x(1,:))];
Hx=[cos(x(1)) 0];
Hxx{1}=[-sin(x(1))   0
          0          0];
end

