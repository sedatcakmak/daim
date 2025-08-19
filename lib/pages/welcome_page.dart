import 'package:daim/localization/language_provider.dart';
import 'package:daim/pages/verification_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class PhoneNumberScreen extends StatefulWidget {
  const PhoneNumberScreen({super.key});

  @override
  State<StatefulWidget> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  final TextEditingController _phoneController =
      TextEditingController(text: "0");
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
    {"name": "English", "code": "en"},
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
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 25),
              _buildLanguageSelector(),
              const SizedBox(height: 20),
              _buildLogo(),
              const SizedBox(height: 20),
              _buildTitleText(),
              const SizedBox(height: 20),
              _buildDescriptionText(),
              const SizedBox(height: 40),
              _buildPhoneNumberInput(),
              const SizedBox(height: 20),
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
        context, MaterialPageRoute(builder: (context) => const TermsPage()));
  }

  void _openPrivacyPolicyPage() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()));
  }

  Widget _buildLinkText(String key, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        key,
        style: const TextStyle(
            fontSize: 20, color: Colors.blue, fontWeight: FontWeight.bold),
      ),
    );
  }

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
      title: Text(lang["name"]!,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

    Provider.of<LanguageProvider>(context, listen: false)
        .changeLanguage(langCode);

    setState(() {
      selectedLanguage =
          languages.firstWhere((lang) => lang["code"] == langCode)["name"]!;
    });

    _showSnackBar("Dil seçildi.");
  }

  void _showSnackBar(String messageKey) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(messageKey)),
    );
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
            Row(children: const [
              Icon(Icons.language),
              SizedBox(width: 8),
              Text("Türkçe") // Varsayılan dil
            ]),
          ],
        ),
      ),
    );
  }

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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: const Text("Devam Et",
            style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold)),
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
          title: Text(
            "Kullanım Şartları",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          iconTheme: IconThemeData(color: Colors.black),
        ),
      ),
      body: Center(child: Text("Kullanım Şartları")),
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
        preferredSize: Size.fromHeight(50),
        child: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          title: Text(
            "Gizlilik Politikası",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          iconTheme: IconThemeData(color: Colors.black),
        ),
      ),
      body: Center(child: Text("Gizlilik Politikası")),
    );
  }
}
