<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Propulsion & Power - VTOL Transition Phase</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.8;
            color: #2c3e50;
            max-width: 900px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f8f9fa;
        }
        h1, h2, h3 {
            color: #0b5345;
            border-bottom: 2px solid #117a65;
            padding-bottom: 5px;
        }
        h1 {
            text-align: center;
        }
        h3 {
            border-bottom: none;
            color: #148f77;
            margin-top: 30px;
        }
        .intro-box {
            background-color: #e8f8f5;
            border-right: 4px solid #117a65;
            padding: 15px 20px;
            margin-bottom: 30px;
            border-radius: 4px;
        }
        .intro-box p {
            margin: 0;
            font-weight: bold;
        }
        ul {
            list-style-type: square;
            padding-right: 20px;
        }
        li {
            margin-bottom: 10px;
        }
        strong {
            color: #c0392b;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
            margin-bottom: 30px;
            background-color: #fff;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
        th, td {
            border: 1px solid #bdc3c7;
            padding: 12px;
            text-align: right;
        }
        th {
            background-color: #117a65;
            color: white;
        }
        tr:nth-child(even) {
            background-color: #f2f3f4;
        }
        .references {
            background-color: #fff;
            padding: 20px;
            border: 1px solid #d5dbdb;
            border-radius: 5px;
            margin-top: 40px;
        }
        .references ol {
            padding-right: 20px;
        }
        .references li {
            margin-bottom: 8px;
            font-size: 0.95em;
            color: #34495e;
        }
    </style>
</head>
<body>

    <h1>تقرير: Propulsion & Power (أنظمة الدفع والطاقة)</h1>
    <h2 style="text-align: center; color: #555; font-size: 1.2em; border: none;">التركيز الأكاديمي: تحديات أنظمة الدفع والطاقة في طائرات VTOL أثناء مرحلة الانتقال (Transition Phase)</h2>

    <div class="intro-box">
        <p>مقدمة: تعتبر طائرات VTOL الهجينة الحل الأمثل للجمع بين مرونة الإقلاع العمودي وكفاءة الطيران الأفقي. ومع ذلك، تعد مرحلة الانتقال (Transition Phase) بين الوضعين هي النقطة الأكثر حرجاً هندسياً، حيث تتعرض أنظمة الدفع والطاقة لأقصى درجات الإجهاد الكهربائي والديناميكي.</p>
    </div>

    <h3>1. تحديات الطاقة: سحب التيار و(Voltage Sag)</h3>
    <p>أثناء مرحلة الانتقال، تعمل محركات الرفع العمودي (Lift Motors) ومحرك الدفع الأفقي (Pusher/Tractor) في آن واحد. هذا التشغيل المزدوج يولد طلباً هائلاً على الطاقة.</p>
    <ul>
        <li><strong>Current Draw (سحب التيار):</strong> يصل سحب التيار من البطارية إلى ذروته (Peak Current) خلال هذه المرحلة.</li>
        <li><strong>Voltage Sag (انخفاض الفولتية):</strong> السحب العالي والمفاجئ للتيار يؤدي إلى هبوط حاد في فولتية البطارية. إذا انخفضت الفولتية دون الحد المسموح، قد تتعرض متحكمات الطيران لإعادة التشغيل (Reboot) أو تفقد المحركات قوة الدفع المطلوبة للحفاظ على الارتفاع.</li>
    </ul>

    <h3>2. الديناميكا الهوائية وتأثيرها على الدفع</h3>
    <p>عندما تبدأ الطائرة باكتساب سرعة أفقية (Airspeed) أثناء عمل محركات الرفع، يتغير تدفق الهواء بشكل جذري.</p>
    <ul>
        <li><strong>Aerodynamic Interference (التداخل الديناميكي الهوائي):</strong> الهواء المتدفق على الأجنحة يتداخل مع الهواء المندفع للأسفل (Downwash) من المراوح العمودية، مما يقلل من كفاءة الدفع ويطلب طاقة أعلى من المحركات لتعويض النقص.</li>
        <li><strong>Angle of Attack (زاوية الهجوم):</strong> التغير السريع في زاوية الهجوم خلال الانتقال قد يؤدي إلى فقدان الرفع (Stall) إذا لم يوفر محرك الدفع الأفقي السرعة الكافية في الوقت المناسب.</li>
    </ul>

    <h3>3. إدارة الدفع (Thrust Blending) في متحكمات الطيران</h3>
    <p>يتطلب الانتقال السلس نظاماً برمجياً معقداً داخل متحكم الطيران (Flight Controller) لتوزيع الطاقة.</p>
    <ul>
        <li><strong>Thrust Blending (مزج الدفع):</strong> يقوم نظام PX4 بتقليل طاقة محركات الرفع تدريجياً بالتزامن مع زيادة طاقة المحرك الأفقي.</li>
        <li><strong>التحدي:</strong> أي خطأ في معايرة (Tuning) منحنى المزج سيؤدي إما إلى هبوط مفاجئ في الارتفاع (Altitude Drop) أو استهلاك مفرط للطاقة يقلل من زمن الرحلة الكلي.</li>
    </ul>

    <h3>4. الإجهاد الحراري (Thermal Spikes) على الـ ESCs</h3>
    <p>التغيرات المفاجئة في سرعة المحركات (RPM) وتغيير الأحمال المطلوبة يضع عبئاً حرارياً على متحكمات السرعة.</p>
    <ul>
        <li><strong>Thermal Spikes (ذروة الأحمال الحرارية):</strong> الانتقال يتطلب تسارعاً وتباطؤاً سريعاً للمحركات، مما يرفع درجة حرارة الـ (ESCs) بشكل حاد، ويستوجب اختيار متحكمات ذات قدرة تشتيت حراري عالية وتصنيف تيار (Amp Rating) أعلى من الحد الأقصى المستمر (Continuous Current).</li>
    </ul>

    <h3>📊 مقارنة استهلاك الطاقة في مراحل طيران الـ VTOL المختلفة</h3>
    <table>
        <thead>
            <tr>
                <th>مرحلة الطيران (Flight Phase)</th>
                <th>حالة المحركات (Motors Status)</th>
                <th>مستوى سحب التيار (Current Draw)</th>
                <th>الكفاءة الهوائية (Aerodynamic Efficiency)</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td><strong>الإقلاع العمودي (Hover)</strong></td>
                <td>محركات الرفع تعمل فقط بأحمال عالية</td>
                <td>مرتفع (High)</td>
                <td>منخفضة (اعتماد كلي على الدفع الخالص)</td>
            </tr>
            <tr>
                <td><strong>الانتقال (Transition Phase)</strong></td>
                <td>محركات الرفع + محرك الدفع الأفقي</td>
                <td>الذروة (Peak - Maximum)</td>
                <td>متغيرة ومعقدة (تدفق مضطرب)</td>
            </tr>
            <tr>
                <td><strong>الطيران الأفقي (Forward Flight)</strong></td>
                <td>محرك الدفع الأفقي فقط (توقف محركات الرفع)</td>
                <td>منخفض إلى متوسط (Low - Medium)</td>
                <td>عالية (اعتماد على رفع الأجنحة)</td>
            </tr>
        </tbody>
    </table>

    <div class="references">
        <h3>📚 المصادر (References)</h3>
        <ol>
            <li><strong>IEEE Xplore Digital Library:</strong> Power Management and Voltage Sag Mitigation in Hybrid VTOL UAVs During Transition Phase.</li>
            <li><strong>NASA Technical Reports Server (NTRS):</strong> Aerodynamic Interference Between Lift Rotors and Wings in eVTOL Aircraft.</li>
            <li><strong>PX4 Autopilot / Dronecode Foundation Documentation:</strong> VTOL Flight Stack: Thrust Blending and Transition Tuning.</li>
            <li><strong>MIT - Department of Aeronautics and Astronautics:</strong> Thermal Analysis of Electronic Speed Controllers (ESCs) under Dynamic Loads in UAVs.</li>
        </ol>
    </div>

</body>
</html>
