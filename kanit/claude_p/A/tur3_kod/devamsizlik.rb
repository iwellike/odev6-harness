require_relative "lib/ogrenci"
require_relative "lib/devamsizlik_kontrol"

ogrenciler = [
  Ogrenci.new(ad: "Ayşe Yılmaz",  durum: :aktif,      devamsiz: 1),
  Ogrenci.new(ad: "Mehmet Kaya",  durum: :aktif,      devamsiz: 2, gecmis_uyari: true),
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
  sonuc = kontrol.degerlendir(o)

  riskli << o if sonuc == :riskli
  kaldi << o if sonuc == :kaldi
  oncelikli << o if kontrol.oncelikli_takip?(o)

  durum_etiketi = o.aktif? ? sonuc : "#{o.durum} [kontrol dışı]"
  puts "#{o.ad} (#{o.durum}) - devamsızlık: #{o.devamsiz}/#{DevamsizlikKontrol::TOPLAM_OTURUM} (%#{oran_yuzde}) -> #{durum_etiketi}"
end

puts "\n--- RİSKLİ (sınıra yakın) ---"
riskli.each { |o| puts o.ad }

puts "\n--- KALDI (%#{(DevamsizlikKontrol::SINIR * 100).to_i} sınırını aştı) ---"
kaldi.each { |o| puts o.ad }

puts "\n--- ÖNCELİKLİ TAKİP (tekrarlayan risk) ---"
oncelikli.each { |o| puts o.ad }
