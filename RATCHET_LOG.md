# RATCHET_LOG — Hata → Kalıcı Kural Günlüğü

Mandal tek yöne döner: bir kez yakalanan hata ya rehbere (AGENTS.md) ya sensöre (Minitest / bin/kontrol) yazılır ve bir daha geçemez.
Her satırın kanıtı `kanit/` altındadır. "Kanıt" sütunu ajanın o turda yazdığı dosyayı, "Kilit" sütunu aynı hatayı bilerek geri soktuğumuzda (`kanit/sensor_dogrulama.txt`) hangi sensörün yakaladığını gösterir.

| # | Tarih | Karşılaşılan hata (koşu · tur) | Kanıt | Kalıcı kural / test | Katman | Kilit (mutasyon) | B'de tekrar etti mi? |
|---|---|---|---|---|---|---|---|
| 1 | 17.11.2026 | Ruby yerine **Python** yazdı (A tur1, A0 tur1) | `kanit/A/tur1/devamsizlik.py` | AGENTS.md "Dil: Ruby 3.4 … Python veya başka dil yazma"; `bin/kontrol` lib/*.rb dosyalarını arar | Rehber + Sensör | M12 | Hayır |
| 2 | 17.11.2026 | Sınırda **`> %30`** yazdı, tam 3 devamsızlık (%30) GEÇTİ sayıldı (A tur1, A0 tur1) | `kanit/A/tur1/devamsizlik.py` (`> SINIR`) | AGENTS.md "Tam 3 riskli SAYILIR. `> 3` yasak"; `test_devamsizlik_tam_3_ise_riskli_olmali`; `bin/kontrol` `devamsizlik > 3` grep'i | Rehber + Sensör | M1 (grep), M2 (Minitest) | Hayır |
| 3 | 17.11.2026 | Oranı **float/yüzde** ile hesapladı (`devamsiz.to_f / OTURUM > 0.30`) (A0 tur3, A tur1-3) | `kanit/A_on_deneme/tur3/lib/devamsizlik_kontrol.rb` | AGENTS.md "tam sayı ile karşılaştır; yüzde/float hesabı yapma"; `test_sinir_taramasi` (0..10 her değer) | Rehber + Sensör | M2 | Hayır |
| 4 | 17.11.2026 | Riskli eşiğini **kendisi uydurdu** (%20 → 2 devamsızlık riskli) (A tur2, tur3) | `kanit/A/tur2/devamsizlik.rb` (`RISK = 20`) | AGENTS.md "Emin olmadığın şeyi farz etme" + "Başka eşik (ör. %20) uydurma"; `test_devamsizlik_2_riskli_degil` | Rehber + Sensör | M3 | Hayır |
| 5 | 17.11.2026 | riskli ve kaldı'yı **ayrık** yaptı (4 devamsızlık riskli değil) ve yanlış davranışı teste kilitledi (A tur3, A0 tur3) | `kanit/A/tur3/test/devamsizlik_test.rb` (`test_riskli_ve_kaldi_ayrik`) | AGENTS.md "Kurallar ayrık değildir: 4 → `[:riskli, :kaldi]`"; `test_devamsizlik_4_ise_hem_riskli_hem_kaldi`; "Testi silme, gevşetme" maddesi | Rehber + Sensör | M4 | Hayır |
| 6 | 17.11.2026 | Sınıf yerine **Hash/Struct**, durum **String** (`"aktif"`) (A tur2, A0 tur2) | `kanit/A/tur2/devamsizlik.rb` | AGENTS.md sözleşmesi (keyword argüman, Symbol durum); `test_gecersiz_durum_ArgumentError` (`"aktif"` reddedilir) | Rehber + Sensör | M9 | Hayır |
| 7 | 17.11.2026 | Durum sorgularını **elle `def`** ile tekrar tekrar yazdı, `define_method` kullanmadı (A tur3, A0 tur3) | `kanit/A/tur3/lib/ogrenci.rb` | AGENTS.md "`DURUMLAR` listesinden `define_method` ile üret"; `bin/kontrol` define_method grep'i; `test_durum_sorgulari_define_method_ile_gercekten_var` | Rehber + Sensör | M11 | Hayır |
| 8 | 17.11.2026 | Devamsızlığın **üst sınırı yok** (11+ kabul), alan adı `devamsiz` (A tur3, A0 tur3) | `kanit/A/tur3/lib/ogrenci.rb` | AGENTS.md "`devamsizlik`: Integer, 0..10"; `test_devamsizlik_0_10_araliginda_tam_sayi` (-1, 11, 2.5, "3", nil) | Rehber + Sensör | M8 | Hayır |
| 9 | 17.11.2026 | **Bilinmeyen metot** testi yok; test dosya adı şartnameye uymuyor (A tur3) | `kanit/A/tur3/test/` | `test/ogrenci_test.rb` adı sabit; `test_bilinmeyen_metot_NoMethodError_verir` (`mezn?`) | Sensör | M5 | Hayır |
| 10 | 17.11.2026 | `.ruby-version` yok; ajan testleri **Ruby 3.3.6**'da koştu (A tur1-4) | `kanit/A/kosu_A.md` (tur 4 itirafı) | `.ruby-version` = `3.4`; `bin/kontrol` çalışan sürüm uyuşmazsa kırmızı; ortama Ruby 3.4.6 kuruldu | Rehber + Sensör | M10 | Hayır |
| 11 | 17.11.2026 | Görevde olmayan **varsayım**: donduruldu/mezun öğrencileri kurallardan çıkardı (A tur2-4, A0 tur2-3) | `kanit/A/tur4/lib/devamsizlik_kontrol.rb` (`ogrenci.aktif? &&`) | AGENTS.md "riskli/kaldi duruma bakmaz"; `test_kurallar_duruma_bakmaz` | Rehber + Sensör | — | Hayır |
| 12 | 17.11.2026 | `DevamsizlikKontrol`'ü **module** yazdı; ödev "sınıf" istiyor (**B koşusu-1**) | `kanit/B/kosu1/lib/devamsizlik_kontrol.rb` | AGENTS.md "`class DevamsizlikKontrol` (module DEĞİL)"; `test_ogrenci_ve_devamsizlik_kontrol_sinif` | Rehber + Sensör | M7 | B koşusu-2'de **Hayır** |

## Önleyici (A'da gözlenmedi, dersten bilinen tuzak)

Bunlar A koşusunda **olmadı**; dersteki ratchet tablosundan (slayt 12) önleyici olarak eklendi. Uydurma hata olarak yazılmamıştır.

| Tuzak | Kalıcı kural / test | Katman | Kilit |
|---|---|---|---|
| `method_missing` ile sessiz `false` | AGENTS.md yasağı; `bin/kontrol` grep; `test_method_missing_tanimlanmamis`, `test_bilinmeyen_metot_NoMethodError_verir` | Rehber + Sensör | M5 |
| Standart sınıfa monkey patch (`class Integer`, `class Date`) | AGENTS.md yasağı; `bin/kontrol` grep; `test_standart_siniflara_monkey_patch_yok` | Rehber + Sensör | M6 |
| `instance_eval` / `class_eval` ile gizli DSL (slayt 7) | AGENTS.md yasağı; `bin/kontrol` grep | Rehber + Sensör | — |

## Mandal sayacı

- A koşusu sonu: sensör yok (0 test bizim harness'ımızdan).
- Ratchet-1 sonrası: 17 test, 68 assertion.
- Ratchet-2 sonrası (B koşusu-1 hatası #12): **18 test, 70 assertion** — hepsi yeşil. Test sayısı yalnızca artar.
