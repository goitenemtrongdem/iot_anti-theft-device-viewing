import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VehicleCardPage extends StatefulWidget {
  const VehicleCardPage({super.key});

  @override
  State<VehicleCardPage> createState() => _VehicleCardPageState();
}

class _VehicleCardPageState extends State<VehicleCardPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  bool showInspect = false;
  bool hideCode = true;
  String error = '';
  final verificationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    if (user == null) {
      return const Center(child: Text('User not logged in'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('devices')
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No vehicle found'));
        }

        final doc = snapshot.data!.docs.first;
        final data = doc.data() as Map<String, dynamic>;
        final vehicle = data['vehicle'] ?? {};
        final status = data['status'] == 1;

        return Center(
          child: Stack(
            children: [
              _vehicleCard(
                deviceId: doc.id,
                status: status,
                brand: vehicle['brand'],
                model: vehicle['model'],
                license: vehicle['licensePlate'],
                color: vehicle['color'],
              ),

              if (showInspect) _inspectDialog(doc.id),
            ],
          ),
        );
      },
    );
  }

  // ================= VEHICLE CARD =================
  Widget _vehicleCard({
    required String deviceId,
    required bool status,
    String? brand,
    String? model,
    String? license,
    String? color,
  }) {
    return Container(
      width: 420,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TOP ROW
          Row(
            children: [
              Icon(
                status ? Icons.toggle_on : Icons.toggle_off,
                size: 36,
                color: status ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                'id: $deviceId',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),

          const SizedBox(height: 12),

          _infoRow(Icons.directions_bike, brand),
          _infoRow(Icons.settings, model),
          _infoRow(Icons.confirmation_number, license),
          _infoRow(Icons.color_lens, color),

          const SizedBox(height: 16),

          Align(
            alignment: Alignment.bottomRight,
            child: TextButton(
              onPressed: () {
                setState(() {
                  showInspect = true;
                  error = '';
                  verificationController.clear();
                });
              },
              child: const Text('Inspect'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String? text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 6),
          Text(
            text ?? '-',
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // ================= INSPECT FORM =================
  Widget _inspectDialog(String deviceId) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.4),
        child: Center(
          child: Container(
            width: 360,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Verify Device',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: verificationController,
                  obscureText: hideCode,
                  decoration: InputDecoration(
                    labelText: 'Verification Code',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        hideCode
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => hideCode = !hideCode);
                      },
                    ),
                  ),
                ),

                if (error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(error,
                        style: const TextStyle(color: Colors.red)),
                  ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() => showInspect = false);
                      },
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => verifyDevice(deviceId),
                      child: const Text('Verify'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= VERIFY LOGIC =================
  Future<void> verifyDevice(String deviceId) async {
    try {
      final ref = _firestore.collection('devices').doc(deviceId);
      final snap = await ref.get();

      if (snap['verificationCode'] !=
          verificationController.text.trim()) {
        throw 'Verification code incorrect';
      }

      await ref.update({'status': 1});

      setState(() {
        showInspect = false;
      });
    } catch (e) {
      setState(() => error = e.toString());
    }
  }
}
