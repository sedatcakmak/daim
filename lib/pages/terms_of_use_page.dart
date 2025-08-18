import 'package:flutter/material.dart';
import 'package:daim/widgets/bottom.dart';
import 'package:daim/widgets/header.dart';

class TermsOfUse extends StatelessWidget {
  const TermsOfUse({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: "Kullanım Şartları"),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: -1),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Text(
                      "Kullanım Şartları",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text("Son Güncelleme: 24 Nisan 2025"),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Bu Kullanım Şartları, "Daim" mobil uygulamasını ("Uygulama") sunan cakmak studios ("Sağlayıcı") ile Uygulamayı yükleyen ve kullanan siz ("Kullanıcı") arasında geçerlidir.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text("Şartların Kabulu",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(
                "Uygulamayı indirmek, yüklemek veya kullanmakla bu şartları kabul etmiş sayılırsınız. Kabul etmediğiniz takdirde Uygulamayı kullanmayınız.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text("Lisans ve Kullanım",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(
                "Sağlayıcı size, kişisel, ticari olmayan kullanım amacıyla Uygulamayı geri alınamaz, münhasır olmayan, devredilemez bir lisansla kullanma hakkı verir.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text("Gizlilik ve Veri Koruma",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(
                "Uygulama; sağladığınız kişisel verileri, yalnızca Hizmet’in sağlanması ve iyileştirilmesi amacıyla işler. Detaylar için lütfen Uygulama içindeki Gizlilik Politikası’nı inceleyin. ",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text("Sorumluluk Sınırlandırması",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(
                "Sağlayıcı, Uygulamanın kesintisiz, hatasız çalışacağı veya belirli bir amaca uygun olduğu konusunda garanti vermez. Kullanıcı, Uygulama kullanımından doğabilecek doğrudan ya da dolaylı zararları kendi sorumluluğunda karşılar.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text("Şartlarda Değişiklik",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(
                "cakmak studios, bu şartları önceden bildirimde bulunmaksızın güncelleyebilir. Güncellenen metin Uygulama’da yayımlandığı anda yürürlüğe girer; kullanımınıza devam ederek yeni şartları kabul etmiş olursunuz.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text("İletişim",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(
                "Her türlü soru, talep veya itirazınız için\ne-posta: support@daimapp.com\nadresinden bize ulaşabilirsiniz.",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
