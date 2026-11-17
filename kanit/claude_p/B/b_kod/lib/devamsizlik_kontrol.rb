class DevamsizlikKontrol
  KURALLAR = {
    riskli: ->(ogr) { ogr.devamsizlik >= 3 },
    kaldi: ->(ogr) { ogr.devamsizlik >= 4 },
    onur_adayi: ->(ogr) { ogr.aktif? && ogr.devamsizlik == 0 }
  }.freeze

  def self.durum(ogr)
    KURALLAR.select { |_, kural| kural.call(ogr) }.keys
  end
end
