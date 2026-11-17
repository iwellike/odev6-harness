#!/bin/bash
# Sensör doğrulama: A koşusunda görülen hataları doğru koda geri sokar, bin/kontrol yakalıyor mu bakar.
R=$(cd "$(dirname "$0")/.." && pwd)
OUT=$R/kanit/sensor_dogrulama.txt
: > "$OUT"

calistir() { # $1=ad  $2=açıklama  $3=değiştirici komut (çalışma kopyasında)
  T=$(mktemp -d)
  cp -a $R/.ruby-version $R/AGENTS.md $R/bin $R/lib $R/test "$T"/
  (cd "$T" && eval "$3")
  { echo "### $1 — $2"
    (cd "$T" && bin/kontrol 2>&1 | grep -E 'KONTROL|Failure:|Expected|Error:|^lib/' | head -6)
    echo "çıkış kodu: $(cd "$T" && bin/kontrol >/dev/null 2>&1; echo $?)"
    echo; } >> "$OUT"
  rm -rf "$T"
}

calistir M0 "Değiştirilmemiş kod (kontrol grubu)" "true"
calistir M1 "riskli '>= 3' yerine '> 3' (A tur1 sınır hatası)" \
  "sed -i 's/devamsizlik >= 3/devamsizlik > 3/' lib/devamsizlik_kontrol.rb"
calistir M2 "float/yüzde ile '> %30' (A tur1-2 hatası; grep'e takılmayan biçim)" \
  "sed -i 's/o.devamsizlik >= 3/o.devamsizlik \/ 10.0 > 0.3/' lib/devamsizlik_kontrol.rb"
calistir M3 "riskli'yi kendisi %20'ye çekti (A tur2-3: 2 devamsızlık riskli)" \
  "sed -i 's/devamsizlik >= 3/devamsizlik >= 2/' lib/devamsizlik_kontrol.rb"
calistir M4 "riskli/kaldi ayrık (A tur3: 4 devamsızlık riskli değil)" \
  "sed -i 's/o.devamsizlik >= 3/o.devamsizlik == 3/' lib/devamsizlik_kontrol.rb"
calistir M5 "define_method yerine method_missing (dersteki tuzak, önleyici)" \
  "python3 -I - <<'PY'
p='lib/ogrenci.rb'; s=open(p).read()
s=s.replace('''  DURUMLAR.each do |d|
    define_method(:\"#{d}?\") { @durum == d }
  end''','''  def method_missing(ad, *args)
    return super unless ad.end_with?(\"?\")
    @durum == ad.to_s.delete_suffix(\"?\").to_sym
  end''')
open(p,'w').write(s)
PY"
calistir M6 "Integer'a monkey patch (dersteki tuzak, önleyici)" \
  "printf 'class Integer\n  def riskli? = self >= 3\nend\n' >> lib/devamsizlik_kontrol.rb"
calistir M7 "DevamsizlikKontrol module (B koşusu-1 hatası)" \
  "sed -i 's/^class DevamsizlikKontrol/module DevamsizlikKontrol/' lib/devamsizlik_kontrol.rb"
calistir M8 "Devamsızlık üst sınırı yok (A tur3: 11 kabul ediliyor)" \
  "sed -i 's/(0..10)/(0..)/' lib/ogrenci.rb"
calistir M9 "Durum String kabul ediliyor (A tur2)" \
  "sed -i 's/unless DURUMLAR.include?(durum)/unless DURUMLAR.include?(durum.to_sym)/; s/@durum = durum$/@durum = durum.to_sym/' lib/ogrenci.rb"
calistir M10 "Yanlış Ruby sürümü (.ruby-version 3.3; A tur4 ortam hatası)" \
  "echo 3.3 > .ruby-version"
calistir M11 "define_method yerine elle def (A tur3)" \
  "sed -i '/DURUMLAR.each do/,/^  end/c\  def aktif? = @durum == :aktif\n  def donduruldu? = @durum == :donduruldu\n  def mezun? = @durum == :mezun' lib/ogrenci.rb"
calistir M12 "Ruby yerine Python (A tur1)" \
  "rm lib/*.rb && echo 'print(1)' > devamsizlik.py"
cat "$OUT"
