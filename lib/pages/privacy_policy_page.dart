import 'package:flutter/material.dart';
import 'package:daim/widgets/bottom.dart';
import 'package:daim/widgets/header.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Gizlilik Politikası"),
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
                      "Gizlilik Politikası",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text("Son Güncelleme: 24 Nisan 2025"),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Bu Gizlilik Politikası, "Daim" mobil uygulamasını ("Uygulama") kullananların kişisel verilerinin nasıl toplandığını, kullanıldığını ve korunduğunu açıklar. Politikayı kabul etmiyorsanız lütfen uygulamayı kullanmayınız.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                "Toplanan Veriler",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                "Zorunlu Veriler: Kullanıcı kaydı sırasında talep edilen ad, soyad, e-posta, telefon ve konum bilgisi.\nKullanım Verileri: Uygulama kullanımına ilişkin işlem kayıtları, tercih edilen dil ve teknik çerezler (analytics).",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                "Veri Kullanımı",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                "Toplanan veriler;\n- Hizmet sunumu ve sipariş yönetimi,\n- Kullanıcı deneyimini kişiselleştirme,\n- Destek taleplerine yanıt verme,\n- Uygulama performansını artırma ve hata düzeltme amaçlarıyla kullanılır.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                "Veri Paylaşımı",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                "cakmak studios, kullanıcı verilerini üçüncü taraflarla paylaşmaz. Yalnızca;\n- Yasal yükümlülükler,\n- Hizmet sağlayıcı iş ortakları (ör. ödeme işlemleri)\ndurumlarında asgari düzeyde ve güvenli iletişim protokolleriyle aktarım yapabilir.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                "Veri Güvenliği",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                "Tüm kişisel veriler, şifreleme ve güvenlik duvarlarıyla korunur.\nYetkisiz erişime, kayba veya kötüye kullanıma karşı teknik ve organizasyonel önlemler uygulanır.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                "Çocukların Gizliliği",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                "Uygulama, 18 yaşın altındaki çocuklardan kasıtlı olarak veri toplamaz. Eğer ebeveyn izni olmadan veri toplandığı tespit edilirse, söz konusu veri derhal silinir.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                "Üçüncü Taraf Bağlantıları",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                "Uygulama içinde yer alan reklam veya analiz araçları, kendi gizlilik politikalarına sahiptir. Bu araçları kullanmadan önce ilgili politikaları inceleyiniz.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                "Politika Güncellemeleri",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                "cakmak studios, bu politikayı önceden bildirimde bulunmaksızın güncelleyebilir. Güncellenen metin Uygulama’da yayımlandığı anda yürürlüğe girer; Uygulamayı kullanmaya devam ederek yeni politikayı kabul etmiş olursunuz.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                "İletişim",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                "Gizlilikle ilgili soru veya talepleriniz için bize ulaşabilirsiniz:\ne-posta: support@daimapp.com",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
