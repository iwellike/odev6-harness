class Ogrenci
  DURUMLAR = %i[aktif donduruldu mezun].freeze

  attr_reader :ad, :durum, :devamsizlik

  def initialize(ad:, durum: :aktif, devamsizlik: 0)
    raise ArgumentError, "geçersiz durum: #{durum.inspect}" unless DURUMLAR.include?(durum)
    unless devamsizlik.is_a?(Integer) && (0..10).cover?(devamsizlik)
      raise ArgumentError, "devamsizlik 0..10 aralığında tam sayı olmalı: #{devamsizlik.inspect}"
    end

    @ad = ad
    @durum = durum
    @devamsizlik = devamsizlik
  end

  DURUMLAR.each do |d|
    define_method("#{d}?") { durum == d }
  end
end
