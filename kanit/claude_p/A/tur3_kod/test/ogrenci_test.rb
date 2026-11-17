require "minitest/autorun"
require_relative "../lib/ogrenci"

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

  def test_gecmis_uyari_varsayilan_false
    o = Ogrenci.new(ad: "A", durum: :aktif, devamsiz: 0)
    refute o.gecmis_uyari?
  end
end
