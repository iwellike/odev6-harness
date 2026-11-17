require "minitest/autorun"
require_relative "../lib/ogrenci"
require_relative "../lib/devamsizlik_kontrol"

class OgrenciTest < Minitest::Test
  def test_durum_sorgulari
    aktif = Ogrenci.new(ad: "A", durum: :aktif, devamsiz: 0)
    assert aktif.aktif?
    refute aktif.mezun?
    refute aktif.donduruldu?

    mezun = Ogrenci.new(ad: "B", durum: :mezun, devamsiz: 0)
    assert mezun.mezun?
    refute mezun.aktif?

    donduruldu = Ogrenci.new(ad: "C", durum: :donduruldu, devamsiz: 0)
    assert donduruldu.donduruldu?
  end

  def test_gecersiz_durum_hata_verir
    assert_raises(ArgumentError) { Ogrenci.new(ad: "X", durum: :bilinmeyen, devamsiz: 0) }
  end

  def test_bilinmeyen_sorgu_metodu_no_method_error_verir
    o = Ogrenci.new(ad: "A", durum: :aktif, devamsiz: 0)
    assert_raises(NoMethodError) { o.mezn? }
  end

  def test_gecmis_uyari_varsayilan_false
    o = Ogrenci.new(ad: "A", durum: :aktif, devamsiz: 0)
    refute o.gecmis_uyari?
  end
end

class DevamsizlikKontrolTest < Minitest::Test
  def setup
    @kontrol = DevamsizlikKontrol.new
  end

  def test_iki_devamsizlik_ne_riskli_ne_kaldi
    o = Ogrenci.new(ad: "A", durum: :aktif, devamsiz: 2)
    refute @kontrol.riskli?(o)
    refute @kontrol.kaldi?(o)
    assert_equal [:normal], @kontrol.degerlendir(o)
  end

  def test_tam_uc_devamsizlik_sadece_riskli
    o = Ogrenci.new(ad: "A", durum: :aktif, devamsiz: 3)
    assert @kontrol.riskli?(o)
    refute @kontrol.kaldi?(o)
    assert_equal [:riskli], @kontrol.degerlendir(o)
  end

  def test_dort_devamsizlik_hem_riskli_hem_kaldi
    o = Ogrenci.new(ad: "A", durum: :aktif, devamsiz: 4)
    assert @kontrol.riskli?(o)
    assert @kontrol.kaldi?(o)
    assert_equal %i[riskli kaldi], @kontrol.degerlendir(o)
  end

  def test_aktif_olmayanlar_kontrol_disi
    donduruldu = Ogrenci.new(ad: "A", durum: :donduruldu, devamsiz: 9)
    mezun = Ogrenci.new(ad: "B", durum: :mezun, devamsiz: 9)

    assert_equal [:kontrol_disi], @kontrol.degerlendir(donduruldu)
    assert_equal [:kontrol_disi], @kontrol.degerlendir(mezun)
    refute @kontrol.kaldi?(donduruldu)
    refute @kontrol.riskli?(mezun)
  end

  def test_oncelikli_takip_gecmis_uyari_ve_tekrar_risk_gerektirir
    tekrarci = Ogrenci.new(ad: "A", durum: :aktif, devamsiz: 3, gecmis_uyari: true)
    ilk_kez = Ogrenci.new(ad: "B", durum: :aktif, devamsiz: 3, gecmis_uyari: false)
    gecmisi_var_ama_normal = Ogrenci.new(ad: "C", durum: :aktif, devamsiz: 0, gecmis_uyari: true)

    assert @kontrol.oncelikli_takip?(tekrarci)
    refute @kontrol.oncelikli_takip?(ilk_kez)
    refute @kontrol.oncelikli_takip?(gecmisi_var_ama_normal)
  end

  def test_ozel_esik_ile_kontrol
    gevsek = DevamsizlikKontrol.new(riskli_esik: 5, kaldi_esik: 6)
    o = Ogrenci.new(ad: "A", durum: :aktif, devamsiz: 4)
    refute gevsek.riskli?(o)
    refute gevsek.kaldi?(o)
  end
end
