require_relative "ogrenci"

# Devamsizlik kurallarini tek yerde toplar (10 oturum, sinir %30).
# Yalnizca aktif ogrenciler degerlendirilir.
class DevamsizlikKontrol
  OTURUM = 10
  RISK_ESIGI = 3   # %30: tam sinir, riskli sayilir
  KALDI_ESIGI = 4  # %30'u gecen kalir

  def oran(ogrenci)
    ogrenci.devamsizlik * 100.0 / OTURUM
  end

  # Kural 1: devamsizlik >= 3 riskli (4 ve uzeri de riskli).
  def riskli?(ogrenci)
    ogrenci.aktif? && ogrenci.devamsizlik >= RISK_ESIGI
  end

  # Kural 2: devamsizlik >= 4 kalir. Riskli ile ayrik degildir.
  def kaldi?(ogrenci)
    ogrenci.aktif? && ogrenci.devamsizlik >= KALDI_ESIGI
  end

  # Kalan devamsizlik hakki (kalmadan once). Kalmissa 0.
  def kalan_hak(ogrenci)
    [RISK_ESIGI - ogrenci.devamsizlik, 0].max
  end

  # Kural 3 (ozgun): Son hakkinda - riskli ama henuz kalmamis.
  def son_hakta?(ogrenci)
    riskli?(ogrenci) && !kaldi?(ogrenci)
  end

  # Ogrenciye uyan tum etiketler; 4 devamsizlikta [:riskli, :kaldi].
  def etiketler(ogrenci)
    %i[riskli kaldi].select { |k| public_send(:"#{k}?", ogrenci) }
  end

  # Tek satirlik ozet: en agir sonuc.
  def sonuc(ogrenci)
    return :degerlendirilmedi unless ogrenci.aktif?
    return :kaldi  if kaldi?(ogrenci)
    return :riskli if riskli?(ogrenci)

    :gecti
  end
end
