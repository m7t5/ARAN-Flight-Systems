%% ========================================================================
%  ARAN Flight Systems - File 5: Main UAV Flight Time & Endurance App
%  الملف الرئيسي لتشغيل محاكي حساب وقت الطيران واستهلاك البطارية وتصدير الفيديو
%  طريقة التشغيل: ضع الملفات الخمسة في مجلد واحد واضغط Run (أو F5) على هذا الملف
% =========================================================================
clear; clc; close all;

fprintf('===================================================================\n');
fprintf('   ARAN FLIGHT SYSTEMS - UAV BATTERY ENDURANCE & FLIGHT TIME SIM   \n');
fprintf('===================================================================\n\n');

%% 1. استدعاء مواصفات الطائرة والبطارية (File 1)
params = UAV_Specs_Parameters();

fprintf('[1] مواصفات الطائرة والبطارية المختارة:\n');
fprintf('    - الطراز                 : %s\n', params.uav_name);
fprintf('    - الوزن الكلي للإقلاع     : %.2f kg\n', params.m_total);
fprintf('    - قطر المراوح            : %.1f inch (%d rotors)\n', params.D_prop_inch, params.N_rotors);
fprintf('    - البطارية               : %d mAh | %dS LiPo (%.1f V Max)\n', ...
        params.Cap_mAh, params.N_cells, params.N_cells * params.V_cell_max);
fprintf('    - حد الأمان للهبوط (SoC) : %.0f%%\n\n', params.SoC_safe_min);

%% 2. تشغيل محاكاة استهلاك القدرة وتفريغ البطارية (Files 2 & 3)
sim_data = Battery_Discharge_Calculator(params);

total_min = floor(sim_data.total_time_s / 60);
total_sec = round(mod(sim_data.total_time_s, 60));
safe_min  = floor((sim_data.safe_time_min * 60) / 60);
safe_sec  = round(mod(sim_data.safe_time_min * 60, 60));

fprintf('[2] نتائج حساب سحب التيار ووقت الطيران الفعلي:\n');
fprintf('    - متوسط التيار في التحويم (Hover)   : %.2f Amps (%.1f Watts)\n', ...
        sim_data.I_hover_avg, sim_data.P_hover_avg);
fprintf('    - متوسط التيار في الطيران (Cruise)  : %.2f Amps (%.1f Watts)\n', ...
        sim_data.I_cruise_avg, sim_data.P_cruise_avg);
fprintf('    - وقت المهمة الآمن (حتى %0.f%% شحن)    : %02d دقيقة و %02d ثانية (%.2f min)\n', ...
        params.SoC_safe_min, safe_min, safe_sec, sim_data.safe_time_min);
fprintf('    - إجمالي زمن الطيران حتى الهبوط     : %02d دقيقة و %02d ثانية (%.2f min)\n\n', ...
        total_min, total_sec, sim_data.total_time_min);

%% 3. تشغيل الأنيميشن ثلاثي الأبعاد وحفظ الفيديو التوضيحي (File 4)
record_video = true; % اجعلها false إذا أردت مشاهدة العرض بدون حفظ ملف فيديو .avi
Endurance_Animation_Video(params, sim_data, record_video);
