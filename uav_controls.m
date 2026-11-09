function [de, da, dr] = uav_controls(t, trim)
de = trim.de;  da = 0;  dr = 0;
if trim.on
    d = pi/180;
    if t >= 2  && t < 2.5,  de = de + 3*d;  end
    if t >= 2.5 && t < 3,   de = de - 3*d;  end
    if t >= 6  && t < 7,    da =  5*d;      end
    if t >= 7  && t < 8,    da = -5*d;      end
    if t >= 11 && t < 12,   dr =  5*d;      end
    if t >= 12 && t < 13,   dr = -5*d;      end
end
lim = 25*pi/180;
de = max(min(de, lim), -lim);
da = max(min(da, lim), -lim);
dr = max(min(dr, lim), -lim);
end