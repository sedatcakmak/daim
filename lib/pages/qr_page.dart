import 'package:daim/managers/deeplink_manager.dart';
import 'package:daim/models/app_loader.dart';
import 'package:daim/models/information.dart';
import 'package:daim/models/restaurant_model.dart';
import 'package:daim/widgets/bottom.dart';
import 'package:daim/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vector_math/vector_math_64.dart' as vmath;

class QRPage extends StatefulWidget {
  const QRPage({super.key});

  @override
  State<QRPage> createState() => _QRPageState();
}

class _QRPageState extends State<QRPage> {
  RestaurantModel? restaurant = Information.restaurant;

  final TextEditingController _textController = TextEditingController();
  final MobileScannerController _scannerController = MobileScannerController(
    formats: [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _isProcessing = false;
  DateTime? _lastScanAt;

  @override
  void dispose() {
    _textController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: 'QR'),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_buildQRCard(context)],
          ),
        ),
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.shade200),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.shade100,
          spreadRadius: 1,
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _buildQRCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _boxDecoration(),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "• Her sipariş sana belli bir yıldız kazandırır.\n"
            "• Çalışanın gösterdiği QR’ı kameraya tut.\n"
            "• Siparişin için yıldızını kazan.",
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 12),

          // Tarayıcı
          AspectRatio(
            aspectRatio: 1, // kare alan
            child: Stack(
              children: [
                if (Information.isGuest)
                  Positioned.fill(
                    child: Container(
                      color: Colors.white.withOpacity(0.8),
                      child: Center(
                        child: Text(
                          "QR okutmak için giriş yapmalısın",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                if (!Information.isGuest)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: MobileScanner(
                      controller: _scannerController,
                      onDetect: (capture) async {
                        if (_isProcessing) return;

                        final now = DateTime.now();
                        // 1 saniyeden sık taramaları filtrele
                        if (_lastScanAt != null &&
                            now.difference(_lastScanAt!).inMilliseconds <
                                1000) {
                          return;
                        }
                        _lastScanAt = now;

                        final barcodes = capture.barcodes;
                        if (barcodes.isEmpty) return;

                        final text = barcodes.first.rawValue;
                        if (text == null || text.isEmpty) return;

                        setState(() => _isProcessing = true);
                        try {
                          await AppLoader.checkQR(context, text);
                        } finally {
                          if (mounted) setState(() => _isProcessing = false);
                        }
                      },
                    ),
                  ),

                // Köşe kılavuzları (scan overlay)
                Positioned.fill(child: _ScanCorners()),

                // Üstte butonlar
                // imports aynı: package:mobile_scanner/mobile_scanner.dart

                // ... Positioned içinde sağ üst butonlar:
                Positioned(
                  right: 12,
                  top: 12,
                  child: Row(
                    children: [
                      _roundIconButton(
                        icon: Icons.flip_camera_android_outlined,
                        tooltip: "Kamerayı çevir",
                        onTap: () async {
                          await _scannerController.switchCamera();
                          setState(() {});
                        },
                      ),
                      const SizedBox(width: 8),
                      ValueListenableBuilder<MobileScannerState>(
                        valueListenable: _scannerController,
                        builder: (context, state, _) {
                          final isOn = state.torchState == TorchState.on;
                          return _roundIconButton(
                            icon: isOn ? Icons.flash_on : Icons.flash_off,
                            tooltip: isOn ? "Fener kapat" : "Fener aç",
                            onTap: () => _scannerController.toggleTorch(),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // İşleniyor overlay
                if (_isProcessing)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Manuel giriş
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration: const InputDecoration(
                    labelText: "QR kodu yaz / yapıştır",
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _submitManual(),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isProcessing || Information.isGuest
                      ? null
                      : _submitManual,
                  icon: const Icon(Icons.verified),
                  label: const Text(
                    "Doğrula",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _submitManual() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Kod girmelisin!")));
      return;
    }
    setState(() => _isProcessing = true);
    try {
      final newCode = "${Information.userId}-$text";
      await DeepLinkManager().verifyQrCode(newCode);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Widget _roundIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.black.withValues(alpha: 0.30),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Tooltip(
          message: tooltip,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

/// Scan alanı için köşe çizgileri (daha profesyonel görünüm)
class _ScanCorners extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const edge = 22.0;
    const stroke = 4.0;
    final color = Colors.black.withValues(alpha: 0.95);

    Widget corner(Alignment a, {bool flipX = false, bool flipY = false}) {
      return Align(
        alignment: a,
        child: Transform(
          transform: Matrix4.identity()
            ..scaleByVector3(
              vmath.Vector3(flipX ? -1.0 : 1.0, flipY ? -1.0 : 1.0, 1.0),
            ),
          alignment: Alignment.center,
          child: CustomPaint(
            size: const Size(edge, edge),
            painter: _CornerPainter(color, stroke),
          ),
        ),
      );
    }

    return IgnorePointer(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Stack(
          children: [
            corner(Alignment.topLeft),
            corner(Alignment.topRight, flipX: true),
            corner(Alignment.bottomLeft, flipY: true),
            corner(Alignment.bottomRight, flipX: true, flipY: true),
          ],
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  final double stroke;
  const _CornerPainter(this.color, this.stroke);

  @override
  void paint(Canvas c, Size s) {
    final p = Paint()
      ..color = color
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(0, s.height)
      ..lineTo(0, 0)
      ..lineTo(s.width, 0);
    c.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
