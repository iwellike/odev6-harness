# A0 Ön Deneme — Ham ajan raporları

Tek konuşma içinde yapıldı: tur 1 yeni oturum, tur 2 ve 3 aynı ajana devam mesajı. Devam mesajlarında araç `<usage>` bloğu döndürmedi; bu yüzden ölçümlü A koşusu (`../A/`) her tur ayrı oturumla tekrarlandı.

## Tur 1
**Prompt**
```
Çalışma klasörün: /home/claude/kosu_A (boş). Yalnızca bu klasörde çalış.

Görev: Öğrenci devamsızlık kontrolü yap, devamsızlık sınırı %30'dur.
```
**Ajan raporu**
```
I wrote a short Python script that checks attendance against the 30% limit and ran it. Since no real student list was given, it uses 4 made-up sample students.

**File:** `/home/claude/kosu_A/devamsizlik.py`

**How it works:** For each student it divides missed classes by total classes. If the result is above 30%, the student fails (KALDI); otherwise they pass (GEÇTİ).

**Output:**
Ali      10/42 = % 23.8 -> GECTI
Ayse     13/42 = % 31.0 -> KALDI
Mehmet   15/42 = % 35.7 -> KALDI
Zeynep   12/40 = % 30.0 -> GECTI

**Decision for you:** I assumed a student fails only when absences go *over* 30%, so exactly 30% passes (Zeynep in the sample). That's how the rule is commonly worded, but I haven't checked it against your school's regulations, so please confirm. If exactly 30% should also fail, change `oran > SINIR` to `oran >= SINIR` in the `kontrol` function.

To use your own data, replace the `ogrenciler` list with real values in the form (name, total classes, missed classes). The script doesn't check for a total of 0 classes, which would crash it.
```
**Usage:** `subagent_tokens: 71338 · tool_uses: 3 · duration_ms: 28163`

## Tur 2
**Devam mesajı:** `Python değil, Ruby ile yaz. Öğrencinin ad, durum (aktif/donduruldu/mezun) ve devamsızlık bilgisi olsun; riskli ve kaldı durumlarını ayrı göster. 10 oturum var.`

**Ajan raporu (özet değil, ilgili kısımlar aynen)**
```
Devamsızlığı %30'u aşan, yani 4 veya daha fazla oturuma gelmeyen öğrenci **KALDI** olur.
...
- **Riskli tanımı:** "Bir devamsızlık daha yaparsa kalır" olarak aldım. 10 oturumda bu sadece tam 3 devamsızlık demek.
- **Tam %30:** Sınırda olan öğrenci kalmıyor, riskli sayılıyor (Ayse). Tam %30 da kalsın istersen kaldı kontrolündeki `>` işaretini `>=` yap.
- **Donduruldu ve mezun öğrenciler:** Bunları kontrol dışı bıraktım, listelere girmiyorlar.
```

## Tur 3
**Devam mesajı:** `Hash yerine Ogrenci sınıfı kur (lib/ogrenci.rb). Durum sembol olsun, aktif? mezun? donduruldu? gibi sorgu metotları olsun. Kuralları ayrı bir DevamsizlikKontrol sınıfında topla (lib/devamsizlik_kontrol.rb): riskli, kaldi ve bir de kendi özgün kuralın. Test de yaz.`

**Ajan raporu (ilgili kısımlar aynen)**
```
- `kaldi`: devamsızlığı %30'u aşanlar, yani 4 veya daha fazla oturuma gelmeyenler.
- `riskli`: henüz kalmamış ama bir devamsızlık daha yaparsa kalacak olanlar. 10 oturumda bu tam 3 devamsızlık demek.
- `tam_devam` (benim eklediğim kural): hiç devamsızlığı olmayan aktif öğrenciler.
```
