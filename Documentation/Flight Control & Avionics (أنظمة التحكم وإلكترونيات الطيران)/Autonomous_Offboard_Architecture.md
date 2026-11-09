<div dir="rtl" align="right">

# مدخل إلى هندسة برمجة الطائرات المسيرة: معمارية الـ Offboard Control والآلات الحالتية غير المتزامنة عبر بروتوكول MAVLink

<div align="center">

![ARAN Flight Systems](https://img.shields.io/badge/ARAN-Flight%20Systems-blue?style=for-the-badge)
![Doc ID](https://img.shields.io/badge/Doc%20ID-ARAN__PRG__001-brightgreen?style=for-the-badge)
![Category](https://img.shields.io/badge/Category-Flight%20Software%20%26%20Autonomy-informational?style=for-the-badge)

**الأساس المعماري لربط الحواسيب المرافقة بالطيار الآلي وبناء خوارزميات الطيران الذاتي الآمن**

</div>

---

## نظرة عامة وفلسفة الفصل المعماري

تعتمد برمجة الطائرات المسيرة المتقدمة على مبدأ هندسي صارم يُعرف باسم **Dual-Compute Architecture** (معمارية الحوسبة المزدوجة). لا يتم أبداً كتابة أكواد الرؤية الحاسوبية أو الذكاء الاصطناعي أو تخطيط المسارات بلغة Python مباشرة داخل شريحة الـ **Flight Controller** (الطيار الآلي)، بل يتم فصل المهام البرمجية فيزيائياً ومنطقياً بين معالجين مستقلين لضمان عدم انهيار الطائرة في حال تعطل الكود البرمجي:

1. **وحدة التحكم الدقيقة في الطيار الآلي (Microcontroller Unit - MCU):**
   تعمل على نظام **Real-Time Operating System - RTOS** (نظام تشغيل الزمن الحقيقي، مثل NuttX في بيئة PX4). وظيفتها حتمية الزمن (**Hard Real-Time**)؛ أي يجب أن تقرأ الجيروسكوب وتشغل مرشحات الـ Notch وتحسب الـ PID في جزء من الألف من الثانية دون أي تأخير.

2. **الحاسوب المرافق على متن الطائرة (Companion Computer):**
   حاسوب مستقل (مثل Raspberry Pi أو NVIDIA Jetson) يعمل بنظام Linux القياسي، ويتصل بالطيار الآلي سلكياً عبر منفذ **UART** (المرسل والمستقبل العالمي غير المتزامن) أو **Ethernet**. يتولى هذا الحاسوب تشغيل أكواد Python أو C++ الخاصة بالمهام العليا وإرسال أوامر التوجيه إلى الطيار الآلي.

| وجه المقارنة | الطيار الآلي (Flight Controller - MCU) | الحاسوب المرافق (Companion Computer) |
|---:|---:|---:|
| **نوع المعالج والذاكرة** | معالج دقيق محدود الموارد (مثل STM32H7 بذاكرة 2MB) | معالج تطبيقي متعدد الأنوية (ARM Cortex-A مع GPU وذاكرة 4GB-16GB) |
| **نظام التشغيل** | نظام زمن حقيقي صارم (RTOS - NuttX / ChibiOS) | نظام تشغيل عام (Ubuntu Linux) |
| **الوظيفة البرمجية** | حفظ التوازن اللحظي، قراءة الحساسات، قيادة المحركات | التخطيط الذاتي للمسار، الرؤية الحاسوبية، اتخاذ القرار |
| **اللغات والأطر البرمجية** | C / C++ المدمجة منخفضة المستوى | Python, Modern C++, ROS 2, MAVSDK |
| **تردد العمليات (Loop Rate)** | من $400\text{ Hz}$ إلى $8000\text{ Hz}$ | من $10\text{ Hz}$ إلى $60\text{ Hz}$ |

---

## بنية الاتصال: من الناقل الداخلي إلى بروتوكول MAVLink

لكي يتحكم برنامجك الخارجي بالطائرة، تمر الأوامر عبر طبقتين من أنظمة المراسلة البرمجية:

### 1. الناقل الداخلي (uORB - Micro Object Request Broker)
داخل شريحة الطيار الآلي، تتواصل الوحدات البرمجية مع بعضها بنمط **Publish-Subscribe** (النشر والاشتراك) عبر ناقل بيانات فائق السرعة يُسمى **uORB**. عندما يقرأ حساس الموقع إحداثيات الطائرة، فإنه "ينشر" البيانات في موضوع (`vehicle_local_position`)، وتشترك فيه وحدة التحكم لقراءته لحظياً.

### 2. البروتوكول الخارجي (MAVLink - Micro Air Vehicle Link)
لا يستطيع الحاسوب المرافق الوصول إلى ذاكرة الـ uORB مباشرة؛ لذا يتحدث مع الطيار الآلي عبر بروتوكول **MAVLink**، وهو بروتوكول تسلسلي خفيف الوزن يحزم البيانات في إطارات ثنائية (Binary Packets) عالية الكفاءة. ولتسهيل البرمجة دون الحاجة لبناء الحزم الثنائية يدوياً، نستخدم واجهة **MAVSDK** (حزمة تطوير برمجيات MAVLink) التي تحول استدعاءات الدوال البرمجية إلى رسائل MAVLink قياسية.

---

## القاعدة الذهبية للطيران الذاتي: عقد الـ Offboard والمحاور المرجعية

عندما يريد المبرمج السيطرة على الطائرة عبر الكود، يجب أن ينقل الطيار الآلي إلى وضع خاص يُسمى **Offboard Mode** (وضع التحكم البرمجي الخارجي). في هذا الوضع، يتجاهل الطيار الآلي عصي التحكم اليدوية، ويستمع للأوامر القادمة من الكود البرمجي كـ **Setpoints** (نقاط هدف مطلوبة للموقع أو السرعة أو الزاوية).

### 1. شرط التدفق المستمر (Continuous Setpoint Streaming Contract)
يرفض الطيار الآلي الدخول في وضع الـ Offboard، أو يقوم بالخروج منه فوراً وتفعيل وضع الطوارئ **Failsafe** (إجراء الأمان عند الفشل)، إلا إذا التزم الكود البرمجي بشرطين صارمين:
* **نبضة الحياة (Heartbeat):** إرسال حزمة تأكيد وجود بشكل مستمر بتردد $1\text{ Hz}$.
* **تدفق الأوامر المسبق والمستمر:** يجب أن يبدأ الكود بإرسال أوامر الـ Setpoints بتردد يزيد عن **$2\text{ Hz}$** (ويُفضل برمجياً من $10\text{ Hz}$ إلى $20\text{ Hz}$) **قبل** طلب تفعيل وضع الـ Offboard، والاستمرار في إرسالها طوال فترة الطيران حتى لو كانت الطائرة ثابتة في مكانها. إذا انقطع الكود عن الإرسال لمدة تتجاوز المعامل `COM_OF_LOSS_T` (عادة $0.5$ ثانية)، يعتبر الطيار الآلي أن الحاسوب المرافق قد تعطل، فيستعيد السيطرة فوراً ويهبط بالطائرة.

### 2. نظام الإحداثيات المحلي (NED Coordinate Frame)
تعتمد خوارزميات الطيران على نظام الإحداثيات الجغرافي المحلي **NED** اختصاراً لـ **North-East-Down** (شمال - شرق - أسفل)، حيث تكون نقطة الأصل $(0, 0, 0)$ هي النقطة التي التقطت فيها الطائرة إشارة الموقع عند تشغيلها:

* **المحور $X$ (North):** الاتجاه نحو الشمال (موجب للأمام نحو الشمال، سالب للجنوب).
* **المحور $Y$ (East):** الاتجاه نحو الشرق (موجب لليمين نحو الشرق، سالب للغرب).
* **المحور $Z$ (Down):** الاتجاه نحو **الأسفل** نحو مركز الأرض.

> [!WARNING]
> **الخطأ البرمجي الأكثر شيوعاً في إحداثيات الطيران:**
> في نظام الـ NED، الاتجاه الموجب للمحور $Z$ يشير إلى **باطن الأرض**. هذا يعني أنه لرفع الطائرة إلى ارتفاع 10 أمتار في الجو، يجب أن ترسل في الكود القيمة **`z = -10.0`** (بالسالب). إرسال قيمة موجبة (`z = +10.0`) يعني أمر الطائرة بالغوص داخل الأرض بأقصى سرعة.

---

## الهندسة البرمجية: الآلة الحالتية والبرمجة غير المتزامنة (Asyncio & FSM)

في البرمجة التقليدية، قد يستخدم المبرمج دالة التوقف `time.sleep(5)` للانتظار 5 ثوانٍ. في برمجة الطائرات، استخدام `time.sleep` هو خطأ قاتل لأنه يجمد الخيط البرمجي (**Blocking Thread**)، فيتوقف إرسال الـ Setpoints والـ Heartbeat، مما يدفع الطيار الآلي لتفعيل الـ Failsafe وإلغاء المهمة.

الحل الهندسي القياسي هو استخدام **Asynchronous Programming** (البرمجة غير المتزامنة) عبر مكتبة `asyncio` لتشغيل المهام بالتوازي داخل **Event Loop** (حلقة أحداث)، مع هيكلة الكود على شكل **Finite State Machine - FSM** (آلة حالتية منتهية) تمر بالمراحل الست التالية:

| رقم الحالة | اسم المرحلة (State) | الوظيفة البرمجية وشروط الانتقال للمرحلة التالية |
|---:|---:|---:|
| **1** | **Connection & Handshake** | فتح قناة الاتصال عبر منفذ UDP (في المحاكاة) أو UART (في الواقع) وانتظار التقاط أول حزمة Heartbeat من الطيار الآلي. |
| **2** | **Pre-Flight Health Check** | فحص مصفوفة الحساسات في مرشح **EKF2** (مرشح كالمان الموسع) والتأكد من استقرار تقدير الموقع المحلي قبل السماح بالتسليح. |
| **3** | **Setpoint Pre-Streaming** | بدء بث نقطة هدف ابتدائية $(0, 0, 0)$ في الخلفية لملء مخزن الطيار الآلي المؤقت وإقناعه بسلامة الاتصال الخارجي. |
| **4** | **Arming & Offboard Engage** | إرسال أمر التسليح (**Arm**)، ثم طلب التحول إلى وضع الـ **Offboard** تحت حماية كتلة معالجة الاستثناءات (`try / except`). |
| **5** | **Trajectory Execution** | تحديث إحداثيات الـ NED تدريجياً لتنفيذ الإقلاع، المناورة، والتحويم مع مراقبة المسافة المتبقية للهدف. |
| **6** | **Safe Landing & Disarm** | الخروج المنظم من وضع الـ Offboard، وتفعيل خوارزمية الهبوط التلقائي للطيار الآلي وإيقاف المحركات فور ملامسة الأرض. |

---

## الكود المرجعي: تنفيذ مهمة طيران ذاتي بلغة Python و MAVSDK

يمثل الكود التالي البنية القياسية النظيفة لبرمجة مهمة إقلاع وتحرك ذاتي في وضع الـ Offboard باستخدام البرمجة غير المتزامنة، وهو جاهز للتشغيل المباشر على بيئة المحاكاة **SITL** (المحاكاة البرمجية في الحلقة - Software-In-The-Loop) أو على حاسوب مرافق حقيقي:

<div dir="ltr" align="left">

```python
import asyncio
from mavsdk import System
from mavsdk.offboard import OffboardError, PositionNedYaw


async def run_autonomous_mission():
    # 1. تهيئة كائن الطائرة والاتصال عبر منفذ UDP القياسي لبيئة PX4 SITL
    drone = System()
    await drone.connect(system_address="udp://:14540")

    print("[ARAN-PRG] Waiting for Flight Controller connection...")
    async for state in drone.core.connection_state():
        if state.is_connected:
            print("[ARAN-PRG] Connected to PX4 Autopilot successfully.")
            break

    # 2. فحص جاهزية مرشح كالمان (EKF2) وتقدير الموقع المحلي قبل الطيران
    print("[ARAN-PRG] Waiting for local position estimate (EKF2)...")
    async for health in drone.telemetry.health():
        if health.is_local_position_ok and health.is_armable:
            print("[ARAN-PRG] Pre-flight health checks passed.")
            break

    # 3. البث المسبق لنقطة الهدف (Pre-streaming Setpoint) - شرط إلزامي قبل تفعيل Offboard
    # الإحداثيات بنظام NED: (North=0.0m, East=0.0m, Down=0.0m, Yaw=0.0 deg)
    initial_setpoint = PositionNedYaw(0.0, 0.0, 0.0, 0.0)
    await drone.offboard.set_position_ned(initial_setpoint)

    # 4. تسليح المحركات (Arming) وتفعيل وضع التحكم البرمجي (Offboard Mode)
    print("[ARAN-PRG] Arming actuators...")
    await drone.action.arm()

    print("[ARAN-PRG] Engaging Offboard control mode...")
    try:
        await drone.offboard.start()
    except OffboardError as error:
        print(f"[ARAN-ERROR] Failed to start Offboard mode: {error._result.result}")
        print("[ARAN-PRG] Disarming for safety...")
        await drone.action.disarm()
        return

    # 5. تنفيذ المسار الفضائي (الإقلاع إلى ارتفاع 5 أمتار -> Z = -5.0 في نظام NED)
    print("[ARAN-PRG] Climbing to target altitude: 5.0 meters (Z = -5.0 NED)...")
    await drone.offboard.set_position_ned(PositionNedYaw(0.0, 0.0, -5.0, 0.0))
    await asyncio.sleep(8)

    # التقدم نحو الشمال مسافة 10 أمتار مع تدوير مقدمة الطائرة بزاوية 90 درجة شرقاً
    print("[ARAN-PRG] Moving North 10.0m and rotating Yaw to 90 degrees...")
    await drone.offboard.set_position_ned(PositionNedYaw(10.0, 0.0, -5.0, 90.0))
    await asyncio.sleep(10)

    # 6. الإنهاء الآمن للمهمة وتسليم القيادة لخوارزمية الهبوط الداخلي
    print("[ARAN-PRG] Stopping Offboard mode and initiating safe landing...")
    try:
        await drone.offboard.stop()
    except OffboardError as error:
        print(f"[ARAN-WARNING] Offboard stop error: {error._result.result}")

    await drone.action.land()
    print("[ARAN-PRG] Mission completed successfully.")


if __name__ == "__main__":
    # تشغيل حلقة الأحداث غير المتزامنة (Asynchronous Event Loop)
    asyncio.run(run_autonomous_mission())
