# Tek bir ogrenciyi temsil eder. Durum sembol olarak tutulur.
class Ogrenci
  DURUMLAR = %i[aktif donduruldu mezun].freeze

  attr_reader :ad, :durum, :devamsiz

  def initialize(ad, durum, devamsiz)
    raise ArgumentError, "Gecersiz durum: #{durum.inspect}" unless DURUMLAR.include?(durum)
    raise ArgumentError, "Devamsizlik negatif olamaz" if devamsiz.negative?

    @ad = ad
    @durum = durum
    @devamsiz = devamsiz
  end

  def aktif?      = durum == :aktif
  def donduruldu? = durum == :donduruldu
  def mezun?      = durum == :mezun
end
