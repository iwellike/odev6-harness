# Ogrenci devamsizlik kontrolu - sinir %30, toplam 10 oturum
require_relative "lib/devamsizlik_kontrol"

kontrol = DevamsizlikKontrol.new(oturum: 10, sinir: 30, risk: 20)

ogrenciler = [
  Ogrenci.new("Ali",    :aktif,      1),
  Ogrenci.new("Ayse",   :aktif,      2),
  Ogrenci.new("Mehmet", :aktif,      3),   # tam %30 sinirinda
  Ogrenci.new("Zeynep", :aktif,      4),
  Ogrenci.new("Can",    :donduruldu, 5),
  Ogrenci.new("Elif",   :mezun,      0),
]

ogrenciler.each do |o|
  uyari = kontrol.son_hakta?(o) ? "  (SON HAK!)" : ""
  printf("%-8s %-11s %2d/%d  %%%-5.1f  %s%s\n", o.ad, o.durum, o.devamsiz, kontrol.oturum,
         kontrol.oran(o), kontrol.sonuc(o).to_s.upcase, uyari)
end

{ "RISKLI" => :riskli?, "KALDI" => :kaldi?, "SON HAKTA" => :son_hakta? }.each do |baslik, kural|
  liste = ogrenciler.select { |o| kontrol.public_send(kural, o) }.map(&:ad)
  puts "\n#{baslik}: #{liste.empty? ? '-' : liste.join(', ')}"
end
