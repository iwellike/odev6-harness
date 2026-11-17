SINIR = 0.30  # devamsizlik siniri %30


def kontrol(toplam_ders, devamsiz):
    oran = devamsiz / toplam_ders
    return oran, oran > SINIR  # %30'u ASARSA kalir


ogrenciler = [
    ("Ali", 42, 10),
    ("Ayse", 42, 13),
    ("Mehmet", 42, 15),
    ("Zeynep", 40, 12),
]

for ad, toplam, devamsiz in ogrenciler:
    oran, kaldi = kontrol(toplam, devamsiz)
    durum = "KALDI" if kaldi else "GECTI"
    print(f"{ad:8} {devamsiz:2}/{toplam} = %{oran * 100:5.1f} -> {durum}")
