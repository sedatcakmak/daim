import 'dart:async';
import 'dart:convert';
import 'package:daim/main.dart';
import 'package:daim/models/information.dart';
import 'package:daim/pages/reward_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DeepLinkManager with WidgetsBindingObserver {
  static final DeepLinkManager _instance = DeepLinkManager._internal();
  factory DeepLinkManager() => _instance;
  DeepLinkManager._internal();

  String? _pendingLink;
  bool _isAppReady = false;

  void init() {
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  Future<void> handleDeepLink(String link) async {
    debugPrint("🎯 Deep link geldi: $link");
    _pendingLink = link;

    if (_isAppReady) {
      _processLink();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _isAppReady = true;
      if (_pendingLink != null) {
        _processLink();
        _pendingLink = null;
      }
    }
  }

  Future<void> _processLink() async {
    final uri = Uri.tryParse(_pendingLink ?? '');
    if (uri == null) return;

    final host = uri.host.toLowerCase();
    if (host != 'reward' && !uri.pathSegments.contains('reward')) return;

    final code = uri.queryParameters['code'];
    if (code == null) return;

    final fullCode = "${Information.userId}-$code";
    await verifyQrCode(fullCode);
  }

  Future<void> verifyQrCode(String fullCode) async {
    final uri = Uri.parse(
      "https://api.daimapp.com/verify_qr",
    ).replace(queryParameters: {"code": fullCode});

    try {
      final response = await http
          .get(uri)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('API timeout'),
          );
      final result = response.statusCode == 200
          ? json.decode(response.body)
          : false;

      final message = result == true
          ? "✅ Kod doğrulandı ve yıldız verildi!"
          : "❌ Kod geçersiz veya süresi dolmuş.";

      _navigateToReward(message);
    } catch (e) {
      _navigateToReward("⚠️ Hata: $e");
    }
  }

  void _navigateToReward(String message) {
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => RewardPage(message: message)),
      (route) => false,
    );
  }
}
