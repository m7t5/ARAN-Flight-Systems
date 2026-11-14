function Endurance_Animation_Video(params, sim_data, record_video)
% =========================================================================
% ARAN Flight Systems - File 4: 3D Animation & Battery Telemetry Video
% ينشئ لوحة تحكم مرئية ثلاثية الأبعاد مع عداد بطارية حي ويصدرها كملف فيديو
% متوافق كلياً مع MATLAB R2014a (باستخدام دوال set و VideoWriter القياسية)
% =========================================================================

    fig = figure('Name', 'ARAN Flight Systems - UAV Battery Endurance & Flight Time Simulator', ...
                 'Color', [0.08 0.10 0.14], 'Position', [60, 50, 1220, 680]);

    % إعداد تسجيل الفيديو إذا كان مفعلاً
    if record_video
        video_filename = 'ARAN_UAV_Battery_Endurance.avi';
        v_writer = VideoWriter(video_filename, 'Motion JPEG AVI');
        v_writer.FrameRate = 20;
        v_writer.Quality   = 95;
        open(v_writer);
        fprintf('>> جاري تسجيل الفيديو التوضيحي في الملف: %s\n', video_filename);
    end

    %% 1. النافذة اليسرى: الفضاء ثلاثي الأبعاد لحركة الطائرة (3D Flight Arena)
    ax3d = subplot(2, 2, [1 3]);
    set(ax3d, 'Color', [0.12 0.15 0.20], 'XColor', 'w', 'YColor', 'w', 'ZColor', 'w');
    hold(ax3d, 'on'); grid(ax3d, 'on'); axis(ax3d, 'equal');
    view(ax3d, 38, 26);
    xlim(ax3d, [-80 15]); ylim(ax3d, [-45 45]); zlim(ax3d, [0 params.alt_cruise + 10]);
    xlabel(ax3d, 'X Position (m)', 'Color', 'w', 'FontWeight', 'bold');
    ylabel(ax3d, 'Y Position (m)', 'Color', 'w', 'FontWeight', 'bold');
    zlabel(ax3d, 'Altitude Z (m)', 'Color', 'w', 'FontWeight', 'bold');
    title(ax3d, sprintf('3D Flight Profile: %s (%d mAh %dS)', params.uav_name, params.Cap_mAh, params.N_cells), ...
          'Color', 'w', 'FontSize', 11, 'FontWeight', 'bold');

    % رسم مهبط الإقلاع والهبوط (Landing Pad)
    theta_pad = linspace(0, 2*pi, 30);
    patch(4*cos(theta_pad), 4*sin(theta_pad), zeros(1,30), [0.25 0.30 0.38], ...
          'EdgeColor', 'c', 'LineWidth', 1.5, 'Parent', ax3d);

    % المسار المقطوع ومجسم الطائرة
    h_trail = plot3(ax3d, sim_data.X(1), sim_data.Y(1), sim_data.Z(1), 'c-', 'LineWidth', 2.0);
    h_arm1  = line([0 0], [0 0], [0 0], 'Color', 'w', 'LineWidth', 3.0, 'Parent', ax3d);
    h_arm2  = line([0 0], [0 0], [0 0], 'Color', 'w', 'LineWidth', 3.0, 'Parent', ax3d);
    h_uav   = plot3(ax3d, 0, 0, 0, 'o', 'MarkerSize', 10, 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'w');

    %% 2. النافذة اليمنى العليا: عداد البطارية الحي وشاشة القراءات (Live Battery HUD)
    ax_hud = subplot(2, 2, 2);
    set(ax_hud, 'Color', [0.10 0.12 0.16], 'XTick', [], 'YTick', [], 'XColor', [0.2 0.25 0.3], 'YColor', [0.2 0.25 0.3]);
    hold(ax_hud, 'on');
    xlim(ax_hud, [0 10]); ylim(ax_hud, [0 10]);
    title(ax_hud, 'Live Battery Telemetry & Endurance HUD', 'Color', 'w', 'FontSize', 11, 'FontWeight', 'bold');

    % رسم الإطار الخارجي لأيقونة البطارية
    patch([1.0 3.2 3.2 1.0], [1.2 1.2 8.2 8.2], [0.18 0.20 0.25], ...
          'EdgeColor', 'w', 'LineWidth', 2.5, 'Parent', ax_hud);
    % رأس البطارية العلوي
    patch([1.6 2.6 2.6 1.6], [8.2 8.2 8.7 8.7], 'w', 'EdgeColor', 'w', 'Parent', ax_hud);
    % شريط التعبئة المتحرك داخل البطارية
    h_batt_fill = patch([1.2 3.0 3.0 1.2], [1.4 1.4 8.0 8.0], [0.1 0.85 0.3], ...
                        'EdgeColor', 'none', 'Parent', ax_hud);
    h_soc_txt   = text(2.1, 4.7, '100%', 'Color', 'w', 'FontSize', 13, ...
                       'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'Parent', ax_hud);

    % النصوص الرقمية الحية (Digital Telemetry Readouts)
    h_txt_time = text(4.0, 7.8, 'Elapsed Time   : 00:00 (min:sec)', 'Color', 'w', 'FontSize', 10, 'FontWeight', 'bold', 'Parent', ax_hud);
    h_txt_rem  = text(4.0, 6.4, 'Remaining Time : --:-- (min:sec)', 'Color', [0.3 0.9 1.0], 'FontSize', 10, 'FontWeight', 'bold', 'Parent', ax_hud);
    h_txt_volt = text(4.0, 5.0, 'Terminal Volt  : 16.80 V', 'Color', 'g', 'FontSize', 10, 'FontWeight', 'bold', 'Parent', ax_hud);
    h_txt_curr = text(4.0, 3.6, 'Current Draw   : 00.0 A (000 W)', 'Color', [1.0 0.85 0.3], 'FontSize', 10, 'FontWeight', 'bold', 'Parent', ax_hud);
    h_txt_mode = text(4.0, 2.0, 'Flight Status  : TAKEOFF', 'Color', 'c', 'FontSize', 11, 'FontWeight', 'bold', 'Parent', ax_hud);

    %% 3. النافذة اليمنى السفلى: منحنى هبوط الجهد والشحن (Discharge Curves)
    ax_curve = subplot(2, 2, 4);
    set(ax_curve, 'Color', [0.12 0.15 0.20], 'XColor', 'w', 'YColor', 'w');
    hold(ax_curve, 'on'); grid(ax_curve, 'on');
    t_min_vec = sim_data.t / 60.0;
    plot(ax_curve, t_min_vec, sim_data.V_term, 'Color', [0.3 0.35 0.45], 'LineWidth', 1.2);
    plot(ax_curve, [0 t_min_vec(end)], [params.N_cells*params.V_cell_min params.N_cells*params.V_cell_min], 'r--', 'LineWidth', 1.2);
    h_volt_live = plot(ax_curve, t_min_vec(1), sim_data.V_term(1), 'g-', 'LineWidth', 2.2);
    h_volt_dot  = plot(ax_curve, t_min_vec(1), sim_data.V_term(1), 'yo', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
    xlim(ax_curve, [0 max(1, t_min_vec(end))]);
    ylim(ax_curve, [params.N_cells*3.1, params.N_cells*4.3]);
    xlabel(ax_curve, 'Flight Time (Minutes)', 'Color', 'w', 'FontWeight', 'bold');
    ylabel(ax_curve, 'Battery Voltage (V)', 'Color', 'w', 'FontWeight', 'bold');
    title(ax_curve, 'Real-Time Terminal Voltage Drop (Under Load)', 'Color', 'w', 'FontSize', 10, 'FontWeight', 'bold');

    %% 4. حلقة التحريك وتوليد الإطارات (Animation Loop)
    N = sim_data.N_steps;
    step_skip = max(1, round(N / 160)); % ضبط عدد الإطارات ليكون الفيديو سلساً وسريعاً
    arm_len   = 4.5;                    % طول ذراع الطائرة التوضيحي في الرسم الثلاثي
    mode_names = {'TAKEOFF (CLIMB)', 'HOVER STABILIZE', 'CRUISE PATROL', 'LOW BATTERY AUTO-LAND'};

    for k = 1:step_skip:N
        % استخراج القيم اللحظية
        tk    = sim_data.t(k);
        rem_s = max(0, sim_data.total_time_s - tk);
        soc_k = sim_data.SoC(k);
        vk    = sim_data.V_term(k);
        ik    = sim_data.I_batt(k);
        pk    = sim_data.P_total(k);
        xk    = sim_data.X(k);
        yk    = sim_data.Y(k);
        zk    = sim_data.Z(k);
        mk    = sim_data.Mode(k);

        % أ. تحديث موقع الطائرة ومسارها في الفضاء الثلاثي
        set(h_trail, 'XData', sim_data.X(1:k), 'YData', sim_data.Y(1:k), 'ZData', sim_data.Z(1:k));
        set(h_arm1,  'XData', [xk-arm_len xk+arm_len], 'YData', [yk-arm_len yk+arm_len], 'ZData', [zk zk]);
        set(h_arm2,  'XData', [xk-arm_len xk+arm_len], 'YData', [yk+arm_len yk-arm_len], 'ZData', [zk zk]);
        set(h_uav,   'XData', xk, 'YData', yk, 'ZData', zk);

        % ب. تحديث ارتفاع ولون شريط البطارية
        fill_top = 1.4 + (8.0 - 1.4) * (soc_k / 100.0);
        if soc_k > 50.0
            batt_col = [0.10 0.85 0.35]; % أخضر
        elseif soc_k > params.SoC_safe_min + 5.0
            batt_col = [1.00 0.75 0.10]; % أصفر / برتقالي
        else
            batt_col = [0.95 0.15 0.15]; % أحمر (تحذير هبوط)
        end
        set(h_batt_fill, 'YData', [1.4 1.4 fill_top fill_top], 'FaceColor', batt_col);
        set(h_uav, 'MarkerFaceColor', batt_col);
        set(h_soc_txt, 'String', sprintf('%.0f%%', soc_k));

        % ج. تحديث القراءات الرقمية على الشاشة
        el_min = floor(tk / 60);    el_sec = round(mod(tk, 60));
        rm_min = floor(rem_s / 60); rm_sec = round(mod(rem_s, 60));
        set(h_txt_time, 'String', sprintf('Elapsed Time   : %02d:%02d (min:sec)', el_min, el_sec));
        set(h_txt_rem,  'String', sprintf('Remaining Time : %02d:%02d (min:sec)', rm_min, rm_sec));
        set(h_txt_volt, 'String', sprintf('Terminal Volt  : %.2f V  (%.2f V/cell)', vk, vk/params.N_cells), 'Color', batt_col);
        set(h_txt_curr, 'String', sprintf('Current Draw   : %.1f A  (%.0f Watts)', ik, pk));
        set(h_txt_mode, 'String', sprintf('Flight Status  : %s', mode_names{mk}), 'Color', batt_col);

        % د. تحديث منحنى الفولتية الحي
        set(h_volt_live, 'XData', t_min_vec(1:k), 'YData', sim_data.V_term(1:k), 'Color', batt_col);
        set(h_volt_dot,  'XData', t_min_vec(k),   'YData', vk);

        drawnow;

        if record_video
            frame = getframe(fig);
            writeVideo(v_writer, frame);
        end
    end

    if record_video
        close(v_writer);
        fprintf('>> تم حفظ الفيديو بنجاح: %s\n', video_filename);
    end
end
