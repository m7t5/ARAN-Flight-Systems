function sim_data = Battery_Discharge_Calculator(params)
% =========================================================================
% ARAN Flight Systems - File 3: Battery Discharge & Flight Time Simulator
% يحاكي تفريغ البطارية ثانية بثانية ويحسب هبوط الجهد وزمن الطيران الفعلي
% =========================================================================

    dt        = params.dt;
    max_steps = 7200; % الحد الأقصى للمحاكاة (ساعتان)

    % تهيئة متجهات حفظ البيانات
    t_vec     = zeros(1, max_steps);
    SoC_vec   = zeros(1, max_steps);
    Voc_vec   = zeros(1, max_steps);
    Vterm_vec = zeros(1, max_steps);
    Ibatt_vec = zeros(1, max_steps);
    Ptot_vec  = zeros(1, max_steps);
    X_vec     = zeros(1, max_steps);
    Y_vec     = zeros(1, max_steps);
    Z_vec     = zeros(1, max_steps);
    Mode_vec  = zeros(1, max_steps); % 1=Takeoff, 2=Hover, 3=Cruise, 4=Landing

    % القيم الابتدائية للبطارية والموقع
    SoC_curr      = 100.0;                  % نسبة الشحن الابتدائية (%)
    Cap_Ah        = params.Cap_mAh / 1000;  % السعة بالأمبير-ساعة (Ah)
    Ah_remaining  = Cap_Ah;
    x_pos = 0; y_pos = 0; z_pos = 0;
    theta_orbit   = 0;
    orbit_radius  = 35.0;
    landing_flag  = false;
    t_safe_limit  = 0;

    k = 1;
    while k < max_steps
        t_curr = (k - 1) * dt;
        t_vec(k) = t_curr;

        % 1. تحديد طور الطيران والسرعات (Flight Phase State Machine)
        if ~landing_flag
            if z_pos < params.alt_cruise
                % طور الإقلاع العمودي (Takeoff)
                mode_id = 1;
                v_horiz = 0.0;
                v_vert  = params.v_climb;
                z_pos   = min(params.alt_cruise, z_pos + v_vert * dt);
            elseif t_curr < 45.0
                % طور التحويم وتثبيت الموقع (Hover Check)
                mode_id = 2;
                v_horiz = 0.0;
                v_vert  = 0.0;
            else
                % طور الطيران الأمامي والبحث في مسار دائري (Cruise Patrol)
                mode_id = 3;
                v_horiz = params.v_cruise;
                v_vert  = 0.0;
                omega_orbit = v_horiz / orbit_radius;
                theta_orbit = theta_orbit + omega_orbit * dt;
                x_pos = orbit_radius * cos(theta_orbit) - orbit_radius;
                y_pos = orbit_radius * sin(theta_orbit);
            end
        else
            % طور الهبوط الاضطراري الآمن عند وصول البطارية للحد الحرج (Auto-Landing)
            mode_id = 4;
            v_horiz = 0.0;
            v_vert  = -params.v_descent;
            z_pos   = max(0.0, z_pos + v_vert * dt);
        end

        % 2. حساب القدرة الكهربائية المطلوبة في هذه اللحظة
        [P_req, ~] = Power_Consumption_Model(v_horiz, v_vert, params);

        % 3. حساب الجهد المفتوح للبطارية (Open-Circuit Voltage vs SoC)
        s_norm   = max(0.01, SoC_curr / 100.0);
        V_cell_oc = 3.30 + 0.82 * s_norm - 0.18 * (s_norm^2) + 0.26 * (s_norm^3) - 0.03 / s_norm;
        V_cell_oc = max(3.20, min(params.V_cell_max, V_cell_oc));
        V_oc      = params.N_cells * V_cell_oc;

        % 4. حساب التيار المسحوب وجهد البطارية الفعلي تحت الحمل (Voltage Sag)
        % حل المعادلة التربيعية: R_int * I^2 - V_oc * I + P_req = 0
        discrim = (V_oc^2) - 4.0 * params.R_internal * P_req;
        if discrim < 0
            discrim = 0;
        end
        I_batt = (V_oc - sqrt(discrim)) / (2.0 * params.R_internal);
        V_term = V_oc - I_batt * params.R_internal;

        % 5. تحديث السعة المتبقية ونسبة الشحن (مع تأثير Peukert)
        I_eff        = I_batt * ((I_batt / Cap_Ah)^(params.k_peukert - 1.0));
        dAh          = (I_eff * dt) / 3600.0;
        Ah_remaining = max(0.0, Ah_remaining - dAh);
        SoC_curr     = (Ah_remaining / Cap_Ah) * 100.0;

        % حفظ القيم في المتجهات
        SoC_vec(k)   = SoC_curr;
        Voc_vec(k)   = V_oc;
        Vterm_vec(k) = V_term;
        Ibatt_vec(k) = I_batt;
        Ptot_vec(k)  = P_req;
        X_vec(k)     = x_pos;
        Y_vec(k)     = y_pos;
        Z_vec(k)     = z_pos;
        Mode_vec(k)  = mode_id;

        % 6. فحص شرط تفعيل الهبوط الاضطراري (وصول الشحن إلى 20% أو الجهد الحرج)
        if ~landing_flag && (SoC_curr <= params.SoC_safe_min || V_term <= params.N_cells * params.V_cell_min)
            landing_flag = true;
            t_safe_limit = t_curr;
        end

        % إنهاء المحاكاة فور ملامسة الطائرة للأرض بعد الهبوط
        if landing_flag && z_pos <= 0.0
            break;
        end

        k = k + 1;
    end

    % قص المتجهات على طول الرحلة الفعلي
    sim_data.N_steps      = k;
    sim_data.t            = t_vec(1:k);
    sim_data.SoC          = SoC_vec(1:k);
    sim_data.V_oc         = Voc_vec(1:k);
    sim_data.V_term       = Vterm_vec(1:k);
    sim_data.I_batt       = Ibatt_vec(1:k);
    sim_data.P_total      = Ptot_vec(1:k);
    sim_data.X            = X_vec(1:k);
    sim_data.Y            = Y_vec(1:k);
    sim_data.Z            = Z_vec(1:k);
    sim_data.Mode         = Mode_vec(1:k);

    % حساب الملخصات الهندسية النهائية
    sim_data.total_time_s   = sim_data.t(end);
    sim_data.total_time_min = sim_data.total_time_s / 60.0;
    sim_data.safe_time_min  = t_safe_limit / 60.0;

    hover_idx = find(sim_data.Mode == 2);
    cruise_idx = find(sim_data.Mode == 3);
    if ~isempty(hover_idx)
        sim_data.I_hover_avg = mean(sim_data.I_batt(hover_idx));
        sim_data.P_hover_avg = mean(sim_data.P_total(hover_idx));
    else
        [sim_data.P_hover_avg, ~] = Power_Consumption_Model(0, 0, params);
        sim_data.I_hover_avg = sim_data.P_hover_avg / (params.N_cells * params.V_cell_nom);
    end

    if ~isempty(cruise_idx)
        sim_data.I_cruise_avg = mean(sim_data.I_batt(cruise_idx));
        sim_data.P_cruise_avg = mean(sim_data.P_total(cruise_idx));
    else
        sim_data.I_cruise_avg = sim_data.I_hover_avg;
        sim_data.P_cruise_avg = sim_data.P_hover_avg;
    end
end
