<div dir="rtl" align="right">

# 𒀀𒊏𒀭 ARAN Flight Systems | مستودع هندسي وبرمجي متخصص في أنظمة الطيران المسير، خوارزميات التحكم، والمحاكاة

<div align="center">

![ARAN Flight Systems](https://img.shields.io/badge/ARAN-Flight%20Systems-blue?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Active%20Research%20Hub-success?style=for-the-badge)
![Domain](https://img.shields.io/badge/Domain-UAV%20Engineering%20%26%20Autonomy-orange?style=for-the-badge)

**مرجع هندسي وبرمجي متكامل لتوثيق وتطوير أنظمة التحكم بالطيران، ديناميكا الطائرات المسيرة (UAVs)، وبرمجة الأنظمة الذاتية**

</div>

---

## أصل التسمية والهوية
**آرآن (ARAN | 𒀀𒊏𒀭):** اسم مستوحى من التراث العراقي السومري القديم، يتكون من دمج مقطعين:
* **ARA:** المسار أو الطريق.
* **AN:** السماء.
ليعبر الاسم عن **"مسار السماء"** وهندسة توجيه المركبات الجوية نحو آفاق جديدة من الأتمتة والدقة.

---

##  الهيكل التنظيمي للمستودع (Repository Architecture)
تم تنظيم محتوى المستودع وتقاريره الهندسية والبرمجية بعناية لغرض الشمولية والاحترافية الأكاديمية:

1. **[Flight Control & Avionics (أنظمة التحكم وإلكترونيات الطيران)](https://github.com/m7t5/ARAN-Flight-Systems/tree/main/Flight%20Control%20%26%20Avionics%20(%D8%A3%D9%86%D8%B8%D9%85%D8%A9%20%D8%A7%D9%84%D8%AA%D8%AD%D9%83%D9%85%20%D9%88%D8%A5%D9%84%D9%83%D8%AA%D8%B1%D9%88%D9%86%D9%8A%D8%A7%D8%AA%20%D8%A7%D9%84%D8%B7%D9%8A%D8%B1%D8%A7%D9%86))**
   * قسم البرمجة، خوارزميات التوازن (PID)، وتوجيه الطائرة والطيار الآلي 
   * 2. **[Airframe & Aerodynamics (الهيكل والديناميكا الهوائية)](https://github.com/m7t5/ARAN-Flight-Systems/tree/main/Airframe%20%26%20Aerodynamics%20(%D8%A7%D9%84%D9%87%D9%8A%D9%83%D9%84%20%D9%88%D8%A7%D9%84%D8%AF%D9%8A%D9%86%D8%A7%D9%85%D9%8A%D9%83%D8%A7%20%D8%A7%D9%84%D9%87%D9%88%D8%A7%D8%A6%D9%8A%D8%A9))**
   * قسم تصميم الجسم، فيزياء المراوح,وكل الاجزاء المؤثرة في ديناميكا الهواء.
3. **[Propulsion & Power (أنظمة الدفع والطاقة)](https://github.com/m7t5/ARAN-Flight-Systems/tree/main/Propulsion%20%26%20Power%20(%D8%A3%D9%86%D8%B8%D9%85%D8%A9%20%D8%A7%D9%84%D8%AF%D9%81%D8%B9%20%D9%88%D8%A7%D9%84%D8%B7%D8%A7%D9%82%D8%A9))**
   * قسم المحركات عديمة الفحمات (BLDC)، منظمات السرعة (ESCs)، نمذجة البطاريات، وتعويض هبوط الجهد اللحظي.
4. **[Diagnostics & Failure Analysis (التشخيص وتحليل الأعطال)](https://github.com/m7t5/ARAN-Flight-Systems/tree/main/Diagnostics%20%26%20Failure%20Analysis%20(%D8%A7%D9%84%D8%AA%D8%B4%D8%AE%D9%8A%D8%B5%20%D9%88%D8%AA%D8%AD%D9%84%D9%8A%D9%84%20%D8%A7%D9%84%D8%A3%D8%B9%D8%B7%D8%A7%D9%84))**
   * قسم الأخطاء، المشاكل التقنية، تحليل سجلات الطيران (ULog)، وحلول أعطال الأنظمة وحالات الطوارئ.
5. **[AI & Autonomous Perception (الذكاء الاصطناعي والإدراك الذاتي)](https://github.com/m7t5/ARAN-Flight-Systems/tree/main/AI%20%26%20Autonomous%20Perception%20(%D8%A7%D9%84%D8%B0%D9%83%D8%A7%D8%A1%20%D8%A7%D9%84%D8%A7%D8%B5%D8%B7%D9%86%D8%A7%D8%B9%D9%8A%20%D9%88%D8%A7%D9%84%D8%A5%D8%AF%D8%B1%D8%A7%D9%83%20%D8%A7%D9%84%D8%B0%D8%A7%D8%AA%D9%8A))**
   * قسم الذكاء الاصطناعي، الرؤية الحاسوبية، خوارزميات الطيران المستقل، والحواسيب المرافقة (Companion Computers).
6. **[Interdisciplinary R&D (البحوث المتقاطعة وتكامل العلوم)](https://github.com/m7t5/ARAN-Flight-Systems/tree/main/Interdisciplinary%20R%26D%20(%D8%A7%D9%84%D8%A8%D8%AD%D9%88%D8%AB%20%D8%A7%D9%84%D9%85%D8%AA%D9%82%D8%A7%D8%B7%D8%B9%D8%A9%20%D9%88%D8%AA%D9%83%D8%A7%D9%85%D9%84%20%D8%A7%D9%84%D8%B9%D9%84%D9%88%D9%85))**
   * قسم دمج العلوم الأخرى، أبحاث الاتصالات، الأجهزة المتقدمة، والتجارب البحثية المتقاطعة.
7. **[Systems Engineering & Docs (هندسة الأنظمة والتوثيق)](https://github.com/m7t5/ARAN-Flight-Systems/tree/main/Systems%20Engineering%20%26%20Docs%20(%D9%87%D9%86%D8%AF%D8%B3%D8%A9%20%D8%A7%D9%84%D8%A3%D9%86%D8%B8%D9%85%D8%A9%20%D9%88%D8%A7%D9%84%D8%AA%D9%88%D8%AB%D9%8A%D9%82))**
   * قسم الشروحات العامة، المراجع، أدلة المساهمة، وسياسات العمل في المشروع.

---

##  ملاحظة تحريرية ومنهجية العمل
* **طبيعة المحتوى:** يتضمن هذا المستودع مزيجاً تكملياً يجمع بين **ترجمة وتكييف وتلخيص المقالات والأوراق البحثية الهندسية المتقدمة** لمطوري العالم، إلى جانب **المقالات والتقارير والتوثيقات الأصلية الخاصة بنا**، ليشكل مرجعاً عربياً رصيناً يربط النظريات الأكاديمية بالكود العملي.
* **مرحلة التطور:** يتم رفع وإضافة بقية التقارير والملفات الهندسية والبرمجية للأقسام السبعة تباعاً وفق خطة التطوير الأكاديمي والبحثي.

---

##  الترخيص والإدارة
هذا المشروع مفتوح المصدر تحت إشراف **ARAN Flight Systems**، ومتاح لطلبة الهندسة والمهتمين بتطوير أنظمة الطيران المسير للتعلم، التطوير، والمساهمة وفق المعايير التقنية العالمية.

---

<div align="center">

**© ARAN Flight Systems** — جميع الحقوق محفوظة

</div>
</div>
