# Ödev 6 · Ajanına Koşum Takımı Geçir — Devamsızlık ve Kural Motoru

YZM379 İleri Ruby ve Harness · Samsun Üniversitesi · Melike

> Ajan = Model + Harness. Bu repoda model aynı kaldı; yalnızca harness (rehber + sensör + kanca + ratchet) değişti. Fark aşağıda **sayılarla** ölçüldü.

## Hızlı başlangıç

```sh
ruby -v                     # 3.4.x  (.ruby-version = 3.4)
ruby test/ogrenci_test.rb   # 18 runs, 71 assertions, 0 failures
bin/kontrol                 # KONTROL OK … (çıkış 0) / KONTROL HATA … (çıkış 2)
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
| `AGENTS.md` + `CLAUDE.md` (`@AGENTS.md` import satırı) | Rehber: ajanın anayasası |
| `bin/kontrol` | Doğrulama kancası (sensör) |
| `.claude/settings.json` | Claude Code `PostToolUse` kancası: her Write/Edit sonrası `bin/kontrol` |
| `bin/izle` | Kanca desteği olmayan ajanlar için arka plan izleyici (POSIX) |
| `RATCHET_LOG.md` | Hata → kalıcı kural günlüğü |
| `kanit/` | A ve B koşularının ham çıktıları, ajan raporları, metrikler, sensör doğrulaması |
| `.ruby-version` | `3.4` |

`lib/` altındaki kod B koşusu-2'de ajanın yazdığı koddur (`kanit/B/kosu2/lib/` ile aynı). Son harness ile yapılan B koşusu-3'ün kodu da yeşildir (`kanit/B/kosu3/lib/`).

## Kurallar

| Kural | Tanım | Sınır testi |
|---|---|---|
| `riskli` | `devamsizlik >= 3` (10 oturumda %30). **Tam 3 riskli sayılır.** | 2 → değil, 3 → riskli |
| `kaldi` | `devamsizlik >= 4` | 3 → değil, 4 → `[:riskli, :kaldi]` |
| `onur_adayi` (özgün kuralım) | `aktif?` **ve** `devamsizlik == 0`. Hiç devamsızlık yapmamış aktif öğrenci onur listesi adayıdır; mezun ve dondurulmuş öğrenci aday olamaz. | 0 → aday, 1 → değil, mezun + 0 → değil |

Kurallar birbirini dışlamaz; `durum` uyan tüm kuralları `KURALLAR` sırasıyla döndürür. Karşılaştırmalar tam sayıyladır (float/yüzde yok). `riskli` ve `kaldi` öğrencinin durumuna bakmaz.

## Harness

### 1. Rehber — `AGENTS.md`
Kısa bir "anayasa". Yalnızca ajanın eğitim verisinde olmayan ve şüpheye düşebileceği maddeler var:
- **Sürüm:** 3.4
- **Sözleşme:** keyword argümanlar, tipler, `class` (module değil)
- **Alan kuralları:** tam 3 devamsızlık risklidir; kurallar ayrık değildir; başka eşik uydurma
- **Yasaklar:** `method_missing`, monkey patch (`refine`/`prepend` dahil), `instance_eval`
- **Döngü:** testi gevşetme; `bin/kontrol` 0 dönmeden "bitti" deme

İlk madde "Emin olmadığın şeyi farz etme, sor." `map` ve `snake_case` gibi ajanın zaten bildiği şeyler yazılmadı. `ln -s AGENTS.md CLAUDE.md` bu makinede yönetici izni gerektirdiği için gerçek bir symlink oluşturulamadı (`New-Item -ItemType SymbolicLink` → "Administrator privilege required"); bunun yerine dersin kendi önerdiği taşınabilir alternatif kullanıldı: `CLAUDE.md` tek satır `@AGENTS.md` (Claude Code'un gerçek import sözdizimi) içeriyor, böylece Claude Code aynı dosyayı okur.

### 2. Sensör — `test/ogrenci_test.rb`
Testler koddan **önce** yazıldı; B koşularında ajan boş bir `lib/` ile başladı. Sınır taraması 0'dan 10'a kadar her devamsızlık değerini tek tek doğrular.

### 3. Doğrulama kancası — `bin/kontrol`
Kontroller sırasıyla:
1. Çalışan Ruby `.ruby-version` ile uyuşuyor mu, dosya boş mu?
2. Teslim dosyaları var mı?
3. Yorum satırları dışında yasak kalıp var mı? Aranan kalıplar: `method_missing`, `class Integer/String/Date…`, `refine`/`prepend`, `instance_eval`, `devamsizlik > 3` / `3 < devamsizlik`. Ayrıca `define_method` zorunlu.
4. `ruby -wc` ile sözdizimi ve uyarı kontrolü.
5. Minitest.

Hata varsa kısa mesajı **stderr**'e yazar ve **2** ile çıkar. Her çalışma `log/kontrol.log`'a tek satır ekler.

**Otomatik çalıştırma**
- **Claude Code:** `.claude/settings.json` içindeki `PostToolUse` kancası, ajan her `Write`/`Edit` yaptığında `bin/kontrol`'ü çalıştırır. Çıkış kodu 2 olunca Claude Code stderr'i doğrudan ajana geri verir; ajan hatayı kendi turunda görür. Kancanın çıkış 0 / 2 davranışı `kanit/kanca_simulasyonu.txt` içinde.
- **Diğer ajanlar (Cursor, Gemini CLI…):** `bin/izle &` çalıştırılır. `lib/` veya `test/` altındaki bir `.rb` dosyasının içeriği her değiştiğinde `bin/kontrol` çalışır.

**Sensör doğrulaması (mutasyon testi):** `bash kanit/mutasyon.sh`, koşularda görülen hataları ve önleyici tuzakları doğru koda bilerek geri sokar:
- A koşusundan 10 hata
- B koşusu-1'den 1 hata
- 3 önleyici tuzak

**14 mutasyonun 14'ü yakalandı** (çıkış 2). Değiştirilmemiş kod (M0) geçti. Çıktı: `kanit/sensor_dogrulama.txt`.

### 4. Ratchet
`RATCHET_LOG.md` gözlenen 12 hatayı ve 3 önleyici kuralı içerir. Her satır hem rehbere (AGENTS.md) hem sensöre (test ya da `bin/kontrol`) bağlandı ve her birinin dosya:satır kanıtı var. B koşusu-1'de çıkan yeni hata (#12, `module`) aynı yöntemle kilitlendi ve B-2 ile B-3'te tekrar etmedi. Assertion sayısı yalnızca arttı: 68 → 70 → 71.

## A/B Koşusu ve Ölçüm Raporu

**Yöntem**
- **Ajan:** Claude Code alt ajanı (Claude Opus 5.5). A ve B'de aynı model.
- **Görev cümlesi:** her koşuda birebir aynı: *"Öğrenci devamsızlık kontrolü yap, devamsızlık sınırı %30'dur."*
- **A:** boş klasör, harness yok. Ajan şartnameyi karşılayana kadar insan düzeltme turu verildi. Her tur ayrı oturumda koştu, böylece her turun sayısı ayrı alındı.
- **B:** klasörde `.ruby-version`, `AGENTS.md`, `CLAUDE.md`, `test/ogrenci_test.rb` ve `bin/kontrol` hazır; `lib/` boş. Claude Code `CLAUDE.md`'yi bağlama otomatik yükler. Alt ajan bunu yapmadığı için AGENTS.md içeriği görev cümlesinin önüne bağlam olarak eklendi; görev cümlesinin kendisi değişmedi.
- **Sayıların kaynağı:** ajan aracının her oturum sonunda verdiği `<usage>` bloğu (`subagent_tokens`, `tool_uses`, `duration_ms`). Promptlar, ajanın raporları ve usage satırları `kanit/A/ajan_raporlari.md` ve `kanit/B/ajan_raporlari.md` içinde olduğu gibi duruyor; sayıların hepsi `kanit/metrikler.json`'da.
- **Hata sayısı:** her tur sonunda 11 şartname maddesinden karşılanmayanların sayısı. Maddeler:
  1. Ruby
  2. `Ogrenci` ve `DevamsizlikKontrol` sınıfları (`ad`/`durum`/`devamsizlik`)
  3. Symbol durum + doğrulama
  4. `define_method`
  5. 0..10 aralığı
  6. `riskli >= 3`
  7. `kaldi >= 4` ve kurallar ayrık değil
  8. Özgün kural
  9. Minitest + sınır testi + NoMethodError testi
  10. `.ruby-version` 3.4
  11. `method_missing` / monkey patch yok

  Şartname dışı varsayımlar (RATCHET #11) ve ortam sorunları (#10) bu sayıma girmez; RATCHET_LOG'da ayrıca kayıtlıdır.

### Özet tablo

| Metrik | A (rehbersiz) | B-1 (harness) | B-2 (ratchet sonrası) | B-3 (son harness) | A → B-2 |
|---|---:|---:|---:|---:|---:|
| İnsan turu (prompt) | **4** | 1 | **1** | 1 | −3 (−%75) |
| Araç çağrısı (ajan içi tur) | 22 | 2 | 4 | 2 | −18 (−%82) |
| Toplam token (`subagent_tokens`) | **303.109** | 76.098 | **77.218** | 76.364 | −225.891 (**−%74,5**) |
| Toplam süre | 184,9 s | 17,9 s | 21,8 s | 23,6 s | −163,0 s (−%88,2) |
| İlk tur sonunda kalan hata (/11) | 10 | 1 | 0 | 0 | |
| Son durumda kalan hata | 0 (4. turda) | 1 (`module`) | 0 | 0 | |
| `bin/kontrol` ilk çalıştırmada | — (sensör yok) | OK, 17 test | OK, 18 test | OK, 18 test | |

### A koşusu tur tur

| Tur | Token | Araç | Süre (s) | Kalan hata (/11) | Ajanın yaptığı belirgin hata |
|---|---:|---:|---:|---:|---|
| 1 | 71.666 | 3 | 31,4 | 10 | Python; `> SINIR` → tam %30 GEÇTİ; test yok |
| 2 | 72.958 | 4 | 24,2 | 9 | `Struct` + String durum; riskli eşiğini %20 uydurdu (2 devamsızlık = riskli) |
| 3 | 76.925 | 7 | 62,2 | 7 | Elle `def`; riskli/kaldı ayrık + teste kilitlendi; üst sınır yok |
| 4 | 81.560 | 8 | 67,1 | 0 | Şartname tamam; ama 3.3.6'da test etti ve aktif olmayanları kurallardan çıkardı (RATCHET #10, #11) |
| **Toplam** | **303.109** | **22** | **184,9** | | |

Aynı ham prompt ayrı bir ön denemede (A0) de verildi. İlk turda yine Python ve `> SINIR` yazdı (71.338 token, 3 araç, 28,2 s). Yani hatalar tesadüf değil, tekrarlanabilir (`kanit/A_on_deneme/`).

### Sorulara cevaplar

**Tur sayısı kaçtan kaça düştü?** İnsan turu 4 → 1; ajan içi araç çağrısı 22 → 2–4. B'de ajan dosyaları yazdı, `bin/kontrol`'ü çalıştırdı, ilk seferde yeşil gördü ve bitirdi.

**Testler ilk seferde yakaladı mı?** İki tarafı var:
- **B-2 ve B-3:** ajanın ilk `bin/kontrol` çalıştırması yeşildi (`kanit/B/kosu2/log/kontrol.log`, `kanit/B/kosu3/log/kontrol.log`). Yani hata koda hiç girmedi; rehber önledi, sensör doğruladı.
- **B-1:** koda bir hata girdi (`module`) ve o anki sensör bunu **yakalayamadı**, testler yeşil geçti. Bu bir harness açığıydı; ratchet #12 ile kapatıldı.

Sensörün gerçekten yakalayabildiğini mutasyon testiyle ayrıca kanıtladım: 14/14. A'da sensör olmadığı için hatalar ancak insan kodu okuyunca fark edildi. 3. turda ajan yanlış davranışı (riskli/kaldı ayrık) kendi testine kilitledi; kendi testi yeşildi ama şartname yanlıştı. Testi ajanın değil, harness'ın yazması bu yüzden önemli.

**Rehber girdi tokenını artırdı ama toplamda kazandırdı mı?** Evet:
- **İlk tur karşılaştırması:** A tur 1 = 71.666, B-2 = 77.218 token. Rehber ve test dosyasını okumanın bedeli **+5.552 token (+%7,7)**. AGENTS.md yaklaşık 2 KB.
- **Ek turların maliyeti:** A'nın her ek turu 72–82 bin token tuttu. Rehber tek bir düzeltme turunu kurtarsa bile bedelini 13 kat öder. A 3 ek tur attı; toplamda **−225.891 token (−%74,5)**.
- **Ratchet dahil:** ratchet'in kendi maliyeti dahil (B-1 + B-2 = 153.316 token) bile A'dan **%49,4 daha ucuz**.
- **Sabit bağlam:** en küçük oturum bile ~71 bin token tuttu. Yani `subagent_tokens` içinde her oturumda yeniden gönderilen büyük bir sabit bağlam var (tahminen ~70 bin). Bu yüzden tur sayısını azaltmak, rehberi kısaltmaktan çok daha fazla kazandırıyor. Dersteki "her tur yeni bir bağlam maliyetidir" tezi sayıyla doğrulandı.

**Hangi ratchet kuralı hatayı anında kilitledi?** B-1'de ajan `DevamsizlikKontrol`'ü `module` yazdı. Sözleşmede "class" yazmadığı için testler geçti; bu bir **harness hatasıydı** ("aynı hata ikinci kez olursa harness'ın hatasıdır"). AGENTS.md'ye "module DEĞİL" satırı, teste `assert_instance_of Class` eklendi. B-2 sıfırdan koştu ve `class` yazdı. B-3'te ajan, sözleşmede olmayan `ad` doğrulamasını farz etmek yerine sordu; "farz etme, sor" maddesi işledi.

### Gerçek Claude Code ölçümü (`claude -p --output-format json`)

Yukarıdaki A/B koşuları alt ajan (`Agent`/Task aracı) ile ölçüldü; `<usage>` bloğu `subagent_tokens` tek bir toplam veriyor, girdi/çıktı/önbellek ayrımı ve dolar maliyeti yoktu (aşağıdaki "Yapamadıklarım" bölümünde bu bir eksiklik olarak işaretlenmişti). Bunu kapatmak için gerçek Claude Code CLI'ı (`claude -p --output-format json`) `kanit/claude_p/olc.sh` betiğiyle uçtan uca çalıştırdım: **A** tamamen boş, kancasız bir klasörde aynı oturumda (`--resume`) 4 ardışık insan turu; **B** `AGENTS.md` + `.claude/settings.json` (`PostToolUse` → `bin/kontrol`) + hazır `test/ogrenci_test.rb` kopyalanmış bir klasörde **tek** insan turu. Görev cümlesi her ikisinde de birebir A tur 1 ile aynı. Ham JSON çıktıları `kanit/claude_p/A/tur1..4.json` ve `kanit/claude_p/B/b.json`; tam tablo `kanit/claude_p/ozet.md`.

| Tur | num_turns | input | cache_read | cache_creation | output | total_cost_usd | is_error |
|---|---:|---:|---:|---:|---:|---:|---|
| A1 | 2 | 4 | 20.984 | 45.655 | 229 | 0,283672 | false |
| A2 | 3 | 6 | 103.032 | 8.477 | 2.265 | 0,115765 | false |
| A3 | 9 | 18 | 404.854 | 16.875 | 6.422 | 0,319090 | false |
| A4 | 9 | 18 | 479.886 | 34.812 | 7.801 | 0,469907 | false |
| **A toplam** | **23** | **46** | **1.008.756** | **105.819** | **16.717** | **1,188434** | |
| **B** | **11** | **14** | **254.907** | **37.577** | **3.442** | **0,353606** | false |

**A toplam → B farkı:** num_turns −12 (−%52,2) · input −32 (−%69,6) · cache_read −753.849 (−%74,7) · output −13.275 (−%79,4) · total_cost_usd −0,834828 (−%70,2).

> `total_cost_usd`, bu ortamda Claude Pro aboneliği üzerinden çalıştırıldığı için **API karşılığı maliyet tahminidir** — gerçek Pro faturasına ek ücret yansımaz, yalnızca göreli karşılaştırma için kullanılabilir.

**Otomatik kanca çalışması (çözüldü):** B'nin tek insan turu içinde `bin/kontrol`, ajan hiçbir elle komut vermeden **3 kez otomatik** çalıştı — `.claude/settings.json`'daki `PostToolUse` kancası Windows'ta da tetiklendi (`kanit/claude_p/B/kontrol.log`):
```
2026-11-17 20:03:24 HATA lib/devamsizlik_kontrol.rb eksik
2026-11-17 20:03:26 OK 18 runs, 71 assertions, 0 failures, 0 errors, 0 skips
2026-11-17 20:03:30 OK 18 runs, 71 assertions, 0 failures, 0 errors, 0 skips
```
Son satırdan sonra ayrıca benim yaptığım tek bir manuel doğrulama çalıştırması var (`kanit/claude_p/B/son_kontrol.txt`, çıkış: 0 — bu satır yukarıdaki sayıma dahil değil).

**Bu A koşusunda gözlenen hatalar (RATCHET_LOG.md ile karşılaştırma):**

| Tur | Gözlenen | RATCHET eşleşmesi | Kanıt |
|---|---|---|---|
| A1 | Kod yazmadan devamsızlık verisini içeren dosyayı istedi (hata değil; AGENTS.md olmadan da "farz etme, sor" tipi bir davranış) | — (yeni davranış, hata değil) | `kanit/claude_p/A/tur1.json` (`result` alanı) |
| A2 | `Hash` + String durum (`"aktif"`); oranı float/yüzde ile karşılaştırdı; riskli eşiğini kendi uydurdu (`oran >= 0.20`) | #6, #3, #4 | `kanit/claude_p/A/tur2_kod/devamsizlik.rb:13,15` |
| A3 | Durum sorgularını elle `def` yazdı (`define_method` yok); float/oran karşılaştırması sürdü; devamsızlığın üst sınırı/tip doğrulaması yok, alan adı `devamsiz`; riskli/kaldı duruma bakıyor (`aktif?` şartı) | #7, #3, #8, #11 | `kanit/claude_p/A/tur3_kod/lib/ogrenci.rb`, `lib/devamsizlik_kontrol.rb:16-27` |
| A4 | `define_method` bu kez doğru kullanıldı ve riskli/kaldı ayrık değil doğru test edildi (#7, #5 bu turda **karşılandı**); ama riskli/kaldı hâlâ `aktif?` şartına bakıyor ve `devamsiz` hâlâ 0..10 doğrulaması/üst sınırı yok, alan adı hâlâ `devamsiz` | #11, #8 | `kanit/claude_p/A/tur4_kod/lib/devamsizlik_kontrol.rb:18,22`, `lib/ogrenci.rb` |

Yeni bir hata **kategorisi** çıkmadı — dördü de RATCHET_LOG.md'deki mevcut 12 maddeyle örtüşüyor (farklı sayılarla/detaylarla tekrar etti). A4'te `define_method` ve ayrık-olmayan kurallar bu kez ilk seferde doğru geldi (muhtemelen tur 4 promptunun bunu açıkça istemesinden); buna karşın `aktif?` filtresi (#11) ve devamsızlık doğrulaması (#8) şartname AGENTS.md olarak yazılı olmadığı için A'da hiç düzelmedi — tam da B'nin bir rehberle önlediği şey.

## Kanıtlar (`kanit/`)

| Yol | İçerik |
|---|---|
| `kanit/A/kosu_A.md` | A koşusu özeti: promptlar, tur tur ölçümler |
| `kanit/A/ajan_raporlari.md` | Her turun promptu, ajanın son raporu ve usage satırı (olduğu gibi) |
| `kanit/A/tur1…tur4/` | Ajanın her turda yazdığı dosyalar (değiştirilmeden) ve çıktıları |
| `kanit/A_on_deneme/` | A0 ön denemesi: aynı hataların tekrarı |
| `kanit/B/ajan_raporlari.md` | B-1, B-2 ve B-3 için prompt yapısı, ajan raporları, usage satırları |
| `kanit/B/kosuN/harness/` | O koşuda klasörde bulunan harness (AGENTS.md, test, bin) |
| `kanit/B/kosuN/lib/`, `kanit/B/kosuN/log/` | Ajanın yazdığı kod ve `bin/kontrol` günlüğü. kosu1 günlüğündeki 2. satır (19:24:27) ajanın değil, benim doğrulama çalıştırmamdır. |
| `kanit/metrikler.json` | Tüm sayılar |
| `kanit/sensor_dogrulama.txt`, `kanit/mutasyon.sh` | 14 mutasyon → 14 yakalama |
| `kanit/kanca_simulasyonu.txt` | `PostToolUse` kancasının çıkış 0 / 2 davranışı |
| `kanit/claude_p/A/tur1..4.json`, `kanit/claude_p/B/b.json` | Gerçek `claude -p --output-format json` çıktıları (num_turns, usage, total_cost_usd) |
| `kanit/claude_p/A/turN_kod/` | Her A turu sonunda çalışma klasöründeki kod anlık görüntüsü |
| `kanit/claude_p/B/kontrol.log`, `son_kontrol.txt` | B'de kancanın otomatik çalıştığı satırlar + son manuel doğrulama |
| `kanit/claude_p/ozet.md` | A/B karşılaştırma tablosu (olc.sh'ın ürettiği ham özet) |

## Yapamadıklarım

- **Token ayrımı ve `$` maliyeti — ÇÖZÜLDÜ.** Slayt 13'teki `claude -p … --output-format json` ile `input_tokens`, `output_tokens`, `cache_read_input_tokens` ayrımını ve `total_cost_usd`'yi almak istiyordum; önceki denemede CLI kimlik doğrulaması olmadığı için çalışmamıştı. Bu kez `kanit/claude_p/olc.sh` ile gerçek bir Claude Code oturumunda (`--resume` ile 4 turluk A, tek turluk B) çalıştırıldı ve tüm ayrım `kanit/claude_p/ozet.md`'de var (bkz. yukarıdaki "Gerçek Claude Code ölçümü" alt başlığı). `total_cost_usd` yine de Pro abonelikte gerçek bir ek ücrete karşılık gelmiyor, yalnızca API karşılığı tahmin.
- **Kanca B'de kendiliğinden tetiklenmedi — ÇÖZÜLDÜ.** Önceki B koşuları (B-1/2/3) alt ajan olarak çalıştığı için `.claude/settings.json` kancası devreye girmiyordu. Gerçek `claude -p` koşusunda B klasörüne `.claude/settings.json` + `bin/kontrol` kopyalandı ve kanca **hiç elle müdahale olmadan 3 kez otomatik çalıştı** (`kanit/claude_p/B/kontrol.log`): önce eksik dosya yüzünden 1 kez HATA (çıkış 2), ardından 2 kez OK. Windows + Git Bash'te `PostToolUse` kancasının gerçekten tetiklendiği artık doğrulanmış durumda.
- **B'de rehber prompta eklendi.** Claude Code'un CLAUDE.md'yi otomatik yüklemesini taklit etmek için AGENTS.md içeriği bağlam olarak eklendi; gerçek bir Claude Code oturumunda ayrıca denenmedi.
- **Az örneklem.** A bir kez (artı A0 ön denemesi), B üç kez ölçüldü. Sayılar yön gösterir; istatistiksel ortalama değildir.
- **Tek ajan ailesi.** Yalnızca Claude ile denendi; Cursor, ChatGPT veya Gemini CLI ile karşılaştırma yapılmadı.
- **RuboCop yok.** Slayt 3'teki kod stili sensörü harici gem gerektirdiği için eklenmedi; yerine `ruby -wc` uyarı kontrolü kondu.
- **Ruby 3.4 başta yoktu.** A koşusunda ajan ortamda yalnızca 3.1–3.3 buldu ve 3.3.6 ile test etti. Ruby 3.4.6 sonradan kuruldu; B koşuları ve bütün son testler 3.4.6 ile çalıştı.
- **Grep sınırı.** `bin/kontrol`'deki grep kontrolleri her yazım biçimini yakalayamaz (ör. `devamsizlik.>(3)`). Bu yüzden asıl güvence Minitest; grep yalnızca hızlı ve net bir mesaj için var.
