import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daim/managers/auth_manager.dart';
import 'package:daim/models/manager.dart';
import 'package:flutter/material.dart';

class RegistrationScreen extends StatefulWidget {
  final String phone;
  final String id;

  const RegistrationScreen({super.key, required this.id, required this.phone});

  @override
  State<StatefulWidget> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController cityController =
      TextEditingController(); // gösterim için (readOnly)
  final AuthManager _authManager = AuthManager();
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool isButtonEnabled = false;
  String? selectedCity;

  // Örnek şehir listesi (kendi listenle değiştir)
  final List<String> cities = <String>["Kayseri"];

  void completeRegistration() async {
    final String id = await Manager.createUser(
      nameController.text.trim(),
      surnameController.text.trim(),
      widget.phone,
      selectedCity ?? "",
    );
    if (!mounted) return;
    _authManager.login(context, id, widget.phone, false);
  }

  void _recheckButton() {
    setState(() {
      isButtonEnabled =
          nameController.text.trim().isNotEmpty &&
          surnameController.text.trim().isNotEmpty &&
          (selectedCity != null && selectedCity!.isNotEmpty);
    });
  }

  void _clearCitySelection() {
    setState(() {
      selectedCity = null;
      cityController.clear();
      _recheckButton();
    });
  }

  @override
  void initState() {
    super.initState();
    nameController.addListener(_recheckButton);
    surnameController.addListener(_recheckButton);
  }

  @override
  void dispose() {
    nameController.dispose();
    surnameController.dispose();
    cityController.dispose();
    super.dispose();
  }

  Future<void> _openCityPicker() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        List<String> filtered = List.from(cities);

        return StatefulBuilder(
          builder: (context, setSheetState) {
            void applyFilter(String q) {
              setSheetState(() {
                final qLower = q.toLowerCase();
                filtered = q.isEmpty
                    ? List.from(cities)
                    : cities
                          .where((c) => c.toLowerCase().contains(qLower))
                          .toList();
              });
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 12,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  TextField(
                    autofocus: true,
                    onChanged: applyFilter,
                    decoration: InputDecoration(
                      labelText: "Şehir ara",
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Kaydırılabilir liste:
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final city = filtered[index];
                        return ListTile(
                          title: Text(city),
                          onTap: () => Navigator.pop(context, city),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        selectedCity = result;
        cityController.text = result;
      });
      _recheckButton();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          title: const Text(
            "Kayıt Ol",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
        ),
      ),
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
              const SizedBox(height: 10),
              Image.asset(
                "assets/logo.png",
                width: 256,
                height: 256,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10),
              const Text(
                "Daim",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "Lütfen ${widget.phone} numarası kaydı için bilgilerinizi girin.",
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // İsim
              SizedBox(
                width: 400,
                height: 60,
                child: TextField(
                  controller: nameController,
                  style: const TextStyle(fontSize: 16),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "İsim",
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Soyisim
              SizedBox(
                width: 400,
                height: 60,
                child: TextField(
                  style: const TextStyle(fontSize: 16),
                  controller: surnameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Soyisim",
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Şehir seçimi - sadece tıklanır, liste açılır
              SizedBox(
                width: 400,
                height: 60,
                child: TextField(
                  controller: cityController,
                  readOnly: true,
                  onTap: _openCityPicker,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: "Şehir Seç",
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (selectedCity != null)
                          IconButton(
                            tooltip: "Temizle",
                            icon: const Icon(Icons.clear),
                            onPressed: _clearCitySelection,
                          ),
                        IconButton(
                          tooltip: "Listeyi aç",
                          icon: const Icon(Icons.arrow_drop_down),
                          onPressed: _openCityPicker,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Kayıt ol
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isButtonEnabled ? completeRegistration : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isButtonEnabled
                        ? Colors.green
                        : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Kayıt Ol",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
