import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'result_page.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final MobileScannerController controller = MobileScannerController();

  bool isScanCompleted = false;
  bool isFlashOn = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> handleScan(String scannedValue) async {
    if (isScanCompleted) return;

    setState(() {
      isScanCompleted = true;
    });

    await controller.stop();

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultPage(url: scannedValue),
      ),
    );

    if (!mounted) return;

    setState(() {
      isScanCompleted = false;
    });

    await controller.start();
  }

  Future<void> toggleFlash() async {
    await controller.toggleTorch();

    setState(() {
      isFlashOn = !isFlashOn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Flashlight',
            icon: Icon(
              isFlashOn ? Icons.flash_on : Icons.flash_off,
            ),
            onPressed: toggleFlash,
          ),
          IconButton(
            tooltip: 'Switch Camera',
            icon: const Icon(Icons.cameraswitch),
            onPressed: () {
              controller.switchCamera();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              for (final barcode in capture.barcodes) {
                final String? value = barcode.rawValue;

                if (value != null && value.trim().isNotEmpty) {
                  handleScan(value.trim());
                  break;
                }
              }
            },
          ),

          Container(
            color: Colors.black.withOpacity(0.18),
          ),

          Center(
            child: Container(
              width: 265,
              height: 265,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Colors.tealAccent,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.tealAccent.withOpacity(0.25),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                children: const [
                  Positioned(
                    top: -2,
                    left: -2,
                    child: _CornerBorder(
                      top: true,
                      left: true,
                    ),
                  ),
                  Positioned(
                    top: -2,
                    right: -2,
                    child: _CornerBorder(
                      top: true,
                      left: false,
                    ),
                  ),
                  Positioned(
                    bottom: -2,
                    left: -2,
                    child: _CornerBorder(
                      top: false,
                      left: true,
                    ),
                  ),
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: _CornerBorder(
                      top: false,
                      left: false,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: 30,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    color: Colors.tealAccent,
                    size: 34,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Scan QR Code',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Align the QR code inside the frame to analyze its content.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 36,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.65),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white24,
                ),
              ),
              child: Row(
                children: const [
                  Icon(
                    Icons.info_outline,
                    color: Colors.tealAccent,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'The scanned result will be checked before opening any link.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CornerBorder extends StatelessWidget {
  final bool top;
  final bool left;

  const _CornerBorder({
    required this.top,
    required this.left,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      height: 42,
      child: CustomPaint(
        painter: _CornerPainter(
          top: top,
          left: left,
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final bool top;
  final bool left;

  _CornerPainter({
    required this.top,
    required this.left,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.tealAccent
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();

    if (top && left) {
      path.moveTo(0, size.height * 0.75);
      path.lineTo(0, 0);
      path.lineTo(size.width * 0.75, 0);
    } else if (top && !left) {
      path.moveTo(size.width * 0.25, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height * 0.75);
    } else if (!top && left) {
      path.moveTo(0, size.height * 0.25);
      path.lineTo(0, size.height);
      path.lineTo(size.width * 0.75, size.height);
    } else {
      path.moveTo(size.width * 0.25, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, size.height * 0.25);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}