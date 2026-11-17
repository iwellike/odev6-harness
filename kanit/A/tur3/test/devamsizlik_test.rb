require "minitest/autorun"
require_relative "../lib/devamsizlik_kontrol"

class OgrenciTest < Minitest::Test
  def test_durum_sorgulari
    assert Ogrenci.new("A", :aktif, 0).aktif?
    assert Ogrenci.new("B", :mezun, 0).mezun?
    assert Ogrenci.new("C", :donduruldu, 0).donduruldu?
    refute Ogrenci.new("A", :aktif, 0).mezun?
  end

  def test_gecersiz_durum_ve_negatif_devamsizlik
    assert_raises(ArgumentError) { Ogrenci.new("X", "aktif", 0) }  # string kabul edilmez
    assert_raises(ArgumentError) { Ogrenci.new("X", :izinli, 0) }
    assert_raises(ArgumentError) { Ogrenci.new("X", :aktif, -1) }
  end
end

class DevamsizlikKontrolTest < Minitest::Test
  def setup
    @k = DevamsizlikKontrol.new(oturum: 10, sinir: 30, risk: 20)
  end

  def aktif(n) = Ogrenci.new("T", :aktif, n)

  def test_sonuclar_sinir_degerlerinde
    assert_equal :gecti,  @k.sonuc(aktif(1))
    assert_equal :riskli, @k.sonuc(aktif(2))   # %20 risk esigi dahil
    assert_equal :riskli, @k.sonuc(aktif(3))   # %30 tam sinir: kalmaz
    assert_equal :kaldi,  @k.sonuc(aktif(4))   # %40 > %30
  end

  def test_riskli_ve_kaldi_ayrik
    refute @k.riskli?(aktif(4))
    refute @k.kaldi?(aktif(3))
  end

  def test_aktif_olmayanlar_degerlendirilmez
    [Ogrenci.new("C", :donduruldu, 9), Ogrenci.new("E", :mezun, 9)].each do |o|
      assert_equal :degerlendirilmedi, @k.sonuc(o)
      refute @k.kaldi?(o)
      refute @k.riskli?(o)
      refute @k.son_hakta?(o)
    end
  end

  def test_kalan_hak
    assert_equal 3, @k.kalan_hak(aktif(0))
    assert_equal 1, @k.kalan_hak(aktif(2))
    assert_equal 0, @k.kalan_hak(aktif(3))
    assert_equal 0, @k.kalan_hak(aktif(5))   # negatife dusmez
  end

  def test_son_hakta_ozgun_kural
    refute @k.son_hakta?(aktif(2))
    assert @k.son_hakta?(aktif(3))   # hakki bitti, henuz kalmadi
    refute @k.son_hakta?(aktif(4))   # zaten kaldi
  end

  def test_oran
    assert_in_delta 30.0, @k.oran(aktif(3))
  end

  def test_farkli_oturum_sayisi
    k = DevamsizlikKontrol.new(oturum: 14)   # 14 * %30 = 4.2 -> 4 hak
    assert_equal :riskli, k.sonuc(aktif(4))
    assert k.son_hakta?(aktif(4))
    assert_equal :kaldi, k.sonuc(aktif(5))
  end

  def test_gecersiz_oturum
    assert_raises(ArgumentError) { DevamsizlikKontrol.new(oturum: 0) }
  end
end
