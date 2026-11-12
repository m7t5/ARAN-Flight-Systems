clc;
clear;
close all;

%% =====================================================
%  1. PHYSICAL PARAMETERS
% ======================================================

R = 0.65;                 % Curved surface radius (m)
theta_end = 110*pi/180;   % Bending angle (rad)

W = 0.60;                 % Surface width (m)

Ujet = 15;                % Jet velocity (m/s)
Uinf = 2;                 % Background velocity (m/s)

d = 0.09;                 % Jet distance from wall (m)
sigma = 0.055;            % Jet thickness (m)


%% =====================================================
%  2. CREATE 3D CURVED SURFACE
% ======================================================

theta = linspace(0,theta_end,100);
z = linspace(-W/2,W/2,35);

[TH,Z] = meshgrid(theta,z);

Xs = R*sin(TH);
Ys = R*(1-cos(TH));


%% =====================================================
%  3. GENERATE AIR JET CENTERLINE
% ======================================================

% First section: Straight airflow

x1 = linspace(-1.2,0,100);
y1 = d*ones(size(x1));


% Second section: Curved airflow

r = R-d;

th = linspace(0,theta_end,140);

x2 = r*sin(th);
y2 = R-r*cos(th);


% Third section: Airflow leaving curved surface

xEnd = x2(end);
yEnd = y2(end);

t = linspace(0,0.9,80);

x3 = xEnd+t*cos(theta_end);
y3 = yEnd+t*sin(theta_end);


% Combine all sections

xc = [x1 x2 x3];
yc = [y1 y2 y3];


%% =====================================================
%  4. CALCULATE CENTERLINE TANGENT
% ======================================================

dx = gradient(xc);
dy = gradient(yc);

mag = sqrt(dx.^2+dy.^2);

tx = dx./mag;
ty = dy./mag;


%% =====================================================
%  5. CREATE COMPUTATIONAL GRID
% ======================================================

xg = linspace(-1.3,2.2,110);
yg = linspace(-0.15,1.7,85);

[Xg,Yg] = meshgrid(xg,yg);

% Convert grid into column vectors

Xp = Xg(:);
Yp = Yg(:);


%% =====================================================
%  6. FIND NEAREST CENTERLINE POINT
% ======================================================

% Calculate squared distances

%% 6. FIND NEAREST CENTERLINE POINT

% Calculate squared distances between grid points and centerline

D2 = bsxfun(@plus, ...
    Xp.^2 + Yp.^2, ...
    xc.^2 + yc.^2) ...
    - 2*(Xp*xc + Yp*yc);

% Find nearest centerline point

[~,idx] = min(D2,[],2);

% Extract nearest coordinates

xNear = reshape(xc(idx),[],1);
yNear = reshape(yc(idx),[],1);

% Extract tangent directions

txNear = reshape(tx(idx),[],1);
tyNear = reshape(ty(idx),[],1);

% Find nearest centerline point

[~,idx] = min(D2,[],2);

% Get nearest coordinates

xNear = xc(idx)';
yNear = yc(idx)';

% Get local tangent direction

txNear = tx(idx)';
tyNear = ty(idx)';


%% =====================================================
%  7. CALCULATE DISTANCE FROM AIR JET
% ======================================================

normalDistance = ...
    -(Xp-xNear).*tyNear + ...
     (Yp-yNear).*txNear;

% Gaussian jet profile

G = exp(-0.5*(normalDistance/sigma).^2);


%% =====================================================
%  8. CALCULATE VELOCITY FIELD
% ======================================================

Ux = Uinf + (Ujet*txNear-Uinf).*G;

Uy = Ujet*tyNear.*G;

% Reshape velocity components

Ux = reshape(Ux,size(Xg));
Uy = reshape(Uy,size(Yg));

% Velocity magnitude

Velocity = sqrt(Ux.^2+Uy.^2);


%% =====================================================
%  9. CREATE 3D FIGURE
% ======================================================

figure('Color','w',...
       'Name','Coanda Effect 3D Model',...
       'Position',[80 80 1100 700]);

hold on;


%% =====================================================
%  10. DRAW CURVED SURFACE
% ======================================================

surf(Xs,Ys,Z,...
    'FaceColor',[0.72 0.76 0.82],...
    'EdgeColor','none',...
    'FaceAlpha',0.95);


%% =====================================================
%  11. DRAW AIR NOZZLE
% ======================================================

nozzleX = -1.2;

patch([nozzleX nozzleX nozzleX nozzleX],...
      [0.02 0.16 0.16 0.02],...
      [-W/2 -W/2 W/2 W/2],...
      [0.2 0.2 0.2],...
      'EdgeColor','k');


% Nozzle opening

plot3([nozzleX nozzleX],...
      [0.02 0.16],...
      [0 0],...
      'r','LineWidth',3);


%% =====================================================
%  12. DRAW VELOCITY VECTORS
% ======================================================

skip = 8;

quiver3(...
    Xg(1:skip:end,1:skip:end),...
    Yg(1:skip:end,1:skip:end),...
    zeros(size(Xg(1:skip:end,1:skip:end))),...
    Ux(1:skip:end,1:skip:end),...
    Uy(1:skip:end,1:skip:end),...
    zeros(size(Ux(1:skip:end,1:skip:end))),...
    0.025,...
    'Color',[0.1 0.4 0.85]);


%% =====================================================
%  13. DRAW AIRFLOW CENTERLINE
% ======================================================

plot3(xc,yc,zeros(size(xc)),...
      'b--','LineWidth',1.5);


%% =====================================================
%  14. CREATE MOVING AIR PARTICLES
% ======================================================

nParticles = 55;

xp = -1.15*ones(nParticles,1);

yp = d+0.015*randn(nParticles,1);

zp = linspace(-W/2,W/2,nParticles)';

initialSpeed = Ujet*ones(nParticles,1);

hParticles = scatter3(xp,yp,zp,35,...
    initialSpeed,'filled');


%% =====================================================
%  15. COLOR AND LIGHTING SETTINGS
% ======================================================

colormap(jet);

colorbar;

caxis([0 Ujet]);

camlight headlight;

lighting gouraud;


%% =====================================================
%  16. GRAPH SETTINGS
% ======================================================

xlabel('X Direction (m)');
ylabel('Y Direction (m)');
zlabel('Z Direction (m)');

title('3D Visualization of Coanda Effect');

axis equal;

xlim([-1.3 2.2]);

ylim([-0.15 1.7]);

zlim([-0.4 0.4]);

grid on;

box on;

view(38,28);


%% =====================================================
%  17. AIRFLOW ANIMATION
% ======================================================

dt = 0.002;

nFrames = 800;

for k = 1:nFrames

    % Calculate local velocity

    u = interp2(Xg,Yg,Ux,...
        xp,yp,'linear',Uinf);

    v = interp2(Xg,Yg,Uy,...
        xp,yp,'linear',0);

    % Update particle positions

    xp = xp+u*dt;

    yp = yp+v*dt;

    % Calculate particle speed

    speed = sqrt(u.^2+v.^2);

    % Reset particles leaving the model

    for j = 1:nParticles

        if xp(j)>2.1 || yp(j)>1.6 || yp(j)<-0.1

            xp(j) = -1.15;

            yp(j) = d+0.015*randn;

        end

    end

    % Update animation

    set(hParticles,...
        'XData',xp,...
        'YData',yp,...
        'ZData',zp,...
        'CData',speed);

    drawnow;

    pause(0.015);

end


%% =====================================================
%  18. DISPLAY RESULTS
% ======================================================

disp('----------------------------------');

disp('COANDA EFFECT 3D MODEL');

disp('----------------------------------');

fprintf('Surface Radius = %.3f m\n',R);

fprintf('Jet Velocity = %.2f m/s\n',Ujet);

fprintf('Jet Thickness = %.3f m\n',sigma);

fprintf('Number of Particles = %d\n',nParticles);

disp('----------------------------------');

disp('Animation Completed Successfully');
