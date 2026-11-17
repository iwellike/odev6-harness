# A Koşusu — Ham ajan raporları

Her turda ajan aracına gönderilen prompt, ajanın döndürdüğü son rapor ve aracın `<usage>` bloğu aşağıda **olduğu gibi** kopyalandı. Tur 1 dışında her prompt aynı giriş cümlesiyle başlar: "Çalışma klasörün: /home/claude/kosu_A2. Yalnızca bu klasörde çalış. Klasördeki kod "Öğrenci devamsızlık kontrolü yap, devamsızlık sınırı %30'dur." görevi için yazıldı." Tur 2'de ajan Türkçe prompta İngilizce cevap verdi; rapor değiştirilmeden bırakıldı.

---

## Tur 1

**Prompt**
```
Çalışma klasörün: /home/claude/kosu_A2 (boş). Yalnızca bu klasörde çalış.

Görev: Öğrenci devamsızlık kontrolü yap, devamsızlık sınırı %30'dur.
```

**Ajan raporu**
```
Öğrenci devamsızlık kontrolünü yazdım ve çalıştırdım. Çıktı beklendiği gibi.

**Dosya:** `/home/claude/kosu_A2/devamsizlik.py` (Python, kısa ve sade)

**Nasıl çalışıyor:**
- Devamsızlık oranı şöyle hesaplanıyor: `devamsız * 100 / toplam ders`
- Oran %30'un üstündeyse **KALDI**, %30 veya altındaysa **GEÇTİ** yazıyor.
- Öğrenciler kodun içindeki örnek bir listeden (ad, devamsız ders, toplam ders) okunuyor ve bir döngüyle tek tek kontrol ediliyor.

**Çıktı:**
Ali      4/14  %28.6  GECTI
Ayse     5/14  %35.7  KALDI
Mehmet   0/14  %0.0  GECTI
Zeynep   3/10  %30.0  GECTI

**Kontrol etmen gerekenler:**
- Görevde tam %30'un ne sayılacağı belirtilmemişti. Ben "%30'a kadar hak var, %30'u geçen kalır" diye kabul ettim; Zeynep bu yüzden tam %30'da geçti. Senin derste tam %30 da kalma sayılıyorsa, kodda `>` yerine `>=` yazman yeterli.
- Öğrenci listesi örnek veri. İstersen kullanıcıdan girdi alacak şekilde değiştirebilirim.
- Toplam ders 0 girilirse program sıfıra bölme hatası verir. Basit kalsın diye bunu kontrol etmedim.
```

**Usage:** `subagent_tokens: 71666 · tool_uses: 3 · duration_ms: 31370`

---

## Tur 2

**Prompt (giriş cümlesinden sonra)**
```
Kullanıcı geri bildirimi: Python değil, Ruby ile yaz. Öğrencinin ad, durum (aktif/donduruldu/mezun) ve devamsızlık bilgisi olsun; riskli ve kaldı durumlarını ayrı göster. 10 oturum var.
```

**Ajan raporu**
```
I rewrote the program in Ruby as `/home/claude/kosu_A2/devamsizlik.rb` and deleted the old `devamsizlik.py`. It runs and gives the output below.

- **Student data:** each student has a name, a status (`aktif`, `donduruldu` or `mezun`) and a number of absences. There are 10 sessions in total.
- **Limit (%30):** missing 3 sessions (%30) is still allowed. A student with 4 or more absences gets `KALDI` (failed).
- **Risky:** I chose this cutoff myself, because you didn't give one. A student at %20 or more who hasn't failed yet, which means 2 or 3 absences, gets `RISKLI`. To change it, edit the `RISK` constant at the top of the file.
- **Frozen and graduated students:** students marked `donduruldu` or `mezun` are not checked for absences and show as `DEGERLENDIRILMEDI` (not evaluated). This was also my own choice; tell me if you want them checked too.
- **Output:** a table for all students, then a separate list for `RISKLI` and one for `KALDI`.

Ali      aktif        1/10  %10.0   GECTI
Ayse     aktif        2/10  %20.0   RISKLI
Mehmet   aktif        3/10  %30.0   RISKLI
Zeynep   aktif        4/10  %40.0   KALDI
Can      donduruldu   5/10  %50.0   DEGERLENDIRILMEDI
Elif     mezun        0/10  %0.0    DEGERLENDIRILMEDI

RISKLI: Ayse, Mehmet

KALDI: Zeynep

To run it: `ruby devamsizlik.rb`
```

**Usage:** `subagent_tokens: 72958 · tool_uses: 4 · duration_ms: 24248`

---

## Tur 3

**Prompt (giriş cümlesinden sonra)**
```
Kullanıcı geri bildirimi: Hash/Struct yerine Ogrenci sınıfı kur (lib/ogrenci.rb). Durum sembol olsun, aktif? mezun? donduruldu? gibi sorgu metotları olsun. Kuralları ayrı bir DevamsizlikKontrol sınıfında topla (lib/devamsizlik_kontrol.rb): riskli, kaldi ve bir de kendi özgün kuralın. Test de yaz.
```

**Ajan raporu**
```
Struct'ı kaldırdım, yerine `Ogrenci` sınıfını yazdım ve tüm kuralları `DevamsizlikKontrol` sınıfına taşıdım. 10 test var, hepsi geçiyor. Ana programın verdiği sonuçlar eskisiyle aynı. Tek fark, sınırdaki öğrencinin yanına bir uyarı eklenmesi.

**Ogrenci sınıfı (`/home/claude/kosu_A2/lib/ogrenci.rb`)**
- Durum sembol olarak tutuluyor: `:aktif`, `:donduruldu`, `:mezun`.
- `aktif?`, `donduruldu?`, `mezun?` sorgu metotları var.
- Geçersiz durum verilirse hata veriyor. `"aktif"` gibi yazı halinde verilen durum da geçersiz sayılıyor. Negatif devamsızlık da hata veriyor.

**DevamsizlikKontrol sınıfı (`/home/claude/kosu_A2/lib/devamsizlik_kontrol.rb`)**
- Oturum sayısı, sınır ve risk eşiği dışarıdan verilebiliyor. Varsayılanlar 10 oturum, %30 sınır ve %20 risk eşiği.
- `kaldi?`: devamsızlık %30'u geçerse kalır. Tam %30'da hakkı hâlâ var.
- `riskli?`: devamsızlık %20 veya üstündeyse ama henüz kalmadıysa risklidir.
- **Özgün kural, `son_hakta?`:** devamsızlık hakkı tam bitmiş ama öğrenci henüz kalmamış durumda. Bir derse daha gelmezse kalacak, o yüzden ayrı bir uyarı alıyor. Bunun için bir de `kalan_hak` metodu ekledim. Bu metot kaç ders daha kaçırılabileceğini gösteriyor ve sıfırın altına düşmüyor.
- Ayrıca `oran` ve `sonuc` metotları var. Sonuçlar da sembol: `:gecti`, `:riskli`, `:kaldi`, `:degerlendirilmedi`.
- Aktif olmayan öğrenciler hiçbir kurala girmiyor.

**Ana program (`/home/claude/kosu_A2/devamsizlik.rb`)** artık bu iki sınıfı kullanıyor ve listelere "SON HAKTA" başlığını ekliyor. Çıktıda Mehmet (3/10, %30) RISKLI olarak görünüyor, yanında "(SON HAK!)" uyarısı var.

**Testler (`/home/claude/kosu_A2/test/devamsizlik_test.rb`)** Ruby'nin kendi test kütüphanesi Minitest ile yazıldı. Şunları kontrol ediyor:
- durum sorgularını ve hatalı girişleri,
- %20 ve %30 sınır değerlerini,
- riskli ile kaldı'nın aynı anda olamayacağını,
- aktif olmayan öğrencilerin değerlendirilmediğini,
- `kalan_hak` ve `son_hakta?` kuralını,
- farklı bir oturum sayısını: 14 oturumda hak 4 ders oluyor, 5. devamsızlıkta öğrenci kalıyor.

Testleri ve programı çalıştırmak için:
ruby test/devamsizlik_test.rb
ruby devamsizlik.rb
```

**Usage:** `subagent_tokens: 76925 · tool_uses: 7 · duration_ms: 62176`

---

## Tur 4

**Prompt (giriş cümlesinden sonra)**
```
Kullanıcı geri bildirimi: Kurallar yanlış. riskli = devamsızlık >= 3 (tam 3 riskli SAYILIR, 4 ve üzeri de riskli), kaldi = devamsızlık >= 4. Riskli ile kaldı ayrık değil, 4 devamsızlıkta ikisi birden döner. 2 devamsızlık riskli değil; %20 eşiğini kaldır. Özellik adı devamsizlik olsun ve 0..10 aralığında olsun. Durum sorgu metotlarını define_method ile üret. Ruby 3.4 kullanıyoruz (.ruby-version). Test dosyası test/ogrenci_test.rb olsun; bilinmeyen metot (örn. mezn?) çağrısının NoMethodError verdiğini de test et.
```

**Ajan raporu**
```
Kuralları istediğin gibi düzelttim. 14 testin hepsi geçiyor (0 hata), ama sistemde Ruby 3.4 kurulu değil (sadece 3.1.6, 3.2.6 ve 3.3.6 var). Bu yüzden testleri 3.3.6'da, 3.4'te gelen uyarıları da gösterecek ayarlarla çalıştırdım; hiç uyarı çıkmadı. Gerçek 3.4 ile ayrıca çalıştırılmadı.

**Kurallar** (`lib/devamsizlik_kontrol.rb`)
- `riskli?`: devamsızlık >= 3. Tam 3 riskli sayılıyor, 4 ve üzeri de riskli.
- `kaldi?`: devamsızlık >= 4.
- %20 eşiği ve `risk` parametresi kaldırıldı; 2 devamsızlık artık riskli değil.
- Riskli ile kaldı artık ayrık değil. Bunu göstermek için `etiketler` metodunu ekledim: 4 devamsızlıkta `[:riskli, :kaldi]`, 3'te `[:riskli]`, 2'de `[]` döner.
- `sonuc` hâlâ tek bir sonuç veriyor ve en ağır olanı seçiyor (kaldı > riskli > geçti). Bu yüzden 4 devamsızlıklı öğrenci tabloda sadece "KALDI" görünüyor, ama RISKLI listesinde de yer alıyor.
- 10 oturum sabit oldu (`OTURUM = 10`). Farklı oturum sayısı verilebilen eski yapı kaldırıldı, çünkü kurallar artık doğrudan devamsızlık sayısına bakıyor.
- `son_hakta?` "riskli ama henüz kalmadı" oldu, yani tam 3 devamsızlık.

**Öğrenci sınıfı** (`lib/ogrenci.rb`)
- Özelliğin adı `devamsiz` yerine `devamsizlik` oldu.
- Değer 0..10 aralığında tam sayı olmak zorunda; değilse `ArgumentError` verir.
- `aktif?`, `donduruldu?`, `mezun?` metotları durum listesinden `define_method` ile üretiliyor. `method_missing` kullanmadığım için `mezn?` gibi bilinmeyen bir metot normal şekilde `NoMethodError` verir.

**Diğer dosyalar**
- `devamsizlik.rb` yeni ada ve kurallara göre güncellendi. Çıktıda Mehmet (3) "RISKLI (SON HAK!)", Zeynep (4) "KALDI"; RISKLI listesinde Mehmet ve Zeynep, KALDI listesinde Zeynep var.
- `.ruby-version` dosyası klasörde yoktu; `3.4` içeriğiyle oluşturdum.
- Test dosyası artık `test/ogrenci_test.rb`; eski `test/devamsizlik_test.rb` silindi. Testler 2/3/4/10 sınır değerlerini, ikisinin birlikte dönmesini, 0..10 aralığını (-1, 11, 2.5 ve "3" reddediliyor), `define_method` ile üretilen metotları ve `mezn?` çağrısının `NoMethodError` verdiğini kontrol ediyor.

Bir de şunu bilmen gerekiyor: eskiden olduğu gibi sadece aktif öğrenciler değerlendiriliyor. Dondurulmuş ya da mezun öğrenci 9 devamsızlıkla bile riskli veya kaldı sayılmıyor. Geri bildirimin bu konuya değinmediği için dokunmadım; bu öğrencilerin de değerlendirilmesini istiyorsan değiştirmem gerekir.
```

**Usage:** `subagent_tokens: 81560 · tool_uses: 8 · duration_ms: 67059`
