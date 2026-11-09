function xdot = uav_eom(t, x, P, trim)
u = x(1); v = x(2); w = x(3);
p = x(4); q = x(5); r = x(6);
phi = x(7); theta = x(8); psi = x(9);

[de, da, dr] = uav_controls(t, trim);

V     = max(sqrt(u^2 + v^2 + w^2), 0.5);
alpha = atan2(w, u);
beta  = asin(v / V);
qb    = 0.5*P.rho*V^2;

ph = p*P.b/(2*V);
qh = q*P.c/(2*V);
rh = r*P.b/(2*V);

CL = P.CL0 + P.CLa*alpha + P.CLde*de;
CD = P.CD0 + P.K*CL^2;
CY = P.CYb*beta + P.CYdr*dr;
Cl = P.Clb*beta + P.Clp*ph + P.Clr*rh + P.Clda*da;
Cm = P.Cm0 + P.Cma*alpha + P.Cmq*qh + P.Cmde*de;
Cn = P.Cnb*beta + P.Cnp*ph + P.Cnr*rh + P.Cndr*dr;

L = qb*P.S*CL;
D = qb*P.S*CD;
Y = qb*P.S*CY;

Fx = -D*cos(alpha) + L*sin(alpha) + trim.T;
Fy =  Y;
Fz = -D*sin(alpha) - L*cos(alpha);

Lm = qb*P.S*P.b*Cl;
Mm = qb*P.S*P.c*Cm;
Nm = qb*P.S*P.b*Cn;

u_dot = Fx/P.m - (q*w - r*v) - P.g*sin(theta);
v_dot = Fy/P.m - (r*u - p*w) + P.g*cos(theta)*sin(phi);
w_dot = Fz/P.m - (p*v - q*u) + P.g*cos(theta)*cos(phi);

J       = [P.Ixx 0 -P.Ixz; 0 P.Iyy 0; -P.Ixz 0 P.Izz];
omega   = [p; q; r];
omega_d = J \ ([Lm; Mm; Nm] - cross(omega, J*omega));

phi_dot   = p + (q*sin(phi) + r*cos(phi))*tan(theta);
theta_dot = q*cos(phi) - r*sin(phi);
psi_dot   = (q*sin(phi) + r*cos(phi)) / max(cos(theta), 0.01);

cf = cos(phi); sf = sin(phi);
ct = cos(theta); st = sin(theta);
cp = cos(psi); sp = sin(psi);
R = [ ct*cp,  sf*st*cp - cf*sp,  cf*st*cp + sf*sp;
      ct*sp,  sf*st*sp + cf*cp,  cf*st*sp - sf*cp;
     -st,     sf*ct,             cf*ct ];
Ve = R*[u; v; w];

xdot = [u_dot; v_dot; w_dot; omega_d; phi_dot; theta_dot; psi_dot; Ve];
end