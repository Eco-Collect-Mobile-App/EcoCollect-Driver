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

  // Add TextEditingController for editable fields
  late TextEditingController addressController;
  late TextEditingController nicController;
  late TextEditingController pickupDateController;
  late TextEditingController pickupTimeController;
  late List<TextEditingController>
      wasteEntryControllers; // Controllers for waste entries
  late List<Map<String, dynamic>> wasteEntries;

  @override
  void initState() {
    super.initState();
    wasteEntryControllers = []; // Initialize the list for controllers
    _fetchDocumentFromFirestore(widget.documentId);
  }

  @override
  void dispose() {
    // Dispose of all controllers
    addressController.dispose();
    nicController.dispose();
    pickupDateController.dispose();
    pickupTimeController.dispose();
    for (var controller in wasteEntryControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // Method to fetch Firestore document using the scanned document ID
  Future<void> _fetchDocumentFromFirestore(String? documentId) async {
    if (documentId != null) {
      print("Scanned Document ID: $documentId"); // Log the scanned ID
      try {
        DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
            .collection('wasteData')
            .doc(documentId)
            .get();

        if (documentSnapshot.exists) {
          setState(() {
            documentData = documentSnapshot.data() as Map<String, dynamic>?;

            // Initialize TextEditingControllers with fetched data
            addressController =
                TextEditingController(text: documentData?['address'] ?? '');
            nicController =
                TextEditingController(text: documentData?['nic'] ?? '');
            pickupDateController =
                TextEditingController(text: documentData?['pickupDate'] ?? '');
            pickupTimeController =
                TextEditingController(text: documentData?['pickupTime'] ?? '');

            // Initialize waste entries
            wasteEntries = List<Map<String, dynamic>>.from(
                documentData?['wasteEntries'] ?? []);

            // Initialize controllers for waste entries
            wasteEntryControllers = wasteEntries
                .map((entry) => TextEditingController(
                    text: entry['weight']?.toString() ??
                        '')) // Initialize with weight
                .toList();
          });

          // Log to verify all fetched data
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

  // Method to update Firestore document with edited data
  Future<void> _submitEditedData() async {
    if (widget.documentId != null && documentData != null) {
      try {
        // Update the wasteEntries with current values from controllers
        for (int i = 0; i < wasteEntries.length; i++) {
          wasteEntries[i]['weight'] = wasteEntryControllers[i].text.isNotEmpty
              ? wasteEntryControllers[i].text
              : null; // Allow null if empty
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

        // Show confirmation message
        _showConfirmation("Data updated successfully.");
      } catch (e) {
        print("Error updating document: $e");
        _showError("Failed to update data. Please try again.");
      }
    }
  }

  // Show a confirmation dialog after successful submission
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

  // Widget for displaying and editing waste entries
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
                fillColor:
                    Color.fromARGB(255, 235, 235, 235), // Change fill color
                filled: true, // Enable the fill color
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
                text: wasteEntries[index]['wasteType'] ??
                    '', // Use empty string if null
              ),
              readOnly: true, // Make this field read-only
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
                fillColor:
                    Color.fromARGB(255, 235, 235, 235), // Change fill color
                filled: true, // Enable the fill color
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
                text: wasteEntries[index]['bagCount']?.toString() ??
                    '', // Use empty string if null
              ),
              readOnly: true, // Make this field read-only
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: 'Weight',
                labelStyle: TextStyle(
                  color: Color.fromARGB(255, 70, 164, 97),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                fillColor:
                    Color.fromARGB(255, 235, 235, 235), // Change fill color
                filled: true, // Enable the fill color
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
              keyboardType: TextInputType.text, // Allow any text input
              onChanged: (value) {
                setState(() {
                  // Store weight as a string; accept any input
                  wasteEntries[index]['weight'] =
                      value.isNotEmpty ? value : null; // Allow null if empty
                });
              },
              controller: wasteEntryControllers[
                  index], // Use the controller from the list
            ),
          ],
        ),
      ),
    );
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
        title: const Text("Insert Garbage Weights",
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
                            decoration: InputDecoration(
                              labelText: "Address",
                              labelStyle: TextStyle(
                                color: Color.fromARGB(255, 69, 69, 69),
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                              fillColor: Color.fromARGB(
                                  255, 235, 235, 235), // Change fill color
                              filled: true, // Enable the fill color
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
                            style: TextStyle(
                                color:
                                    const Color.fromARGB(255, 133, 133, 133)),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: pickupDateController,
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: "Pickup Date",
                              labelStyle: TextStyle(
                                color: Color.fromARGB(255, 69, 69, 69),
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                              fillColor: Color.fromARGB(
                                  255, 235, 235, 235), // Change fill color
                              filled: true, // Enable the fill color
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
                            style: TextStyle(
                                color:
                                    const Color.fromARGB(255, 133, 133, 133)),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: pickupTimeController,
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: "Pickup Time",
                              labelStyle: TextStyle(
                                color: Color.fromARGB(255, 69, 69, 69),
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                              fillColor: Color.fromARGB(
                                  255, 235, 235, 235), // Change fill color
                              filled: true, // Enable the fill color
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
                            style: TextStyle(
                                color:
                                    const Color.fromARGB(255, 133, 133, 133)),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Waste Details",
                    style: TextStyle(
                        color: const Color.fromARGB(255, 66, 66, 66),
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
                      await _submitEditedData(); // Submit the edited data
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const QRCodeScanner(), // Navigate to QRCodeScanner
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

  // Show error message if fetching fails or document is not found
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
