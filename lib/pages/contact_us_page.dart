import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:daim/widgets/bottom.dart';
import 'package:daim/widgets/header.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({super.key});

  @override
  ContactUsState createState() => ContactUsState();
}

class ContactUsState extends State<ContactUs> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  String selectedTopic = "Genel";
  final List<String> topics = ["Genel", "Fikir", "Öneri", "Şikayet", "Destek"];

  void sendMessage() {
    String email = emailController.text.trim();
    String message = messageController.text.trim();

    if (email.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen tüm alanları doldurun.")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Mesajınız ($selectedTopic) olarak gönderildi!")),
    );

    _sendMessage(selectedTopic, email, message);

    emailController.clear();
    messageController.clear();
    setState(() {
      selectedTopic = "Genel";
    });
  }

  Future<void> _sendMessage(String topic, String email, String message) async {
    final subjectMap = {
      "Genel": "general",
      "Fikir": "suggestion",
      "Öneri": "suggestion",
      "Şikayet": "complaint",
      "Destek": "other",
    };
    final subjectKey = subjectMap[topic] ?? "general";

    final uri = Uri.parse("https://api.daimapp.com/contact_message");
    final payload = {
      "name": "Uygulama Mesajı",
      "email": email,
      "phone": "",
      "subject": subjectKey,
      "message": message,
    };

    print("📤 İstek gönderildi: $uri");

    try {
      final res = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      // Backend düz metin döndürüyor: "Mesaj başarıyla gönderildi."
      if (!mounted) return;
      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Mesajınız ($topic) olarak gönderildi!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gönderilemedi (${res.statusCode})")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata: $e")),
      );
    }
  }

  void openInstagram() async {
    final Uri appUri =
        Uri.parse("instagram://user?username=daim.app"); // 📱 Uygulama için
    final Uri webUri =
        Uri.parse("https://www.instagram.com/daim.app"); // 🌐 Web için

    if (await canLaunchUrl(appUri)) {
      await launchUrl(appUri, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Instagram açılamadı!")),
      );
    }
  }

  void openEmail() async {
    Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@daimapp.com',
      queryParameters: {'subject': selectedTopic},
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("E-posta açılamadı!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: "Bize Ulaşın"),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: -1),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: selectedTopic,
                dropdownColor: Colors.white,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.black, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        const BorderSide(color: Color(0xFF1098F7), width: 2),
                  ),
                  labelText: "Konu Seçin",
                  labelStyle: const TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                items: topics.map((topic) {
                  return DropdownMenuItem(
                    value: topic,
                    child: Text(topic),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedTopic = value!;
                  });
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  labelText: 'E-posta adresiniz',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.black, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        const BorderSide(color: Color(0xFF1098F7), width: 2),
                  ),
                  labelStyle: const TextStyle(color: Colors.grey),
                  floatingLabelStyle: const TextStyle(color: Color(0xFF1098F7)),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: messageController,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  labelText: 'Mesajınız',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.black, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        const BorderSide(color: Color(0xFF1098F7), width: 2),
                  ),
                  labelStyle: const TextStyle(color: Colors.grey),
                  floatingLabelStyle: const TextStyle(color: Color(0xFF1098F7)),
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: sendMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1098F7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    elevation: 3,
                  ),
                  child: const Text('Gönder'),
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              const Text(
                "İletişim",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: openInstagram,
                child: Row(
                  children: const [
                    Icon(Icons.camera_alt, color: Color(0xFF1098F7), size: 24),
                    SizedBox(width: 8),
                    Text(
                      "daim.app",
                      style: TextStyle(fontSize: 16, color: Color(0xFF1098F7)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: openEmail,
                child: Row(
                  children: const [
                    Icon(Icons.email, color: Color(0xFF1098F7), size: 24),
                    SizedBox(width: 8),
                    Text(
                      "support@daimapp.com",
                      style: TextStyle(fontSize: 16, color: Color(0xFF1098F7)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
