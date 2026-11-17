# B Koşuları — Ham ajan raporları

Prompt yapısı her B koşusunda aynıdır:

```
Çalışma klasörün: /home/claude/kosu_B<n>. Yalnızca bu klasörde çalış.

Proje talimatı (CLAUDE.md -> AGENTS.md, otomatik yüklendi):
<<<
[o koşuda klasörde bulunan AGENTS.md'nin tam içeriği; bkz. kosu<n>/harness/AGENTS.md]
>>>

Görev: Öğrenci devamsızlık kontrolü yap, devamsızlık sınırı %30'dur.
```

Görev cümlesi A koşusunun tur 1 promptuyla birebir aynıdır. Fark yalnızca klasördeki harness ve onun bağlama eklenmesidir. Claude Code CLAUDE.md'yi otomatik yükler; alt ajan yüklemediği için içerik prompta eklendi.

## B koşusu-1 (harness: `kosu1/harness/`)
**Ajan raporu**
```
Devamsızlık kontrolü hazır ve testler geçiyor. `bin/kontrol` 0 koduyla çıktı: 17 test çalıştı, hiçbiri başarısız olmadı.

- **`/home/claude/kosu_B/lib/ogrenci.rb`**: `Ogrenci` sınıfı öğrencinin adını, durumunu ve devamsızlık sayısını tutar. Geçersiz bir durum (`"aktif"` gibi metin olarak yazılmış hali de dahil) ya da 0–10 arasında olmayan veya tam sayı olmayan bir devamsızlık değeri verilirse `ArgumentError` hatası verir. `aktif?`, `donduruldu?` ve `mezun?` metotları `define_method` ile üretiliyor.
- **`/home/claude/kosu_B/lib/devamsizlik_kontrol.rb`**: Kurallar `KURALLAR` içinde tanımlı. `DevamsizlikKontrol.durum(ogr)` öğrenciye uyan kuralları bu sırayla döndürür:
  - `riskli`: devamsızlık 3 veya daha fazla (10 oturumun %30'u)
  - `kaldi`: devamsızlık 4 veya daha fazla
  - `onur_adayi`: öğrenci aktif ve hiç devamsızlığı yok

Kurallar birbirini dışlamıyor; 4 devamsızlığı olan bir öğrenci için sonuç `[:riskli, :kaldi]` olur. Yüzde ya da ondalıklı sayı hesabı yok, sadece tam sayılar karşılaştırılıyor.
```
**Usage:** `subagent_tokens: 76098 · tool_uses: 2 · duration_ms: 17885`

**Not:** Testler yeşildi ama `lib/devamsizlik_kontrol.rb` `module DevamsizlikKontrol` idi. Ödev "sınıf" istiyor → RATCHET #12.

## B koşusu-2 (harness: `kosu2/harness/`, ratchet #12 sonrası)
**Ajan raporu**
```
Devamsızlık kontrolü hazır. `bin/kontrol` 0 koduyla çıktı ve testlerin hepsi geçiyor (18 test, 70 doğrulama, hata yok).

- **`lib/ogrenci.rb`**:
  - Öğrenci adı, durumu ve devamsızlığıyla oluşturuluyor.
  - Durum yalnızca `:aktif`, `:donduruldu` veya `:mezun` olabilir. Geçersiz durumda ya da 0–10 dışındaki veya tam sayı olmayan devamsızlıkta `ArgumentError` veriyor.
  - `aktif?`, `donduruldu?`, `mezun?` metotları durum listesinden `define_method` ile üretiliyor.
- **`lib/devamsizlik_kontrol.rb`**: `DevamsizlikKontrol.durum(ogr)` uyan kuralları sırayla dizi olarak döndürüyor. Kurallar:
  - **`riskli`**: devamsızlık 3 veya fazlaysa. 10 oturumda %30, tam 3 devamsızlığa denk geliyor ve tam 3 riskli sayılıyor.
  - **`kaldi`**: devamsızlık 4 veya fazlaysa. Kurallar ayrı değil, örneğin 4 devamsızlık `[:riskli, :kaldi]` veriyor.
  - **`onur_adayi`**: öğrenci aktif ve hiç devamsızlığı yoksa.

Kurallar yüzde hesaplamıyor, doğrudan tam sayıyla karşılaştırıyor. `riskli` ve `kaldi` öğrencinin durumuna bakmıyor.
```
**Usage:** `subagent_tokens: 77218 · tool_uses: 4 · duration_ms: 21822`

## B koşusu-3 (harness: `kosu3/harness/` = repodaki son harness)
Denetim sonrası yapılan ifade/sağlamlaştırma değişikliklerinden (AGENTS.md birebir ifadeler, `refine`/`prepend` yasağı, `bin/kontrol` yorum satırı filtresi, ek assertion) sonra son harness'ın da çalıştığını doğrulamak için sıfırdan koşturuldu.

**Ajan raporu**
```
Devamsızlık kontrolü yazıldı. `bin/kontrol` 0 koduyla çıktı ve 18 testin hepsi geçti (71 doğrulama, hata yok).

- **`lib/ogrenci.rb`**: Durum yalnızca `:aktif`, `:donduruldu` veya `:mezun` olabilir; `"aktif"` gibi String bir değer `ArgumentError` verir. Devamsızlık 0 ile 10 arasında tam sayı olmalı, değilse yine `ArgumentError` verir. `aktif?`, `donduruldu?` ve `mezun?` metotları `define_method` ile üretiliyor.
- **`lib/devamsizlik_kontrol.rb`**: Üç kural var ve tam sayıyla karşılaştırıyor, yüzde hesabı yok.
  - `riskli`: 3 ve üzeri devamsızlık (%30 sınırı). Tam 3 risklidir.
  - `kaldi`: 4 ve üzeri devamsızlık.
  - `onur_adayi`: aktif öğrenci ve sıfır devamsızlık.

  `DevamsizlikKontrol.durum(ogr)` uyan kuralları bu sırayla döndürür; 4 devamsızlık için sonuç `[:riskli, :kaldi]` olur.

`ad` alanının String olup olmadığını kontrol etmedim, çünkü AGENTS.md hata koşullarında yalnızca durum ve devamsızlığı sayıyor. İstersen eklerim.

Dosyalar `/home/claude/kosu_B3/lib/` klasöründe.
```
**Usage:** `subagent_tokens: 76364 · tool_uses: 2 · duration_ms: 23645`

**Not:** Ajan, sözleşmede yazmayan `ad` doğrulamasını farz etmek yerine sordu; AGENTS.md'nin ilk maddesi ("farz etme, sor") işledi. Ödev `ad` için doğrulama istemediğinden eklenmedi.
