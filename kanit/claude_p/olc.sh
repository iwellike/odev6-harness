#!/usr/bin/env bash
# kanit/claude_p/olc.sh — gerçek "claude -p --output-format json" ile A/B ölçümü.
#
# A: tamamen boş bir klasörde (AGENTS.md/test/kanca YOK), aynı oturumda (--resume)
#    4 ardışık insan turu (A/kosu_A.md'deki promptlarla birebir aynı).
# B: AGENTS.md + .claude/settings.json (PostToolUse kancası: bin/kontrol) + hazır
#    test/ogrenci_test.rb kopyalanmış bir klasörde, TEK insan turu.
#
# Bu betik proje kökündeki lib/, test/, AGENTS.md, bin/, .claude/ dosyalarını
# DEĞİŞTİRMEZ — yalnızca okur/kopyalar. Ajanın ürettiği kod ~/odev6_olcum altında,
# ölçüm kanıtı ise kanit/claude_p/ altında kalır.
#
# Kullanım: bash kanit/claude_p/olc.sh   (Git Bash, proje kökünden veya herhangi bir yerden)
set -uo pipefail

PROJE_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
KANIT_DIR="$PROJE_DIR/kanit/claude_p"
SCRATCH="$HOME/odev6_olcum"
GLOBAL_CLAUDE_MD="$HOME/.claude/CLAUDE.md"
GLOBAL_CLAUDE_MD_BAK="$HOME/.claude/CLAUDE.md.bak"

dur() {
  echo "HATA: $1" >&2
  exit 1
}

echo "== proje   : $PROJE_DIR"
echo "== kanıt   : $KANIT_DIR"
echo "== çalışma : $SCRATCH"

command -v claude >/dev/null || dur "claude CLI bulunamadı"
command -v ruby >/dev/null || dur "ruby bulunamadı"

rm -rf "$SCRATCH"
mkdir -p "$SCRATCH/A" "$SCRATCH/B"
rm -rf "$KANIT_DIR/A" "$KANIT_DIR/B"
mkdir -p "$KANIT_DIR/A" "$KANIT_DIR/B"

if [ -f "$GLOBAL_CLAUDE_MD" ]; then
  mv "$GLOBAL_CLAUDE_MD" "$GLOBAL_CLAUDE_MD_BAK" || dur "~/.claude/CLAUDE.md taşınamadı"
  echo "== ~/.claude/CLAUDE.md geçici olarak .bak yapıldı"
fi
geri_yukle() {
  if [ -f "$GLOBAL_CLAUDE_MD_BAK" ]; then
    mv "$GLOBAL_CLAUDE_MD_BAK" "$GLOBAL_CLAUDE_MD"
    echo "== ~/.claude/CLAUDE.md geri yüklendi"
  fi
}
trap geri_yukle EXIT

json_get() {
  ruby -rjson -e '
    j = JSON.parse(File.read(ARGV[0]))
    path = ARGV[1].split(".")
    v = path.inject(j) { |h, k| h.is_a?(Hash) ? h[k] : nil }
    puts v.nil? ? "" : v
  ' "$1" "$2" 2>/dev/null
}

claude_cagir() {
  # claude_cagir <calisma_dizini> <prompt> <cikti_json> [resume_id]
  local dizin="$1" prompt="$2" cikti="$3" resume="${4:-}"
  local args=(-p "$prompt" --output-format json --permission-mode bypassPermissions)
  [ -n "$resume" ] && args+=(--resume "$resume")
  ( cd "$dizin" && env -u CLAUDECODE claude "${args[@]}" > "$cikti" 2> "$cikti.stderr" )
  local kod=$?
  if [ $kod -ne 0 ]; then
    echo "HATA: claude çağrısı başarısız (çıkış $kod) — $cikti.stderr:" >&2
    cat "$cikti.stderr" >&2
    exit 1
  fi
  local hata
  hata=$(json_get "$cikti" "is_error")
  if [ "$hata" = "true" ]; then
    echo "HATA: $cikti içinde is_error=true:" >&2
    cat "$cikti" >&2
    exit 1
  fi
}

anlik_kod_kopyala() {
  local kaynak="$1" hedef="$2"
  mkdir -p "$hedef"
  cp -r "$kaynak"/. "$hedef"/ 2>/dev/null || true
}

### === A KOŞUSU ===
echo; echo "=== A koşusu başlıyor (boş klasör, kancasız, 4 insan turu) ==="
A_DIR="$SCRATCH/A"

T1="Öğrenci devamsızlık kontrolü yap, devamsızlık sınırı %30'dur."
T2="Python değil, Ruby ile yaz. Öğrencinin ad, durum (aktif/donduruldu/mezun) ve devamsızlık bilgisi olsun; riskli ve kaldı durumlarını ayrı göster. 10 oturum var."
T3="Hash/Struct yerine Ogrenci sınıfı kur (lib/ogrenci.rb). Durum sembol olsun, aktif? mezun? donduruldu? gibi sorgu metotları olsun. Kuralları ayrı bir DevamsizlikKontrol sınıfında topla (lib/devamsizlik_kontrol.rb): riskli, kaldi ve bir de kendi özgün kuralın. Test de yaz."
T4="Kurallar yanlış. riskli = devamsızlık >= 3 (tam 3 riskli SAYILIR, 4 ve üzeri de riskli), kaldi = devamsızlık >= 4. Kurallar ayrık değildir, ikisi birden geçerli olabilir. Durum sorgu metotlarını define_method ile üret. Ruby 3.4 kullanıyoruz (.ruby-version). Test dosyası test/ogrenci_test.rb olsun; bilinmeyen metot (örn. mezn?) çağrısının NoMethodError verdiğini de test et."

echo "-- A tur1"
claude_cagir "$A_DIR" "$T1" "$KANIT_DIR/A/tur1.json"
SID=$(json_get "$KANIT_DIR/A/tur1.json" "session_id")
[ -n "$SID" ] || dur "A tur1: session_id alınamadı"
anlik_kod_kopyala "$A_DIR" "$KANIT_DIR/A/tur1_kod"

echo "-- A tur2 (resume $SID)"
claude_cagir "$A_DIR" "$T2" "$KANIT_DIR/A/tur2.json" "$SID"
anlik_kod_kopyala "$A_DIR" "$KANIT_DIR/A/tur2_kod"

echo "-- A tur3 (resume $SID)"
claude_cagir "$A_DIR" "$T3" "$KANIT_DIR/A/tur3.json" "$SID"
anlik_kod_kopyala "$A_DIR" "$KANIT_DIR/A/tur3_kod"

echo "-- A tur4 (resume $SID)"
claude_cagir "$A_DIR" "$T4" "$KANIT_DIR/A/tur4.json" "$SID"
anlik_kod_kopyala "$A_DIR" "$KANIT_DIR/A/tur4_kod"

if [ -f "$A_DIR/test/ogrenci_test.rb" ]; then
  echo "-- A son test çalıştırılıyor"
  ( cd "$A_DIR" && ruby test/ogrenci_test.rb > "$KANIT_DIR/A/tur4_test_cikti.txt" 2>&1 )
  echo "çıkış: $?" >> "$KANIT_DIR/A/tur4_test_cikti.txt"
else
  echo "(A tur4 sonunda test/ogrenci_test.rb yok)" > "$KANIT_DIR/A/tur4_test_cikti.txt"
fi

### === B KOŞUSU ===
echo; echo "=== B koşusu başlıyor (AGENTS.md + kanca + hazır test, TEK insan turu) ==="
B_DIR="$SCRATCH/B"
mkdir -p "$B_DIR/.claude" "$B_DIR/bin" "$B_DIR/test" "$B_DIR/log"
cp "$PROJE_DIR/AGENTS.md" "$B_DIR/AGENTS.md" || dur "AGENTS.md kopyalanamadı"
cp "$PROJE_DIR/.ruby-version" "$B_DIR/.ruby-version" || dur ".ruby-version kopyalanamadı"
cp "$PROJE_DIR/bin/kontrol" "$B_DIR/bin/kontrol" || dur "bin/kontrol kopyalanamadı"
cp "$PROJE_DIR/bin/izle" "$B_DIR/bin/izle" || dur "bin/izle kopyalanamadı"
chmod +x "$B_DIR/bin/kontrol" "$B_DIR/bin/izle"
cp "$PROJE_DIR/test/ogrenci_test.rb" "$B_DIR/test/ogrenci_test.rb" || dur "test/ogrenci_test.rb kopyalanamadı"
cp "$PROJE_DIR/.claude/settings.json" "$B_DIR/.claude/settings.json" || dur ".claude/settings.json kopyalanamadı"

echo "-- B tek tur"
claude_cagir "$B_DIR" "$T1" "$KANIT_DIR/B/b.json"

if [ -f "$B_DIR/log/kontrol.log" ]; then
  cp "$B_DIR/log/kontrol.log" "$KANIT_DIR/B/kontrol.log"
  OTOMATIK_SAYISI=$(wc -l < "$KANIT_DIR/B/kontrol.log" | tr -d ' ')
else
  echo "(log/kontrol.log oluşmadı — kanca hiç tetiklenmemiş olabilir)" > "$KANIT_DIR/B/kontrol.log"
  OTOMATIK_SAYISI=0
fi

echo "-- B final bin/kontrol doğrulaması (bu manuel çalıştırma otomatik sayıma dahil DEĞİL)"
( cd "$B_DIR" && ./bin/kontrol > "$KANIT_DIR/B/son_kontrol_cikti.txt" 2>&1 )
SON_KOD=$?
{
  echo "çıkış: $SON_KOD"
  echo
  cat "$KANIT_DIR/B/son_kontrol_cikti.txt"
} > "$KANIT_DIR/B/son_kontrol.txt"

anlik_kod_kopyala "$B_DIR" "$KANIT_DIR/B/b_kod"

### === ÖZET ===
echo; echo "=== ozet.md üretiliyor ==="
ruby "$KANIT_DIR/ozet_uret.rb" "$KANIT_DIR" "$OTOMATIK_SAYISI" > "$KANIT_DIR/ozet.md"

echo
echo "TAMAMLANDI"
echo "Otomatik kanca çalışma sayısı (B, tek insan turu içinde): $OTOMATIK_SAYISI"
echo "B final bin/kontrol çıkış kodu: $SON_KOD"
echo "Özet: $KANIT_DIR/ozet.md"
