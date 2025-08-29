### L10n Generate Komutu
Flutter yerelleştirme dosyalarını ARB’lerden yeniden üretmek için:

```bash
flutter gen-l10n
```

- Projede `l10n.yaml` bulunduğu için, CLI bayrakları yerine bu dosyadaki ayarlar kullanılır.
- ARB güncellemelerinden sonra bu komutu çalıştırmayı unutma.
- Tipik değişiklik akışı:
  1. `lib/l10n/app_en.arb` ve `lib/l10n/app_tr.arb` içine yeni anahtarları ekle.
  2. Komutu çalıştır: `flutter gen-l10n`
  3. Üretilen dosyaları kontrol et: `lib/l10n/app_localizations_en.dart`, `lib/l10n/app_localizations_tr.dart`, `lib/l10n/app_localizations.dart`.