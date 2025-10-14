import 'package:daim/managers/auth_manager.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthManager _authManager = AuthManager();
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    debugPrint('SplashScreen: initState called');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    try {
      debugPrint('SplashScreen: Starting auto login...');

      // Add a small delay to ensure everything is loaded
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      await _authManager.autoLogin(context);
      debugPrint('SplashScreen: Auto login completed');
    } catch (e) {
      debugPrint('SplashScreen: Error during initialization: $e');

      if (!mounted) return;

      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });

      // Show error for a few seconds, then try to continue
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _hasError) {
          _showFallbackNavigation();
        }
      });
    }
  }

  void _showFallbackNavigation() {
    // Navigate to a fallback screen (like welcome/login page)
    // Replace this with your actual fallback navigation
    Navigator.pushReplacementNamed(context, '/welcome');
  }

  void _retry() {
    setState(() {
      _hasError = false;
      _errorMessage = '';
    });
    _initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/logo.png",
                width: 256,
                height: 256,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('Error loading logo: $error');
                  return Container(
                    width: 256,
                    height: 256,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.restaurant,
                      size: 100,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
              const SizedBox(height: 25),
              const Text(
                "Daim",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 25),

              if (_hasError)
                Column(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Bir hata oluştu',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Uygulama başlatılırken sorun yaşandı. Lütfen tekrar deneyin.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _retry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Tekrar Dene'),
                    ),
                  ],
                )
              else
                const CircularProgressIndicator(color: Colors.black),

              const SizedBox(height: 40),

              // Add version info for debugging (optional)
              if (_hasError)
                Text(
                  'Hata: ${_errorMessage.length > 100 ? '${_errorMessage.substring(0, 100)}...' : _errorMessage}',
                  style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
