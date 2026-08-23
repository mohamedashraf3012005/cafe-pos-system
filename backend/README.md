# Cafe POS - WhatsApp Backend Server

خادم بسيط وآمن مبني بـ **Node.js + Express** لربط تطبيق Flutter Desktop مع **WhatsApp Cloud API** من Meta.

---

## طريقة التشغيل السريعة

### 1. تثبيت الـ Dependencies
في مجلد `backend`:
```bash
cd backend
npm install
```

### 2. إعداد المفاتيح `.env`
قم بإنشاء ملف `.env` داخل مجلد `backend` وضع فيه بيانات حساب Meta Developer:
```env
PORT=3000
META_PHONE_NUMBER_ID=ضع_هنا_phone_number_id
META_ACCESS_TOKEN=ضع_هنا_access_token
```

### 3. تشغيل الخادم
```bash
npm start
```
سيعمل الخادم على: `http://localhost:3000/api/whatsapp`

---

## في تطبيق الكاشير POS
1. افتح **إعدادات WhatsApp**.
2. حدد **خادم خاص (Backend Proxy)**.
3. ضع الرابط: `http://localhost:3000/api/whatsapp`
4. اضغط **حفظ الإعدادات** ثم **اختبار WhatsApp**.
