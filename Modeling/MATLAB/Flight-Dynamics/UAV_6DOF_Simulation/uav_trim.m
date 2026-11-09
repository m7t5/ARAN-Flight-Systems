function [alpha, de, T] = uav_trim(P, V)
qb = 0.5*P.rho*V^2;
W  = P.m*P.g;

de = 0;
alpha = 0;
for k = 1:50
    f = @(a) qb*P.S*( (P.CL0+P.CLa*a+P.CLde*de) * cos(a) + ...
                      (P.CD0+P.K*(P.CL0+P.CLa*a+P.CLde*de)^2) * sin(a) ) - W*cos(a);
    alpha  = fzero(f, 0.0);
    de_new = -(P.Cm0 + P.Cma*alpha) / P.Cmde;
    if abs(de_new - de) < 1e-12
        de = de_new; break;
    end
    de = de_new;
end

CL = P.CL0 + P.CLa*alpha + P.CLde*de;
CD = P.CD0 + P.K*CL^2;
L  = qb*P.S*CL;
D  = qb*P.S*CD;
T  = D*cos(alpha) - L*sin(alpha) + W*sin(alpha);
end