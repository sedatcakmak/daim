import 'package:daim/models/app_loader.dart';
import 'package:daim/models/information.dart';
import 'package:daim/models/restaurant_model.dart';
import 'package:daim/models/user_model.dart';
import 'package:daim/pages/employee_home_page.dart';
import 'package:daim/widgets/employee_bottom.dart';
import 'package:daim/widgets/employee_header.dart';
import 'package:flutter/material.dart';

class EmployeeUserPage extends StatefulWidget {
  final UserModel user;

  const EmployeeUserPage({super.key, required this.user});

  @override
  State<EmployeeUserPage> createState() => _EmployeeUserPageState();
}

class _EmployeeUserPageState extends State<EmployeeUserPage> {
  RestaurantModel? restaurant = Information.restaurant;
  final _addController = TextEditingController();
  final _removeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomEmployeeAppBar(title: 'Müşteri'),
      backgroundColor: Colors.white,
      bottomNavigationBar: CustomEmployeeBottomNavBar(currentIndex: -1),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserInfo(),
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              _buildSection(
                title: "Yıldız Ekleme",
                subtitle: "Bu bölümden kullanıcıya yıldız ekleyebilirsin.",
                controller: _addController,
                label: "Eklenecek Yıldız",
                hint: "Minimum: 1 ⭐",
                confirmAction: _confirmAddStars,
              ),
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              _buildSection(
                title: "Yıldız Harcama",
                subtitle: "Bu bölümden kullanıcının yıldızını azaltabilirsin.",
                controller: _removeController,
                label: "Harcanacak Yıldız",
                hint: "Maksimum: ${widget.user.currentStars} ⭐",
                confirmAction: _confirmRemoveStars,
              ),
              const SizedBox(height: 8),
              Divider(),
              const SizedBox(height: 8),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: _customButton(
                          "Kapat", Icons.close, Colors.red, _navigateToQRPage),
                    ),
                    const SizedBox(width: 8)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required TextEditingController controller,
    required String label,
    required String hint,
    required VoidCallback confirmAction,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        Text(subtitle,
            style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
        const SizedBox(height: 16),
        _buildTextField(controller, label, hint),
        const SizedBox(height: 8),
        _buildActionButtons(confirmAction),
      ],
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildActionButtons(VoidCallback confirmAction) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      child: Row(
        children: [
          Expanded(
              child: _customButton(
                  "Onayla", Icons.check, Colors.green, confirmAction)),
          const SizedBox(width: 8)
        ],
      ),
    );
  }

  Widget _customButton(
      String text, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      label: Text(text,
          style: const TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      icon: Icon(icon, size: 24, color: Colors.white),
    );
  }

  void _confirmAddStars() async {
    final stars = int.tryParse(_addController.text);
    if (stars == null || stars <= 0) {
      _showSnackBar("Lütfen en az 1 girin.");
      return;
    }

    try {
      await AppLoader.addCurrentStars(widget.user.id, stars);
      _showSnackBar("$stars yıldız başarıyla eklendi.");
      _navigateToHome();
    } catch (e) {
      _showSnackBar("Yıldızlar eklenemedi: $e");
    }
  }

  void _confirmRemoveStars() async {
    final stars = int.tryParse(_removeController.text);
    if (stars == null || stars <= 0 || stars > widget.user.currentStars) {
      _showSnackBar(
          "Lütfen 1 ile ${widget.user.currentStars} arasında bir değer girin.");
      return;
    }

    try {
      await AppLoader.removeStarsByUserId(widget.user.id, stars);
      _showSnackBar("$stars yıldız başarıyla harcandı.");
      _navigateToHome();
    } catch (e) {
      _showSnackBar("Yıldızlar harcanamadı: $e");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => EmployeeHomePage()));
  }

  void _navigateToQRPage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => EmployeeHomePage()));
  }

  Widget _buildUserInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: _boxDecoration(),
        width: double.infinity,
        child: Row(
          children: [
            Image.network(
              restaurant?.image ?? '',
              width: 80,
              height: 80,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.broken_image, size: 80, color: Colors.grey),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoText(
                    "Müşteri: ", "${widget.user.name} ${widget.user.surname}"),
                _infoText(
                    "Harcanabilen Yıldız: ", "${widget.user.currentStars} ⭐"),
                _infoText("Toplam Yıldız: ", "${widget.user.totalStars} ⭐"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoText(String boldText, String normalText) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
              text: boldText,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          TextSpan(text: normalText, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
      boxShadow: [
        BoxShadow(color: Colors.grey.shade200, spreadRadius: 1, blurRadius: 3)
      ],
    );
  }
}
