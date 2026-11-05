#!/usr/bin/env bash
# iOS uchun tayyorgarlik: Flutter paketlari, Podfile va CocoaPods.
# Faqat macOS'da ishlaydi. Batafsil: IOS_BUILD.md
set -euo pipefail

cd "$(dirname "$0")/.."

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Xato: iOS build faqat macOS'da ishlaydi (hozir: $(uname -s))." >&2
  exit 1
fi

if ! command -v flutter >/dev/null 2>&1; then
  echo "Xato: 'flutter' topilmadi. IOS_BUILD.md ning 2-qadamini bajaring." >&2
  exit 1
fi

if ! command -v pod >/dev/null 2>&1; then
  echo "Xato: CocoaPods topilmadi. 'brew install cocoapods' yoki" >&2
  echo "'sudo gem install cocoapods' buyrug'ini bajaring." >&2
  exit 1
fi

echo "==> flutter pub get"
flutter pub get

echo "==> Flutter iOS konfiguratsiyasi (Podfile yaratish)"
flutter build ios --config-only || true

if [[ ! -f ios/Podfile ]]; then
  echo "==> Podfile topilmadi, to'liq (imzosiz) build orqali yaratilmoqda..."
  flutter build ios --release --no-codesign
fi

echo "==> CocoaPods o'rnatilmoqda"
(cd ios && pod install)

echo ""
echo "Tayyor! Xcode ochilmoqda: ios/Runner.xcworkspace"
echo "Xcode'da: Runner → Signing & Capabilities → Team → iPhone → Run."
open ios/Runner.xcworkspace
