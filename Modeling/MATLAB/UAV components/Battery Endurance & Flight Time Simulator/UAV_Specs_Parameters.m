function params = UAV_Specs_Parameters()
% =========================================================================
% ARAN Flight Systems - File 1: UAV & Battery Specifications
% يحدد هذا الملف جميع المواصفات الفيزيائية للطائرة المسيرة والبطارية
% متوافق مع MATLAB R2014a وجميع الإصدارات الأحدث
% =========================================================================

    %% 1. مواصفات هيكل الطائرة المسيرة والوزن (UAV Mass & Frame Specs)
    params.uav_name      = 'ARAN-F450 Quadcopter';
    params.m_frame       = 0.85;      % وزن الهيكل والمحركات والإلكترونيات (kg)
    params.m_payload     = 0.15;      % وزن الحمولة الإضافية / الكاميرا (kg)
    params.m_battery     = 0.42;      % وزن البطارية (kg)
    params.m_total       = params.m_frame + params.m_payload + params.m_battery;
    params.g             = 9.81;      % تسارع الجاذبية الأرضية (m/s^2)
    params.rho_air       = 1.225;     % كثافة الهواء عند سطح البحر (kg/m^3)

    %% 2. مواصفات منظومة الدفع والمراوح (Propulsion & Aerodynamics)
    params.N_rotors      = 4;         % عدد المحركات (رباعية المراوح)
    params.D_prop_inch   = 10.0;      % قطر المروحة بالإنش (10 inch)
    params.D_prop        = params.D_prop_inch * 0.0254; % قطر المروحة بالمتر (m)
    params.eta_prop      = 0.68;      % الكفاءة الهوائية للمروحة (Figure of Merit)
    params.eta_motor_esc = 0.82;      % الكفاءة الكهروميكانيكية للمحرك و ESC
    params.Cd_A          = 0.045;     % معامل السحب مضروباً بالمساحة الأمامية (m^2)
    params.P_avionics    = 9.0;       % القدرة المستهلكة للإلكترونيات ومتحكم الطيران (Watts)

    %% 3. مواصفات البطارية (LiPo Battery Specifications)
    params.Cap_mAh       = 5000;      % سعة البطارية الاسمية (mAh)
    params.N_cells       = 4;         % عدد الخلايا على التوالي (4S LiPo)
    params.V_cell_max    = 4.20;      % أقصى جهد للخلية عند الشحن الكامل 100% (V)
    params.V_cell_nom    = 3.70;      % الجهد الاسمي للخلية (V)
    params.V_cell_min    = 3.35;      % الحد الأدنى الآمن لجهد الخلية تحت الحمل (V)
    params.R_cell_int    = 0.0075;    % المقاومة الداخلية للخلية الواحدة (Ohm)
    params.R_internal    = params.N_cells * params.R_cell_int; % المقاومة الكلية (Ohm)
    params.SoC_safe_min  = 20.0;      % نسبة الشحن الحرجة لبدء الهبوط الاضطراري (%)
    params.k_peukert     = 1.04;      % معامل بوكيرت لتأثير سحب التيار العالي

    %% 4. إعدادات مهمة الطيران والمحاكاة (Mission Profile Settings)
    params.dt            = 1.0;       % خطوة المحاكاة الزمنية (1 second)
    params.alt_cruise    = 25.0;      % ارتفاع الطيران المرجعي (m)
    params.v_climb       = 2.5;       % سرعة الإقلاع العمودي (m/s)
    params.v_descent     = 1.8;       % سرعة الهبوط الآمن (m/s)
    params.v_cruise      = 6.0;       % سرعة الطيران الأمامي أثناء الدورية (m/s)
end
