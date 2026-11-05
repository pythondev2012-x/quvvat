import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';

class L10n {
  const L10n(this.language);

  final String language;

  static L10n of(BuildContext context) {
    return L10n(context.watch<SettingsProvider>().language);
  }

  String t(String key) {
    return _values[key]?[language] ?? _values[key]?['uz'] ?? key;
  }

  String statusLabel(int status) {
    switch (status) {
      case 2:
        return t('status2');
      case 3:
        return t('status3');
      case 4:
        return t('status4');
      case 5:
        return t('status5');
      default:
        return t('status1');
    }
  }

  static const Map<String, Map<String, String>> _values = {
    'appName': {'uz': 'Quvvat', 'ru': 'Quvvat', 'en': 'Quvvat'},
    'home': {'uz': 'Bosh sahifa', 'ru': 'Главная', 'en': 'Home'},
    'catalog': {'uz': 'Katalog', 'ru': 'Каталог', 'en': 'Catalog'},
    'cart': {'uz': 'Savat', 'ru': 'Корзина', 'en': 'Cart'},
    'profile': {'uz': 'Profil', 'ru': 'Профиль', 'en': 'Profile'},
    'search': {'uz': 'Qidirish', 'ru': 'Поиск', 'en': 'Search'},
    'searchHint': {
      'uz': 'Mahsulot qidirish',
      'ru': 'Поиск товаров',
      'en': 'Search products',
    },
    'retry': {'uz': 'Qayta urinish', 'ru': 'Повторить', 'en': 'Retry'},
    'loading': {'uz': 'Yuklanmoqda...', 'ru': 'Загрузка...', 'en': 'Loading...'},
    'error': {
      'uz': 'Xatolik yuz berdi',
      'ru': 'Произошла ошибка',
      'en': 'Something went wrong',
    },
    'empty': {'uz': "Bo'sh", 'ru': 'Пусто', 'en': 'Empty'},
    'cancel': {'uz': 'Bekor qilish', 'ru': 'Отмена', 'en': 'Cancel'},
    'save': {'uz': 'Saqlash', 'ru': 'Сохранить', 'en': 'Save'},
    'close': {'uz': 'Yopish', 'ru': 'Закрыть', 'en': 'Close'},
    'clear': {'uz': 'Tozalash', 'ru': 'Очистить', 'en': 'Clear'},
    'seeAll': {'uz': 'Barchasi', 'ru': 'Все', 'en': 'See all'},
    'loadMore': {
      'uz': "Ko'proq yuklash",
      'ru': 'Загрузить ещё',
      'en': 'Load more',
    },
    'login': {'uz': 'Kirish', 'ru': 'Вход', 'en': 'Login'},
    'register': {
      'uz': "Ro'yxatdan o'tish",
      'ru': 'Регистрация',
      'en': 'Sign up',
    },
    'logout': {'uz': 'Chiqish', 'ru': 'Выйти', 'en': 'Logout'},
    'username': {'uz': 'Login', 'ru': 'Логин', 'en': 'Username'},
    'password': {'uz': 'Parol', 'ru': 'Пароль', 'en': 'Password'},
    'confirmPassword': {
      'uz': 'Parolni tasdiqlang',
      'ru': 'Подтвердите пароль',
      'en': 'Confirm password',
    },
    'email': {'uz': 'Email', 'ru': 'Email', 'en': 'Email'},
    'phone': {'uz': 'Telefon', 'ru': 'Телефон', 'en': 'Phone'},
    'address': {'uz': 'Manzil', 'ru': 'Адрес', 'en': 'Address'},
    'loginRequired': {
      'uz': 'Avval tizimga kiring',
      'ru': 'Сначала войдите в систему',
      'en': 'Please login first',
    },
    'loginToContinue': {
      'uz': 'Davom etish uchun hisobingizga kiring.',
      'ru': 'Войдите в аккаунт, чтобы продолжить.',
      'en': 'Login to continue.',
    },
    'noAccount': {
      'uz': "Hisobingiz yo'qmi?",
      'ru': 'Нет аккаунта?',
      'en': 'No account?',
    },
    'haveAccount': {
      'uz': 'Hisobingiz bormi?',
      'ru': 'Уже есть аккаунт?',
      'en': 'Already have an account?',
    },
    'welcomeBack': {
      'uz': 'Xush kelibsiz',
      'ru': 'С возвращением',
      'en': 'Welcome back',
    },
    'createAccount': {
      'uz': 'Hisob yaratish',
      'ru': 'Создать аккаунт',
      'en': 'Create account',
    },
    'loginButton': {'uz': 'Kirish', 'ru': 'Войти', 'en': 'Login'},
    'registerButton': {
      'uz': "Ro'yxatdan o'tish",
      'ru': 'Зарегистрироваться',
      'en': 'Create account',
    },
    'logoutConfirm': {
      'uz': 'Hisobdan chiqmoqchimisiz?',
      'ru': 'Выйти из аккаунта?',
      'en': 'Logout?',
    },
    'logoutSuccess': {
      'uz': 'Hisobdan chiqdingiz',
      'ru': 'Вы вышли из аккаунта',
      'en': 'Logged out',
    },
    'deliveryNote': {
      'uz': "O'zbekiston bo'ylab yetkazib berish",
      'ru': 'Доставка по Узбекистану',
      'en': 'Delivery across Uzbekistan',
    },
    'categories': {
      'uz': 'Kategoriyalar',
      'ru': 'Категории',
      'en': 'Categories',
    },
    'newProducts': {
      'uz': 'Yangi mahsulotlar',
      'ru': 'Новые товары',
      'en': 'New products',
    },
    'allProducts': {
      'uz': 'Barcha mahsulotlar',
      'ru': 'Все товары',
      'en': 'All products',
    },
    'addToCart': {
      'uz': "Savatga qo'shish",
      'ru': 'В корзину',
      'en': 'Add to cart',
    },
    'outOfStock': {
      'uz': 'Tugagan',
      'ru': 'Нет в наличии',
      'en': 'Out of stock',
    },
    'inStock': {
      'uz': 'Sotuvda bor',
      'ru': 'В наличии',
      'en': 'In stock',
    },
    'quantity': {'uz': 'Soni', 'ru': 'Количество', 'en': 'Quantity'},
    'description': {'uz': 'Tavsif', 'ru': 'Описание', 'en': 'Description'},
    'discount': {'uz': 'Chegirma', 'ru': 'Скидка', 'en': 'Discount'},
    'saved': {
      'uz': "Saqlanganlarga qo'shildi",
      'ru': 'Добавлено в избранное',
      'en': 'Saved to wishlist',
    },
    'removedFromWishlist': {
      'uz': 'Saqlanganlardan olib tashlandi',
      'ru': 'Удалено из избранного',
      'en': 'Removed from wishlist',
    },
    'cartEmpty': {
      'uz': "Savat bo'sh",
      'ru': 'Корзина пуста',
      'en': 'Cart is empty',
    },
    'cartEmptyHint': {
      'uz': 'Mahsulotlarni katalogdan tanlang.',
      'ru': 'Выберите товары из каталога.',
      'en': 'Pick products from the catalog.',
    },
    'orderNow': {
      'uz': 'Buyurtma berish',
      'ru': 'Оформить заказ',
      'en': 'Checkout',
    },
    'total': {'uz': 'Jami', 'ru': 'Итого', 'en': 'Total'},
    'discountTotal': {'uz': 'Chegirma', 'ru': 'Скидка', 'en': 'Discount'},
    'clearCart': {
      'uz': 'Savatni tozalash',
      'ru': 'Очистить корзину',
      'en': 'Clear cart',
    },
    'clearCartConfirm': {
      'uz': "Savatdagi barcha mahsulotlar o'chiriladi. Davom etasizmi?",
      'ru': 'Все товары будут удалены. Продолжить?',
      'en': 'All items will be removed. Continue?',
    },
    'continueShopping': {
      'uz': 'Xaridni davom ettirish',
      'ru': 'Продолжить покупки',
      'en': 'Continue shopping',
    },
    'checkout': {
      'uz': 'Buyurtma berish',
      'ru': 'Оформление заказа',
      'en': 'Checkout',
    },
    'orderDetails': {
      'uz': 'Buyurtma ma’lumotlari',
      'ru': 'Данные заказа',
      'en': 'Order details',
    },
    'fullName': {
      'uz': 'Ism yoki login',
      'ru': 'Имя или логин',
      'en': 'Name or username',
    },
    'phoneNumber': {
      'uz': 'Telefon raqam',
      'ru': 'Номер телефона',
      'en': 'Phone number',
    },
    'deliveryAddress': {
      'uz': 'Yetkazib berish manzili',
      'ru': 'Адрес доставки',
      'en': 'Delivery address',
    },
    'attachLocation': {
      'uz': 'Lokatsiyani biriktirish',
      'ru': 'Прикрепить местоположение',
      'en': 'Attach location',
    },
    'updateLocation': {
      'uz': 'Lokatsiyani yangilash',
      'ru': 'Обновить местоположение',
      'en': 'Update location',
    },
    'locating': {
      'uz': 'Lokatsiya aniqlanmoqda…',
      'ru': 'Определение местоположения…',
      'en': 'Locating…',
    },
    'locationAttached': {
      'uz': 'Lokatsiya biriktirildi ✓',
      'ru': 'Местоположение прикреплено ✓',
      'en': 'Location attached ✓',
    },
    'locationFailed': {
      'uz': "Lokatsiyani olib bo'lmadi — manzilni qo'lda kiriting.",
      'ru': 'Не удалось получить местоположение — введите адрес вручную.',
      'en': 'Could not get location — enter the address manually.',
    },
    'locationPermissionDenied': {
      'uz': "Lokatsiyaga ruxsat berilmadi — manzilni qo'lda kiriting.",
      'ru': 'Доступ к геолокации не разрешён — введите адрес вручную.',
      'en': 'Location permission denied — enter the address manually.',
    },
    'locationServiceOff': {
      'uz': "GPS o'chirilgan — telefonda lokatsiyani yoqing.",
      'ru': 'GPS выключен — включите геолокацию на телефоне.',
      'en': 'GPS is off — turn on location on your phone.',
    },
    'locationNote': {
      'uz': 'Aniq yetkazib berish uchun lokatsiyani biriktiring (ixtiyoriy).',
      'ru': 'Прикрепите местоположение для точной доставки (необязательно).',
      'en': 'Attach your location for precise delivery (optional).',
    },
    'coordinates': {
      'uz': 'Koordinatalar',
      'ru': 'Координаты',
      'en': 'Coordinates',
    },
    'placeOrder': {
      'uz': 'Buyurtmani tasdiqlash',
      'ru': 'Подтвердить заказ',
      'en': 'Place order',
    },
    'orderSuccess': {
      'uz': 'Buyurtma qabul qilindi!',
      'ru': 'Заказ принят!',
      'en': 'Order placed!',
    },
    'orderSuccessMessage': {
      'uz': "Tez orada operatorimiz siz bilan bog'lanadi.",
      'ru': 'Наш оператор скоро свяжется с вами.',
      'en': 'Our operator will contact you soon.',
    },
    'orderNumber': {
      'uz': 'Buyurtma raqami',
      'ru': 'Номер заказа',
      'en': 'Order number',
    },
    'orderStatus': {'uz': 'Holat', 'ru': 'Статус', 'en': 'Status'},
    'backToHome': {
      'uz': 'Bosh sahifaga qaytish',
      'ru': 'На главную',
      'en': 'Back to home',
    },
    'myOrders': {
      'uz': 'Buyurtmalarim',
      'ru': 'Мои заказы',
      'en': 'My orders',
    },
    'noOrders': {
      'uz': "Hozircha buyurtmalar yo'q",
      'ru': 'Пока нет заказов',
      'en': 'No orders yet',
    },
    'wishlist': {
      'uz': 'Saqlanganlar',
      'ru': 'Избранное',
      'en': 'Wishlist',
    },
    'wishlistEmpty': {
      'uz': "Saqlangan mahsulotlar yo'q",
      'ru': 'Нет избранных товаров',
      'en': 'No saved products',
    },
    'settings': {'uz': 'Sozlamalar', 'ru': 'Настройки', 'en': 'Settings'},
    'serverSettings': {
      'uz': 'Server manzili',
      'ru': 'Адрес сервера',
      'en': 'Server address',
    },
    'serverUrl': {'uz': 'API manzili', 'ru': 'Адрес API', 'en': 'API URL'},
    'serverUrlHint': {
      'uz': 'http://192.168.1.10:8000/api',
      'ru': 'http://192.168.1.10:8000/api',
      'en': 'http://192.168.1.10:8000/api',
    },
    'serverHint': {
      'uz':
          "Emulyator uchun http://10.0.2.2:8000/api. Telefonda kompyuterning lokal IP manzilini yozing (masalan http://192.168.1.10:8000/api).",
      'ru':
          'Для эмулятора: http://10.0.2.2:8000/api. На телефоне укажите локальный IP компьютера (например http://192.168.1.10:8000/api).',
      'en':
          'For the emulator use http://10.0.2.2:8000/api. On a phone use the computer local IP (for example http://192.168.1.10:8000/api).',
    },
    'testConnection': {
      'uz': 'Ulanishni tekshirish',
      'ru': 'Проверить подключение',
      'en': 'Test connection',
    },
    'connectionOk': {
      'uz': 'Ulanish muvaffaqiyatli',
      'ru': 'Подключение успешно',
      'en': 'Connection successful',
    },
    'connectionFailed': {
      'uz': "Ulanib bo'lmadi",
      'ru': 'Не удалось подключиться',
      'en': 'Connection failed',
    },
    'language': {'uz': 'Til', 'ru': 'Язык', 'en': 'Language'},
    'about': {'uz': 'Ilova haqida', 'ru': 'О приложении', 'en': 'About'},
    'version': {'uz': 'Versiya', 'ru': 'Версия', 'en': 'Version'},
    'addedToCart': {
      'uz': "Savatga qo'shildi",
      'ru': 'Добавлено в корзину',
      'en': 'Added to cart',
    },
    'removedFromCart': {
      'uz': 'Savatdan olib tashlandi',
      'ru': 'Удалено из корзины',
      'en': 'Removed from cart',
    },
    'orderPlaced': {
      'uz': 'Buyurtma yaratildi',
      'ru': 'Заказ создан',
      'en': 'Order created',
    },
    'profileGuestTitle': {
      'uz': 'Quvvat ilovasiga xush kelibsiz',
      'ru': 'Добро пожаловать в Quvvat',
      'en': 'Welcome to Quvvat',
    },
    'profileGuestText': {
      'uz': "Buyurtmalar va saqlanganlarni ko'rish uchun kiring.",
      'ru': 'Войдите, чтобы видеть заказы и избранное.',
      'en': 'Login to see orders and wishlist.',
    },
    'myWishlist': {
      'uz': 'Saqlanganlarim',
      'ru': 'Моё избранное',
      'en': 'My wishlist',
    },
    'myProfile': {
      'uz': 'Mening profilim',
      'ru': 'Мой профиль',
      'en': 'My profile',
    },
    'memberSince': {
      'uz': "Ro'yxatdan o'tgan",
      'ru': 'Дата регистрации',
      'en': 'Member since',
    },
    'status1': {
      'uz': 'Faol emas',
      'ru': 'Не активен',
      'en': 'Inactive',
    },
    'status2': {
      'uz': "Yig'ilmoqda",
      'ru': 'Собирается',
      'en': 'Processing',
    },
    'status3': {'uz': "Yo'lda", 'ru': 'В пути', 'en': 'On the way'},
    'status4': {'uz': 'Yetkazilgan', 'ru': 'Доставлен', 'en': 'Delivered'},
    'status5': {
      'uz': 'Qaytarilgan',
      'ru': 'Возвращён',
      'en': 'Returned',
    },
    'itemCount': {
      'uz': 'ta mahsulot',
      'ru': 'товаров',
      'en': 'items',
    },
    'currency': {'uz': "so'm", 'ru': 'сум', 'en': 'UZS'},
    'noProducts': {
      'uz': 'Mahsulot topilmadi',
      'ru': 'Товары не найдены',
      'en': 'No products found',
    },
    'requiredField': {
      'uz': "Bu maydonni to'ldiring",
      'ru': 'Заполните это поле',
      'en': 'This field is required',
    },
    'passwordMismatch': {
      'uz': 'Parollar bir xil emas',
      'ru': 'Пароли не совпадают',
      'en': 'Passwords do not match',
    },
    'minPassword': {
      'uz': 'Kamida 6 ta belgi',
      'ru': 'Минимум 6 символов',
      'en': 'At least 6 characters',
    },
    'optional': {
      'uz': 'ixtiyoriy',
      'ru': 'необязательно',
      'en': 'optional',
    },
    'reset': {'uz': 'Tiklash', 'ru': 'Сбросить', 'en': 'Reset'},
    'orderCode': {'uz': 'Buyurtma', 'ru': 'Заказ', 'en': 'Order'},
    'newest': {'uz': 'Yangi', 'ru': 'Новые', 'en': 'Newest'},
    'priceLow': {
      'uz': 'Narx ↑',
      'ru': 'Цена ↑',
      'en': 'Price ↑',
    },
    'priceHigh': {
      'uz': 'Narx ↓',
      'ru': 'Цена ↓',
      'en': 'Price ↓',
    },
    'nameAZ': {'uz': 'Nomi A-Z', 'ru': 'Название A-Z', 'en': 'Name A-Z'},
  };
}

extension L10nBuildContext on BuildContext {
  String tr(String key) => L10n.of(this).t(key);
}
