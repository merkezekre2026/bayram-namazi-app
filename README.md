# 🕌 Bayram Namazı Saatleri ve Ezan Vakitleri Uygulaması

Bu proje; Türkiye'nin tüm il ve ilçeleri için Diyanet İşleri Başkanlığı'nın resmi namaz vakitlerini canlı olarak Web API üzerinden çeken, çevrimdışı önbellekleme desteği, interaktif bayram namazı kılınış kılavuzu ve çevrimdışı Kıble yön bulucusu sunan, modern ve premium tasarımlı bir **Flutter** mobil/web uygulamasıdır.

---

## ✨ Özellikler

*   **Dinamik Konum Seçimi:** Ülke -> İl -> İlçe hiyerarşisi ile tam Diyanet uyumlu konum seçimi.
*   **Akıllı Çevrimdışı Önbellekleme (Offline Caching):** `shared_preferences` entegrasyonu sayesinde internet bağlantısı koptuğunda veya olmadığında, daha önce yüklenmiş olan vakitleri otomatik olarak yükler ve kesintisiz hizmet sunar.
*   **Bayram Günü Algılama ve Geri Sayım:**
    *   Hicri takvime göre o günün Ramazan Bayramı (1 Şevval) veya Kurban Bayramı (10 Zilhicce) olup olmadığını otomatik algılar.
    *   Bayram gününde özel bayramlaşma/tebrik kartı açılır ve gün doğumu (`gunes`) vaktine 40 dakika eklenerek hesaplanan Bayram Namazı saati gösterilir.
    *   Diğer günlerde ise yaklaşan ilk bayram için (örn: Ramazan veya Kurban) gün bazında geri sayım ve kalan gün sayısını gösterir.
*   **Kıble Yön Bulucu (Matematiksel Pusula):**
    *   Türkiye'nin 81 iline ait coğrafi koordinat verileri yerel olarak gömülüdür.
    *   Bulunduğunuz konumun enlem/boylam bilgileri ile Kabe koordinatları ($21.4225^\circ \text{ N}, 39.8262^\circ \text{ E}$) arasındaki sapma açısı (bearing) tamamen çevrimdışı hesaplanır.
    *   Cihazda pusula donanımı olmasa dahi yön bulmayı kolaylaştıran şık, altın renkli bir gösterge arayüzü sunulur.
*   **Bayram Namazı Nasıl Kılınır? Rehberi:** Bayram namazındaki ilave 6 zaid tekbiri (unutulan en kritik bölümleri) rekat rekat gösteren adım adım görsel ve yazılı rehber.
*   **Premium Tasarım Teması:** Manevi atmosfere uygun Koyu Yeşil (`#071B15` / `#0F4C3A`) ve Altın Sarısı (`#D4AF37`) renk şeması, yumuşatılmış modern kart tasarımları ve canlı geçişler.

---

## 📂 Klasör Yapısı

```
bayram-namazi-app/
├── .github/
│   └── workflows/
│       └── android_build.yml              # CI/CD: Otomatik Android APK derleyici
├── android/
│   └── app/src/main/AndroidManifest.xml  # Minimal Android yapılandırması & İnternet izni
├── lib/
│   ├── constants/
│   │   └── cities.dart                    # 81 ilin coğrafi koordinat listesi
│   ├── models/
│   │   └── city.dart                      # Şehir modeli (enlem, boylam vb.)
│   ├── services/
│   │   ├── api_service.dart               # Web API bağlantı ve önbellekleme servisi
│   │   └── qibla_service.dart             # Kıble yönü hesaplama servisi
│   ├── screens/
│   │   ├── home_screen.dart               # Dashboard, geri sayım ve ezan vakitleri ekranı
│   │   ├── location_selection_screen.dart # Arama özellikli Ülke/İl/İlçe seçim ekranı
│   │   ├── guide_screen.dart              # Adım adım namaz kılınış kılavuzu
│   │   └── qibla_screen.dart              # Görsel Kıble kadranı ekranı
│   └── main.dart                          # Rotalar, durum yükleme ve ana tema
├── test/
│   └── api_test.dart                      # API entegrasyonu ve Kıble matematik testleri
├── web/
│   └── index.html                         # Web sürümü SEO & meta yapılandırması
├── pubspec.yaml                           # Flutter bağımlılık dosyası
└── analysis_options.yaml                  # Dart linter standartları
```

---

## 🚀 Başlangıç ve Çalıştırma

Projeyi yerel makinenizde çalıştırmak için aşağıdaki adımları takip edin:

### Gereksinimler
*   [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.0.0 veya üzeri)
*   [Dart SDK](https://dart.dev/get-started) (v3.0.0 veya üzeri)

### Kurulum Adımları
1.  Projeyi klonlayın:
    ```bash
    git clone https://github.com/merkezekre2026/bayram-namazi-app.git
    cd bayram-namazi-app
    ```
2.  Bağımlılıkları yükleyin:
    ```bash
    flutter pub get
    ```
3.  Uygulamayı çalıştırın:
    *   **Android/iOS (Emülatör veya Cihaz):**
        ```bash
        flutter run
        ```
    *   **Tarayıcı (Web):**
        ```bash
        flutter run -d chrome
        ```

---

## 🧪 Testlerin Çalıştırılması

Projede hem Kıble yön hesaplama formülünün doğruluğunu hem de Diyanet API uç noktalarının (endpoint) doğru çalışıp çalışmadığını doğrulayan entegrasyon testleri yer almaktadır.

Testleri koşturmak için:
```bash
flutter test
```

---

## 🛠️ GitHub Actions CI/CD

Projede entegre bir GitHub Actions akışı yer almaktadır. `main` veya `master` dallarına yapılan her `push` ve `pull request` işleminde otomatik olarak tetiklenerek:
1.  Kod kalitesi ve linter kurallarını denetler.
2.  Birim ve entegrasyon testlerini koşturur (`flutter test`).
3.  Hata yoksa uygulamayı Android için derler (`flutter build apk --release`).
4.  Derlenen `.apk` dosyasını indirilebilir bir **GitHub Artifact** olarak çıktı verir.