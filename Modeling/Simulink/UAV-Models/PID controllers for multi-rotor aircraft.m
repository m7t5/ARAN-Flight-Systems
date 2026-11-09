%% ========================================================================
%  Project: ARAN-Flight-Systems (𒀀𒊏𒀭)
%  Module : Closed-Loop 6-DOF Quadrotor UAV Simulink Model Generator
%  Path   : ARAN-Flight-Systems/Modeling/Simulink/UAV_Models_Simulink.m
%  Author : Mustafa Mahmoud Al-Khalifi
%  License: MIT License
%% ========================================================================
clc; clear; close all;

% 1. تحميل مكتبة Simulink الأساسية في الذاكرة لمنع خطأ عدم التعرف على البلوكات
load_system('simulink');

modelName = 'UAV_Models';

% إغلاق وحذف أي نسخة سابقة مفتوحة في الذاكرة لتجنب تعارض الملفات
if bdIsLoaded(modelName)
    close_system(modelName, 0);
end
if exist([modelName '.slx'], 'file')
    delete([modelName '.slx']);
end

% 2. إنشاء نموذج Simulink جديد وضبط إعدادات المحلل العددي (Solver)
new_system(modelName);
open_system(modelName);
set_param(modelName, ...
    'Solver', 'ode45', ...
    'StopTime', '15.0', ...
    'MaxStep', '0.01', ...
    'RelTol', '1e-4');

% 3. مصفوفة المعاملات الفيزيائية ومعاملات متحكم PID مع مرشح التفاضل (N = 100)
% الأعمدة: {اسم القناة، الكتلة/القصور الذاتي، التخميد، Kp، Ki، Kd، زمن الإشارة، القيمة المرجعية}
channels = {
    'Altitude_Z',  1.50,  0.200,  12.0,  2.0,  8.0,  '1.0', '10.0';  % الارتفاع بالمتر (10 m)
    'Roll_Phi',    0.03,  0.010,   2.5,  0.5,  0.6,  '2.0', '0.35';  % زاوية الميلان الجانبي بالراديان (~20 deg)
    'Pitch_Theta', 0.03,  0.010,   2.5,  0.5,  0.6,  '4.0', '0.25';  % زاوية الميلان الأمامي بالراديان (~14.3 deg)
    'Yaw_Psi',     0.05,  0.015,   3.0,  0.4,  0.9,  '6.0', '0.785'  % زاوية الانعطاف بالراديان (~45 deg)
};

N_filter = 100; % معامل مرشح التفاضل لمنع تضخيم الضوضاء

% 4. بناء الحلقات الأربع برمجياً وربطها داخل Simulink
for i = 1:size(channels, 1)
    chName   = channels{i, 1};
    inertia  = channels{i, 2};
    damping  = channels{i, 3};
    Kp       = channels{i, 4};
    Ki       = channels{i, 5};
    Kd       = channels{i, 6};
    stepTime = channels{i, 7};
    stepVal  = channels{i, 8};
    
    % الإزاحة الرأسية لمنع تداخل البلوكات في واجهة Simulink
    yOffset = (i - 1) * 140 + 50;
    
    % مسارات البلوكات داخل النموذج
    refBlock   = [modelName '/Ref_' chName];
    sumBlock   = [modelName '/Sum_' chName];
    pidBlock   = [modelName '/PID_' chName];
    satBlock   = [modelName '/Sat_' chName];
    plantBlock = [modelName '/UAV_Plant_' chName];
    muxBlock   = [modelName '/Mux_' chName];
    scopeBlock = [modelName '/Scope_' chName];
    
    % أ) إشارة الدخل المرجعية (Step Input)
    add_block('simulink/Sources/Step', refBlock, ...
        'Position', [50, yOffset, 80, yOffset+30], ...
        'Time', stepTime, ...
        'Before', '0', ...
        'After', stepVal);
        
    % ب) نقطة المقارنة وحساب الخطأ (Error Sum)
    add_block('simulink/Math Operations/Sum', sumBlock, ...
        'Position', [140, yOffset, 170, yOffset+30], ...
        'IconShape', 'round', ...
        'Inputs', '|+-');
        
    % ج) متحكم PID المفلتر: C(s) = ((Kp + Kd*N)s^2 + (Kp*N + Ki)s + Ki*N) / (s^2 + N*s)
    pidNumStr = sprintf('[%g %g %g]', (Kp + Kd*N_filter), (Kp*N_filter + Ki), (Ki*N_filter));
    pidDenStr = sprintf('[1 %g 0]', N_filter);
    add_block('simulink/Continuous/Transfer Fcn', pidBlock, ...
        'Position', [225, yOffset-5, 335, yOffset+35], ...
        'Numerator', pidNumStr, ...
        'Denominator', pidDenStr);
        
    % د) محدد التشبع الفيزيائي للمحركات (Actuator Saturation)
    add_block('simulink/Discontinuities/Saturation', satBlock, ...
        'Position', [390, yOffset, 420, yOffset+30], ...
        'UpperLimit', '50', ...
        'LowerLimit', '-50');
        
    % هـ) ديناميكا الطائرة المسيّرة: P(s) = 1 / (I*s^2 + c*s)
    plantDenStr = sprintf('[%g %g 0]', inertia, damping);
    add_block('simulink/Continuous/Transfer Fcn', plantBlock, ...
        'Position', [475, yOffset-5, 575, yOffset+35], ...
        'Numerator', '[1]', ...
        'Denominator', plantDenStr);
        
    % و) دامج الإشارات لعرض المرجع والاستجابة معاً (Mux)
    add_block('simulink/Signal Routing/Mux', muxBlock, ...
        'Position', [645, yOffset-10, 650, yOffset+40], ...
        'Inputs', '2', ...
        'DisplayOption', 'bar');
        
    % ز) شاشة عرض الاستجابة الزمنية (Scope)
    add_block('simulink/Sinks/Scope', scopeBlock, ...
        'Position', [705, yOffset, 740, yOffset+35]);
        
    % 5. توصيل خطوط الإشارة بين البلوكات (Signal Routing)
    add_line(modelName, ['Ref_' chName '/1'],       ['Sum_' chName '/1'],       'autorouting', 'on');
    add_line(modelName, ['Sum_' chName '/1'],       ['PID_' chName '/1'],       'autorouting', 'on');
    add_line(modelName, ['PID_' chName '/1'],       ['Sat_' chName '/1'],       'autorouting', 'on');
    add_line(modelName, ['Sat_' chName '/1'],       ['UAV_Plant_' chName '/1'], 'autorouting', 'on');
    add_line(modelName, ['UAV_Plant_' chName '/1'], ['Sum_' chName '/2'],       'autorouting', 'on');
    add_line(modelName, ['Ref_' chName '/1'],       ['Mux_' chName '/1'],       'autorouting', 'on');
    add_line(modelName, ['UAV_Plant_' chName '/1'], ['Mux_' chName '/2'],       'autorouting', 'on');
    add_line(modelName, ['Mux_' chName '/1'],       ['Scope_' chName '/1'],     'autorouting', 'on');
end

% 6. حفظ ملف Simulink بصيغة .slx وتشغيل المحاكاة
save_system(modelName);
sim(modelName);

fprintf('\n====================================================================\n');
fprintf(' [ARAN-Flight-Systems] Model "%s.slx" generated and simulated successfully.\n', modelName);
fprintf('====================================================================\n');
