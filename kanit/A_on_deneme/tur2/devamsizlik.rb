OTURUM = 10
SINIR  = 0.30 # %30'u ASAN kalir

ogrenciler = [
  { ad: "Ali",    durum: "aktif",      devamsiz: 1 },
  { ad: "Ayse",   durum: "aktif",      devamsiz: 3 },
  { ad: "Mehmet", durum: "aktif",      devamsiz: 4 },
  { ad: "Zeynep", durum: "donduruldu", devamsiz: 6 },
  { ad: "Can",    durum: "mezun",      devamsiz: 0 },
  { ad: "Elif",   durum: "aktif",      devamsiz: 7 }
]

def sonuc(devamsiz)
  return "KALDI"  if devamsiz.to_f / OTURUM > SINIR
  return "RISKLI" if (devamsiz + 1).to_f / OTURUM > SINIR # bir devamsizlik daha = kalir
  "NORMAL"
end

riskli = []
kaldi  = []

ogrenciler.each do |o|
  next unless o[:durum] == "aktif" # donduruldu/mezun kontrol edilmez
  case sonuc(o[:devamsiz])
  when "KALDI"  then kaldi  << o
  when "RISKLI" then riskli << o
  end
end

yaz = ->(o) { puts "  #{o[:ad].ljust(8)} #{o[:devamsiz]}/#{OTURUM} (%#{o[:devamsiz] * 100 / OTURUM})" }

puts "RISKLI:"
riskli.each(&yaz)
puts "KALDI:"
kaldi.each(&yaz)
