<div dir="rtl" align="right">

# هندسة الـ Fault-Tolerant Control (التحكم المتسامح مع الأعطال): خوارزمية التضحية بمحور الـ Yaw لإنقاذ الطائرة الرباعية بثلاث مراوح

<div align="center">

![ARAN Flight Systems](https://img.shields.io/badge/ARAN-Flight%20Systems-blue?style=for-the-badge)
![Doc ID](https://img.shields.io/badge/Doc%20ID-ARAN__ENG__005-green?style=for-the-badge)
![Category](https://img.shields.io/badge/Category-Advanced%20Flight%20Control-red?style=for-the-badge)

**إعادة هيكلة مصفوفة توزيع القوى برمجياً لمنع السقوط الحر عند الفقدان الكامل لأحد المحركات في الجو**

</div>

---

## نظرة عامة والمعضلة الفيزيائية

تُصنف الطائرة الرباعية القياسية ميكانيكياً كنظام **Underactuated System** (نظام ناقص المشغلات)؛ فهي تمتلك 6 **Degrees of Freedom - DOF** (درجات حرية: 3 خطية و3 دورانية)، بينما تعتمد على 4 **Actuators** (مشغلات/محركات) فقط للتحكم بها. في الطيران الطبيعي، تُستخدم هذه المحركات الأربعة للتحكم المباشر في أربع قيم أساسية: قوة الدفع الكلية (Total Thrust)، وزوايا الـ **Roll** (الالتفاف)، والـ **Pitch** (الانحدار)، والـ **Yaw** (الانعراج).

عند حدوث عطل كامل في أحد المحركات أثناء الطيران — سواء بسبب احتراق الـ **ESC** (متحكم السرعة الإلكتروني) أو انكسار إحدى الـ **Propellers** (المراوح) — يتبقى للطائرة 3 محركات فقط. إذا استمر الـ **Flight Controller** (الطيار الآلي) في استخدام خوارزميات الـ **PID** (التحكم التناسبي التكاملي التفاضلي) التقليدية، فستنقلب الطائرة وتسقط فوراً لسبب فيزيائي حتمي:

> **لماذا يفشل متحكم الـ PID التقليدي عند تعطل محرك؟**
> عند توقف المحرك رقم (4) مثلاً، يختل توازن عزم الدوران العكسي. يحاول متحكم الـ Yaw التقليدي منع الطائرة من الدوران حول نفسها عبر خفض سرعة المحرك المقابل له قطرياً (المحرك رقم 3). وبما أن المحرك رقم (3) هو الوحيد القادر على موازنة ميلان الطائرة، فإن خفض سرعته يؤدي إلى انهيار قوة الرفع في ذلك الجانب وانقلاب الطائرة رأساً على عقب خلال أجزاء من الثانية.

---

## الحل الهندسي: مبدأ الـ Relaxed Hover (التحويم المرن)

الحل الهندسي المبتكر في مختبرات المعهد الفدرالي السويسري (ETH Zurich) وجامعة دلفت (TU Delft) يقوم على قاعدة حاسمة: **بثلاثة محركات، يمكنك التحكم في 3 متغيرات مستقلة فقط؛ لذا يجب التضحية بالمتغير الرابع فوراً.**

بما أن بقاء الطائرة أفقية في الجو يتطلب الحفاظ على الارتفاع ($Z$) وزاويتي الـ Roll ($\phi$) والـ Pitch ($\theta$)، يقوم النظام بإلغاء السيطرة على زاوية الـ Yaw ($\psi$) تماماً، والتحول إلى نظام **Reduced Attitude Control** (التحكم المختزل بالوضعية).

| الحالة | المتغيرات المتحكم بها | المتغير المُضحى به | سلوك الطائرة الفيزيائي في الجو |
|---:|---:|---:|---:|
| **الطيران الطبيعي (4 محركات)** | Thrust, Roll, Pitch, Yaw | لا يوجد | ثبات كامل في الموقع والاتجاه الزاوي |
| **حالة الطوارئ (3 محركات)** | Thrust, Roll, Pitch | **Yaw Rate ($\dot{\psi}$)** | تدور الطائرة حول نفسها بسرعة ثابتة مع بقائها أفقية ومستقرة الارتفاع |

في هذا الوضع، يُسمح للطائرة بالدوران الحر حول محور يُسمى **Primary Thrust Axis** (محور الدفع الرئيسي) بمعدل سرعة زاوية ثابتة ($\omega_z \neq 0$)، بينما تتولى المحركات الثلاثة المتبقية تعديل سرعاتها دورياً بتناغم مع سرعة الدوران للحفاظ على توازن الطائرة ومنع انقلابها حتى تهبط بسلام.

---

## الصياغة الرياضية وإعادة تشكيل الـ Control Allocation

في البنية البرمجية الحديثة للطيار الآلي (مثل معمارية **Dynamic Control Allocation** في نظام PX4)، يتم ربط أوامر العزوم المطلوبة بقوى المحركات عبر **Effectiveness Matrix** (مصفوفة الفعالية) ورمزها $\mathbf{B}$:

$$\begin{bmatrix} F_z \\ \tau_x \\ \tau_y \\ \tau_z \end{bmatrix} = \begin{bmatrix} -c_T & -c_T & -c_T & -c_T \\ -l c_T & l c_T & l c_T & -l c_T \\ l c_T & -l c_T & l c_T & -l c_T \\ c_Q & c_Q & -c_Q & -c_Q \end{bmatrix} \begin{bmatrix} u_1 \\ u_2 \\ u_3 \\ u_4 \end{bmatrix}$$

حيث:
* **$F_z$:** قوة الدفع الكلية على المحور العمودي.
* **$\tau_x, \tau_y, \tau_z$:** عزوم الدوران حول محاور Roll و Pitch و Yaw.
* **$c_T, c_Q$:** معاملات الدفع والسحب الهوائي للمروحة.
* **$l$:** طول ذراع المحرك عن مركز الثقل **Center of Gravity - CG**.
* **$u_1 \dots u_4$:** مربع السرعة الزاوية لكل محرك ($\omega_i^2$).

### التعديل البرمجي لحظة اكتشاف العطل

بمجرد اكتشاف توقف المحرك الرابع ($u_4 = 0$)، يقوم النظام بتنفيذ خطوتين رياضيتين خلال دورة معالجة واحدة:
1. **حذف العمود الرابع** من مصفوفة الفعالية $\mathbf{B}$ (لأن المحرك الرابع أصبح خارج الخدمة).
2. **حذف الصف الرابع** الخاص بعزم الانعراج ($\tau_z$) أو ضرب وزنه في مصفوفة الأولويات بـ `0`، لتتحول المعادلة إلى نظام خطي قابل للحل بأبعاد $3 \times 3$:

$$\begin{bmatrix} F_z \\ \tau_x \\ \tau_y \end{bmatrix} = \mathbf{B}_{\text{reduced (3×3)}} \begin{bmatrix} u_1 \\ u_2 \\ u_3 \end{bmatrix}$$

وبأخذ المعكوس المباشر أو **Pseudo-Inverse** (المعكوس الزائف) للمصفوفة المختزلة $\mathbf{B}_{\text{reduced}}^{-1}$، يحسب الطيار الآلي السرعات الدقيقة للمحركات الثلاثة المتبقية لتوليد الدفع والتوازن الأفقي دون الاكتراث بعزم الدوران حول محور الـ Yaw.

---

## التسلسل المنطقي للخوارزمية داخل الطيار الآلي

| المرحلة | العملية الهندسية | الآلية البرمجية والفيزيائية |
|---:|---:|---:|
| **1** | **Fault Detection and Isolation - FDI** (اكتشاف وعزل العطل) | رصد انقطاع التغذية الراجعة من **ESC Telemetry** (بيانات متحكم السرعة) أو ملاحظة فجوة مستمرة بين أمر المحرك واستجابة الـ **Gyroscope** (الجيروسكوب) تتجاوز 50 ملي ثانية. |
| **2** | **Matrix Reconfiguration** (إعادة تشكيل المصفوفة) | تصفير عمود المحرك المتعطل في مصفوفة $\mathbf{B}$ وإلغاء قيد محور الـ Yaw من حسابات الـ Control Allocator. |
| **3** | **INDI Control Loop** (حلقة الانعكاس الديناميكي) | تفعيل خوارزمية **Incremental Nonlinear Dynamic Inversion - INDI** (الانعكاس الديناميكي غير الخطي التزايدي) للتعويض عن القوى الهوائية المعقدة الناتجة عن الدوران السريع. |
| **4** | **Rotating Frame Transformation** (تحويل الإطار المرجعي) | تحويل أوامر الهبوط والموقع باستمرار باستخدام زاوية الـ Yaw اللحظية؛ لأن الأمام والخلف في هيكل الطائرة يتغيران عدة مرات في الثانية الواحدة. |

---

## الشروط والقيود الهندسية لنجاح الإنقاذ

لا يمكن لأي طائرة رباعية النجاة بثلاث مراوح إلا إذا استوفت الشروط التصميمية التالية:

1. **نسبة الدفع إلى الوزن (Thrust-to-Weight Ratio):**
   يجب ألا تقل نسبة الدفع الكلية للطائرة السليمة عن **2.5 : 1**. السبب الهندسي هو أنه عند تعطل المحرك رقم (4)، يجب أن يخفض المحرك المقابل له قطرياً (رقم 3) سرعته للحفاظ على توازن العزم حول المركز، مما يعني أن المحركين المتبقيين (1 و 2) سيتحملان وحدهما أكثر من 70% من وزن الطائرة بالإضافة إلى قوة الطرد المركزي.

2. **مدى قراءة الـ Gyroscope (Gyro Saturation Limit):**
   بسبب غياب الكبح على محور الـ Yaw، ستدور الطائرة حول نفسها بسرعة تتراوح بين $800^\circ/\text{s}$ و $1500^\circ/\text{s}$. إذا كان حساس الـ **IMU** (وحدة القياس بالقصور الذاتي) مضبوطاً على مدى منخفض (مثل $\pm 500^\circ/\text{s}$)، فسيحدث **Sensor Saturation** (تشبع الحساس) وتفقد الطائرة قدرتها على تقدير زاوية ميلانها، لذا يجب ضبط المدى البرمجي للحساس على $\pm 2000^\circ/\text{s}$.

3. **تردد حلقة التحكم (Control Loop Rate):**
   نظراً لأن الطائرة تدور بسرعة عالية، فإن أي تأخر زمني (Latency) في إرسال أوامر الـ **PWM** (تضمين عرض النبضة) أو **DShot** (بروتوكول الإشارة الرقمية للمحركات) سيؤدي إلى تطبيق العزم في زاوية خاطئة. يُشترط تشغيل حلقة التحكم بسرعة لا تقل عن $500\text{ Hz}$ مع تفضيل استخدام بروتوكول DShot600 لضمان استجابة لحظية من المحركات.

---

## تشخيص الأعطال والمشاكل أثناء المحاكاة والتطبيق

| الظاهرة الملاحظة في الاختبار | السبب الفيزيائي أو البرمجي | المعالجة الهندسية |
|---:|---:|---:|
| الطائرة تنقلب قبل تفعيل وضع الطوارئ | تأخر خوارزمية الـ FDI في اكتشاف توقف المحرك | استخدام قراءة التيار والـ RPM المباشرة من الـ ESC عبر بروتوكول DShot ثنائي الاتجاه بدلاً من الاعتماد على ميلان الهيكل فقط |
| الطائرة تبقى أفقية لكنها تفقد الارتفاع بسرعة | تشبع المحركين السليمين ووصولهما إلى 100% Throttle | تخفيف الوزن الكلي للمركبة أو استخدام مراوح ذات خطوة (Pitch) أعلى لتوفير هامش دفع كافٍ |
| تذبذب عنيف (Coning Motion) يتزايد مع الوقت | تأثير الـ Gyroscopic Precession (المبادرة الجيروسكوبية) غير المعوض | إضافة حد تعويض العزم الجيروسكوبي ($\omega \times J\omega$) داخل معادلة متحكم الـ Rate |

---

## المراجع العلمية والهندسية المعتمدة

1. **ETH Zurich (Institute for Dynamic Systems and Control):**
   Mueller, M. W., & D'Andrea, R. (2014). *"Stability and control of a quadrocopter despite the complete loss of a propeller."* **IEEE International Conference on Robotics and Automation (ICRA)**, pp. 495–502.
2. **The International Journal of Robotics Research (IJRR):**
   Mueller, M. W., & D'Andrea, R. (2015). *"Relaxed hover solutions for multicopters: Application to algorithmic redundancy and novel vehicles."* **SAGE Journals / IJRR**, Vol. 35(8), pp. 873–889.
3. **TU Delft (Micro Air Vehicle Lab) & IEEE Transactions on Robotics:**
   Sun, S., Wang, X., Chu, Q., & de Visser, C. C. (2020). *"Incremental Nonlinear Fault-Tolerant Control of a Quadrotor with Complete Loss of Two Opposing Rotors."* **IEEE Transactions on Robotics (T-RO)**, Vol. 37(1), pp. 116–130.
4. **American Institute of Aeronautics and Astronautics (AIAA):**
   Lanzon, A., Freddi, A., & Longhi, S. (2014). *"Flight Control of a Quadrotor Vehicle Subsequent to a Rotor Failure."* **AIAA Journal of Guidance, Control, and Dynamics (JGCD)**, Vol. 37(2), pp. 580–591.
5. **IEEE/RSJ International Conference on Intelligent Robots and Systems (IROS):**
   Lippiello, V., Ruggiero, F., & Serra, D. (2014). *"Emergency Landing for a Quadrotor in Case of a Propeller Failure: A Backstepping Approach."* **IROS**, pp. 3175–3180.
6. **PX4 Autopilot Architecture:**
   PX4 Dynamic Control Allocation & Pseudo-Inverse Effectiveness Matrix (`src/modules/control_allocator/ControlAllocation/ControlAllocationPseudoInverse.cpp`).

---

## روابط ذات صلة في المستودع

* **[دليل إعداد الـ Actuators وتوزيع المحركات](./ARAN_ENG_004_Actuators_PWM_Setup.md)**
* **[دليل الـ Autotune للضبط التلقائي](./ARAN_ENG_003_Autotune_System.md)**
* **[دليل معايرة الـ ESC](./ARAN_ENG_002_ESC_Calibration.md)**
* **[دليل ضبط الـ PID الأساسي](https://github.com/m7t5/ARAN-Flight-Systems/blob/main/ARAN_ENG_001_PID_Tuning.md)**

---

<div align="center">

**[العودة إلى الصفحة الرئيسية (ARAN Flight Systems)](./README.md)**

---

**© ARAN Flight Systems** — جميع الحقوق محفوظة

</div>
</div>
