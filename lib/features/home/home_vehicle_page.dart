import 'package:flutter/material.dart';
import '../vehicle/add_vehicle_page.dart';
// import '../features/main/main_page.dart';
class HomeVehiclePage extends StatelessWidget {
  const HomeVehiclePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vehicle',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Don't have device info, Please add device",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_link),
                label: const Text('Add vehicle here'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddVehiclePage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
