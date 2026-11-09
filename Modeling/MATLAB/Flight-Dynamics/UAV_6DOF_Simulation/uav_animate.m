function uav_animate(t, X, save_video)
fps = 30;
sc  = 6;
w   = 40;
bg  = [0.10 0.12 0.16];
axc = [0.14 0.16 0.22];

tt = (0:1/fps:t(end))';
Xi = interp1(t, X, tt);
nF = length(tt);
N  = Xi(:,10);  E = Xi(:,11);  H = -Xi(:,12);

fus   = [ 0.60 -0.60;  0 0;  0 0];
wing  = [ 0.15 -0.05 -0.05  0.15; -0.90 -0.90 0.90 0.90; 0 0 0 0];
htail = [-0.45 -0.60 -0.60 -0.45; -0.30 -0.30 0.30 0.30; 0 0 0 0];
fin   = [-0.50 -0.62;  0 0;  0 -0.25];

fig = figure('Name','Flight Animation','Color',bg,'Position',[80 80 960 600]);
ax  = axes('Parent',fig);
hold(ax,'on');
hTrail = plot3(E(1),N(1),H(1),'c-','LineWidth',1.5);
hFus   = plot3([0 1],[0 1],[0 1],'w-','LineWidth',3);
hFin   = plot3([0 1],[0 1],[0 1],'r-','LineWidth',3);
hWing  = patch([0 1 1 0],[0 0 1 1],[0 0 0 0],[0.3 0.7 1.0]);
hTail  = patch([0 1 1 0],[0 0 1 1],[0 0 0 0],[1.0 0.6 0.2]);
set(ax,'Color',axc,'XColor','w','YColor','w','ZColor','w', ...
     'DataAspectRatio',[1 1 1]);
grid(ax,'on');
xlabel(ax,'East (m)','Color','w');
ylabel(ax,'North (m)','Color','w');
zlabel(ax,'Altitude (m)','Color','w');
view(ax,-35,22);
hT = title(ax,'','Color','w','FontWeight','bold');

% ---- �?تح مل�? ال�?يديو ----
vw = [];
vidFile = 'UAV_flight.avi';
if save_video
    try
        vw = VideoWriter(vidFile, 'Motion JPEG AVI');
        set(vw,'FrameRate',fps,'Quality',90);
        open(vw);
        fprintf('Recording: %s\n', fullfile(pwd, vidFile));
    catch ME1
        fprintf('AVI failed: %s\nTrying MP4...\n', ME1.message);
        try
            vidFile = 'UAV_flight.mp4';
            vw = VideoWriter(vidFile, 'MPEG-4');
            set(vw,'FrameRate',fps,'Quality',90);
            open(vw);
            fprintf('Recording: %s\n', fullfile(pwd, vidFile));
        catch ME2
            fprintf('MP4 failed: %s\nNo video will be saved.\n', ME2.message);
            vw = [];
        end
    end
end

for k = 1:nF
    if ~ishandle(fig), break; end

    phi = Xi(k,7); th = Xi(k,8); psi = Xi(k,9);
    cf = cos(phi); sf = sin(phi);
    ct = cos(th);  st = sin(th);
    cp = cos(psi); sp = sin(psi);
    R = [ ct*cp,  sf*st*cp - cf*sp,  cf*st*cp + sf*sp;
          ct*sp,  sf*st*sp + cf*cp,  cf*st*sp - sf*cp;
         -st,     sf*ct,             cf*ct ];

    [x,y,z] = body2plot(R,fus,  sc,N(k),E(k),H(k)); set(hFus, 'XData',x,'YData',y,'ZData',z);
    [x,y,z] = body2plot(R,fin,  sc,N(k),E(k),H(k)); set(hFin, 'XData',x,'YData',y,'ZData',z);
    [x,y,z] = body2plot(R,wing, sc,N(k),E(k),H(k)); set(hWing,'XData',x,'YData',y,'ZData',z);
    [x,y,z] = body2plot(R,htail,sc,N(k),E(k),H(k)); set(hTail,'XData',x,'YData',y,'ZData',z);

    set(hTrail,'XData',E(1:k),'YData',N(1:k),'ZData',H(1:k));
    set(ax,'XLim',E(k)+[-w w],'YLim',N(k)+[-w w],'ZLim',H(k)+[-0.7*w 0.7*w]);

    V = sqrt(Xi(k,1)^2+Xi(k,2)^2+Xi(k,3)^2);
    set(hT,'String',sprintf('t=%.2fs | V=%.1fm/s | Alt=%.1fm | Roll=%.1f Pitch=%.1f Yaw=%.1f', ...
        tt(k),V,H(k),phi*180/pi,th*180/pi,psi*180/pi));

    drawnow;

    if ~isempty(vw)
        writeVideo(vw, getframe(fig));
    else
        pause(1/fps);
    end
end

if ~isempty(vw)
    close(vw);
    fprintf('✔ Video saved: %s\n', fullfile(pwd, vidFile));
end
end