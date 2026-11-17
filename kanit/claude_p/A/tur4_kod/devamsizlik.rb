require_relative "lib/ogrenci"
require_relative "lib/devamsizlik_kontrol"

ogrenciler = [
  Ogrenci.new(ad: "Ayşe Yılmaz",  durum: :aktif,      devamsiz: 1),
  Ogrenci.new(ad: "Mehmet Kaya",  durum: :aktif,      devamsiz: 3, gecmis_uyari: true),
  Ogrenci.new(ad: "Zeynep Demir", durum: :aktif,      devamsiz: 4),
  Ogrenci.new(ad: "Ali Can",      durum: :donduruldu, devamsiz: 5),
  Ogrenci.new(ad: "Elif Şahin",   durum: :mezun,      devamsiz: 0),
]

kontrol = DevamsizlikKontrol.new
riskli = []
kaldi = []
oncelikli = []

ogrenciler.each do |o|
  oran_yuzde = (kontrol.oran(o) * 100).round(1)
  etiketler = kontrol.degerlendir(o)

  riskli << o if etiketler.include?(:riskli)
  kaldi << o if etiketler.include?(:kaldi)
  oncelikli << o if etiketler.include?(:oncelikli_takip)

  puts "#{o.ad} (#{o.durum}) - devamsızlık: #{o.devamsiz}/#{DevamsizlikKontrol::TOPLAM_OTURUM} (%#{oran_yuzde}) -> #{etiketler.join(", ")}"
end

puts "\n--- RİSKLİ (devamsız >= #{DevamsizlikKontrol::RISKLI_ESIK}) ---"
riskli.each { |o| puts o.ad }

puts "\n--- KALDI (devamsız >= #{DevamsizlikKontrol::KALDI_ESIK}) ---"
kaldi.each { |o| puts o.ad }

puts "\n--- ÖNCELİKLİ TAKİP (tekrarlayan risk) ---"
oncelikli.each { |o| puts o.ad }
