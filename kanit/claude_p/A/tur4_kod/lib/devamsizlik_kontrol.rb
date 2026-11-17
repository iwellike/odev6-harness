require_relative "ogrenci"

class DevamsizlikKontrol
  TOPLAM_OTURUM = 10
  RISKLI_ESIK = 3 # devamsız >= 3 riskli sayılır
  KALDI_ESIK = 4  # devamsız >= 4 kaldı sayılır (riskli ile çakışabilir)

  def initialize(toplam_oturum: TOPLAM_OTURUM, riskli_esik: RISKLI_ESIK, kaldi_esik: KALDI_ESIK)
    @toplam_oturum = toplam_oturum
    @riskli_esik = riskli_esik
    @kaldi_esik = kaldi_esik
  end

  def oran(ogrenci)
    ogrenci.devamsiz.to_f / @toplam_oturum
  end

  def riskli?(ogrenci)
    ogrenci.aktif? && ogrenci.devamsiz >= @riskli_esik
  end

  def kaldi?(ogrenci)
    ogrenci.aktif? && ogrenci.devamsiz >= @kaldi_esik
  end

  # Özgün kural: daha önce de uyarı almış ve bu dönem yine riskli/kaldı
  # durumuna düşen öğrenci öncelikli takibe alınır (tekrarlayan risk).
  def oncelikli_takip?(ogrenci)
    ogrenci.gecmis_uyari? && (riskli?(ogrenci) || kaldi?(ogrenci))
  end

  # Kurallar ayrık değildir; bir öğrenci aynı anda birden fazla etikete sahip olabilir.
  def degerlendir(ogrenci)
    return [:kontrol_disi] unless ogrenci.aktif?

    etiketler = []
    etiketler << :riskli if riskli?(ogrenci)
    etiketler << :kaldi if kaldi?(ogrenci)
    etiketler << :oncelikli_takip if oncelikli_takip?(ogrenci)
    etiketler.empty? ? [:normal] : etiketler
  end
end
