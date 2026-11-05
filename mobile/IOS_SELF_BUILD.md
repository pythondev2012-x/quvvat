# iOS'ni Macsiz o'zingiz yig'ish (Windows + bepul Apple ID)

Bu yo'l **Mac ham, $99 Apple Developer hisobi ham talab qilmaydi**.
Ikki qismdan iborat:

1. **Codemagic** (bulutli macOS) — imzosiz `.ipa` yig'adi, bepul 500 daqiqa/oy.
2. **Sideloadly** (Windows) — o'sha `.ipa`ni bepul Apple ID'ingiz bilan
   imzolab, iPhone'ga o'rnatadi.

> Cheklov: bepul Apple ID bilan ilova **7 kunda** o'chadi. Har hafta
> Sideloadly orqali qayta o'rnatib turish kerak (1 daqiqalik ish, IPA fayl
> saqlanib qoladi). Doimiy yechim — $99/yil Apple Developer Program
> (TestFlight, 90 kun, cheklovsiz).

Repo'da tayyor fayl: [`codemagic.yaml`](codemagic.yaml).

---

## 1-qism. Codemagic'da IPA yig'ish

1. [codemagic.io](https://codemagic.io) → **Sign up** → **GitHub** bilan kiring.
2. **Add application** → `pythondev2012-x/quvvat` repo'sini tanlang.
   - Repo private bo'lsa, GitHub ruxsat oynasida faqat shu repo'ga
     access bering.
3. Codemagic repo'dagi `mobile/codemagic.yaml`ni avtomatik topadi.
   Agar so'rasa, **Project settings → Build configuration** yo'lini
   `mobile/codemagic.yaml` qilib belgilang.
4. **Start new build** → workflow: **Quvvat iOS (imzosiz IPA)** → **Start build**.
5. Birinchi build 10–20 daqiqa (keyingilari kesh bilan 5–8 daqiqa).
6. Tugagach **Artifacts** bo'limidan yuklab oling:

   ```text
   Quvvat-unsigned.ipa
   ```

Bu fayl hali imzolanmagan — to'g'ridan-to'g'ri o'rnatib bo'lmaydi.
Keyingi qadamda Sideloadly imzolaydi.

> Codemagic'da bepul 500 daqiqa/oy bor. Bitta build ~15 daqiqa, ya'ni oyiga
> ~30 marta yig'sa bo'ladi.

---

## 2-qism. Sideloadly bilan iPhone'ga o'rnatish

### Tayyorgarlik (bir marta)

1. Windows'ga **Apple Devices** dasturini o'rnating (Microsoft Store'dan) —
   iPhone drayverlari uchun. iTunes ham bo'ladi.
2. [sideloadly.io](https://sideloadly.io) → **Download for Windows** →
   o'rnating.
3. iPhone'ni USB bilan ulang → telefonda **Trust This Computer** → parol.
4. iPhone'da **Developer Mode** yoqilsin (iOS 16+):
   **Settings → Privacy & Security → Developer Mode → On** → telefon qayta
   yuklanadi.

### O'rnatish

1. Sideloadly'ni oching.
2. **IPA** maydoniga `Quvvat-unsigned.ipa` faylini tashlang.
3. **Apple ID** maydoniga Apple ID'ingizni yozing (parol keyin so'raladi;
   Sideloadly'ga to'g'ridan-to'g'ri bermang — u Apple serveriga yuboradi).
4. **Start** → parolni kiriting → 1–3 daqiqa kuting.
5. Telefonda: **Settings → General → VPN & Device Management →
   Developer App → Trust**.
6. Ilova **Quvvat** nomi bilan paydo bo'ladi.

### 7 kundan keyin

Ilova ochilmay qolsa ("Unable to Verify App"):

1. Telefonni yana USB bilan ulang.
2. Sideloadly'da **avvalgi IPA**ni qayta tanlang, **Start** bosing.
3. Yangi 7 kunlik imzo yaratiladi. Ma'lumotlar (savat, akkaunt) saqlanadi.

Bepul Apple ID cheklovlari: bir vaqtda **3 ta ilova**, haftasiga **10 ta
App ID**. O'chirilgan ilovalarni tozalab tursangiz muammo bo'lmaydi.

---

## 3-qism. API manzilini sozlash

Ilova ichida: **Profil → Sozlamalar → API manzili**.

- Telefon kompyuter bilan bir Wi-Fi'da: `http://10.144.82.174:8000/api`
- Kompyuter IP'si o'zgargan bo'lsa, Windows'da `ipconfig` → IPv4.
- Django `0.0.0.0:8000` da ishlayotgan bo'lsin (`scripts\start.ps1`).
- Turli tarmoqda bo'lsa, backend'ni tunnel orqali oching:

  ```powershell
  cloudflared tunnel --url http://localhost:8000
  ```

  Chiqqan `https://...trycloudflare.com` manziliga `/api` qo'shib yozing.

> IPA ichidagi standart manzil `10.0.2.2` (emulyator uchun). Shuning uchun
> birinchi ochilishda sozlamalarda manzilni albatta o'zgartiring.

---

## Muammolar

| Muammo | Yechim |
|---|---|
| `Unable to install "Quvvat"` | IPA imzosiz bo'lishi mumkin — Sideloadly bilan imzolang; yoki iPhone iOS versiyasi Xcode SDK'dan past |
| `Unable to Verify App` | 7 kun o'tgan; Sideloadly bilan qayta imzolang |
| `Untrusted Developer` | Settings → General → VPN & Device Management → Trust |
| `Developer Mode` ko'rinmaydi | iOS 16+ talab; iPhone'ni Mac/PC'ga ulab, Xcode/Sideloadly chaqirgandan keyin paydo bo'ladi |
| Sideloadly Apple ID'ni qabul qilmayapti | 2FA yoqilgan bo'lsa, app-specific parol yarating (appleid.apple.com → Sign-In and Security → App-Specific Passwords) |
| Build'da `CocoaPods` xatosi | Codemagic'da qayta build; yoki `pod repo update` |
| `No signing certificate` | Bu normal — biz `--no-codesign` bilan yig'amiz, imzo Sideloadly'da qo'yiladi |
| Ilova API'ga ulanmayapti | Sozlamalardagi manzil, Wi-Fi va Windows Firewall 8000-port |

---

## Alternativa: $99/yil Apple Developer Program

Agar har hafta qayta imzolash noqulay bo'lsa:

1. [developer.apple.com/programs](https://developer.apple.com/programs/) →
   $99/yil.
2. Codemagic'da **iOS code signing** sozlanadi (App Store Connect API key
   yoki `.p12` + provisioning profile).
3. Build → **TestFlight**ga yuklanadi → iPhone'ga App Store'dagi TestFlight
   ilovasi orqali o'rnatiladi. 90 kun, istalgan joydan, qayta imzosiz.

Bu variant uchun Codemagic'ning rasmiy qo'llanmasi:
<https://docs.codemagic.io/flutter-publishing/publishing-to-app-store/>

---

## Eng tez variant (umuman build qilmasdan)

Agar maqsad shunchaki "telefonda ilova kabi ochish" bo'lsa — **PWA**:

1. iPhone'da **Safari**'da saytni oching (`http://10.144.82.174:8000/`).
2. **Share** → **Add to Home Screen**.
3. Bosh ekranda ikonka paydo bo'ladi, to'liq ekranda ochiladi.

Cheklov yo'q, 7 kun muammosi yo'q. Lekin bu native ilova emas — push
bildirishnoma va ba'zi qurilma funksiyalari ishlamaydi.
