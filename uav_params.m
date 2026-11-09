function P = uav_params()
P.m   = 2.5;
P.g   = 9.81;
P.rho = 1.225;
P.S   = 0.55;
P.c   = 0.22;
P.b   = 1.8;

P.Ixx = 0.18;  P.Iyy = 0.22;  P.Izz = 0.35;  P.Ixz = 0.02;

P.CL0  = 0.25;   P.CLa = 4.5;   P.CLde = 0.30;
P.CD0  = 0.03;   P.K   = 0.05;

P.Cm0  = -0.05;  P.Cma = -0.6;  P.Cmq  = -8.0;  P.Cmde = -0.9;

P.CYb  = -0.30;  P.CYdr = 0.12;

P.Clb  = -0.10;  P.Clp = -0.40; P.Clr = 0.05;   P.Clda = 0.25;

P.Cnb  =  0.08;  P.Cnp = -0.02; P.Cnr = -0.10;  P.Cndr = -0.06;

P.lim  = 25*pi/180;
end