function [x,y,z] = body2plot(R, pts, sc, N0, E0, H0)
pe = R*pts*sc;
x  =  pe(2,:) + E0;
y  =  pe(1,:) + N0;
z  = -pe(3,:) + H0;
end