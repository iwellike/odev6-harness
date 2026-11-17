TOPLAM_OTURUM = 10
DEVAMSIZLIK_SINIRI = 0.30 # %30

ogrenciler = [
  { ad: "Ayşe Yılmaz",   durum: "aktif",      devamsiz: 1 },
  { ad: "Mehmet Kaya",   durum: "aktif",      devamsiz: 2 },
  { ad: "Zeynep Demir",  durum: "aktif",      devamsiz: 4 },
  { ad: "Ali Can",       durum: "donduruldu", devamsiz: 5 },
  { ad: "Elif Şahin",    durum: "mezun",      devamsiz: 0 },
]

def durumu_degerlendir(devamsiz)
  oran = devamsiz.to_f / TOPLAM_OTURUM
  return :kaldi if oran > DEVAMSIZLIK_SINIRI
  return :riskli if oran >= DEVAMSIZLIK_SINIRI - 0.10 # son 1 oturum hakkı kaldıysa uyar
  :normal
end

riskli = []
kaldi = []

ogrenciler.each do |o|
  oran_yuzde = (o[:devamsiz].to_f / TOPLAM_OTURUM * 100).round(1)

  if o[:durum] != "aktif"
    puts "#{o[:ad]} (#{o[:durum]}) - devamsızlık: #{o[:devamsiz]}/#{TOPLAM_OTURUM} (%#{oran_yuzde}) [kontrol dışı]"
    next
  end

  sonuc = durumu_degerlendir(o[:devamsiz])
  riskli << o if sonuc == :riskli
  kaldi << o if sonuc == :kaldi
  puts "#{o[:ad]} (aktif) - devamsızlık: #{o[:devamsiz]}/#{TOPLAM_OTURUM} (%#{oran_yuzde}) -> #{sonuc}"
end

puts "\n--- RİSKLİ (sınıra yakın) ---"
riskli.each { |o| puts o[:ad] }

puts "\n--- KALDI (%#{(DEVAMSIZLIK_SINIRI * 100).to_i} sınırını aştı) ---"
kaldi.each { |o| puts o[:ad] }

if __FILE__ == $0 && ARGV[0] == "test"
  raise "2/10 riskli olmalı" unless durumu_degerlendir(2) == :riskli
  raise "3/10 riskli olmalı" unless durumu_degerlendir(3) == :riskli
  raise "4/10 kaldı olmalı" unless durumu_degerlendir(4) == :kaldi
  raise "1/10 normal olmalı" unless durumu_degerlendir(1) == :normal
  puts "\nTüm testler geçti."
end
