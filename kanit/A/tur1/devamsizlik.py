# Ogrenci devamsizlik kontrolu - sinir %30
SINIR = 30  # yuzde


def devamsizlik_orani(devamsiz, toplam):
    return devamsiz * 100 / toplam


def durum(devamsiz, toplam):
    # %30 dahil hakki var; %30'u gecen kalir
    if devamsizlik_orani(devamsiz, toplam) > SINIR:
        return "KALDI"
    return "GECTI"


ogrenciler = [
    ("Ali", 4, 14),
    ("Ayse", 5, 14),
    ("Mehmet", 0, 14),
    ("Zeynep", 3, 10),   # tam %30 sinirinda
]

for ad, devamsiz, toplam in ogrenciler:
    oran = devamsizlik_orani(devamsiz, toplam)
    print(f"{ad:<8} {devamsiz}/{toplam}  %{oran:.1f}  {durum(devamsiz, toplam)}")
