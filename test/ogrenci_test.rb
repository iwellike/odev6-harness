require "minitest/autorun"
require_relative "../lib/ogrenci"
require_relative "../lib/devamsizlik_kontrol"

class OgrenciTest < Minitest::Test
  def ogr(devamsizlik, durum: :aktif)
    Ogrenci.new(ad: "Ayşe", durum: durum, devamsizlik: devamsizlik)
  end

  def durum(devamsizlik, durum: :aktif)
    DevamsizlikKontrol.durum(ogr(devamsizlik, durum: durum))
  end

  # --- Sözleşme ---
  def test_varsayilanlar_ve_okuyucular
    o = Ogrenci.new(ad: "Ali")
    assert_equal "Ali", o.ad
    assert_equal :aktif, o.durum
    assert_equal 0, o.devamsizlik
  end

  def test_durum_sorgulari_define_method_ile_gercekten_var
    o = ogr(0, durum: :mezun)
    assert o.mezun?
    refute o.aktif?
    refute o.donduruldu?
    %i[aktif? donduruldu? mezun?].each do |m|
      assert_includes Ogrenci.public_instance_methods(false), m
      assert_respond_to o, m
    end
  end

  def test_bilinmeyen_metot_NoMethodError_verir
    o = ogr(0)
    refute_respond_to o, :mezn?
    assert_raises(NoMethodError) { o.mezn? }
  end

  def test_method_missing_tanimlanmamis
    assert_equal BasicObject, Ogrenci.instance_method(:method_missing).owner
    refute Ogrenci.private_method_defined?(:respond_to_missing?, false)
    refute Ogrenci.method_defined?(:respond_to_missing?, false)
  end

  def test_standart_siniflara_monkey_patch_yok
    [3, "Ayşe", :aktif].each do |deger|
      %i[riskli? kaldi? aktif? mezun?].each { |m| refute_respond_to deger, m }
    end
  end

  def test_gecersiz_durum_ArgumentError
    assert_raises(ArgumentError) { ogr(0, durum: :silindi) }
    assert_raises(ArgumentError) { ogr(0, durum: "aktif") }
  end

  def test_devamsizlik_0_10_araliginda_tam_sayi
    [-1, 11, 2.5, "3", nil].each do |d|
      assert_raises(ArgumentError, "devamsizlik=#{d.inspect}") { ogr(d) }
    end
    assert_equal 10, ogr(10).devamsizlik
  end

  # --- Kural: riskli (>= 3) ---
  def test_devamsizlik_2_riskli_degil
    assert_empty durum(2)
  end

  def test_devamsizlik_tam_3_ise_riskli_olmali
    assert_includes durum(3), :riskli
    refute_includes durum(3), :kaldi
  end

  # --- Kural: kaldi (>= 4) ---
  def test_devamsizlik_4_ise_hem_riskli_hem_kaldi
    assert_equal %i[riskli kaldi], durum(4)
  end

  def test_devamsizlik_10_ise_hem_riskli_hem_kaldi
    assert_equal %i[riskli kaldi], durum(10)
  end

  def test_kurallar_duruma_bakmaz
    assert_equal %i[riskli kaldi], durum(5, durum: :donduruldu)
  end

  # --- Kural: onur_adayi (özgün) ---
  def test_aktif_ve_sifir_devamsizlik_onur_adayi
    assert_equal [:onur_adayi], durum(0)
  end

  def test_1_devamsizlik_onur_adayi_degil
    assert_empty durum(1)
  end

  def test_mezun_veya_donduruldu_onur_adayi_olamaz
    assert_empty durum(0, durum: :mezun)
    assert_empty durum(0, durum: :donduruldu)
  end

  # --- Tüm sınır taraması 0..10 ---
  def test_sinir_taramasi
    beklenen = { 0 => [:onur_adayi], 1 => [], 2 => [], 3 => [:riskli] }
    (4..10).each { |d| beklenen[d] = %i[riskli kaldi] }
    beklenen.each { |d, b| assert_equal b, durum(d), "devamsizlik=#{d}" }
  end

  def test_ogrenci_ve_devamsizlik_kontrol_sinif
    assert_instance_of Class, Ogrenci
    assert_instance_of Class, DevamsizlikKontrol
  end

  def test_kurallar_acik_hash
    assert_equal %i[riskli kaldi onur_adayi], DevamsizlikKontrol::KURALLAR.keys
    assert DevamsizlikKontrol::KURALLAR.values.all? { |k| k.respond_to?(:call) }
  end
end
