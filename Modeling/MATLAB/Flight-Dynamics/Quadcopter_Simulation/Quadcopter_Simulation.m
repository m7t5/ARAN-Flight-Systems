clc;
clear;
close all;

%% ============================================================
% Quadcopter Flight Simulation 
%ARAN Flight Systems 
%% ============================================================

%% 1. Simulation Setup

dt = 0.02;
T = 30;
t = (0:dt:T)';
N = length(t);

% Physical parameters
m = 1.2;                  % Drone mass (kg)
g = 9.81;                 % Gravity (m/s^2)

% Controller gains
Kp = [5 5 7];
Kd = [4 4 5];

% Maximum commanded acceleration
amax = 5;                 % m/s^2

%% 2. Variable Initialization

pos = zeros(N,3);
vel = zeros(N,3);
acc = zeros(N,3);

ref = zeros(N,3);
refVel = zeros(N,3);
refAcc = zeros(N,3);

error = zeros(N,3);
thrust = zeros(N,1);

%% 3. Reference Trajectory Generation

for k = 1:N

    tk = t(k);

    if tk < 5

        % Phase 1: Smooth Takeoff
        u = tk/5;

        s = 10*u^3 - 15*u^4 + 6*u^5;
        ds = (30*u^2 - 60*u^3 + 30*u^4)/5;
        dds = (60*u - 180*u^2 + 120*u^3)/25;

        ref(k,:) = [0 0 2*s];
        refVel(k,:) = [0 0 2*ds];
        refAcc(k,:) = [0 0 2*dds];

    elseif tk < 10

        % Phase 2: Hovering
        ref(k,:) = [0 0 2];
        refVel(k,:) = [0 0 0];
        refAcc(k,:) = [0 0 0];

    elseif tk < 25

        % Phase 3: Smooth 3D Flight
        u = (tk-10)/15;

        s = 10*u^3 - 15*u^4 + 6*u^5;
        ds = (30*u^2 - 60*u^3 + 30*u^4)/15;
        dds = (60*u - 180*u^2 + 120*u^3)/225;

        xref = -2*s;
        vxref = -2*ds;
        axref = -2*dds;

        yref = 1.2*sin(pi*s)^2;
        vyref = 1.2*pi*sin(2*pi*s)*ds;
        ayref = 1.2*pi*(2*pi*cos(2*pi*s)*ds^2 + sin(2*pi*s)*dds);

        zref = 2 + 0.5*sin(pi*s)^2;
        vzref = 0.5*pi*sin(2*pi*s)*ds;
        azref = 0.5*pi*(2*pi*cos(2*pi*s)*ds^2 + sin(2*pi*s)*dds);

        ref(k,:) = [xref yref zref];
        refVel(k,:) = [vxref vyref vzref];
        refAcc(k,:) = [axref ayref azref];

    else

        % Phase 4: Final Hover
        ref(k,:) = [-2 0 2];
        refVel(k,:) = [0 0 0];
        refAcc(k,:) = [0 0 0];

    end

end

%% 4. Control Loop & Dynamics

for k = 1:N-1

    error(k,:) = ref(k,:) - pos(k,:);
    velError = refVel(k,:) - vel(k,:);

    a_cmd = refAcc(k,:) + Kp.*error(k,:) + Kd.*velError;
    a_cmd = max(min(a_cmd,amax),-amax);

    acc(k,:) = a_cmd;

    F = m*(a_cmd + [0 0 g]);
    thrust(k) = norm(F);

    vel(k+1,:) = vel(k,:) + acc(k,:)*dt;
    pos(k+1,:) = pos(k,:) + vel(k+1,:)*dt;

    if pos(k+1,3) < 0
        pos(k+1,3) = 0;
        if vel(k+1,3) < 0
            vel(k+1,3) = 0;
        end
    end

end

error(N,:) = ref(N,:) - pos(N,:);
acc(N,:) = acc(N-1,:);
thrust(N) = thrust(N-1);

%% 5. Performance Metrics

speed = sqrt(sum(vel.^2,2));
trackingError = sqrt(sum(error.^2,2));

rmse = sqrt(mean(trackingError.^2));
finalError = norm(ref(end,:) - pos(end,:));

fprintf('\n====================================\n');
fprintf(' QUADCOPTER SIMULATION RESULTS\n');
fprintf('The software was developed by Mustafa Mahmoud\n');
fprintf('====================================\n');
fprintf('Simulation time: %.1f s\n',T);
fprintf('Final X position: %.4f m\n',pos(end,1));
fprintf('Final Y position: %.4f m\n',pos(end,2));
fprintf('Final altitude: %.4f m\n',pos(end,3));
fprintf('Overall position RMSE: %.4f m\n',rmse);
fprintf('Final position error: %.4f m\n',finalError);
fprintf('Maximum tracking error: %.4f m\n',max(trackingError));
fprintf('====================================\n');

%% 6. Live 3D Animation

figure(1);
set(gcf,'Name','Quadcopter 3D Animation','Color','w');

L = 0.35;
r = 0.13;
theta = linspace(0,2*pi,40);

rotors = [ L  0  0;
          -L  0  0;
           0  L  0;
           0 -L  0];

plot3(ref(:,1),ref(:,2),ref(:,3),'r--','LineWidth',1.5);
hold on;
plot3(pos(:,1),pos(:,2),pos(:,3),'b:','LineWidth',1.5);
grid on;
axis equal;

xlabel('X (m)');
ylabel('Y (m)');
zlabel('Altitude (m)');
axis([-3 1 -1 2 0 3.5]);
view(35,25);

arm1 = plot3([0 0],[0 0],[0 0],'k-','LineWidth',5);
arm2 = plot3([0 0],[0 0],[0 0],'k-','LineWidth',5);
body = plot3(0,0,0,'ks','MarkerSize',12,'MarkerFaceColor',[0.2 0.6 0.9]);

rotorPlot = zeros(4,1);
for j = 1:4
    rotorPlot(j) = plot3(0,0,0,'LineWidth',2);
    if j <= 2
        set(rotorPlot(j),'Color','r');
    else
        set(rotorPlot(j),'Color','g');
    end
end

for k = 1:5:N
    x = pos(k,1);
    y = pos(k,2);
    z = pos(k,3);

    set(arm1,'XData',[x-L x+L],'YData',[y y],'ZData',[z z]);
    set(arm2,'XData',[x x],'YData',[y-L y+L],'ZData',[z z]);
    set(body,'XData',x,'YData',y,'ZData',z);

    for j = 1:4
        cx = x + rotors(j,1);
        cy = y + rotors(j,2);
        xr = cx + r*cos(theta);
        yr = cy + r*sin(theta);
        zr = z*ones(size(theta));
        set(rotorPlot(j),'XData',xr,'YData',yr,'ZData',zr);
    end

    if t(k) < 5
        phase = 'TAKEOFF';
    elseif t(k) < 10
        phase = 'HOVERING';
    elseif t(k) < 25
        phase = '3D FLIGHT';
    else
        phase = 'FINAL HOVER';
    end

    if mod(k,25) == 1 || k == N
        title(sprintf('Quadcopter | Time: %.1f s | %s',t(k),phase));
    end
    drawnow;
end

disp('Animation completed.');

%% 7. Position Response Curves

figure(2);
set(gcf,'Name','Position Response','Color','w');
names = {'X Position','Y Position','Altitude Z'};

for j = 1:3
    subplot(3,1,j);
    plot(t,ref(:,j),'r--','LineWidth',1.8);
    hold on;
    plot(t,pos(:,j),'b','LineWidth',1.5);
    grid on;
    title(names{j});
    ylabel('Position (m)');
    legend('Desired','Actual','Location','best');
end
xlabel('Time (s)');

%% 8. Speed, Error, and Thrust Analytics

figure(3);
set(gcf,'Name','Speed Error and Thrust','Color','w');

subplot(3,1,1);
plot(t,speed,'b','LineWidth',1.6);
grid on;
title('Quadcopter Speed');
ylabel('Speed (m/s)');

subplot(3,1,2);
plot(t,trackingError,'r','LineWidth',1.6);
grid on;
title('3D Position Tracking Error');
ylabel('Error (m)');

subplot(3,1,3);
plot(t,thrust,'m','LineWidth',1.6);
grid on;
title('Total Thrust Force');
ylabel('Force (N)');
xlabel('Time (s)');

%% 9. 3D Flight Trajectory

figure(4);
set(gcf,'Name','3D Flight Trajectory','Color','w');
plot3(ref(:,1),ref(:,2),ref(:,3),'r--','LineWidth',2);
hold on;
plot3(pos(:,1),pos(:,2),pos(:,3),'b','LineWidth',2);
plot3(pos(1,1),pos(1,2),pos(1,3),'go','MarkerFaceColor','g');
plot3(pos(end,1),pos(end,2),pos(end,3),'ko','MarkerFaceColor','k');
grid on;
axis equal;
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');
title('Smooth 3D Flight Trajectory');
legend('Desired Path','Actual Path','Start','End','Location','best');
view(35,25);

%% 10. Final Completion Notice

disp('====================================');
disp('ALL FOUR FIGURES CREATED SUCCESSFULLY');
disp('The software was developed by Mustafa Mahmoud');
disp('====================================');

figure(2);
