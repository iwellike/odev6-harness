require "minitest/autorun"
require_relative "../lib/ogrenci"
require_relative "../lib/devamsizlik_kontrol"

class OgrenciTest < Minitest::Test
  def test_durum_sorgulari
    o = Ogrenci.new("Ali", :mezun, 0)
    assert o.mezun?
    refute o.aktif?
    refute o.donduruldu?
  end

  def test_gecersiz_durum_hata_verir
    assert_raises(ArgumentError) { Ogrenci.new("Ali", :silindi, 0) }
  end

  def test_negatif_devamsizlik_hata_verir
    assert_raises(ArgumentError) { Ogrenci.new("Ali", :aktif, -1) }
  end
end

class DevamsizlikKontrolTest < Minitest::Test
  def kontrol(*ogrenciler) = DevamsizlikKontrol.new(ogrenciler)

  def test_sinir_degerleri
    k = kontrol(*(0..5).map { |d| Ogrenci.new("o#{d}", :aktif, d) })
    assert_equal [4, 5], k.kaldi.map(&:devamsiz)  # %40 ve %50
    assert_equal [3],    k.riskli.map(&:devamsiz) # tam %30 kalmaz, riskli
    assert_equal [0],    k.tam_devam.map(&:devamsiz)
  end

  def test_aktif_olmayanlar_kontrol_edilmez
    k = kontrol(Ogrenci.new("Z", :donduruldu, 8), Ogrenci.new("C", :mezun, 0))
    assert_empty k.kaldi
    assert_empty k.riskli
    assert_empty k.tam_devam
  end
end
