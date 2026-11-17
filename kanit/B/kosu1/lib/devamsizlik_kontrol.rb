module DevamsizlikKontrol
  # 10 oturum, sınır %30 → 3 devamsızlık riskli, 4 ve üzeri kaldı.
  KURALLAR = {
    riskli: ->(o) { o.devamsizlik >= 3 },
    kaldi: ->(o) { o.devamsizlik >= 4 },
    onur_adayi: ->(o) { o.aktif? && o.devamsizlik.zero? }
  }.freeze

  def self.durum(ogr)
    KURALLAR.select { |_, kural| kural.call(ogr) }.keys
  end
end
