<div dir="rtl" align="right">

# تقرير منظومة الدفع والطاقة في طائرات الإقلاع والهبوط العمودي (ARAN Flight Systems)

<div align="center">

[![System](https://img.shields.io/badge/Architecture-Hybrid_VTOL-0b5345?style=flat-square)](docs/system_architecture.md)
[![Flight Stack](https://img.shields.io/badge/Flight_Stack-PX4_Autopilot-117a65?style=flat-square)](firmware/px4_firmware_tree.md)
[![Standard](https://img.shields.io/badge/Compliance-DO--178C_%7C_DO--254-148f77?style=flat-square)](docs/compliance_standards.md)
[![V&V](https://img.shields.io/badge/Protocol-Verification_%26_Validation-0e6655?style=flat-square)](tests/verification_validation.md)
[![Configuration Management](https://img.shields.io/badge/Baseline-CM_v2.4-16a085?style=flat-square)](config/configuration_management.md)

</div>

---

## 1. نطاق التقرير والتنظيم المنهجي (Scope & Systematic Organization)

يوثق هذا التقرير الهندسي المحددات التشغيلية والفيزيائية لأنظمة الدفع وتوزيع الطاقة (Propulsion & Power Systems) لمنصة ARAN VTOL أثناء مرحلة الانتقال (Transition Phase).

يعتمد التنظيم المنهجي للتقرير على توصيف الظواهر الكهروميكانيكية والهوائية الملازمة للتحول من الطيران العمودي إلى الطيران الأفقي، وربطها المباشر بمعايير إدارة التهيئة (Configuration Management).

---

## 2. التحليل الحرج لديناميكا الطاقة والشبكة الكهربائية (Electrical Dynamics & Power Sag)

يبلغ سحب التيار (Current Draw) مستواه الأقصى (Peak Current) نتيجة التشغيل المتزامن لمحركات الرفع العمودي (Lift Motors) ومحرك الدفع الأفقي (Forward Propulsion Motor).

يفرض هذا التزامن طلباً لحظياً يفوق السعة الاسمية المعتادة لحزمة البطاريات، مما يُحدث انخفاضاً حاداً في الجهد يعرف بظاهرة هبوط الفولتية (Voltage Sag).

تؤدي عدم معالجة هذا الهبوط إلى نزول الجهد دون عتبة التشغيل الدنيا، مما يعرض وحدة تحكم الطيران (Flight Controller) لمخاطر إعادة التشغيل اللحظي (Brownout Reboot) وفقدان التحكم الميداني.

---

## 3. التداخل الديناميكي الهوائي وكفاءة الدفع (Aerodynamic Interference & Coupling)

يُولّد اكتساب السرعة الهوائية الأفقية (Airspeed) مع استمرار دوران مراوح الرفع تدفقاً هوائياً مركباً يُعرف بالتداخل الديناميكي الهوائي (Aerodynamic Interference).

يؤثر تيار الهواء الهابط (Downwash) الناتج عن مراوح الرفع سلباً على تدفق الهواء حول الأجنحة الثابتة، مما يقلل الكفاءة الرفعِيّة ويفرض على محركات الرفع استهلاك طاقة إضافية للتعويض.

يستلزم هذا التداخل الحفاظ على استقرار زاوية الهجوم (Angle of Attack - AoA) بدقة متناهية لتفادي حدوث الانهيار الهوائي (Aerodynamic Stall) قبل بلوغ السرعة الحرجة للرفع الجناحي المستقل.

---

## 4. بنية مزج الدفع في برمجيات التحكم (Thrust Blending & Control Stack)

تطبق برمجية التحكم المضمنة (Flight Stack) خوارزمية مزج الدفع (Thrust Blending) لتوزيع العزوم وقوى الدفع بين المنظومتين الرفعِيّة والدفعية بصورة تدريجية.

يقوم متحكم الطيران بخفض دورات محركات الرفع بالتوازي مع التسارع التدريجي لمحرك الدفع الأمامي، استناداً إلى دالة وزن ديناميكية تعتمد على قراءات حساس السرعة الهوائية (Pitot Tube).

يسبب أي خلل في ضبط المعلمات (Parameter Tuning) لمنحنى المزج انخفاضاً فجائياً في الارتفاع (Altitude Drop) أو زمناً مطولاً للانتقال يؤدي إلى الاستنزاف الحراري للبطاريات.

---

## 5. الإجهاد الحراري لمتحكمات السرعة (Thermal Stress on ESCs)

تتعرض وحدات التحكم بالسرعة الإلكترونية (Electronic Speed Controllers - ESCs) إلى قمم حرارية مفاجئة (Thermal Spikes) ناتجة عن التغير اللحظي في سرعة دوران المحركات (RPM).

تتطلب التبدلات المستمرة في قيم التيار المار عبر ترانزستورات التأثير الحقلي (MOSFETs) كفاءة تبديد حراري مرتفعة لمنع التدهور الهيكلي للمكونات الدقيقة.

يقضي التوصيف الهندسي باختيار متحكمات سرعة ذات قدرة تحمل للتيار المستمر (Continuous Current) تفوق التيار التشغيلي الأقصى بنسبة أمان لا تقل عن 35%.

---

## 6. مصفوفة الأداء المقارن لمراحل الطيران (Comparative Flight Phase Performance Matrix)

| مرحلة الطيران (Flight Phase) | تشغيل محركات الرفع (Lift Motors) | تشغيل محرك الدفع (Forward Motor) | نمط سحب التيار (Current Profile) | الكفاءة الديناميكية الهوائية (Aerodynamic Efficiency) | تصنيف المخاطر التشغيلية (System Risk Level) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **التحليق العمودي (Hover)** | تشغيل مستمر بحمل مرتفع | في حالة سكون | مستقر عند قيم مرتفعة | منخفضة (اعتماد مطلق على الدفع النفاث للمراوح) | إجهاد حراري تباكمي متوقع |
| **مرحلة الانتقال (Transition)** | تشغيل تنازلي تدريجي | تسارع لحظي نحو الذروة | قمة الذروة القصوى (Peak Load) | متغيرة (اضطراب هوائي غير خطي وتداخل تيارات) | هبوط جهد حاد (Voltage Sag) وإجهاد حراري مفاجئ |
| **الطيران الأفقي (Cruise)** | إيقاف كلي مع تأمين المراوح | تشغيل مستقر عند نقطة التصميم | منخفض إلى متوسط ومستقر | قصوى (اعتماد كلي على رفع السطوح الجناحية) | مخاطر تشغيلية منخفضة واستقرار كهربي تام |

---

## 7. بروتوكول التثبُّت والمصادقة وإدارة التهيئة (V&V Protocol & Configuration Management)

تتطلب عملية التثبُّت (Verification) إخضاع وحدة توزيع الطاقة (PDB) لاختبارات المحاكاة في الحلقة (Hardware-in-the-Loop - HIL) لضمان متانة دوائر الترشيح ومنع هبوط الجهد الحرج.

تعتمد المصادقة (Validation) على منصات الاختبار الثابتة (Static Thrust Benches) والطلعات التجريبية لتقييم تطابق المنحنيات الحرارية والكهربائية الواقعية مع النماذج الرياضية المعتمدة.

تخضع كافة معلمات التحكم وخوارزميات المزج لنظام إدارة التهيئة (Configuration Management) المعتمد بالمستودع لضمان التتبع الهندسي والامتثال لمعايير السلامة الجوية.

---

## 8. مصفوفة معلمات التهيئة وضبط المتحكم (Configuration & Firmware Parameters Matrix)

| المعلمة البرمجية (Parameter) | النظام الفرعي (Subsystem) | القيمة المحددة (Baseline Value) | اشتراط التثبُّت الهندسي (Verification Requirement) | ملف التوثيق المرجعي (Documentation Ref) |
| :--- | :--- | :--- | :--- | :--- |
| `VT_TRANS_TIMEOUT` | زمن مرحلة الانتقال | 15.0 ثانية | التحقق من عدم تجاوز عتبة التبديد الحراري للـ ESCs | [`transition_timing.md`](config/transition_timing.md) |
| `VT_ARSP_TRANS` | سرعة الانتقال الهوائية | 14.5 م/ث | ضمان هامش أمان كافٍ للوقاية من الانهيار الهوائي | [`aerodynamic_limits.md`](config/aerodynamic_limits.md) |
| `BAT_V_OFF_TRANS` | تعويض هبوط الجهد | 0.35 فولت | منع إشارات التحذير الخاطئة الناتجة عن هبوط الجهد اللحظي | [`power_thresholds.md`](config/power_thresholds.md) |
| `VT_B_TRANS_DUR` | مدة مزج عزم المحركات | 3.5 ثوانٍ | تجنب الفقدان الحاد في الارتفاع واستقرار عزم الرفع | [`blending_curves.md`](config/blending_curves.md) |

---

## 9. المراجع الأكاديمية والوثائق الداخلية (Academic References & Internal Docs)

1. **IEEE Xplore Digital Library:** Power Distribution Network Optimization and Voltage Sag Mitigation in eVTOL Unmanned Aircraft, IEEE Aerospace and Electronic Systems Society, 2023.
2. **NASA Technical Reports Server (NTRS):** Computational and Experimental Analysis of Rotor-Wing Aerodynamic Interference During eVTOL Transition Mode, NASA/TP-20220008431, 2022.
3. **AIAA SciTech Forum:** Dynamic In-Flight Thrust Blending Methodologies for Tilt-Wing and Lift-Plus-Cruise Configurations, American Institute of Aeronautics and Astronautics, 2024.
4. **Dronecode Foundation & PX4 Community:** PX4 Autopilot Architecture: VTOL Core State Machine and Blending Formulation, Documentation Suite, 2024.
5. **SAE International:** ARP4754A: Guidelines for Development of Civil Aircraft and Systems, SAE Aerospace Standard.


</div>
