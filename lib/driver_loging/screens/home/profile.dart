import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final String driverId;

  const ProfilePage({super.key, required this.driverId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? driverData;

  Future<void> getDriverDetails() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('drivers')
          .doc(widget.driverId)
          .get();

      if (doc.exists) {
        setState(() {
          driverData = doc.data();
        });
      } else {
        setState(() {
          driverData = null; // No data found
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        driverData = null; // In case of error, set data to null
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getDriverDetails(); // Fetch the driver's details when the page loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Driver Profile", style: TextStyle(fontSize: 22)),
        backgroundColor: const Color(0Xff27AE60),
      ),
      body: driverData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey,
                    backgroundImage:
                        AssetImage("assets/images/driver_avatar.png"),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Driver Details",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0Xff27AE60),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                    shadowColor: Colors.black12,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProfileDetail("Name", driverData!['name']),
                          const Divider(thickness: 1),
                          _buildProfileDetail("Phone", driverData!['phone']),
                          const Divider(thickness: 1),
                          _buildProfileDetail("Driving License",
                              driverData!['driving_license_number']),
                          const Divider(thickness: 1),
                          _buildProfileDetail("NIC", driverData!['nic']),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.exit_to_app),
                    label: const Text("Log Out"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0Xff27AE60),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Helper method to build each profile detail row
  Widget _buildProfileDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$label:",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
