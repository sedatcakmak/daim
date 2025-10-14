import 'package:daim/localization/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:daim/widgets/bottom.dart';
import 'package:daim/widgets/header.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Language extends StatefulWidget {
  const Language({super.key});

  @override
  State<StatefulWidget> createState() => _LanguageState();
}

class _LanguageState extends State<Language> {
  String selectedLanguage = "Türkçe (TR)";

  final List<Map<String, String>> languages = [
    {"name": "Türkçe (TR)", "flag": "🇹🇷", "native": "Türkçe", "code": "tr"},
    /*
    {
      "name": "İngilizce (UK)",
      "flag": "🇬🇧",
      "native": "English",
      "code": "en"
    },
    */
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? langCode = prefs.getString('language') ?? "tr";
    setState(() {
      selectedLanguage =
          languages.firstWhere((lang) => lang["code"] == langCode)["name"] ??
          "Türkçe (TR)";
    });
  }

  Future<void> _changeLanguage(String langCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', langCode);

    if (!mounted) return;
    var languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    await languageProvider.changeLanguage(langCode);

    setState(() {
      selectedLanguage = languages.firstWhere(
        (lang) => lang["code"] == langCode,
      )["name"]!;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Seçilen Dil: $selectedLanguage")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Dil / Language"),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: -1),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: languages.length,
                itemBuilder: (context, index) {
                  final language = languages[index];
                  final isSelected = language["name"] == selectedLanguage;

                  return GestureDetector(
                    onTap: () => _changeLanguage(language["code"]!),
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue.shade100 : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.grey,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                language["flag"]!,
                                style: TextStyle(fontSize: 24),
                              ),
                              SizedBox(width: 12),
                              Text(
                                language["name"]!,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            language["native"]!,
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
