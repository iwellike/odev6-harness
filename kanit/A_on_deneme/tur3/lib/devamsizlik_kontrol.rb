class DevamsizlikKontrol
  OTURUM = 10
  SINIR  = 0.30 # %30'u ASAN kalir

  def initialize(ogrenciler)
    @aktifler = ogrenciler.select(&:aktif?) # donduruldu/mezun kontrol edilmez
  end

  def oran(ogrenci) = ogrenci.devamsiz.to_f / OTURUM

  # Sinir asildi
  def kaldi
    @aktifler.select { |o| oran(o) > SINIR }
  end

  # Henuz kalmadi ama bir devamsizlik daha yaparsa kalir
  def riskli
    @aktifler.select { |o| oran(o) <= SINIR && (o.devamsiz + 1).to_f / OTURUM > SINIR }
  end

  # Ozgun kural: hic devamsizligi olmayan (tam devam) ogrenciler
  def tam_devam
    @aktifler.select { |o| o.devamsiz.zero? }
  end
end
