# AGENTS.md · Devamsızlık ve Kural Motoru

Emin olmadığın şeyi farz etme, sor.

## Ortam
- Sürüm: 3.4 (`.ruby-version`). Dil Ruby; Python veya başka dil yazma.
- Yalnızca stdlib + Minitest. Gem ekleme, Gemfile açma.

## Sözleşme
- `lib/ogrenci.rb` → `class Ogrenci`, `Ogrenci.new(ad:, durum: :aktif, devamsizlik: 0)` (keyword argüman)
  - `ad`: String · `durum`: Symbol, yalnızca `:aktif`, `:donduruldu`, `:mezun` · `devamsizlik`: Integer, 0..10 (10 oturum)
  - Geçersiz durum (String `"aktif"` dahil) veya aralık dışı/tam sayı olmayan devamsızlık → `ArgumentError`
  - `aktif?`, `donduruldu?`, `mezun?` → `DURUMLAR` listesinden `define_method` ile üret.
- `lib/devamsizlik_kontrol.rb` → `class DevamsizlikKontrol` (module DEĞİL) · `DevamsizlikKontrol::KURALLAR` (Hash: sembol → lambda) ve `DevamsizlikKontrol.durum(ogr)` → uyan kural sembollerinin dizisi, KURALLAR sırasıyla.

## Alan kuralları (10 oturum, sınır %30)
- `riskli`: `devamsizlik >= 3`. Tam 3 devamsızlık risklidir. `> 3` yazmak yasak.
- `kaldi`: `devamsizlik >= 4`.
- Kurallar ayrık değildir: 4 devamsızlık → `[:riskli, :kaldi]`.
- `onur_adayi` (özgün kural): `aktif?` ve `devamsizlik == 0`.
- Kurallar tam sayı ile karşılaştırır; yüzde/float hesabı yapma. Başka eşik (ör. %20) uydurma.
- riskli/kaldi duruma bakmaz; yalnızca devamsızlığa bakar.

## Yasaklar
- `method_missing` / `respond_to_missing?` yasaktır. Bilinmeyen metot `NoMethodError` vermeli.
- Monkey patch yasaktır: Integer, String, Date vb. standart sınıfları açma, `refine`/`prepend` etme. Gerekirse açık modül/servis yaz.
- `instance_eval`, `class_eval` ile gizli DSL yasaktır.

## Döngü
- Test: `ruby test/ogrenci_test.rb` (Minitest). Testi silme, gevşetme, atlatma.
- Her dosya kaydından sonra `bin/kontrol` çalıştır. Çıkış kodu 0 olmadan "bitti" deme.
- Açıklama yerine kod yaz; raporu kısa tut.
