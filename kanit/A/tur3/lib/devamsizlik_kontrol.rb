require_relative "ogrenci"

# Devamsizlik kurallarini tek yerde toplar.
# Yalnizca aktif ogrenciler degerlendirilir.
class DevamsizlikKontrol
  attr_reader :oturum, :sinir, :risk

  # sinir ve risk yuzde olarak verilir.
  def initialize(oturum: 10, sinir: 30, risk: 20)
    raise ArgumentError, "Oturum sayisi pozitif olmali" unless oturum.positive?

    @oturum = oturum
    @sinir = sinir
    @risk = risk
  end

  def oran(ogrenci)
    ogrenci.devamsiz * 100.0 / oturum
  end

  # Kural 1: %30'u GECEN kalir (%30 dahil hakki var).
  def kaldi?(ogrenci)
    ogrenci.aktif? && ogrenci.devamsiz * 100 > sinir * oturum
  end

  # Kural 2: %20 ve ustu riskli, ama henuz kalmamis (sinir dahil).
  def riskli?(ogrenci)
    ogrenci.aktif? && !kaldi?(ogrenci) && ogrenci.devamsiz * 100 >= risk * oturum
  end

  # Kalan devamsizlik hakki (oturum sayisi). Kalmissa 0.
  def kalan_hak(ogrenci)
    [sinir * oturum / 100 - ogrenci.devamsiz, 0].max
  end

  # Kural 3 (ozgun): Son hakkinda - hakki tam tukenmis ama henuz kalmamis.
  # Bir oturuma daha gelmezse kalacak; ayri uyari gerektirir.
  def son_hakta?(ogrenci)
    ogrenci.aktif? && !kaldi?(ogrenci) && kalan_hak(ogrenci).zero?
  end

  def sonuc(ogrenci)
    return :degerlendirilmedi unless ogrenci.aktif?
    return :kaldi  if kaldi?(ogrenci)
    return :riskli if riskli?(ogrenci)

    :gecti
  end
end
