# Quvvat mobil ilovasi (Flutter)

Quvvat onlayn do'konining Flutter ilovasi. Backend — loyihaning ildizidagi
Django REST API (`/api/`).

## Imkoniyatlar

- Katalog, kategoriyalar, qidiruv va saralash
- Mahsulot tafsiloti, chegirma va qoldiq
- Savat, miqdorni o'zgartirish, buyurtma berish
- Buyurtmaga joriy lokatsiyani biriktirish (saytdagi kabi)
- Ro'yxatdan o'tish, kirish, profil
- Buyurtmalar tarixi va saqlanganlar (wishlist)
- `uz` / `ru` / `en` tillari (interfeys va API kontenti)
- Server manzilini ilova ichidan o'zgartirish

## Talablar

- Flutter 3.24+ (Dart 3.6+)
- Android SDK 35+ va JDK 17
- iOS uchun: macOS + Xcode 15+ (faqat iOS build uchun)

## Ishga tushirish

```bash
cd mobile
flutter pub get
flutter run
```

Standart API manzili: `http://10.0.2.2:8000/api` (Android emulyator uchun
kompyuterning `localhost` manzili).

### Haqiqiy telefonda

1. Kompyuter va telefon bir Wi-Fi tarmog'ida bo'lsin.
2. Backendni tashqi ulanishga oching:

   ```powershell
   .\scripts\start.ps1
   ```

3. Kompyuterning lokal IP manzilini aniqlang (`ipconfig`).
4. Telefonda ilova → **Profil → Sozlamalar → API manzili** ga yozing:

   ```text
   http://192.168.1.10:8000/api
   ```

5. Windows Firewall 8000-portga ruxsat bersin.

## Build

### Android

Eng oson yo'l — `tool\build_android.bat` faylini ikki marta bosing. Skript
Flutter, JDK va Android SDK'ni o'zi topadi va APK'ni yig'adi.

Qo'lda build qilish:

```bash
flutter build apk --release
```

Natija: `build/app/outputs/flutter-apk/app-release.apk`.

Haqiqiy telefonda ishlatish uchun API manzilini build vaqtida berish mumkin:

```bash
flutter build apk --release --dart-define=API_BASE_URL=http://10.144.82.174:8000/api
```

### iOS

iOS ilovani **faqat macOS + Xcode** muhitida yig'ish mumkin (Windows'da
build qilib bo'lmaydi). `ios/` loyihasi tayyor: bundle ID `uz.quvvat.quvvat`,
ilova nomi `Quvvat`, lokal tarmoq (HTTP) uchun ATS ruxsati qo'shilgan.

Mac'da:

```bash
cd mobile
flutter pub get
cd ios && pod install && cd ..
flutter build ios --release --dart-define=API_BASE_URL=http://10.144.82.174:8000/api
open ios/Runner.xcworkspace   # Xcode'da imzo qo'yish va qurilmaga o'rnatish
```

Xcode'da **Runner → Signing & Capabilities** bo'limida Apple ID (Personal
Team) tanlanadi. Bepul Apple ID ilovani faqat 7 kunga o'rnatish imkonini
beradi; TestFlight/App Store uchun Apple Developer Program ($99/yil) kerak.

Mac bo'lmasa, bulutli macOS (masalan, Codemagic yoki GitHub Actions macOS
runner) yordamida `.ipa` yig'ish mumkin — repozitoriy shu holatda tayyor.

**To'liq qadam-baqadam qo'llanma (Mac'li do'stingiz uchun):**
[`IOS_BUILD.md`](IOS_BUILD.md). Tayyor skript: `./tool/ios_setup.sh`.

**Mac yo'qmi?** [`IOS_SELF_BUILD.md`](IOS_SELF_BUILD.md) — Codemagic +
Sideloadly bilan o'zingiz yig'ib, bepul Apple ID bilan o'rnatasiz
(`codemagic.yaml` tayyor).

Launcher ikonkasini yangilash:

```bash
dart run flutter_launcher_icons
```

## Tuzilish

```text
lib/
  config/       API manzili
  l10n/         uz/ru/en matnlari
  models/       API modellari
  providers/    holat boshqaruvi (auth, savat, wishlist, sozlamalar)
  screens/      ekranlar
  services/     HTTP klient
  theme/        oq-qora-qizil dizayn
  utils/        formatlash va yordamchilar
  widgets/      umumiy komponentlar
assets/
  fonts/        Onest va Unbounded
  icon/         launcher ikonkalari
```

## Eslatma

Lokal test uchun HTTP ishlatiladi, shuning uchun Android manifestda
`usesCleartextTraffic="true"` yoqilgan. Ishlab chiqarishda API'ni HTTPS
bilan joylashtirib, bu sozlamani o'chirish tavsiya etiladi.
