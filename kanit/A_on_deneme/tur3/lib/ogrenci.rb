class Ogrenci
  DURUMLAR = %i[aktif donduruldu mezun].freeze

  attr_reader :ad, :durum, :devamsiz

  def initialize(ad, durum, devamsiz)
    raise ArgumentError, "gecersiz durum: #{durum}" unless DURUMLAR.include?(durum)
    raise ArgumentError, "devamsizlik negatif olamaz" if devamsiz.negative?

    @ad = ad
    @durum = durum
    @devamsiz = devamsiz
  end

  def aktif?      = durum == :aktif
  def donduruldu? = durum == :donduruldu
  def mezun?      = durum == :mezun
end
