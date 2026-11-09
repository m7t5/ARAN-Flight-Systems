function uav_plots(S)
bg  = [0.10 0.12 0.16];
axc = [0.14 0.16 0.22];
c1 = [1.0 0.35 0.35]; c2 = [0.4 1.0 0.5]; c3 = [0.4 0.7 1.0];

figure('Name','6DOF Simulation','Color',bg,'Position',[60 60 1200 760]);

subplot(3,2,1);
plot3(S.Xe, S.Ye, -S.Ze, 'c-', 'LineWidth', 2);
style_axes(axc); grid on;
xlabel('X (m)','Color','w'); ylabel('Y (m)','Color','w'); zlabel('Alt (m)','Color','w');
title('3D Trajectory','Color','w','FontWeight','bold'); view(35,25);

subplot(3,2,2);
plot(S.t, S.phi,'Color',c1,'LineWidth',1.5); hold on;
plot(S.t, S.theta,'Color',c2,'LineWidth',1.5);
plot(S.t, S.psi,'Color',c3,'LineWidth',1.5);
style_axes(axc); grid on;
xlabel('Time (s)','Color','w'); ylabel('deg','Color','w');
title('Euler Angles','Color','w');
style_legend(legend('Roll','Pitch','Yaw','Location','best'), axc);

subplot(3,2,3);
plot(S.t,S.u,'Color',c1,'LineWidth',1.5); hold on;
plot(S.t,S.v,'Color',c2,'LineWidth',1.5);
plot(S.t,S.w,'Color',c3,'LineWidth',1.5);
style_axes(axc); grid on;
xlabel('Time (s)','Color','w'); ylabel('m/s','Color','w');
title('Body Velocities','Color','w');
style_legend(legend('u','v','w','Location','best'), axc);

subplot(3,2,4);
plot(S.t,S.p,'Color',c1,'LineWidth',1.5); hold on;
plot(S.t,S.q,'Color',c2,'LineWidth',1.5);
plot(S.t,S.r,'Color',c3,'LineWidth',1.5);
style_axes(axc); grid on;
xlabel('Time (s)','Color','w'); ylabel('rad/s','Color','w');
title('Body Rates','Color','w');
style_legend(legend('p','q','r','Location','best'), axc);

subplot(3,2,5);
plot(S.t,S.de,'Color',c1,'LineWidth',1.5); hold on;
plot(S.t,S.da,'Color',c2,'LineWidth',1.5);
plot(S.t,S.dr,'Color',c3,'LineWidth',1.5);
style_axes(axc); grid on;
xlabel('Time (s)','Color','w'); ylabel('deg','Color','w');
title('Controls','Color','w');
style_legend(legend('Elevator','Aileron','Rudder','Location','best'), axc);

subplot(3,2,6);
plot(S.t,S.alpha,'Color',c1,'LineWidth',1.5); hold on;
plot(S.t,S.beta,'Color',c3,'LineWidth',1.5);
style_axes(axc); grid on;
xlabel('Time (s)','Color','w'); ylabel('deg','Color','w');
title('Alpha & Beta','Color','w');
style_legend(legend('alpha','beta','Location','best'), axc);

figure('Name','Airspeed & Altitude','Color',bg,'Position',[120 120 900 420]);
subplot(1,2,1);
plot(S.t,S.V,'Color',c1,'LineWidth',1.8);
style_axes(axc); grid on;
xlabel('Time (s)','Color','w'); ylabel('m/s','Color','w');
title('Airspeed','Color','w');

subplot(1,2,2);
plot(S.t,-S.Ze,'Color',c2,'LineWidth',1.8);
style_axes(axc); grid on;
xlabel('Time (s)','Color','w'); ylabel('m','Color','w');
title('Altitude','Color','w');
end