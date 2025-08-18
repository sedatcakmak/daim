import 'dart:math';

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
  final TextEditingController cityController = TextEditingController();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool isButtonEnabled = false;
  String? selectedCity;
  List<String> filteredCities = [];
  final AuthManager _authManager = AuthManager();

  final List<String> cities = [
    "Adana",
    "Adıyaman",
    "Afyonkarahisar",
    "Ağrı",
    "Amasya",
    "Ankara",
    "Antalya",
    "Artvin",
    "Aydın",
    "Balıkesir",
    "Bilecik",
    "Bingöl",
    "Bitlis",
    "Bolu",
    "Burdur",
    "Bursa",
    "Çanakkale",
    "Çankırı",
    "Çorum",
    "Denizli",
    "Diyarbakır",
    "Edirne",
    "Elazığ",
    "Erzincan",
    "Erzurum",
    "Eskişehir",
    "Gaziantep",
    "Giresun",
    "Gümüşhane",
    "Hakkari",
    "Hatay",
    "Isparta",
    "Mersin",
    "İstanbul",
    "İzmir",
    "Kars",
    "Kastamonu",
    "Kayseri",
    "Kırklareli",
    "Kırşehir",
    "Kocaeli",
    "Konya",
    "Kütahya",
    "Malatya",
    "Manisa",
    "Kahramanmaraş",
    "Mardin",
    "Muğla",
    "Muş",
    "Nevşehir",
    "Niğde",
    "Ordu",
    "Rize",
    "Sakarya",
    "Samsun",
    "Siirt",
    "Sinop",
    "Sivas",
    "Tekirdağ",
    "Tokat",
    "Trabzon",
    "Tunceli",
    "Şanlıurfa",
    "Uşak",
    "Van",
    "Yozgat",
    "Zonguldak",
    "Aksaray",
    "Bayburt",
    "Karaman",
    "Kırıkkale",
    "Batman",
    "Şırnak",
    "Bartın",
    "Ardahan",
    "Iğdır",
    "Yalova",
    "Karabük",
    "Kilis",
    "Osmaniye",
    "Düzce"
  ];

  void completeRegistration() async {
    String id = await Manager.createUser(nameController.text,
        surnameController.text, widget.phone, selectedCity ?? "");

    _authManager.login(context, id, widget.phone, false);
  }

  void _onTextChanged() {
    setState(() {
      isButtonEnabled = nameController.text.trim().isNotEmpty &&
          surnameController.text.trim().isNotEmpty &&
          selectedCity != null;
    });
  }

  void _onCityChanged(String input) {
    setState(() {
      if (input.isEmpty) {
        filteredCities = [];
      } else {
        filteredCities = cities
            .where((city) => city.toLowerCase().contains(input.toLowerCase()))
            .toList();

        if (filteredCities.isNotEmpty) {
          String? city = cities
              .where((city) => city.toLowerCase() == input.toLowerCase())
              .firstOrNull;

          if (city != null) {
            selectedCity = city;
            _onTextChanged();
          }
        }
      }
    });
  }

  void _clearCitySelection() {
    setState(() {
      selectedCity = null;
      cityController.clear();
      filteredCities = [];
      _onTextChanged();
    });
  }

  @override
  void initState() {
    super.initState();
    nameController.addListener(_onTextChanged);
    surnameController.addListener(_onTextChanged);
    cityController.addListener(() {
      _onCityChanged(cityController.text);
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    surnameController.dispose();
    cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          title: Text(
            "Kayıt Ol",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          iconTheme: IconThemeData(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 10),
              Image.asset(
                "assets/logo.png",
                width: 256,
                height: 256,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 10),
              Text("Daim",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text(
                "Lütfen ${widget.phone} numarası kaydı için bilgilerinizi girin.",
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 400,
                height: 60,
                child: TextField(
                  controller: nameController,
                  style: TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "İsim",
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 400,
                height: 60,
                child: TextField(
                  style: TextStyle(fontSize: 16),
                  controller: surnameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Soyisim",
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 400,
                height: 60,
                child: TextField(
                  controller: cityController,
                  style: TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Şehir Ara",
                    suffixIcon: selectedCity != null
                        ? IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: _clearCitySelection,
                          )
                        : null,
                  ),
                ),
              ),
              if (filteredCities.isNotEmpty)
                Container(
                  color: Colors.grey.shade100,
                  child: Column(
                    children: List.generate(
                      min(2, filteredCities.length),
                      (index) => ListTile(
                        title: Text(
                          filteredCities[index],
                          style: TextStyle(fontSize: 16),
                        ),
                        onTap: () {
                          setState(() {
                            selectedCity = filteredCities[index];
                            cityController.text = selectedCity!;
                            filteredCities = [];
                            _onTextChanged();
                          });
                        },
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isButtonEnabled ? completeRegistration : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isButtonEnabled ? Colors.green : Colors.grey,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text("Kayıt Ol",
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
