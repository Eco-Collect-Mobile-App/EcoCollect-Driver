import 'package:eco_collect/driver_loging/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:eco_collect/pages/qr_code_scanner.dart';
import 'package:eco_collect/pages/all_requests.dart';
import 'package:eco_collect/driver_loging/screens/home/Home.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the NavigationController without passing driverId
    final NavigationController controller = Get.put(NavigationController());

    return Scaffold(
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
      bottomNavigationBar: Obx(
        () => BottomAppBar(
          color: const Color(0xFF27AE60),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(60),
            child: SizedBox(
              height: 64,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  buildIcon(controller, Iconsax.clock, 0),
                  buildIcon(controller, Iconsax.scan, 1),
                  buildIcon(controller, Iconsax.profile_circle, 2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build the icons
  Widget buildIcon(NavigationController controller, IconData icon, int index) {
    return IconButton(
      icon: Icon(
        icon,
        color: controller.selectedIndex.value == index
            ? Colors.white
            : Colors.black.withOpacity(0.4),
      ),
      onPressed: () {
        controller.selectedIndex.value = index;
      },
    );
  }
}

class NavigationController extends GetxController {
  // No longer need driverId
  NavigationController();

  // Observing the selectedIndex state
  final Rx<int> selectedIndex = 0.obs;

  // List of screens for navigation
  late final List<Widget> screens = [
    const PickupReqHistory(), // History page
    const QRCodeScanner(), // QR Scanner page
  ];
}
