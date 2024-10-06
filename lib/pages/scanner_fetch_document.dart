import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_collect/pages/qr_code_scanner.dart';

class FetchDocumentPage extends StatefulWidget {
  final String? documentId;

  const FetchDocumentPage({Key? key, this.documentId}) : super(key: key);

  @override
  _FetchDocumentPageState createState() => _FetchDocumentPageState();
}

class _FetchDocumentPageState extends State<FetchDocumentPage> {
  Map<String, dynamic>? documentData;

  late TextEditingController addressController;
  late TextEditingController nicController;
  late TextEditingController pickupDateController;
  late TextEditingController pickupTimeController;
  late List<TextEditingController> wasteEntryControllers;
  late List<Map<String, dynamic>> wasteEntries;

  @override
  void initState() {
    super.initState();
    wasteEntryControllers = [];
    _fetchDocumentFromFirestore(widget.documentId);
  }

  @override
  void dispose() {
    addressController.dispose();
    nicController.dispose();
    pickupDateController.dispose();
    pickupTimeController.dispose();
    for (var controller in wasteEntryControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchDocumentFromFirestore(String? documentId) async {
    if (documentId != null) {
      print("Scanned Document ID: $documentId");
      try {
        DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
            .collection('wasteData')
            .doc(documentId)
            .get();

        if (documentSnapshot.exists) {
          setState(() {
            documentData = documentSnapshot.data() as Map<String, dynamic>?;

            addressController =
                TextEditingController(text: documentData?['address'] ?? '');
            nicController =
                TextEditingController(text: documentData?['nic'] ?? '');
            pickupDateController =
                TextEditingController(text: documentData?['pickupDate'] ?? '');
            pickupTimeController =
                TextEditingController(text: documentData?['pickupTime'] ?? '');
            wasteEntries = List<Map<String, dynamic>>.from(
                documentData?['wasteEntries'] ?? []);
            wasteEntryControllers = wasteEntries
                .map((entry) => TextEditingController(
                    text: entry['weight']?.toString() ?? ''))
                .toList();
          });
          print("Document Data: $documentData");
        } else {
          _showError("Document not found.");
        }
      } on FirebaseException catch (e) {
        print("Error fetching document: $e");
        _showError("An error occurred: ${e.message}");
      } catch (e) {
        print("Unexpected error: $e");
        _showError("An unknown error occurred.");
      }
    }
  }

  Future<void> _submitEditedData() async {
    if (widget.documentId != null && documentData != null) {
      try {
        for (int i = 0; i < wasteEntries.length; i++) {
          wasteEntries[i]['weight'] = wasteEntryControllers[i].text.isNotEmpty
              ? double.tryParse(wasteEntryControllers[i].text)
              : null;
        }
        await FirebaseFirestore.instance
            .collection('wasteData')
            .doc(widget.documentId)
            .update({
          'address': addressController.text,
          'nic': nicController.text,
          'pickupDate': pickupDateController.text,
          'pickupTime': pickupTimeController.text,
          'wasteEntries': wasteEntries,
        });
        _showConfirmation("Data updated successfully.");
      } catch (e) {
        print("Error updating document: $e");
        _showError("Failed to update data. Please try again.");
      }
    }
  }

  void _showConfirmation(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Success"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("OK"),
            )
          ],
        );
      },
    );
  }

  Widget _buildWasteEntryEditor(int index) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: Color(0xFFFFFEF8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Waste Type',
                labelStyle: TextStyle(
                  color: Color.fromARGB(255, 69, 69, 69),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                fillColor: Color.fromARGB(255, 235, 235, 235),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(
                      color: Color.fromARGB(255, 236, 236, 236), width: 2.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: Color(0xFF27AE60), width: 2.0),
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              ),
              onChanged: (value) {
                setState(() {
                  wasteEntries[index]['wasteType'] = value;
                });
              },
              controller: TextEditingController(
                text: wasteEntries[index]['wasteType'] ?? '',
              ),
              readOnly: true,
            ),
            SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Bag Count',
                labelStyle: TextStyle(
                  color: Color.fromARGB(255, 69, 69, 69),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                fillColor: Color.fromARGB(255, 235, 235, 235),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(
                      color: Color.fromARGB(255, 236, 236, 236), width: 2.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: Color(0xFF27AE60), width: 2.0),
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  wasteEntries[index]['bagCount'] = int.tryParse(value) ?? 0;
                });
              },
              controller: TextEditingController(
                text: wasteEntries[index]['bagCount']?.toString() ?? '',
              ),
              readOnly: true,
            ),
            SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Weight',
                labelStyle: TextStyle(
                  color: Color.fromARGB(255, 70, 164, 97),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                fillColor: Color.fromARGB(255, 255, 255, 255),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(
                      color: Color.fromARGB(255, 236, 236, 236), width: 2.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: Color(0xFF27AE60), width: 2.0),
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  if (_isValidWeight(value)) {
                    wasteEntries[index]['weight'] =
                        value.isNotEmpty ? double.tryParse(value) : null;
                  }
                });
              },
              controller: wasteEntryControllers[index],
            ),
          ],
        ),
      ),
    );
  }

  bool _isValidWeight(String value) {
    if (value.isEmpty) return true;
    return RegExp(r'^\d*\.?\d*$').hasMatch(value);
  }

  String? _getWeightErrorText(String value) {
    if (value.isEmpty) return null;
    if (!_isValidWeight(value)) {
      return 'Please enter a valid number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF27AE60),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        title: const Text("Insert Garbage Weight",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: documentData == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView(
                children: [
                  Card(
                    elevation: 2,
                    color: Color(0xFFFFFEF8),
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: addressController,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: "Address",
                              labelStyle: TextStyle(
                                color: Color.fromARGB(255, 69, 69, 69),
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                              fillColor: Color.fromARGB(255, 235, 235, 235),
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 236, 236, 236),
                                    width: 2.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                                borderSide: BorderSide(
                                    color: Color(0xFF27AE60), width: 2.0),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 16),
                            ),
                            style: const TextStyle(
                                color: Color.fromARGB(255, 133, 133, 133)),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: pickupDateController,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: "Pickup Date",
                              labelStyle: TextStyle(
                                color: Color.fromARGB(255, 69, 69, 69),
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                              fillColor: Color.fromARGB(255, 235, 235, 235),
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 236, 236, 236),
                                    width: 2.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                                borderSide: BorderSide(
                                    color: Color(0xFF27AE60), width: 2.0),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 16),
                            ),
                            style: const TextStyle(
                                color: Color.fromARGB(255, 133, 133, 133)),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: pickupTimeController,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: "Pickup Time",
                              labelStyle: TextStyle(
                                color: Color.fromARGB(255, 69, 69, 69),
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                              fillColor: Color.fromARGB(255, 235, 235, 235),
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 236, 236, 236),
                                    width: 2.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                                borderSide: BorderSide(
                                    color: Color(0xFF27AE60), width: 2.0),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 16),
                            ),
                            style: const TextStyle(
                                color: Color.fromARGB(255, 133, 133, 133)),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  const Text(
                    "Waste Details",
                    style: TextStyle(
                        color: Color.fromARGB(255, 66, 66, 66),
                        fontSize: 18,
                        fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 10),
                  ...wasteEntries
                      .asMap()
                      .entries
                      .map((entry) => _buildWasteEntryEditor(entry.key))
                      .toList(),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await _submitEditedData();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const QRCodeScanner(),
                        ),
                      );
                    },
                    child: Text("Submit Weights"),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color(0xFF5FAD46),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("OK"),
            )
          ],
        );
      },
    );
  }
}
