%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Supplemental Matlab code for Exercise 4.6 in the book
%
% Simo Sarkka (2013), Bayesian Filtering and Smoothing,
% Cambridge University Press. 
%
% Last updated: $Date: 2013/08/26 12:58:41 $
%
% This software is distributed under the GNU General Public 
% Licence (version 2 or later); please refer to the file 
% Licence.txt, included with the software, for details.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Generate data
    
  %Using Simo Sarkka's code,added 4.6a and 4.6b stuff

  % Lock random seed
  randn('state',123);

  % Gaussian ranom draw, m is the mean and S the covariance
  gauss_rnd = @(m,S) m + chol(S)'*randn(size(m));
  
  % Calculate root mean squared error
  rmse = @(x,y) sqrt(mean((x(:)-y(:)).^2));
  
  % Define parameters
  steps = 100;  % Number of time steps
  w     = 0.5;  % Angular velocity
  q     = 0.01; % Process noise spectral density
  r     = 0.1;  % Measurement noise variance

  % This is the transition matrix
  A = [cos(w)    sin(w)/w; 
       -w*sin(w) cos(w)];

  % This is the process noise covariance
  Q = [0.5*q*(w-cos(w)*sin(w))/w^3 0.5*q*sin(w)^2/w^2;
       0.5*q*sin(w)^2/w^2          0.5*q*(w+cos(w)*sin(w))/w];

  % This is the true initial value
  x0 = [0;0.1]; 

  % Simulate data
  X = zeros(2,steps);  % The true signal
  Y = zeros(1,steps);  % Measurements
  T = 1:steps;         % Time
  x = x0;
  for k=1:steps
    x = gauss_rnd(A*x,Q);
    y = gauss_rnd(x(1),r);
    X(:,k) = x;
    Y(:,k) = y;
  end

  % Visualize
  figure; clf;
    plot(T,X(1,:),'--',T,Y,'o');
    legend('True signal','Measurements');
    xlabel('Time step'); title('\bf Simulated data')
    
  % Report and pause
  fprintf('This is the simulated data. Press enter.\n');
  pause;

  
%% Baseline solution

  % Baseline solution. The estimates
  % of x_k are stored as columns of
  % the matrix EST1.
  
  % Calculate baseline estimate
  m1 = [0;1];  % Initialize first step with a guess
  EST1 = zeros(2,steps);
  for k=1:steps
    m1(2) = Y(k)-m1(1);
    m1(1) = Y(k);
    EST1(:,k) = m1;
  end

  % Visualize results
  figure; clf;
  
  % Plot the signal and its estimate
  subplot(2,1,1);
    plot(T,X(1,:),'--',T,EST1(1,:),'-',T,Y,'o');
    legend('True signal','Estimated signal','Measurements');
    xlabel('Time step'); title('\bf Baseline solution')
  
  % Plot the derivative and its estimate
  subplot(2,1,2);
    plot(T,X(2,:),'--',T,EST1(2,:),'-');
    legend('True derivative','Estimated derivative');
    xlabel('Time step')

  % Compute error
  err1 = rmse(X,EST1)
  % 0.3793
  
  % Report and pause
  %fprintf('This is the base line estimate. Press enter.\n');
  pause
  
  
%% Kalman filter
  
  % Kalman filter solution. The estimates
  % of x_k are stored as columns of
  % the matrix EST2.

  m2 = [0;1];  % Initialize first step
  P2 = eye(2); % Some uncertanty in covariance  
  EST2 = zeros(2,steps); % Allocate space for results
    
  R2 = r;
  H2 = [1 0];
  % Run Kalman filter
  for k=1:steps
    % Replace these with the Kalman filter equations
    %m2 = m2;
    %P2 = P2;
    m2 = A*m2;
    P2 = A*P2*A'+Q;
    
    v2 = Y(:,k)-H2*m2;
    S2 = H2*P2*H2'+R2;
    K2 = P2*H2'/S2;     % /S is  same as *inv(S) but faster and more accurate
    m2 = m2+K2*v2;
    P2 = P2-K2*S2*K2';
    
    % Store the results
    EST2(:,k) = m2;
  end

  % Visualize results
  figure; clf
  
  % Plot the signal and its estimate
  subplot(2,1,1);
    plot(T,X(1,:),'--',T,EST2(1,:),'-',T,Y,'o');
    legend('True signal','Estimated signal','Measurements');
    xlabel('Time step'); title('\bf Kalman filter')
  
  % Plot the derivative and its estimate
  subplot(2,1,2);
    plot(T,X(2,:),'--',T,EST2(2,:),'-');
    legend('True derivative','Estimated derivative');
    xlabel('Time step')

  % Compute error
  err2 = rmse(X,EST2)
  % 0.1722
  
  % Report and pause
  %fprintf('This will be the KF estimate. Press enter.\n');
  pause;


%% Stationary Kalman filter solution

  % The estimates of x_k are stored as columns of
  % the matrix EST3.

  H3 = [1 0];
  m3 = [0;1];  % Initialize first step
  P3 = eye(2); % Some uncertanty in covariance  
  K  = [0;0];  % Store the stationary gain here  
  EST3 = zeros(2,steps); % Allocate space for results
  R3 = r;
  
  XX=dare(A',H3',Q,R3);
  S3=H3*XX*H3'+R3; 
  K3=XX*H3'/S3;  
  P3=XX-K3*S3*K3';
  
  for k=1:steps
    % Replace these with the stationary Kalman filter equations
    m3 = m3;
    
    
    
    m3 = A*m3;
    m3 = m3 + K3*(Y(:,k)-H3*m3);
    % Store the results
    EST3(:,k) = m3;
  end

  % Visualize results
  figure; clf
  
  % Plot the signal and its estimate
  subplot(2,1,1);
    plot(T,X(1,:),'--',T,EST3(1,:),'-',T,Y,'o');
    legend('True signal','Estimated signal','Measurements');
    xlabel('Time step'); ; title('\bf Stationary Kalman filter')
  
  % Plot the derivative and its estimate
  subplot(2,1,2);
    plot(T,X(2,:),'--',T,EST3(2,:),'-');
    legend('True derivative','Estimated derivative');
    xlabel('Time step')
 
  % Compute error
  err3 = rmse(X,EST3) 
  % 0.1873

  %so pratical difference between stationary and non-stationary kalman
  %filters is that in SKF K isn't updated. In KF K is updated but K
  %congerges into SKF's K. And filtering results are a bit different in the
  %beginning but they converges pretty quickly into same filtering result.
  
  
  % Report and pause
  %fprintf('This will be the SKF estimate. Press enter.\n');

%%
    figure; clf
  
  % Plot the signal and its estimate
  subplot(2,1,1);
    plot(T,X(1,:),'--')
    hold on
    plot(T,EST1(1,:),'-')
    hold on
    plot(T,EST2(1,:),'-')
    hold on
    plot(T,EST3(1,:),'-')
    hold on
    plot(T,Y,'o')
    legend('True signal','Estimated signal(baseline)', ...
        'Estimated signal(KF)', ...
        'Estimated signal(SKF)','Measurements');
    xlabel('Time step'); %; title('\bf Stationary Kalman filter')
  
  % Plot the derivative and its estimate
  subplot(2,1,2);
    plot(T,X(2,:),'--')
    hold on
    plot(T,EST1(2,:),'-')
    hold on
    plot(T,EST2(2,:),'-')
    hold on
    plot(T,EST3(2,:),'-')
    legend('True derivative','Estimated derivative(baseline)', ...
        'Estimated derivative(KF)','Estimated derivative(SKF)');
    xlabel('Time step')
