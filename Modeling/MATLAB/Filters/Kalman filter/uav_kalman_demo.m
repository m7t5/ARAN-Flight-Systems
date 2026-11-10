%% UAV Kalman Filter - تقدير الموقع والسرعة (بنية حلقة متغيرة زمنياً)
% مناسب للطائرات بدون طيار أحادية البعد أو مبسطة، مع إمكانية التوسع مباشرة إلى ثلاثي الأبعاد
clear; clc; close all;

%% 1. إعدادات المعلمات
dt = 0.1;                % فترة أخذ العينات (ثانية)
T = 50;                  % مدة المحاكاة الإجمالية (ثانية)
N = T / dt;              % إجمالي عدد الخطوات الزمنية

% مصفوفات فضاء الحالة (نموذج سرعة ثابتة: الحالة = [الموقع; السرعة])
% x(k+1) = A * x(k) + B * u + w
A = [1, dt; 
     0, 1];
B = [0.5*dt^2; 
     dt];                % مصفوفة التحكم (إذا كان هناك إدخال تسارع، هنا نفترض أن u هو التسارع)
C = [1, 0];              % مصفوفة القياس (نقيس الموقع فقط)

% إعدادات ضوضاء كالمان (تحتاج إلى التعديل وفقاً للمستشعر الفعلي)
Q = diag([0.1, 0.5]);    % تباين ضوضاء العملية (عدم اليقين في النموذج، يتعلق بالرياح/الاهتزاز)
R = 2.0;                 % تباين ضوضاء القياس (دقة GPS/البارومتر، يتطلب قيمة أكبر عند سوء الإشارة)

%% 2. توليد البيانات الحقيقية والقياسات (للمحاكاة والتحقق)
% إدخال تسارع حقيقي (على سبيل المثال من مقياس التسارع، هنا نفترض حركة تسارع متناغمة)
t = (0:N-1) * dt;
u_true = 0.5 * sin(0.5 * t);   % إدخال تسارع افتراضي

% تهيئة الحالة الحقيقية
x_true = zeros(2, N);
x_true(:,1) = [0; 0];          % الموقع والسرعة الأولية

% توليد الحالة الحقيقية (بدون ضوضاء)
for k = 2:N
    x_true(:,k) = A * x_true(:,k-1) + B * u_true(k-1);
end

% توليد قياسات ضوضائية (الموقع فقط)
y_meas = x_true(1,:) + sqrt(R) * randn(1, N);

%% 3. تهيئة كالمان فلتر
x_est = zeros(2, N);           % مصفوفة تخزين نتائج التقدير
x_est(:,1) = [0; 0];           % تقدير الحالة الأولية (يمكن ضبطه وفقاً للحالة الفعلية)
P = eye(2);                    % مصفوفة التغاير الأولية للخطأ

% تخزين تغاير الخطأ للتشخيص
P_store = zeros(2, 2, N);
P_store(:,:,1) = P;

%% 4. حلقة كالمان الرئيسية (تحديث الوقت + تحديث القياس)
for k = 2:N
    % --- الخطوة 1: التنبؤ (تحديث الوقت) ---
    % التنبؤ بالحالة: x(k|k-1) = A * x(k-1|k-1) + B * u(k-1)
    x_pred = A * x_est(:,k-1) + B * u_true(k-1);
    
    % التنبؤ بالتغاير: P(k|k-1) = A * P(k-1|k-1) * A' + Q
    P_pred = A * P * A' + Q;
    
    % --- الخطوة 2: التصحيح (تحديث القياس) ---
    % حساب مكسب كالمان: K = P_pred * C' / (C * P_pred * C' + R)
    S = C * P_pred * C' + R;       % تباين الابتكار
    K = P_pred * C' / S;           % مكسب كالمان
    
    % تحديث الحالة: x(k|k) = x_pred + K * (y(k) - C * x_pred)
    innovation = y_meas(k) - C * x_pred;
    x_est(:,k) = x_pred + K * innovation;
    
    % تحديث التغاير: P(k|k) = (I - K*C) * P_pred
    P = (eye(2) - K * C) * P_pred;
    P_store(:,:,k) = P;
end

%% 5. رسم النتائج
figure('Name', 'UAV Kalman Filter Results', 'Color', 'w');

% الموقع
subplot(2,1,1);
plot(t, x_true(1,:), 'b-', 'LineWidth', 1.5); hold on;
plot(t, y_meas, 'g.', 'MarkerSize', 6);
plot(t, x_est(1,:), 'r--', 'LineWidth', 1.5);
xlabel('Time (s)'); ylabel('Position (m)');
legend('True Position', 'Noisy Measurement', 'Kalman Estimate', 'Location', 'best');
title('UAV Position Estimation');
grid on;

% السرعة (السرعة الحقيقية غير مقاسة مباشرة، لكن كالمان يقدم تقديراً)
subplot(2,1,2);
plot(t, x_true(2,:), 'b-', 'LineWidth', 1.5); hold on;
plot(t, x_est(2,:), 'r--', 'LineWidth', 1.5);
xlabel('Time (s)'); ylabel('Velocity (m/s)');
legend('True Velocity', 'Kalman Estimate', 'Location', 'best');
title('UAV Velocity Estimation (Inferred)');
grid on;

%% 6. حساب مؤشرات الخطأ
pos_rmse = sqrt(mean((x_true(1,:) - x_est(1,:)).^2));
vel_rmse = sqrt(mean((x_true(2,:) - x_est(2,:)).^2));
fprintf('Position RMSE: %.4f m\n', pos_rmse);
fprintf('Velocity RMSE: %.4f m/s\n', vel_rmse);
