# iOS build — Mac'da bajariladigan qo'llanma

Bu qo'llanma **macOS + Xcode** bor kompyuterda iOS ilovani yig'ish va
iPhone'ga o'rnatish uchun. Windows'da iOS build qilib bo'lmaydi.

Repo: `https://github.com/pythondev2012-x/quvvat` (branch `main`).
Ilova papkasi: `mobile/`.

---

## 0. Talablar (hammasi bepul, Apple Developer hisobidan tashqari)

| Dastur | Versiya | Izoh |
|---|---|---|
| macOS | 13 Ventura yoki yangiroq | Xcode 15+ talab qiladi |
| Xcode | 15.0+ (App Store'dan) | iOS SDK va imzo qo'yish |
| Flutter SDK | 3.24+ (tekshirilgan: 3.47.9) | `mobile/` shu versiyada yozilgan |
| Dart | 3.6+ (tekshirilgan: 3.13.7) | Flutter bilan birga keladi |
| CocoaPods | 1.15+ | iOS kutubxonalarini o'rnatadi |
| Git | har qanday | repo'ni klonlash |
| Apple ID | bepul yoki $99/yil | imzo qo'yish uchun |

Ilova ishlatadigan paketlar (hammasi `flutter pub get` bilan avtomatik
o'rnatiladi, qo'lda o'rnatish shart emas):

| Paket | Versiya | Vazifasi |
|---|---|---|
| `http` | 1.6.0 | API so'rovlari |
| `provider` | 6.1.5+1 | holat boshqaruvi |
| `shared_preferences` | 2.5.6 | til va API manzilini saqlash |
| `cached_network_image` | 3.4.1 | rasmlarni keshlash |
| `cupertino_icons` | 1.0.9 | iOS ikonkalari |
| `flutter_localizations` | Flutter SDK | uz/ru/en tarjimalar |
| `flutter_lints` | 5.0.0 | kod tekshiruvi (dev) |
| `flutter_launcher_icons` | 0.14.4 | ikonka generatsiyasi (dev) |

iOS native tomoni (Flutter o'zi qo'shadi): **CocoaPods** orqali
`shared_preferences_foundation`, `path_provider_foundation`,
`sqflite_darwin` va h.k.

---

## 1. Xcode'ni o'rnatish

App Store'dan **Xcode**ni o'rnating (8–10 GB, vaqt oladi), so'ng Terminal'da:

```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -license accept
sudo xcodebuild -runFirstLaunch
xcodebuild -version
```

`xcodebuild -version` Xcode versiyasini ko'rsatsa — tayyor.

---

## 2. Flutter'ni o'rnatish

**Eng oson (Homebrew bilan):**

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install --cask flutter
brew install cocoapods
```

**Yoki qo'lda:**

```bash
git clone https://github.com/flutter/flutter.git -b stable ~/development/flutter
echo 'export PATH="$HOME/development/flutter/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
sudo gem install cocoapods
```

Tekshirish:

```bash
flutter --version          # 3.24 dan yuqori bo'lsin
flutter doctor -v          # Xcode va CocoaPods yashil bo'lsin
flutter precache --ios
```

`flutter doctor` da faqat Android/Chrome haqidagi ogohlantirishlar qolsa —
bu normal, iOS uchun muhim emas.

---

## 3. Repo'ni klonlash

```bash
git clone https://github.com/pythondev2012-x/quvvat.git
cd quvvat/mobile
flutter pub get
```

Variant: repo'ni ZIP qilib yuborish ham mumkin, lekin `git clone` qulayroq.

---

## 4. iOS kutubxonalarini o'rnatish

```bash
flutter build ios --config-only
cd ios
pod install
cd ..
```

Yoki tayyor skript bilan (repo ichida bor):

```bash
./tool/ios_setup.sh
```

Bu buyruq `ios/Podfile` va `ios/Pods/` ni yaratadi. Xato bersa:

```bash
pod repo update
sudo gem install cocoapods
```

---

## 5. Xcode'da imzo qo'yish va o'rnatish

```bash
open ios/Runner.xcworkspace
```

> **Muhim:** `Runner.xcodeproj` emas, aynan **`Runner.xcworkspace`** ochiladi.

Xcode'da:

1. Chapdagi navigatorda **Runner** loyihasini tanlang.
2. **TARGETS → Runner → Signing & Capabilities**.
3. **Team** → Apple ID'ingizni qo'shing (**Add Account…** → bepul Apple ID
   kiriting). Xcode **Personal Team** yaratadi.
4. **Automatically manage signing** belgilangan bo'lsin.
5. Agar "bundle identifier is not available" xatosi chiqsa, **Bundle
   Identifier**ni o'zgartiring, masalan `uz.quvvat.quvvat.dev`.
6. iPhone'ni USB bilan ulang, telefonda **Trust This Computer** bosing.
7. Yuqoridagi qurilma ro'yxatidan iPhone'ni tanlang va **▶ Run** bosing.

Birinchi o'rnatishdan keyin telefonda:

- **Settings → General → VPN & Device Management → Developer App** →
  dasturchi profilini **Trust** qiling.
- iOS 16+ da: **Settings → Privacy & Security → Developer Mode** → yoqing
  (telefon qayta yuklanadi).

Bepul Apple ID bilan ilova **7 kun** ishlaydi, keyin Xcode'dan qayta Run
qilish kerak. $99/yil Apple Developer Program bilan bu cheklov yo'q
(TestFlight orqali 90 kun).

---

## 6. API manzilini sozlash

Ilova ichida: **Profil → Sozlamalar → API manzili**.

- Kompyuter bilan **bir Wi-Fi**da bo'lsa:
  `http://10.144.82.174:8000/api`
- Kompyuterning IP'si o'zgargan bo'lsa, Windows'da `ipconfig` dan yangi
  IPv4 manzilni oling.
- Django `0.0.0.0:8000` da ishlashi kerak (`scripts\start.ps1`) va Windows
  Firewall 8000-portga ruxsat bergan bo'lishi kerak.
- Do'stingiz boshqa shaharda/tarmoqda bo'lsa, lokal IP ishlamaydi. U holda
  backend'ni internetga chiqarish kerak (domen + HTTPS yoki vaqtincha
  `cloudflared tunnel --url http://localhost:8000`). Tunnel bergan HTTPS
  manzilni ilova sozlamalariga yozish kifoya.

---

## 7. "Build qilib menga tashlab berish" — qanday ishlaydi

Bu yerda eng muhim nuance:

| Hisob | Qanday yetkaziladi |
|---|---|
| **Bepul Apple ID** | iPhone **do'stning Mac'iga USB bilan ulangan bo'lishi shart**. `.ipa` faylni Telegram orqali yuborib o'rnatib bo'lmaydi — imzo faqat o'sha qurilma uchun va Mac'da yaratiladi. |
| **$99/yil Developer Program** | Do'st `.ipa`ni **ad-hoc** qilib yuborishi mumkin (sizning iPhone UDID'i ro'yxatga qo'shiladi), yoki **TestFlight**ga yuklaydi — siz istalgan joydan o'rnatasiz. |

Ya'ni:

- **Bepul variant:** telefonni do'stingizga qoldirasiz/uchrashtirasiz, u
  Xcode'dan Run qiladi — 10 daqiqalik ish.
- **Pullik variant:** do'stingiz Apple Developer hisobini ochadi (yoki siz
  ochib, unga Team'ga qo'shilish huquqini berasiz), Xcode → **Product →
  Archive → Distribute App → Ad Hoc / App Store Connect**, keyin `.ipa`
  yoki TestFlight havolasini yuboradi.

---

## 8. Tez-tez uchraydigan xatolar

| Xato | Yechim |
|---|---|
| `CocoaPods not installed` | `brew install cocoapods` yoki `sudo gem install cocoapods` |
| `pod install` xato beradi | `cd ios && pod repo update && pod install` |
| `No profiles for 'uz.quvvat.quvvat' were found` | Xcode → Signing → Team tanlang; kerak bo'lsa bundle ID'ni o'zgartiring |
| `Building for iOS, but the linked framework was built for iOS Simulator` | `flutter clean && flutter pub get && cd ios && pod install` |
| `Could not build the application for the simulator` | Xcode → Window → Devices and Simulators → qurilmani tanlang, simulator emas |
| Eski kesh xatolari | `flutter clean`, `rm -rf ios/Pods ios/Podfile.lock`, keyin 4-qadamni takrorlang |
| `flutter: command not found` | `~/.zshrc` ga PATH qo'shilganini tekshiring, yangi Terminal oching |
| Xcode juda eski | macOS'ni yangilang yoki Xcode 15+ versiyasini o'rnating |

---

## 9. Tekshirish ro'yxati (do'stingiz uchun)

- [ ] Xcode o'rnatildi, litsenziya qabul qilindi
- [ ] `flutter doctor -v` — Xcode va CocoaPods yashil
- [ ] `git clone` + `cd mobile` + `flutter pub get` bajarildi
- [ ] `./tool/ios_setup.sh` (yoki `flutter build ios --config-only` + `pod install`)
- [ ] `Runner.xcworkspace` Xcode'da ochildi
- [ ] Signing → Personal Team tanlandi
- [ ] iPhone ulandi va **▶ Run** bosildi
- [ ] Telefonda dasturchi profili **Trust** qilindi
- [ ] Ilova → Sozlamalar → API manzili to'g'ri kiritildi
- [ ] Katalog va rasm lar yuklanmoqda

Tayyor. Muammo bo'lsa, Xcode'dagi xato matnini va `flutter doctor -v`
natijasini yuboring.
