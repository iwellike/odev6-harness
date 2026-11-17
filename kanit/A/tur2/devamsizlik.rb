# Ogrenci devamsizlik kontrolu - sinir %30, toplam 10 oturum
OTURUM = 10
SINIR  = 30   # yuzde; %30 dahil hakki var, gecen kalir
RISK   = 20   # yuzde; %20 ve ustu (sinir dahil) riskli

Ogrenci = Struct.new(:ad, :durum, :devamsiz)   # durum: aktif / donduruldu / mezun

def oran(devamsiz)
  devamsiz * 100.0 / OTURUM
end

def sonuc(o)
  return "DEGERLENDIRILMEDI" unless o.durum == "aktif"
  return "KALDI"  if o.devamsiz * 100 > SINIR * OTURUM
  return "RISKLI" if o.devamsiz * 100 >= RISK * OTURUM
  "GECTI"
end

ogrenciler = [
  Ogrenci.new("Ali",    "aktif",      1),
  Ogrenci.new("Ayse",   "aktif",      2),
  Ogrenci.new("Mehmet", "aktif",      3),   # tam %30 sinirinda
  Ogrenci.new("Zeynep", "aktif",      4),
  Ogrenci.new("Can",    "donduruldu", 5),
  Ogrenci.new("Elif",   "mezun",      0),
]

ogrenciler.each do |o|
  printf("%-8s %-11s %2d/%d  %%%-5.1f  %s\n", o.ad, o.durum, o.devamsiz, OTURUM, oran(o.devamsiz), sonuc(o))
end

%w[RISKLI KALDI].each do |s|
  liste = ogrenciler.select { |o| sonuc(o) == s }.map(&:ad)
  puts "\n#{s}: #{liste.empty? ? '-' : liste.join(', ')}"
end
