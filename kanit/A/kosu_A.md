# A Koşusu (Rehbersiz, ham koşu) — Kayıt

- Tarih: 17 Kasım 2026
- Ajan: Claude Code alt ajanı (general-purpose, Claude Opus 5.5). Her tur yeni ajan oturumu olarak çalıştı; böylece her turun token/araç/süre sayısı ayrı ayrı ölçüldü.
- Klasör: boş klasör (`kosu_A2`). AGENTS.md, test, kanca YOK.
- Ruby: ajan koşu sırasında ortamda 3.3.6 buldu (tur 4 raporu). Ruby 3.4.6 sonradan kuruldu ve son kod 3.4.6 ile tekrar test edildi: `14 runs, 49 assertions, 0 failures`.
- Ölçüm kaynağı: Ajan aracının her tur sonunda verdiği `<usage>` bloğu (`subagent_tokens`, `tool_uses`, `duration_ms`).

## Tur tur promptlar ve ölçüm

| Tur | Kullanıcının (insan) verdiği prompt | subagent_tokens | tool_uses | süre (ms) | Sonuç |
|---|---|---:|---:|---:|---|
| 1 | "Öğrenci devamsızlık kontrolü yap, devamsızlık sınırı %30'dur." | 71.666 | 3 | 31.370 | Python yazdı, `oran > SINIR` (tam %30 GEÇTİ), test yok |
| 2 | "Python değil, Ruby ile yaz. Öğrencinin ad, durum (aktif/donduruldu/mezun) ve devamsızlık bilgisi olsun; riskli ve kaldı durumlarını ayrı göster. 10 oturum var." | 72.958 | 4 | 24.248 | Ruby ama `Struct` + String durum; riskli eşiğini kendisi %20 uydurdu (2 devamsızlık = riskli); kaldı `>` |
| 3 | "Hash/Struct yerine Ogrenci sınıfı kur (lib/ogrenci.rb). Durum sembol olsun, aktif? mezun? donduruldu? gibi sorgu metotları olsun. Kuralları ayrı bir DevamsizlikKontrol sınıfında topla (lib/devamsizlik_kontrol.rb): riskli, kaldi ve bir de kendi özgün kuralın. Test de yaz." | 76.925 | 7 | 62.176 | Sınıflar geldi; metotlar elle `def`; riskli %20 hâlâ; riskli/kaldı "ayrık" yapıldı ve testle yanlış davranış kilitlendi; `devamsiz` adı; üst sınır (10) yok |
| 4 | "Kurallar yanlış. riskli = devamsızlık >= 3 (tam 3 riskli SAYILIR, 4 ve üzeri de riskli), kaldi = devamsızlık >= 4. … Durum sorgu metotlarını define_method ile üret. Ruby 3.4 kullanıyoruz (.ruby-version). Test dosyası test/ogrenci_test.rb olsun; bilinmeyen metot (örn. mezn?) çağrısının NoMethodError verdiğini de test et." | 81.560 | 8 | 67.059 | Şartname karşılandı, 14 test yeşil |
| **Toplam** | **4 insan turu** | **303.109** | **22** | **184.853** | |

Her turun kod çıktısı: `tur1/ … tur4/` klasörlerinde (dosyalar ajanın yazdığı haliyle, değiştirilmeden kopyalandı).

## Ajanın kendi raporlarından sınır değer itirafları (alıntı)

- Tur 1: "Ben '%30'a kadar hak var, %30'u geçen kalır' diye kabul ettim; Zeynep bu yüzden tam %30'da geçti."
- Tur 2: "Risky: I chose this cutoff myself, because you didn't give one. A student at %20 or more … gets RISKLI."
- Tur 3: "riskli ile kaldı'nın aynı anda olamayacağını" test ettiğini söyledi (yanlış davranış teste kilitlendi).
- Tur 4: "sistemde Ruby 3.4 kurulu değil (sadece 3.1.6, 3.2.6 ve 3.3.6 var). Bu yüzden testleri 3.3.6'da … çalıştırdım."

## Ön deneme (A0)

`../A_on_deneme/` aynı ham promptla, aynı gün, tek konuşma içinde (SendMessage ile devam ettirilerek) yapılan ilk denemedir. Hatalar tekrar etti: tur 1'de yine Python ve `oran > SINIR`, tur 2'de Hash + String durum, tur 3'te riskli/kaldı ayrık ve testle kilitlenmiş. Tur 1 ölçümü: 71.338 token, 3 araç çağrısı, 28.163 ms. Bu konuşma modunda sonraki turların token sayısını araç raporlamadığı için ölçümlü A koşusu yukarıdaki gibi her tur ayrı oturumla yeniden yapıldı.
