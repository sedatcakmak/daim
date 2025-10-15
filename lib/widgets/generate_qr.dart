import 'dart:async';
import 'dart:convert';
import 'package:daim/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';

class GenerateQRWidget extends StatefulWidget {
  final String restaurantId;

  const GenerateQRWidget({required this.restaurantId, super.key});

  @override
  State<GenerateQRWidget> createState() => _GenerateQRWidgetState();
}

class _GenerateQRWidgetState extends State<GenerateQRWidget> {
  String? qrCode;

  Future<void> _generateQRCode() async {
    final response = await http
        .post(
          Uri.parse("https://api.daimapp.com/generate_qr"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"restaurant_id": widget.restaurantId}),
        )
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw TimeoutException('API timeout'),
        );

    if (response.statusCode == 200) {
      setState(() {
        qrCode = "https://daimapp.com/reward?code=${response.body}";
        debugPrint(response.body);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('QR başarıyla oluşturuldu!')));
      });
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('QR oluşturulamadı!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (qrCode != null)
          Container(
            margin: EdgeInsets.all(12),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.black),
              borderRadius: BorderRadius.circular(12),
            ),
            child: QrImageView(
              data: qrCode!,
              version: QrVersions.auto,
              size: 300.0,
            ),
          ),
        SizedBox(height: 8),
        ElevatedButton(onPressed: _generateQRCode, child: Text("QR Oluştur")),
      ],
    );
  }
}
