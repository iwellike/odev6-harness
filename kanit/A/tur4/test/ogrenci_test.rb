require "minitest/autorun"
require_relative "../lib/devamsizlik_kontrol"

class OgrenciTest < Minitest::Test
  def test_durum_sorgulari
    assert Ogrenci.new("A", :aktif, 0).aktif?
    assert Ogrenci.new("B", :mezun, 0).mezun?
    assert Ogrenci.new("C", :donduruldu, 0).donduruldu?
    refute Ogrenci.new("A", :aktif, 0).mezun?
  end

  def test_durum_metotlari_define_method_ile_uretilir
    Ogrenci::DURUMLAR.each do |d|
      assert Ogrenci.public_method_defined?(:"#{d}?")
    end
  end

  def test_bilinmeyen_durum_metodu_nomethoderror_verir
    o = Ogrenci.new("A", :aktif, 0)
    assert_raises(NoMethodError) { o.mezn? }
    refute o.respond_to?(:mezn?)
  end

  def test_devamsizlik_ozelligi
    assert_equal 7, Ogrenci.new("A", :aktif, 7).devamsizlik
  end

  def test_devamsizlik_sinirlari
    assert_equal 0,  Ogrenci.new("A", :aktif, 0).devamsizlik
    assert_equal 10, Ogrenci.new("A", :aktif, 10).devamsizlik
    assert_raises(ArgumentError) { Ogrenci.new("X", :aktif, -1) }
    assert_raises(ArgumentError) { Ogrenci.new("X", :aktif, 11) }
    assert_raises(ArgumentError) { Ogrenci.new("X", :aktif, 2.5) }
    assert_raises(ArgumentError) { Ogrenci.new("X", :aktif, "3") }
  end

  def test_gecersiz_durum
    assert_raises(ArgumentError) { Ogrenci.new("X", "aktif", 0) }  # string kabul edilmez
    assert_raises(ArgumentError) { Ogrenci.new("X", :izinli, 0) }
  end
end

class DevamsizlikKontrolTest < Minitest::Test
  def setup
    @k = DevamsizlikKontrol.new
  end

  def aktif(n) = Ogrenci.new("T", :aktif, n)

  def test_riskli_esigi
    refute @k.riskli?(aktif(2))   # 2 riskli degil
    assert @k.riskli?(aktif(3))   # tam 3 riskli sayilir
    assert @k.riskli?(aktif(4))
    assert @k.riskli?(aktif(10))
  end

  def test_kaldi_esigi
    refute @k.kaldi?(aktif(3))
    assert @k.kaldi?(aktif(4))
    assert @k.kaldi?(aktif(10))
  end

  def test_riskli_ve_kaldi_ayrik_degil
    assert_equal [],               @k.etiketler(aktif(2))
    assert_equal [:riskli],        @k.etiketler(aktif(3))
    assert_equal %i[riskli kaldi], @k.etiketler(aktif(4))
  end

  def test_sonuc_ozeti
    assert_equal :gecti,  @k.sonuc(aktif(2))
    assert_equal :riskli, @k.sonuc(aktif(3))
    assert_equal :kaldi,  @k.sonuc(aktif(4))
  end

  def test_aktif_olmayanlar_degerlendirilmez
    [Ogrenci.new("C", :donduruldu, 9), Ogrenci.new("E", :mezun, 9)].each do |o|
      assert_equal :degerlendirilmedi, @k.sonuc(o)
      assert_equal [], @k.etiketler(o)
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

  def test_son_hakta
    refute @k.son_hakta?(aktif(2))
    assert @k.son_hakta?(aktif(3))   # riskli, henuz kalmadi
    refute @k.son_hakta?(aktif(4))   # zaten kaldi
  end

  def test_oran
    assert_in_delta 30.0, @k.oran(aktif(3))
  end
end
