function [P_total, Thrust_req] = Power_Consumption_Model(v_horiz, v_vert, params)
% =========================================================================
% ARAN Flight Systems - File 2: Aerodynamic & Electrical Power Model
% يحسب القدرة الكهربائية الكلية المسحوبة من البطارية (Watts) وقوة الدفع (N)
% بالاعتماد على نظرية كمية الحركة (Momentum Theory) ومقاومة الهواء
% =========================================================================

    % 1. حساب المساحة الكلية لأقراص المراوح (Total Rotor Disk Area)
    R_prop  = params.D_prop / 2.0;
    A_total = params.N_rotors * pi * (R_prop^2);

    % 2. حساب مقاومة الهواء الأفقية والعمودية (Parasitic Drag Force)
    F_drag_horiz = 0.5 * params.rho_air * params.Cd_A * (v_horiz^2);
    F_drag_vert  = 0.5 * params.rho_air * (params.Cd_A * 1.5) * abs(v_vert) * v_vert;

    % 3. قوة الدفع الكلية المطلوبة من المحركات (Total Thrust Required)
    W_uav      = params.m_total * params.g;
    Thrust_req = sqrt((W_uav + F_drag_vert)^2 + F_drag_horiz^2);

    % 4. السرعة المستحثة عند التحويم (Hover Induced Velocity)
    v_hover = sqrt(Thrust_req / (2.0 * params.rho_air * A_total));

    % 5. حساب السرعة المستحثة في الطيران الأمامي/العمودي (Glauert Iteration)
    v_i = v_hover;
    for iter = 1:4
        denom = sqrt((v_horiz^2) + (v_vert + v_i)^2);
        if denom > 0.01
            v_i = (v_hover^2) / denom;
        end
    end

    % 6. القدرة الميكانيكية الهوائية المطلوبة (Aerodynamic Power)
    P_induced   = (Thrust_req * v_i) / params.eta_prop;
    P_climb     = Thrust_req * max(-0.5 * v_hover, v_vert);
    P_parasitic = F_drag_horiz * v_horiz;
    P_aero      = max(15.0, P_induced + P_climb + P_parasitic);

    % 7. القدرة الكهربائية الكلية المسحوبة من البطارية (Total Electrical Power)
    P_motors = P_aero / params.eta_motor_esc;
    P_total  = P_motors + params.P_avionics;
end
