#!/usr/bin/env ruby
# kanit/claude_p/ozet_uret.rb — olc.sh'ın ürettiği A/tur*.json + B/b.json dosyalarından
# kanit/claude_p/ozet.md tablosunu üretir. Kullanım: ruby ozet_uret.rb <kanit_dir> <otomatik_kanca_sayisi>
require "json"

def load(path)
  JSON.parse(File.read(path))
rescue StandardError
  nil
end

def d(v)
  v.nil? ? "ölçülemedi" : v
end

kanit_dir = ARGV[0]
otomatik = ARGV[1]

a_files = (1..4).map { |n| ["A#{n}", "#{kanit_dir}/A/tur#{n}.json"] }
b_files = [["B", "#{kanit_dir}/B/b.json"]]

rows = (a_files + b_files).map do |label, path|
  j = load(path)
  u = (j && j["usage"]) || {}
  {
    label: label,
    path: path,
    bulundu: !j.nil?,
    num_turns: j && j["num_turns"],
    input: u["input_tokens"],
    cache_read: u["cache_read_input_tokens"],
    cache_creation: u["cache_creation_input_tokens"],
    output: u["output_tokens"],
    cost: j && j["total_cost_usd"],
    is_error: j && j["is_error"],
  }
end

puts "# Gerçek Claude Code ölçümü (claude -p --output-format json)"
puts
puts "| Tur | num_turns | input | cache_read | cache_creation | output | total_cost_usd | is_error |"
puts "|---|---:|---:|---:|---:|---:|---:|---|"

toplam = { num_turns: 0, input: 0, cache_read: 0, cache_creation: 0, output: 0, cost: 0.0 }
eksik = false

rows.each do |r|
  unless r[:bulundu]
    puts "| #{r[:label]} | ölçülemedi (#{r[:path]} yok) | | | | | | |"
    eksik = true
    next
  end
  puts "| #{r[:label]} | #{d(r[:num_turns])} | #{d(r[:input])} | #{d(r[:cache_read])} | #{d(r[:cache_creation])} | #{d(r[:output])} | #{d(r[:cost])} | #{d(r[:is_error])} |"
  next if r[:label] == "B"

  toplam[:num_turns] += r[:num_turns] || 0
  toplam[:input] += r[:input] || 0
  toplam[:cache_read] += r[:cache_read] || 0
  toplam[:cache_creation] += r[:cache_creation] || 0
  toplam[:output] += r[:output] || 0
  toplam[:cost] += r[:cost] || 0.0
end

a_bulundu = rows[0..3].all? { |r| r[:bulundu] }
b_bulundu = rows[4][:bulundu]

if a_bulundu
  puts "| **A toplam** | #{toplam[:num_turns]} | #{toplam[:input]} | #{toplam[:cache_read]} | #{toplam[:cache_creation]} | #{toplam[:output]} | #{toplam[:cost].round(6)} | |"
else
  puts "| **A toplam** | ölçülemedi | | | | | | |"
end

puts
puts "## A toplam ile B farkı"
puts

if a_bulundu && b_bulundu
  b = rows[4]
  [[:num_turns, "num_turns"], [:input, "input"], [:cache_read, "cache_read"], [:output, "output"]].each do |key, ad|
    av = toplam[key].to_f
    bv = (b[key] || 0).to_f
    fark = av - bv
    yuzde = av.zero? ? 0 : (fark / av * 100).round(1)
    puts "- #{ad}: A toplam=#{toplam[key]}, B=#{d(b[key])}, fark=#{fark} (A'ya göre %#{yuzde})"
  end
  av = toplam[:cost].to_f
  bv = (b[:cost] || 0).to_f
  fark = (av - bv).round(6)
  yuzde = av.zero? ? 0 : (fark / av * 100).round(1)
  puts "- total_cost_usd: A toplam=#{toplam[:cost].round(6)}, B=#{d(b[:cost])}, fark=#{fark} (A'ya göre %#{yuzde})"
  puts
  puts "> Not: total_cost_usd, Claude Pro abonelik üzerinden çalıştırıldığında API karşılığı maliyet TAHMİNİDİR (gerçek Pro faturasına ek ücret yansımaz)."
else
  puts "Karşılaştırma yapılamadı: #{eksik || !b_bulundu ? "bazı JSON dosyaları eksik/ölçülemedi" : "bilinmeyen durum"}."
end

puts
puts "## Otomatik kanca çalışması"
puts
if otomatik && otomatik.to_s =~ /\A\d+\z/
  puts "B koşusunda, tek insan turu içinde `bin/kontrol` kancası **#{otomatik}** kez otomatik çalıştı (kaynak: `kanit/claude_p/B/kontrol.log`)."
else
  puts "ölçülemedi (kanit/claude_p/B/kontrol.log okunamadı)."
end
