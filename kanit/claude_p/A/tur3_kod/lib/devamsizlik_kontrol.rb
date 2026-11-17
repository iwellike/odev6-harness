require_relative "ogrenci"

class DevamsizlikKontrol
  TOPLAM_OTURUM = 10
  SINIR = 0.30
  RISK_PAYI = 0.10 # sınıra bu kadar kala "riskli" sayılır

  def initialize(toplam_oturum: TOPLAM_OTURUM, sinir: SINIR)
    @toplam_oturum = toplam_oturum
    @sinir = sinir
  end

  def oran(ogrenci)
    ogrenci.devamsiz.to_f / @toplam_oturum
  end

  def kaldi?(ogrenci)
    ogrenci.aktif? && oran(ogrenci) > @sinir
  end

  def riskli?(ogrenci)
    return false unless ogrenci.aktif?

    o = oran(ogrenci)
    o >= @sinir - RISK_PAYI && o <= @sinir
  end

  # Özgün kural: daha önce de uyarı almış ve bu dönem yine riskli/kaldı
  # durumuna düşen öğrenci öncelikli takibe alınır (tekrarlayan risk).
  def oncelikli_takip?(ogrenci)
    ogrenci.gecmis_uyari? && (riskli?(ogrenci) || kaldi?(ogrenci))
  end

  def degerlendir(ogrenci)
    return :kontrol_disi unless ogrenci.aktif?
    return :kaldi if kaldi?(ogrenci)
    return :riskli if riskli?(ogrenci)

    :normal
  end
end
