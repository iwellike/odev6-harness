# Ödev 6 · Ajanına Koşum Takımı Geçir — Devamsızlık ve Kural Motoru

YZM379 İleri Ruby ve Harness · Samsun Üniversitesi · Melike

> Ajan = Model + Harness. Bu repoda model aynı kaldı; yalnızca harness (rehber + sensör + kanca + ratchet) değişti. Fark aşağıda **sayılarla** ölçüldü.

## Hızlı başlangıç

```sh
ruby -v                 # 3.4.x  (.ruby-version = 3.4)
ruby test/ogrenci_test.rb   # 18 runs, 70 assertions, 0 failures
bin/kontrol             # KONTROL OK … (çıkış 0) / KONTROL HATA … (çıkış 2)
```

```ruby
require_relative "lib/ogrenci"
require_relative "lib/devamsizlik_kontrol"

DevamsizlikKontrol.durum(Ogrenci.new(ad: "Ayşe", devamsizlik: 3)) # => [:riskli]
DevamsizlikKontrol.durum(Ogrenci.new(ad: "Can",  devamsizlik: 4)) # => [:riskli, :kaldi]
DevamsizlikKontrol.durum(Ogrenci.new(ad: "Ali"))                  # => [:onur_adayi]
Ogrenci.new(ad: "Ali", durum: :mezun).mezun?                      # => true
Ogrenci.new(ad: "Ali").mezn?                                      # => NoMethodError
```

## Repo yapısı

| Dosya | Görev |
|---|---|
| `lib/ogrenci.rb` | `Ogrenci` sınıfı: `ad`, `durum` (`:aktif`, `:donduruldu`, `:mezun`), `devamsizlik` (0..10). `aktif?` / `donduruldu?` / `mezun?` `define_method` ile üretilir. `method_missing` ve monkey patch yok. |
| `lib/devamsizlik_kontrol.rb` | `DevamsizlikKontrol` sınıfı: `KURALLAR` Hash'i (sembol → lambda) ve `DevamsizlikKontrol.durum(ogr)` |
| `test/ogrenci_test.rb` | Minitest sensörü (18 test): sınır taraması 0..10, tam 3, NoMethodError, monkey patch, sözleşme |
| `AGENTS.md` + `CLAUDE.md → AGENTS.md` (symlink) | Rehber: ajanın anayasası |
| `bin/kontrol` | Doğrulama kancası (sensör) |
| `.claude/settings.json` | Claude Code `PostToolUse` kancası: her Write/Edit sonrası `bin/kontrol` |
| `bin/izle` | Kanca desteği olmayan ajanlar için arka plan izleyici |
| `RATCHET_LOG.md` | Hata → kalıcı kural günlüğü |
| `kanit/` | A ve B koşularının ham çıktıları, metrikler, sensör doğrulaması |
| `.ruby-version` | `3.4` |

## Kurallar

| Kural | Tanım | Sınır testi |
|---|---|---|
| `riskli` | `devamsizlik >= 3` (10 oturumda %30). **Tam 3 riskli sayılır.** | 2 → değil, 3 → riskli |
| `kaldi` | `devamsizlik >= 4` | 3 → değil, 4 → `[:riskli, :kaldi]` |
| `onur_adayi` (özgün kuralım) | `aktif?` **ve** `devamsizlik == 0` — hiç devamsızlık yapmamış aktif öğrenci onur listesi adayıdır. Mezun ve dondurulmuş öğrenci aday olamaz. | 0 → aday, 1 → değil, mezun+0 → değil |

Kurallar birbirini dışlamaz; `durum` uyan tüm kuralları `KURALLAR` sırasıyla döndürür. Karşılaştırmalar tam sayıyladır (float/yüzde yok). `riskli` ve `kaldi` öğrencinin durumuna bakmaz.

## Harness

### 1. Rehber — `AGENTS.md`
234 kelimelik "anayasa". Yalnızca ajanın eğitim verisinde olmayan, şüpheye düşebileceği maddeler var: sürüm (3.4), sözleşme (keyword argümanlar, tipler), alan kuralları (tam 3 riskli, ayrık değil, %20 uydurma), yasaklar (method_missing, monkey patch, instance_eval), döngü (testi gevşetme, `bin/kontrol` 0 olmadan bitti deme). `map`, `snake_case` gibi ajanın zaten bildiği şeyler yazılmadı. `ln -s AGENTS.md CLAUDE.md` ile Claude Code da aynı dosyayı okur.

### 2. Sensör — `test/ogrenci_test.rb`
Testler koddan **önce** yazıldı (B koşusunda ajan boş `lib/` ile başladı). Sınır taraması 0'dan 10'a her devamsızlık değerini tek tek doğrular.

### 3. Doğrulama kancası — `bin/kontrol`
Sırasıyla: (1) çalışan Ruby `.ruby-version` ile uyuşuyor mu, (2) teslim dosyaları var mı, (3) yasak kalıplar (`method_missing`, `class Integer/String/Date…`, `instance_eval`, `devamsizlik > 3`, `define_method` zorunlu), (4) `ruby -wc` sözdizimi + uyarı, (5) Minitest. Hata varsa kısa mesajı **stderr**'e yazar ve **2** ile çıkar; her çalışma `log/kontrol.log`'a tek satır ekler.

**Otomatik çalıştırma:**
- Claude Code: `.claude/settings.json` içindeki `PostToolUse` kancası, ajan her `Write`/`Edit` yaptığında `bin/kontrol`'ü çalıştırır. Çıkış kodu 2 olunca Claude Code stderr'i doğrudan ajana geri verir; ajan hatayı kendi turunda görür. Simülasyon: `kanit/kanca_simulasyonu.txt`.
- Diğer ajanlar (Cursor, Gemini CLI…): `bin/izle &` → `lib/` veya `test/` altındaki bir `.rb` dosyası her değiştiğinde `bin/kontrol` çalışır.

**Sensör doğrulaması (mutasyon testi):** `bash kanit/mutasyon.sh` A koşusunda görülen 12 hatayı bilerek doğru koda geri sokar. **12/12 yakalandı** (çıkış 2), değiştirilmemiş kod (M0) geçti. Çıktı: `kanit/sensor_dogrulama.txt`.

### 4. Ratchet
Her hata hem rehbere hem sensöre bağlandı: `RATCHET_LOG.md` (12 gözlenen hata + 3 önleyici kural). B koşusu-1'de çıkan yeni hata (#12, `module`) da aynı yöntemle kilitlendi ve B koşusu-2'de tekrar etmedi. Test sayısı yalnızca arttı: 17 → 18.

## A/B Koşusu ve Ölçüm Raporu

**Yöntem.** Ajan: Claude Code alt ajanı (Claude Opus 5.5), A ve B'de aynı model. Görev promptu her iki koşuda aynı: *"Öğrenci devamsızlık kontrolü yap, devamsızlık sınırı %30'dur."*
- **A:** boş klasör, harness yok. Ajan şartnameyi karşılayana kadar insan düzeltme turu verildi. Her tur ayrı oturum olarak koşturuldu, böylece her turun sayıları ayrı ayrı alındı.
- **B:** klasörde `.ruby-version`, `AGENTS.md`, `CLAUDE.md`, `test/ogrenci_test.rb`, `bin/kontrol` hazır, `lib/` boş. Claude Code'un `CLAUDE.md`'yi otomatik yüklemesini taklit etmek için AGENTS.md içeriği prompta eklendi.
- **Sayıların kaynağı:** Ajan aracının her oturum sonunda verdiği `<usage>` bloğu (`subagent_tokens`, `tool_uses`, `duration_ms`). Ham veri: `kanit/metrikler.json`, `kanit/A/kosu_A.md`.
- **Hata sayısı:** her tur sonunda 10 şartname maddesinden (Ruby · Ogrenci sınıfı/alanlar · Symbol durum + doğrulama · define_method · 0..10 · riskli >= 3 · kaldi >= 4 ve ayrık değil · özgün kural · Minitest + sınır + NoMethodError testi · .ruby-version 3.4) karşılanmayanların sayısı.

### Özet tablo

| Metrik | A (rehbersiz) | B koşusu-1 (harness) | B koşusu-2 (ratchet sonrası) | A → B-2 |
|---|---:|---:|---:|---:|
| İnsan turu (prompt) | **4** | 1 | **1** | −3 (−%75) |
| Araç çağrısı (ajan içi tur) | 22 | 2 | 4 | −18 (−%82) |
| Toplam token (`subagent_tokens`) | **303.109** | 76.098 | **77.218** | −225.891 (**−%74,5**) |
| Toplam süre | 184,9 s | 17,9 s | 21,8 s | −163,1 s (−%88,2) |
| İlk tur sonunda kalan şartname hatası | 10 | 1 | 0 | |
| Son durumda kalan hata | 0 (4. turda) | 1 (`module`) | 0 | |
| `bin/kontrol` ilk çalıştırmada | — (sensör yok) | OK, 17 test | OK, 18 test | |

### A koşusu tur tur

| Tur | Token | Araç | Süre (s) | Kalan hata | Ajanın yaptığı belirgin hata |
|---|---:|---:|---:|---:|---|
| 1 | 71.666 | 3 | 31,4 | 10 | Python; `oran > SINIR` → tam %30 GEÇTİ; test yok |
| 2 | 72.958 | 4 | 24,2 | 9 | `Struct` + String durum; riskli eşiğini %20 uydurdu (2 = riskli) |
| 3 | 76.925 | 7 | 62,2 | 7 | Elle `def`; riskli/kaldı ayrık + teste kilitlendi; üst sınır yok |
| 4 | 81.560 | 8 | 67,1 | 0 | — (Ruby 3.3.6'da test etti; 3.4 ortamda yoktu) |
| **Toplam** | **303.109** | **22** | **184,9** | | |

Kontrol için aynı ham prompt ayrı bir ön denemede (A0) de verildi; ilk turda yine Python ve `> SINIR` yazdı (71.338 token, 3 araç, 28,2 s). Hatalar tesadüf değil, tekrarlanabilir (`kanit/A_on_deneme/`).

### Sorulara cevaplar

**Tur sayısı kaçtan kaça düştü?** İnsan turu 4 → 1, ajan içi araç çağrısı 22 → 4. B'de ajan dosyaları yazdı, `bin/kontrol`'ü çalıştırdı, ilk seferde yeşil gördü ve bitirdi.

**Testler ilk seferde yakaladı mı?** B'de ajanın ilk `bin/kontrol` çalıştırması yeşildi (`kanit/B/kosu2/log/kontrol.log`: `18 runs, 70 assertions, 0 failures`). Yani B'de hata koda hiç girmedi; rehber hatayı önledi, sensör de bunu doğruladı. Sensörün gerçekten yakalayabildiğini mutasyon testiyle ayrıca kanıtladım: A'nın 12 hatasından 12'si yakalandı. A'da ise sensör olmadığı için hatalar ancak insan okuyunca fark edildi. 3. turda ajan yanlış davranışı (riskli/kaldı ayrık) kendi testine kilitledi: kendi yazdığı test yeşildi ama şartname yanlıştı. Testi ajanın değil, harness'ın yazması bu yüzden önemli.

**Rehber girdi tokenını artırdı ama toplamda kazandırdı mı?** Evet:
- İlk tur karşılaştırması: A tur 1 = 71.666, B-2 = 77.218 token. Rehber + testi okuma bedeli **+5.552 token (+%7,7)**. AGENTS.md 1.940 bayt / 234 kelime.
- A'nın her ek turu 72–82 bin token tuttu. Yani rehber tek bir düzeltme turunu kurtarsa bile kendini 13 kat öder. A 3 ek tur attı: toplamda **−225.891 token (−%74,5)**.
- Ratchet'in kendi maliyeti dahil (B-1 + B-2 = 153.316 token) bile A'dan **%49,4 daha ucuz**.
- Not: En küçük oturum bile ~71 bin token tuttu; yani `subagent_tokens` içinde her oturumda tekrar gönderilen büyük bir sabit bağlam (tahminen ~70 bin) var. Bu yüzden tur sayısını azaltmak, rehberi kısaltmaktan çok daha fazla kazandırıyor. Bu, dersteki "her tur yeni bir bağlam maliyetidir" tezini sayıyla doğruluyor.

**Hangi ratchet kuralı hatayı anında kilitledi?** B koşusu-1'de ajan `DevamsizlikKontrol`'ü `module` yazdı; testler geçti çünkü sözleşmede "class" yazmıyordu. Bu bir **harness hatasıydı** ("aynı hata ikinci kez olursa harness'ın hatasıdır"). AGENTS.md'ye "module DEĞİL" satırı, teste `assert_instance_of Class` eklendi. B koşusu-2 sıfırdan koştu ve `class` yazdı.

## Kanıtlar (`kanit/`)

| Yol | İçerik |
|---|---|
| `kanit/A/kosu_A.md` | A koşusunun promptları, tur tur ölçümler, ajanın kendi itirafları |
| `kanit/A/tur1…tur4/` | Ajanın her turda yazdığı dosyalar (değiştirilmeden) ve çıktıları |
| `kanit/A_on_deneme/` | A0 ön denemesi: aynı hataların tekrarı |
| `kanit/B/kosu1/`, `kanit/B/kosu2/` | B koşularında ajanın yazdığı `lib/` ve `bin/kontrol` günlüğü (kosu1 günlüğündeki 2. satır, 19:24:27, ajanın değil benim doğrulama çalıştırmamdır) |
| `kanit/metrikler.json` | Tüm sayılar |
| `kanit/sensor_dogrulama.txt`, `kanit/mutasyon.sh` | 12 mutasyon → 12 yakalama |
| `kanit/kanca_simulasyonu.txt` | `PostToolUse` kancasının çıkış 0 / 2 davranışı |

## Yapamadıklarım

- **Token ayrımı yok.** Slayt 13'teki `claude -p … --output-format json` ile `input_tokens` / `output_tokens` / `cache_read` ayrımını almak istedim. Bu ortamdaki Claude Code CLI kimlik doğrulaması olmadığı için çalışmadı (`Authentication error`). Bu yüzden ajan aracının verdiği toplam `subagent_tokens` kullanıldı. Girdi/çıktı/önbellek ayrımı ve `$` maliyeti raporlanamadı.
- **Kanca B'de kendiliğinden tetiklenmedi.** B ajanı alt ajan olarak çalıştığı için projedeki `.claude/settings.json` kancası devreye girmedi. Ajan `bin/kontrol`'ü AGENTS.md kuralı gereği kendisi çalıştırdı. Kancanın kendisi ayrıca simülasyonla doğrulandı. Ayrıca ajan `bin/kontrol`'ü her dosya kaydından sonra değil, iki dosyayı yazdıktan sonra bir kez çalıştırdı (günlükte tek satır var).
- **Tek örneklem.** Her koşu bir kez ölçüldü (A0 ön denemesi hariç). Sayılar yön gösterir; istatistiksel ortalama değildir.
- **Tek ajan ailesi.** Yalnızca Claude ile denendi; Cursor, ChatGPT veya Gemini CLI ile karşılaştırma yapılmadı.
- **RuboCop yok.** Slayt 3'teki kod stili sensörü harici gem gerektirdiği için eklenmedi; yerine `ruby -wc` uyarı kontrolü kondu.
- **Ruby 3.4 başta yoktu.** A koşusunda ajan ortamda yalnızca 3.1–3.3 buldu ve 3.3.6 ile test etti. Ruby 3.4.6 sonradan kuruldu; bütün son testler ve kontroller 3.4.6 ile çalıştı.
