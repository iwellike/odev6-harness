class Ogrenci
  DURUMLAR = %i[aktif donduruldu mezun].freeze

  attr_reader :ad, :durum, :devamsiz, :gecmis_uyari

  DURUMLAR.each do |d|
    define_method(:"#{d}?") { durum == d }
  end

  def initialize(ad:, durum:, devamsiz:, gecmis_uyari: false)
    raise ArgumentError, "geçersiz durum: #{durum.inspect}" unless DURUMLAR.include?(durum)

    @ad = ad
    @durum = durum
    @devamsiz = devamsiz
    @gecmis_uyari = gecmis_uyari
  end

  def gecmis_uyari?
    @gecmis_uyari
  end
end
