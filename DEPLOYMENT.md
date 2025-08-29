# CV Maker - Web Deployment Guide

## 🚀 Projeyi Web'e Yayımlama Rehberi

Bu rehber, CV Maker uygulamasını www.flutech.org/CvMaker adresinde yayımlamak için gerekli adımları içerir.

## 📋 Ön Gereksinimler

- Flutter SDK kurulu olmalı
- Web desteği aktifleştirilmiş olmalı: `flutter config --enable-web`
- Projenin çalıştığından emin olun: `flutter run -d chrome`

## 🔧 Build İşlemi

### 1. Web Build Komutunu Çalıştır

```bash
flutter build web --base-href="/CvMaker/" --release
```

**Komut Açıklaması:**
- `--base-href="/CvMaker/"`: Uygulamanın subdirectory'de çalışmasını sağlar
- `--release`: Optimized production build oluşturur
- Build çıktısı: `build/web/` klasöründe oluşur

### 2. Build Sonrası Kontrol

Build başarılı olduktan sonra aşağıdaki dosyaların oluştuğunu kontrol edin:

```
build/web/
├── index.html
├── main.dart.js
├── flutter.js
├── flutter_service_worker.js
├── manifest.json
├── favicon.png
├── icons/
├── assets/
└── canvaskit/
```

## 📁 Deployment İşlemi

### 1. CvMaker Klasörü Oluştur

Sunucunuzda web root dizininde (genellikle `public_html` veya `www`) `CvMaker` klasörü oluşturun:

```bash
# Sunucuda
mkdir /path/to/your/website/CvMaker
```

### 2. Build Dosyalarını Kopyala

`build/web/` klasöründeki **tüm dosya ve klasörleri** CvMaker klasörüne kopyalayın:

```bash
# Local'den sunucuya
rsync -av build/web/ user@yourserver:/path/to/website/CvMaker/

# veya FTP/SFTP ile manuel kopyalama
```

### 3. Dizin Yapısı Kontrol

Sunucudaki son dizin yapısı şöyle olmalı:

```
www.flutech.org/
├── (ana site dosyaları)
└── CvMaker/
    ├── index.html
    ├── main.dart.js
    ├── flutter.js
    ├── flutter_service_worker.js
    ├── manifest.json
    ├── favicon.png
    ├── icons/
    ├── assets/
    └── canvaskit/
```

## 🌐 Web Server Konfigürasyonu

### Apache (.htaccess)

CvMaker klasöründe `.htaccess` dosyası oluşturun:

```apache
# .htaccess
RewriteEngine On
RewriteBase /CvMaker/

# Handle client-side routing
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . index.html [L]

# MIME types for Flutter web
AddType application/javascript .js
AddType application/wasm .wasm

# Cache control
<IfModule mod_expires.c>
    ExpiresActive On
    ExpiresByType application/javascript "access plus 1 year"
    ExpiresByType text/css "access plus 1 year"
    ExpiresByType application/wasm "access plus 1 year"
    ExpiresByType image/png "access plus 1 year"
    ExpiresByType image/ico "access plus 1 year"
</IfModule>
```

### Nginx

Nginx konfigürasyonuna ekleyin:

```nginx
location /CvMaker/ {
    alias /path/to/website/CvMaker/;
    try_files $uri $uri/ /CvMaker/index.html;
    
    # MIME types
    location ~* \.(js)$ {
        add_header Content-Type application/javascript;
        expires 1y;
    }
    
    location ~* \.(wasm)$ {
        add_header Content-Type application/wasm;
        expires 1y;
    }
}
```

## ✅ Test İşlemi

1. **Local Test:**
   ```bash
   cd build/web
   python -m http.server 8000
   # Tarayıcıda: http://localhost:8000
   ```

2. **Production Test:**
   - Tarayıcıda `www.flutech.org/CvMaker` adresini ziyaret edin
   - Uygulamanın doğru çalıştığını kontrol edin
   - Tema değiştirme, dil değiştirme, PDF export gibi tüm özellikleri test edin

## 🔄 Güncelleme İşlemi

Projeyi güncellemek için:

1. Kod değişikliklerini yapın
2. Build komutunu tekrar çalıştırın:
   ```bash
   flutter build web --base-href="/CvMaker/" --release
   ```
3. Yeni build dosyalarını sunucuya kopyalayın
4. Browser cache'ini temizleyin (Ctrl+F5)

## 📱 Mobil Uyumluluk

Uygulama responsive tasarıma sahiptir ve mobil cihazlarda da düzgün çalışır:
- ✅ Mobil dokunmatik kontroller
- ✅ Responsive layout
- ✅ PWA (Progressive Web App) desteği

## 🎯 SEO ve Meta Tags

`index.html` dosyasında SEO için uygun meta taglar mevcuttur:
- Open Graph tags
- Twitter Card support
- Proper title and description

## 🐛 Sorun Giderme

### Yaygın Sorunlar:

1. **404 Hatası:**
   - `.htaccess` veya nginx konfigürasyonunu kontrol edin
   - Base href ayarının doğru olduğundan emin olun

2. **Beyaz Sayfa:**
   - Browser console'da hata mesajlarını kontrol edin
   - CORS ayarlarını kontrol edin

3. **Statik Dosyalar Yüklenmiyor:**
   - MIME type ayarlarını kontrol edin
   - Dosya yollarının doğru olduğundan emin olun

4. **PWA Cache Sorunları:**
   ```bash
   # Service Worker'ı temizle
   # Browser Developer Tools > Application > Storage > Clear storage
   ```

## 📞 Destek

Sorun yaşarsanız:
1. Browser developer tools console'ı kontrol edin
2. Network sekmesinde failed request'leri inceleyin
3. Server error log'larını kontrol edin

---

**Son Güncelleme:** 29 Ağustos 2025  
**Versiyon:** 1.0.0  
**Deploy URL:** https://www.flutech.org/CvMaker