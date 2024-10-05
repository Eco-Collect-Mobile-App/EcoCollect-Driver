import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'scanner_fetch_document.dart'; // Make sure this is imported

class QRCodeScanner extends StatefulWidget {
  const QRCodeScanner({super.key});

  @override
  _QRCodeScannerState createState() => _QRCodeScannerState();
}

class _QRCodeScannerState extends State<QRCodeScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  // This method is called when the QR code scanner detects a code
  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });

      if (result != null) {
        print('Scanned QR Code Data: ${result!.code}');
        controller.pauseCamera(); // Pause the camera after scanning

        // Show dialog with scanned QR code (request ID)
        _showDialog(result!.code);
      }
    });
  }

  void _showDialog(String? requestId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "QR Code Scanned",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 168, 168, 168), // Title color
            ),
          ),
          content: Text(
            "Request ID: $requestId",
            style: const TextStyle(
                fontSize: 16, // Font size for content
                color: Color.fromARGB(255, 56, 56, 56),
                fontWeight: FontWeight.w700 // Content text color
                ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "OK",
                style: TextStyle(
                  color: Color(0xFF27AE60), // Button text color
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                // Navigate to the FetchDocumentPage with the request ID
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        FetchDocumentPage(documentId: requestId),
                  ),
                );
                controller
                    ?.resumeCamera(); // Resume the camera after navigating
              },
            ),
          ],
          backgroundColor: Color(0xFFFFFEF8), // Background color of the dialog
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0), // Rounded corners
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF27AE60),
        elevation: 0,
        title: const Text("QR Code Scanner",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: const Color.fromARGB(255, 155, 255, 158),
                borderRadius: 18,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16.0), // Padding around the text
              decoration: BoxDecoration(
                color: const Color(0xFF27AE60),
                borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Center(
                child: (result != null)
                    ? Text(
                        'Scanned Data: ${result!.code}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Direct your camera towards the QR code',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
