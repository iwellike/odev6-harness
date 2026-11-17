require_relative "lib/ogrenci"
require_relative "lib/devamsizlik_kontrol"

ogrenciler = [
  Ogrenci.new("Ali",    :aktif,      0),
  Ogrenci.new("Ayse",   :aktif,      3),
  Ogrenci.new("Mehmet", :aktif,      4),
  Ogrenci.new("Zeynep", :donduruldu, 6),
  Ogrenci.new("Can",    :mezun,      0),
  Ogrenci.new("Elif",   :aktif,      7)
]

kontrol = DevamsizlikKontrol.new(ogrenciler)
yaz = ->(o) { puts "  #{o.ad.ljust(8)} #{o.devamsiz}/#{DevamsizlikKontrol::OTURUM}" }

puts "RISKLI:";    kontrol.riskli.each(&yaz)
puts "KALDI:";     kontrol.kaldi.each(&yaz)
puts "TAM DEVAM:"; kontrol.tam_devam.each(&yaz)
