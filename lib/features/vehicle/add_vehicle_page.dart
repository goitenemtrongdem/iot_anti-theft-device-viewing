import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddVehiclePage extends StatefulWidget {
  const AddVehiclePage({super.key});

  @override
  State<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  final vehicleIdCtrl = TextEditingController();
  final codeCtrl = TextEditingController();
  final brandCtrl = TextEditingController();
  final modelCtrl = TextEditingController();
  final licenseCtrl = TextEditingController();
  final colorCtrl = TextEditingController();

  bool loading = false;
  String error = '';

  Future<void> submit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      loading = true;
      error = '';
    });

    try {
      final doc = FirebaseFirestore.instance
          .collection('devices')
          .doc(vehicleIdCtrl.text.trim());

      final snap = await doc.get();

      if (!snap.exists) {
        throw 'Device not found';
      }

      if (snap['verificationCode'] != codeCtrl.text.trim()) {
        throw 'Verification code is incorrect';
      }

      await doc.update({
        'userId': user.uid,
        'vehicle': {
          'brand': brandCtrl.text.trim(),
          'model': modelCtrl.text.trim(),
          'licensePlate': licenseCtrl.text.trim(),
          'color': colorCtrl.text.trim(),
        },
        'status': 1,
      });

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Vehicle')),
      body: Center(
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _field(vehicleIdCtrl, 'Vehicle ID'),
              _field(codeCtrl, 'Verification Code'),
              _field(brandCtrl, 'Brand'),
              _field(modelCtrl, 'Model'),
              _field(licenseCtrl, 'License Plate'),
              _field(colorCtrl, 'Color'),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : submit,
                  child: loading
                      ? const CircularProgressIndicator()
                      : const Text('Link Vehicle'),
                ),
              ),

              if (error.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(error, style: const TextStyle(color: Colors.red)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
