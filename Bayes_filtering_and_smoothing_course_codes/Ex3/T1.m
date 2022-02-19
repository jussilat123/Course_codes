%LINREG_DEMO Batch and recursive linear regression

%%
% Simulate data
%

  t = [1 2 3 4 5 6 7 8 9 10];
  y = [-0.083 0.028 0.285 0.780 0.757 1.076 1.173 1.409 1.521 1.773];
  
  sd = 0.1;

  figure(1),clf
  h = plot(t,y,'.');
  
  axis([0 12 -0.5 2.5]);
  
  set(h,'Markersize',7);
  set(h,'LineWidth',4);
  set(h(1),'Color',[1.0 0.0 0.0]);
  
  
  h = legend('Measurement');
  xlabel('{\it t}');
  ylabel('{\it y}','rot',0);

%%
% Batch linear regression

  %solve problem
  m0 = [0;0];
  P0 = 100*eye(2);
  n  = length(y);
  H  = [ones(length(t),1) t'];
  Pb = inv(inv(P0) + 1/sd^2*H'*H);
  mb = Pb*(1/sd^2*H'*y'+P0\m0);
  
  % plot result
  figure(2),clf
  h = plot(t,y,'.',t,mb(1)+mb(2)*t,'-');

  axis([0 12 -0.5 2.5]);
  
  set(h,'Markersize',7);
  set(h(2),'LineWidth',4);
  set(h(1),'Color',[0.0 0.0 0.0]);
  set(h(2),'Color',[0.7 0.7 0.7]);
  
  h = legend('Measurement','Estimate');
  xlabel('{\it t}');
  ylabel('{\it y}','rot',0);
 
%%
% Recursive linear regression
%
  m = m0;
  P = P0;
  MM = zeros(size(m0,1),length(y));
  PP = zeros(size(P0,1),size(P0,1),length(y));
  count = 0;
  figure(3),clf
  text(0,0.5,{'press a key';'to continue'},'fontsize',30)
  axis off
  pause
  for k=1:length(y)
      H = [1 t(k)];
      S = H*P*H'+sd^2;
      K = P*H'/S;
      m = m + K*(y(k)-H*m);
      P = P - K*S*K';
      
      MM(:,k) = m;
      PP(:,:,k) = P;

      HH = [ones(length(t),1) t'];
      VV = diag(HH*P*HH');
      q1 = HH*m+1.96*sqrt(VV);
      q2 = HH*m-1.96*sqrt(VV);
      
      clf;
      p=patch([t fliplr(t)],[q1' fliplr(q2')],1);
      set(p,'FaceColor',[0 1 0])
      hold on;
      h = plot(t,y,'.',t,HH*m,'-',...
               t(1:k),y(1:k),'ko');

      axis([0 12 -0.5 2.5]);
  
      set(h,'linewidth',2);
      set(h,'Markersize',10);
      %set(h(2),'LineWidth',4);
      set(h(2),'LineWidth',1.5);
      set(h(3),'Markersize',10);
      grid on;
      
      pause(0.1);
      drawnow;
  end
  

%%  
% Plot the evolution of estimates
%

  figure(4);clf
  h = plot(t,MM(1,:),'b-',[0 1],[mb(1) mb(1)],'b--',...
           t,MM(2,:),'r-',[0 1],[mb(2) mb(2)],'r--');
  
  set(h,'Markersize',10);
  set(h,'LineWidth',2);
  set(h(1),'Color',[0.0 0.0 0.0]);
  set(h(2),'Color',[0.0 0.0 0.0]);
  set(h(3),'Color',[0.5 0.5 0.5]);
  set(h(4),'Color',[0.5 0.5 0.5]);

  
  h = legend('Recursive E[ {\it\theta}_1 ]','Batch E[ {\it\theta}_1 ]',...
         'Recursive E[ {\it\theta}_2 ]','Batch E[ {\it\theta}_2 ]',...
         'location','northeast');
  
  xlabel('{\it t}');
  

%%  
% Plot the evolution of variances
%

  figure(5),clf
  h = semilogy(t,squeeze(PP(1,1,:)),'b-',[0 1],[Pb(1,1) Pb(1,1)],'b--',...
               t,squeeze(PP(2,2,:)),'r-',[0 1],[Pb(2,2) Pb(2,2)],'r--');

  set(h,'Markersize',10);
  set(h,'LineWidth',2);
  set(h(1:2),'Color',[0.0 0.0 0.0]);
  set(h(3:4),'Color',[0.5 0.5 0.5]);
  
  h = legend('Recursive Var[ {\it\theta}_1 ]','Batch Var[ {\it\theta}_1 ]',...
         'Recursive Var[ {\it\theta}_2 ]','Batch Var[ {\it\theta}_2 ]');     
  
  xlabel('{\it t}');
 
  grid on;