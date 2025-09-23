import 'package:daim/pages/verification_page.dart';
import 'package:flutter/material.dart';

class PhoneNumberScreen extends StatefulWidget {
  const PhoneNumberScreen({super.key});

  @override
  State<StatefulWidget> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  final TextEditingController _phoneController = TextEditingController(
    text: "0",
  );
  bool isButtonEnabled = false;
  String selectedLanguage = "Türkçe";

  @override
  void initState() {
    super.initState();
    isButtonEnabled = _phoneController.text.length == 11;
  }

  void _goToOtp() {
    final raw = _phoneController.text.trim();
    if (raw.isEmpty) return;
    final phone = "+9$raw";

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OTPVerificationScreen(phone: phone)),
    );
  }

  final List<Map<String, String>> languages = [
    {"name": "Türkçe", "code": "tr"},
    // {"name": "English", "code": "en"},
  ];

  void _onPhoneNumberChanged(String value) {
    if (!value.startsWith("0")) {
      var corrected = "0$value";
      if (corrected.length > 11) {
        corrected = corrected.substring(0, 11);
      }

      _phoneController.text = corrected;
      _phoneController.selection = TextSelection.fromPosition(
        TextPosition(offset: corrected.length),
      );
    }

    setState(() {
      isButtonEnabled = _phoneController.text.length == 11;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /*
              const SizedBox(height: 25),
              _buildLanguageSelector(),
              const SizedBox(height: 20),
              */
              const SizedBox(height: 10),
              _buildLogo(),
              const SizedBox(height: 10),
              _buildTitleText(),
              const SizedBox(height: 10),
              _buildDescriptionText(),
              const SizedBox(height: 40),
              _buildPhoneNumberInput(),
              const SizedBox(height: 40),
              _buildContinueButton(),
              const SizedBox(height: 40),
              _buildTermsAndPrivacy(),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleText() {
    return const Text(
      "Daim",
      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildDescriptionText() {
    return const Text(
      "Daim uygulamasına hoşgeldin!",
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
    );
  }

  Widget _buildTermsAndPrivacy() {
    return Column(
      children: [
        _buildLinkText('Kullanım Şartları', _openTermsPage),
        const SizedBox(height: 10),
        _buildLinkText('Gizlilik Politikası', _openPrivacyPolicyPage),
      ],
    );
  }

  void _openTermsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TermsPage()),
    );
  }

  void _openPrivacyPolicyPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
    );
  }

  Widget _buildLinkText(String key, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        key,
        style: const TextStyle(
          fontSize: 20,
          color: Colors.blue,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /*
  void _showLanguageBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            ...languages.map((lang) => _buildLanguageOption(lang)),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(Map<String, String> lang) {
    bool isSelected = selectedLanguage == lang["name"];
    return ListTile(
      leading: const Icon(Icons.language),
      title: Text(
        lang["name"]!,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Colors.blue)
          : null,
      tileColor: isSelected ? Colors.blue.shade100 : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onTap: () {
        if (!isSelected) _changeLanguage(lang["code"]!);
        if (Navigator.canPop(context)) Navigator.pop(context, true);
      },
    );
  }

  Future<void> _changeLanguage(String langCode) async {
    if (!mounted) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', langCode);

    Provider.of<LanguageProvider>(
      context,
      listen: false,
    ).changeLanguage(langCode);

    setState(() {
      selectedLanguage = languages.firstWhere(
        (lang) => lang["code"] == langCode,
      )["name"]!;
    });

    _showSnackBar("Dil seçildi.");
  }

  void _showSnackBar(String messageKey) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(messageKey)));
  }

  Widget _buildLanguageSelector() {
    return GestureDetector(
      onTap: _showLanguageBottomSheet,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Seçili Dil", style: TextStyle(fontSize: 16)),
            Row(
              children: const [
                Icon(Icons.language),
                SizedBox(width: 8),
                Text("Türkçe"), // Varsayılan dil
              ],
            ),
          ],
        ),
      ),
    );
  }
  */

  Widget _buildLogo() {
    return Image.asset(
      "assets/logo.png",
      width: 256,
      height: 256,
      fit: BoxFit.contain,
    );
  }

  Widget _buildPhoneNumberInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: _phoneController,
        maxLength: 11,
        maxLines: 1,
        keyboardType: TextInputType.phone,
        onChanged: _onPhoneNumberChanged,
        scrollPadding: EdgeInsets.only(bottom: 200),
        decoration: InputDecoration(
          labelText: "Telefon numaranı gir.",
          labelStyle: const TextStyle(color: Colors.black),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent, width: 2),
          ),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isButtonEnabled ? _goToOtp : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isButtonEnabled ? Colors.green : Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          "Devam Et",
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          title: const Text(
            "Kullanım Şartları",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Column(
                  children: const [
                    Text(
                      "Kullanım Şartları",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text("Son Güncelleme: 24 Nisan 2025"),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Bu Kullanım Şartları, "Daim" mobil uygulamasını ("Uygulama") sunan cakmak studios ("Sağlayıcı") ile Uygulamayı yükleyen ve kullanan siz ("Kullanıcı") arasında geçerlidir.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                "Şartların Kabulu",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Uygulamayı indirmek, yüklemek veya kullanmakla bu şartları kabul etmiş sayılırsınız. Kabul etmediğiniz takdirde Uygulamayı kullanmayınız.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                "Lisans ve Kullanım",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Sağlayıcı size, kişisel, ticari olmayan kullanım amacıyla Uygulamayı geri alınamaz, münhasır olmayan, devredilemez bir lisansla kullanma hakkı verir.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                "Gizlilik ve Veri Koruma",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Uygulama; sağladığınız kişisel verileri, yalnızca Hizmet’in sağlanması ve iyileştirilmesi amacıyla işler. Detaylar için lütfen Uygulama içindeki Gizlilik Politikası’nı inceleyin.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                "Sorumluluk Sınırlandırması",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Sağlayıcı, Uygulamanın kesintisiz, hatasız çalışacağı veya belirli bir amaca uygun olduğu konusunda garanti vermez. Kullanıcı, Uygulama kullanımından doğabilecek doğrudan ya da dolaylı zararları kendi sorumluluğunda karşılar.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                "Şartlarda Değişiklik",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Text(
                "cakmak studios, bu şartları önceden bildirimde bulunmaksızın güncelleyebilir. Güncellenen metin Uygulama’da yayımlandığı anda yürürlüğe girer; kullanımınıza devam ederek yeni şartları kabul etmiş olursunuz.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                "İletişim",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Her türlü soru, talep veya itirazınız için\ne-posta: support@daimapp.com\nadresinden bize ulaşabilirsiniz.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          title: const Text(
            "Gizlilik Politikası",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Column(
                  children: const [
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
              const SizedBox(height: 16),
              const Text(
                'Bu Gizlilik Politikası, "Daim" mobil uygulamasını ("Uygulama") kullananların kişisel verilerinin nasıl toplandığını, kullanıldığını ve korunduğunu açıklar. Politikayı kabul etmiyorsanız lütfen uygulamayı kullanmayınız.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                "Toplanan Veriler",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Zorunlu Veriler: Kullanıcı kaydı sırasında talep edilen ad, soyad, e-posta, telefon ve konum bilgisi.\nKullanım Verileri: Uygulama kullanımına ilişkin işlem kayıtları, tercih edilen dil ve teknik çerezler (analytics).",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                "Veri Kullanımı",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Toplanan veriler;\n- Hizmet sunumu ve sipariş yönetimi,\n- Kullanıcı deneyimini kişiselleştirme,\n- Destek taleplerine yanıt verme,\n- Uygulama performansını artırma ve hata düzeltme amaçlarıyla kullanılır.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                "Veri Paylaşımı",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Text(
                "cakmak studios, kullanıcı verilerini üçüncü taraflarla paylaşmaz. Yalnızca;\n- Yasal yükümlülükler,\n- Hizmet sağlayıcı iş ortakları (ör. ödeme işlemleri)\ndurumlarında asgari düzeyde ve güvenli iletişim protokolleriyle aktarım yapabilir.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                "Veri Güvenliği",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Tüm kişisel veriler, şifreleme ve güvenlik duvarlarıyla korunur.\nYetkisiz erişime, kayba veya kötüye kullanıma karşı teknik ve organizasyonel önlemler uygulanır.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                "Çocukların Gizliliği",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Uygulama, 18 yaşın altındaki çocuklardan kasıtlı olarak veri toplamaz. Eğer ebeveyn izni olmadan veri toplandığı tespit edilirse, söz konusu veri derhal silinir.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                "Üçüncü Taraf Bağlantıları",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Uygulama içinde yer alan reklam veya analiz araçları, kendi gizlilik politikalarına sahiptir. Bu araçları kullanmadan önce ilgili politikaları inceleyiniz.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                "Politika Güncellemeleri",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Text(
                "cakmak studios, bu politikayı önceden bildirimde bulunmaksızın güncelleyebilir. Güncellenen metin Uygulama’da yayımlandığı anda yürürlüğe girer; Uygulamayı kullanmaya devam ederek yeni politikayı kabul etmiş olursunuz.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                "İletişim",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Gizlilikle ilgili soru veya talepleriniz için bize ulaşabilirsiniz:\ne-posta: support@daimapp.com",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
