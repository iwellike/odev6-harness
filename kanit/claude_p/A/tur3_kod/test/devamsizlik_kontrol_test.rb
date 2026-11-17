require "minitest/autorun"
require_relative "../lib/devamsizlik_kontrol"

class DevamsizlikKontrolTest < Minitest::Test
  def setup
    @kontrol = DevamsizlikKontrol.new
  end

  def test_normal
    o = Ogrenci.new(ad: "A", durum: :aktif, devamsiz: 1)
    assert_equal :normal, @kontrol.degerlendir(o)
  end

  def test_riskli_alt_sinir
    o = Ogrenci.new(ad: "A", durum: :aktif, devamsiz: 2) # %20
    assert @kontrol.riskli?(o)
    assert_equal :riskli, @kontrol.degerlendir(o)
  end

  def test_riskli_ust_sinir
    o = Ogrenci.new(ad: "A", durum: :aktif, devamsiz: 3) # %30, tam sınır
    assert @kontrol.riskli?(o)
    refute @kontrol.kaldi?(o)
  end

  def test_kaldi
    o = Ogrenci.new(ad: "A", durum: :aktif, devamsiz: 4) # %40
    assert @kontrol.kaldi?(o)
    assert_equal :kaldi, @kontrol.degerlendir(o)
  end

  def test_aktif_olmayanlar_kontrol_disi
    donduruldu = Ogrenci.new(ad: "A", durum: :donduruldu, devamsiz: 9)
    mezun = Ogrenci.new(ad: "B", durum: :mezun, devamsiz: 9)

    assert_equal :kontrol_disi, @kontrol.degerlendir(donduruldu)
    assert_equal :kontrol_disi, @kontrol.degerlendir(mezun)
    refute @kontrol.kaldi?(donduruldu)
    refute @kontrol.riskli?(mezun)
  end

  def test_oncelikli_takip_gecmis_uyari_ve_tekrar_risk_gerektirir
    tekrarci = Ogrenci.new(ad: "A", durum: :aktif, devamsiz: 2, gecmis_uyari: true)
    ilk_kez = Ogrenci.new(ad: "B", durum: :aktif, devamsiz: 2, gecmis_uyari: false)
    gecmisi_var_ama_normal = Ogrenci.new(ad: "C", durum: :aktif, devamsiz: 0, gecmis_uyari: true)

    assert @kontrol.oncelikli_takip?(tekrarci)
    refute @kontrol.oncelikli_takip?(ilk_kez)
    refute @kontrol.oncelikli_takip?(gecmisi_var_ama_normal)
  end

  def test_ozel_sinir_ile_kontrol
    gevsek = DevamsizlikKontrol.new(sinir: 0.50)
    o = Ogrenci.new(ad: "A", durum: :aktif, devamsiz: 4) # %40, %50 sınırında kalmaz
    refute gevsek.kaldi?(o)
  end
end
