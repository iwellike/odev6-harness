# RATCHET_LOG — Hata → Kalıcı Kural Günlüğü

Mandal tek yöne döner: bir kez yakalanan hata ya rehbere (AGENTS.md) ya sensöre (Minitest / bin/kontrol) yazılır ve bir daha geçemez.
- **Kanıt** sütunu: ajanın o turda yazdığı dosya (`kanit/`, değiştirilmeden) ve ham ajan raporları (`kanit/*/ajan_raporlari.md`).
- **Kilit** sütunu: aynı hata doğru koda bilerek geri sokulduğunda hangi mutasyonun yakalandığı (`kanit/sensor_dogrulama.txt`, `bash kanit/mutasyon.sh`).

| # | Tarih | Karşılaşılan hata (koşu · tur) | Kanıt | Kalıcı kural / test | Katman | Kilit | B'de tekrar etti mi? |
|---|---|---|---|---|---|---|---|
| 1 | 17.11.2026 | Ruby yerine **Python** yazdı (A tur1, A0 tur1) | `kanit/A/tur1/devamsizlik.py` | AGENTS.md "Dil Ruby; Python veya başka dil yazma"; `bin/kontrol` `lib/*.rb` dosyalarını arar | Rehber + Sensör | M12 | Hayır |
| 2 | 17.11.2026 | Sınırda **`>`** yazdı, tam %30 (3/10) GEÇTİ sayıldı (A tur1, A0 tur1) | `kanit/A/tur1/devamsizlik.py:11` (`> SINIR`) | AGENTS.md "Tam 3 devamsızlık risklidir. `> 3` yazmak yasak"; `test_devamsizlik_tam_3_ise_riskli_olmali`; `bin/kontrol` `devamsizlik > 3` / `3 < devamsizlik` grep'i | Rehber + Sensör | M1 (grep), M2 (Minitest) | Hayır |
| 3 | 17.11.2026 | Sınırı **float/yüzde** ile karşılaştırdı: A0 tur3'te `oran(o) > SINIR` (`SINIR = 0.30`, `oran` = `to_f / OTURUM`); A tur1'de `devamsiz * 100 / toplam > 30` | `kanit/A_on_deneme/tur3/lib/devamsizlik_kontrol.rb:3,9,13`; `kanit/A/tur1/devamsizlik.py:6,11` | AGENTS.md "Kurallar tam sayı ile karşılaştırır; yüzde/float hesabı yapma"; `test_sinir_taramasi` (0..10 her değer) | Rehber + Sensör | M2 | Hayır |
| 4 | 17.11.2026 | Riskli eşiği verilmemişti; ajan **sormak yerine uydurdu** (%20 → 2 devamsızlık riskli) (A tur2, tur3) | `kanit/A/tur2/devamsizlik.rb:4` (`RISK = 20`); ajan raporu: "I chose this cutoff myself" | AGENTS.md "Emin olmadığın şeyi farz etme, sor" + "Başka eşik (ör. %20) uydurma"; `test_devamsizlik_2_riskli_degil` | Rehber + Sensör | M3 | Hayır |
| 5 | 17.11.2026 | riskli ve kaldı'yı **ayrık** yaptı (4 devamsızlık riskli değil) ve yanlış davranışı kendi testine kilitledi (A tur3, A0 tur3). Bunda tur 2'de benim yazdığım "ayrı göster" ifadesinin belirsizliğinin de payı var; rehbere bu yüzden açık bir örnek yazıldı | `kanit/A/tur3/test/devamsizlik_test.rb:33` (`test_riskli_ve_kaldi_ayrik`) | AGENTS.md "Kurallar ayrık değildir: 4 devamsızlık → `[:riskli, :kaldi]`"; `test_devamsizlik_4_ise_hem_riskli_hem_kaldi`; "Testi silme, gevşetme" | Rehber + Sensör | M4 | Hayır |
| 6 | 17.11.2026 | Sınıf yerine **Hash/Struct**, durum **String** (`"aktif"`) (A tur2, A0 tur2) | `kanit/A/tur2/devamsizlik.rb:6,20` | AGENTS.md sözleşmesi (keyword argüman, Symbol durum); `test_gecersiz_durum_ArgumentError` (`"aktif"` reddedilir) | Rehber + Sensör | M9 | Hayır |
| 7 | 17.11.2026 | Durum sorgularını **elle `def`** ile tek tek yazdı, `define_method` kullanmadı (A tur3, A0 tur3) | `kanit/A/tur3/lib/ogrenci.rb:16-18` | AGENTS.md "`DURUMLAR` listesinden `define_method` ile üret"; `bin/kontrol` define_method kontrolü (yorumlar hariç); `test_durum_sorgulari_define_method_ile_gercekten_var` | Rehber + Sensör | M11 | Hayır |
| 8 | 17.11.2026 | Devamsızlığın **üst sınırı yok** (11+ kabul), alan adı `devamsiz` (A tur3, A0 tur3) | `kanit/A/tur3/lib/ogrenci.rb:5,9` | AGENTS.md "`devamsizlik`: Integer, 0..10"; `test_devamsizlik_0_10_araliginda_tam_sayi` (-1, 11, 2.5, "3", nil) | Rehber + Sensör | M8 | Hayır |
| 9 | 17.11.2026 | **Bilinmeyen metot** testi yok, test dosya adı şartnameye uymuyor (A tur3) | `kanit/A/tur3/test/devamsizlik_test.rb` | AGENTS.md "Bilinmeyen metot `NoMethodError` vermeli" ve "Test: `ruby test/ogrenci_test.rb`"; `test_bilinmeyen_metot_NoMethodError_verir` (`mezn?`) | Rehber + Sensör | M5 | Hayır |
| 10 | 17.11.2026 | `.ruby-version` yoktu (A tur1-3); tur 4'te oluşturdu ama testleri **Ruby 3.3.6**'da koştu | `kanit/A/tur4/.ruby-version`; tur 4 ajan raporu: "sistemde Ruby 3.4 kurulu değil" | `.ruby-version` = `3.4`; `bin/kontrol` sürüm uyuşmazlığında ve boş dosyada kırmızı; ortama Ruby 3.4.6 kuruldu | Rehber + Sensör | M10 | Hayır |
| 11 | 17.11.2026 | Görevde olmayan **varsayım**: donduruldu/mezun öğrencileri kurallardan çıkardı (A tur2-4, A0 tur2-3) | `kanit/A/tur4/lib/devamsizlik_kontrol.rb:16,21` (`ogrenci.aktif? &&`) | AGENTS.md "riskli/kaldi duruma bakmaz"; `test_kurallar_duruma_bakmaz` | Rehber + Sensör | M13 | Hayır |
| 12 | 17.11.2026 | `DevamsizlikKontrol`'ü **module** yazdı; ödev "sınıf" istiyor. Testler yeşil geçti, yani sensörde açık vardı (**B koşusu-1**) | `kanit/B/kosu1/lib/devamsizlik_kontrol.rb:1` | AGENTS.md "`class DevamsizlikKontrol` (module DEĞİL)"; `test_ogrenci_ve_devamsizlik_kontrol_sinif` | Rehber + Sensör | M7 | B-2 ve B-3'te **Hayır** |

## Önleyici kurallar (koşularda gözlenmedi)

Bunlar A ve B koşularında **olmadı**; dersteki ratchet tablosundaki (slayt 12) bilinen tuzaklardan önleyici olarak eklendi. Gözlenmiş hata gibi yazılmadı.

| Tuzak | Kalıcı kural / test | Katman | Kilit |
|---|---|---|---|
| `method_missing` ile sessiz `false` | AGENTS.md yasağı; `bin/kontrol` grep; `test_method_missing_tanimlanmamis`, `test_bilinmeyen_metot_NoMethodError_verir` | Rehber + Sensör | M5 |
| Standart sınıfa monkey patch (`class Integer`, `Integer.prepend`, `refine`) | AGENTS.md yasağı; `bin/kontrol` grep; `test_standart_siniflara_monkey_patch_yok` | Rehber + Sensör | M6, M14 |
| `instance_eval` / `class_eval` ile gizli DSL (slayt 7) | AGENTS.md yasağı; `bin/kontrol` grep | Rehber + Sensör | — |

## Mandal sayacı (test sayısı yalnızca artar)

| An | Test | Assertion |
|---|---:|---:|
| A koşusu (harness yok) | 0 | 0 |
| Ratchet-1 (B koşusu-1 öncesi) | 17 | 68 |
| Ratchet-2 (#12 sonrası, B koşusu-2) | 18 | 70 |
| Denetim sonrası sağlamlaştırma (B koşusu-3) | 18 | 71 |
