# Tek bir ogrenciyi temsil eder. Durum sembol olarak tutulur.
class Ogrenci
  DURUMLAR = %i[aktif donduruldu mezun].freeze
  DEVAMSIZLIK_ARALIGI = (0..10)

  attr_reader :ad, :durum, :devamsizlik

  def initialize(ad, durum, devamsizlik)
    raise ArgumentError, "Gecersiz durum: #{durum.inspect}" unless DURUMLAR.include?(durum)
    unless devamsizlik.is_a?(Integer) && DEVAMSIZLIK_ARALIGI.cover?(devamsizlik)
      raise ArgumentError, "Devamsizlik #{DEVAMSIZLIK_ARALIGI} araliginda tam sayi olmali: #{devamsizlik.inspect}"
    end

    @ad = ad
    @durum = durum
    @devamsizlik = devamsizlik
  end

  # aktif?, donduruldu?, mezun? metotlari DURUMLAR listesinden uretilir.
  DURUMLAR.each do |d|
    define_method(:"#{d}?") { durum == d }
  end
end
