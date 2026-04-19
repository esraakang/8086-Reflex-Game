# 8086 Assembly - Refleks Oyunu

Bu proje, Marmara Üniversitesi Bilgisayar Mühendisliği dersi kapsamında geliştirilmiş bir refleks ölçme oyunudur. Emu8086 emülatörü ile uyumlu çalışacak şekilde 8086 Assembly diliyle yazılmıştır.

## Oyun Kuralları ve Eklenen Mekanikler

* **Rastgele Harf Üretimi:** Ekrana gelecek komutlar, **LCG (Linear Congruential Generator)** algoritması kullanılarak sistem saati (Tick) ile harmanlanıp rastgele üretilmektedir.
* **Zorluk Artışı:** Oyuncu doğru tuşa bastıkça bir sonraki harfin ekranda kalma süresi (timeout) giderek kısalır ve oyun hızlanır.
* **Oynanışı İyileştirme (Combo):** Üst üste 3 doğru cevap verildiğinde ekranda özel **COMBO!** bildirimi çıkar.
* **Skor ve Hata:** Oyuncu 3 hata yaptığında elenir. Oyun sonunda hesaplanan ortalama tepki süresi **Sistem Tick'i** (1 Tick = ~55ms) cinsinden ekrana yazdırılır.

## Nasıl Çalıştırılır?
1. Emu8086 programını açın.
2. `reflex_game.asm` dosyasını yükleyin.
3. `emulate` butonuna basın ve ardından `run` diyerek oyunu başlatın.
