<div dir="rtl">

# 𒀀𒊏𒀭 | ARAN Flight Systems — Simulink UAV Control Architecture
## نمذجة ومحاكاة نظام التحكم المغلق للطائرة المسيّرة في بيئة Simulink

![MATLAB](https://img.shields.io/badge/MATLAB-R2014a%2B-orange.svg)
![Simulink](https://img.shields.io/badge/Simulink-Closed--Loop_PID-blue.svg)
![Architecture](https://img.shields.io/badge/Control-4--Channel_Quadrotor-success.svg)
![License](https://img.shields.io/badge/License-MIT-lightgrey.svg)


---

## 1. البنية الهندسية لحلقات التحكم (Control Loop Architecture)

يتكون النموذج من أربع قنوات تحكم مستقلة مغلقة الحلقة (**Closed-Loop Channels**) تشمل:
1. **قناة الارتفاع الرأسي (Altitude Control - $Z$):** تتبّع الارتفاع المرجعي بالمتر مع تعويض التخميد الديناميكي الهوائي.
2. **قناة الميلان الجانبي (Roll Control - $\phi$):** تثبيت زاوية الدوران حول المحور الطولي $X$.
3. **قناة الميلان الأمامي (Pitch Control - $\theta$):** تثبيت زاوية الدوران حول المحور العرضي $Y$.
4. **قناة الانعطاف الاتجاهي (Yaw Control - $\psi$):** التحكم بزاوية التوجيه حول المحور الرأسي $Z$.

### مسار الإشارة داخل كل قناة في Simulink:

```text
[Reference Step] ---> ( + / - ) ---> [Filtered PID Controller] ---> [Actuator Saturation] ---> [UAV Rigid-Body Plant] ---> [Mux & Scope]
                          ^                                                                               |
                          |_______________________________________________________________________________|
                                                       (Closed-Loop Feedback)
```

---

## 2. النمذجة الرياضية (Mathematical Formulation)

### أ) دالة التحويل لديناميكا الطائرة (UAV Plant Dynamics)
تُمثَّل كل قناة من قنوات الحركة الخطية والدورانية بدالة تحويل من الدرجة الثانية تتضمن القصور الذاتي أو الكتلة ($M_i$) ومعامل التخميد الهوائي ($c_i$):

$$P_i(s) = \frac{1}{M_i s^2 + c_i s}$$

### ب) متحكم PID مع مرشح التفاضل (Filtered PID Controller)
لتجنب الحلقات الجبرية (Algebraic Loops) ومنع تضخيم الضوضاء عالية التردد في الفرع التفاضلي، صيغ المتحكم بدالة تحويل كسرية صحيحة (Proper Transfer Function) بمعامل ترشيح $N = 100$:

$$C_{PID}(s) = K_p + \frac{K_i}{s} + \frac{K_d N s}{s + N} = \frac{(K_p + K_d N)s^2 + (K_p N + K_i)s + K_i N}{s^2 + N s}$$

---

## 3. جدول المعاملات الفيزيائية ومعاملات الضبط (System & Tuning Parameters)

| القناة (Channel) | الرمز | الكتلة / عزم القصور ($M_i$) | معامل التخميد ($c_i$) | $K_p$ | $K_i$ | $K_d$ | الإشارة المرجعية (Step Reference) | حد التشبع (Saturation) |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Altitude ($Z$)** | $z$ | $1.50\text{ kg}$ | $0.200$ | $12.0$ | $2.0$ | $8.0$ | $10.0\text{ m}$ عند $t = 1\text{ s}$ | $\pm 50\text{ N}$ |
| **Roll ($\phi$)** | $\phi$ | $0.03\text{ kg}\cdot\text{m}^2$ | $0.010$ | $2.5$ | $0.5$ | $0.6$ | $0.35\text{ rad}$ عند $t = 2\text{ s}$ | $\pm 50\text{ N}\cdot\text{m}$ |
| **Pitch ($\theta$)** | $\theta$ | $0.03\text{ kg}\cdot\text{m}^2$ | $0.010$ | $2.5$ | $0.5$ | $0.6$ | $0.25\text{ rad}$ عند $t = 4\text{ s}$ | $\pm 50\text{ N}\cdot\text{m}$ |
| **Yaw ($\psi$)** | $\psi$ | $0.05\text{ kg}\cdot\text{m}^2$ | $0.015$ | $3.0$ | $0.4$ | $0.9$ | $0.785\text{ rad}$ عند $t = 6\text{ s}$ | $\pm 50\text{ N}\cdot\text{m}$ |

---

## 4. طريقة التشغيل وتوليد ملف `.slx` (Execution Guide)

1. استنسخ المستودع أو انتقل إلى مجلد Simulink داخل بيئة **MATLAB**:
   ```matlab
   cd(ARAN-Flight-Systems/Modeling/Simulink/UAV-Models
/PID controllers for multi-rotor aircraft.m
)
   ```
2. شغّل السكربت المولد للنموذج في نافذة الأوامر (**Command Window**):
   ```matlab
Modeling/Simulink/UAV-Models/PID controllers for multi-rotor aircraft.m
```
3. سيقوم السكربت تلقائياً بالخطوات التالية دون أي تدخل يدوي:
   * تحميل مكتبة Simulink الأساسية في الذاكرة (`load_system`).
   * بناء القنوات الأربع وتوصيل البلوكات وضبط المحلل العددي `ode45` لزمن محاكاة $15\text{ s}$.
   * حفظ الملف النهائي باسم **`UAV_Models.slx`** في نفس المجلد.
   * تشغيل المحاكاة تلقائياً؛ ويمكنك النقر المزدوج على أي بلوك **Scope** لمعاينة تطابق الاستجابة الفعلية مع الإشارة المرجعية.

---

## 5. محتويات المجلد (Directory Contents)

* `Modeling/Simulink/UAV-Models/PID controllers for multi-rotor aircraft.m` — السكربت البرمجي لتوليد ومحاكاة نموذج 

---


</div>
