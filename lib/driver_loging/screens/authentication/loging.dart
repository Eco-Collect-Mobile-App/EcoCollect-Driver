import 'package:eco_collect/driver_loging/cocnstants/colors.dart';
import 'package:eco_collect/driver_loging/cocnstants/discription.dart';
import 'package:eco_collect/driver_loging/cocnstants/styles.dart';

import 'package:eco_collect/driver_loging/screens/authentication/register.dart'; // Import the new register page
import 'package:eco_collect/driver_loging/screens/home/home.dart';
import 'package:eco_collect/driver_loging/services/auth_service.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  final Function toggle;

  const SignIn({Key? key, required this.toggle}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _formKey = GlobalKey<FormState>();
  String username = "";
  String nic = "";
  String error = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XffE7EBE8),
      appBar: AppBar(
        title: const Text("SIGN IN"),
        backgroundColor: const Color(0XffE7EBE8),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 15, right: 10),
          child: Column(
            children: [
              const Text(
                description,
                style: descriptionStyle,
              ),
              Center(
                child: Image.asset(
                  "assets/images/ecologo.png",
                  height: 200,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        style: const TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0)),
                        decoration:
                            TextInputDecorarion.copyWith(hintText: "Username"),
                        validator: (val) => val?.isEmpty == true
                            ? "Enter a valid username"
                            : null,
                        onChanged: (val) {
                          setState(() {
                            username = val;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        style: const TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0)),
                        decoration:
                            TextInputDecorarion.copyWith(hintText: "NIC"),
                        validator: (val) =>
                            val!.length < 6 ? "Enter a valid NIC" : null,
                        onChanged: (val) {
                          setState(() {
                            nic = val;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      Text(
                        error,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            final driverId =
                                await AuthService().signIn(username, nic);
                            if (driverId != null) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        Home(driverId: driverId)),
                              );
                            } else {
                              setState(() {
                                error = "Invalid username or NIC.";
                              });
                            }
                          }
                        },
                        child: Container(
                          height: 40,
                          width: 200,
                          decoration: BoxDecoration(
                            color: const Color(0Xff5FAD46),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(width: 2, color: mainYellow),
                          ),
                          child: const Center(
                            child: Text(
                              "LOG IN",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const Register(), // Navigate to Register page
                            ),
                          );
                        },
                        child: const Text(
                          "Don't have an account? Register here.",
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
