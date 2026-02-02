import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeVehiclePage extends StatefulWidget {
  const HomeVehiclePage({super.key});

  @override
  State<HomeVehiclePage> createState() => _HomeVehiclePageState();
}

class _HomeVehiclePageState extends State<HomeVehiclePage> {
  bool showAddForm = false;
  bool showMap = false;
  bool hideCode = true;
  bool loading = false;

  final deviceIdController = TextEditingController();
  final verificationCodeController = TextEditingController();
  final brandController = TextEditingController();
  final modelController = TextEditingController();
  final licenseController = TextEditingController();
  final colorController = TextEditingController();

  // ===== MAP STATE =====
  String? activeDeviceId;
  double? lat;
  double? lng;
  String? gpsTime;
  StreamSubscription<DatabaseEvent>? locationSub;

  @override
  void dispose() {
    locationSub?.cancel();
    super.dispose();
  }

  void resetForm() {
    deviceIdController.clear();
    verificationCodeController.clear();
    brandController.clear();
    modelController.clear();
    licenseController.clear();
    colorController.clear();
    hideCode = true;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Row(
        children: [
          // ================= SIDEBAR =================
          if (user != null)
            Container(
              width: 300,
              padding: const EdgeInsets.all(16),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('devices')
                    .where('userId', isEqualTo: user.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();

                  return ListView(
                    children: snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final vehicle = data['vehicle'] ?? {};
                      final status =
                          data['status'] == true || data['status'] == 1;

                      return _vehicleCard(doc.id, vehicle, status);
                    }).toList(),
                  );
                },
              ),
            ),

          // ================= MAIN =================
          Expanded(
            child: Stack(
              children: [
                if (showMap) _mapView(),
                if (!showMap) _addVehicleBox(),
                if (showAddForm) _addForm(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= VEHICLE CARD =================
  Widget _vehicleCard(String deviceId, Map vehicle, bool status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                status ? Icons.wifi : Icons.wifi_off,
                size: 16,
                color: status ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'ID: $deviceId',
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.search, size: 18),
                onPressed: () => _showVerifyDialog(deviceId),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _infoRow(Icons.directions_bike, vehicle['brand']),
          _infoRow(Icons.settings, vehicle['model']),
          _infoRow(Icons.confirmation_number, vehicle['licensePlate']),
          _infoRow(Icons.color_lens, vehicle['color']),
        ],
      ),
    );
  }

  // ================= ADD VEHICLE BOX =================
  Widget _addVehicleBox() {
    return Center(
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 12),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Vehicle',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                  setState(() {
                    resetForm();
                    showAddForm = true;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= MAP VIEW =================
  Widget _mapView() {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(lat ?? 21.0285, lng ?? 105.8542),
            zoom: 16,
          ),
          markers: lat != null && lng != null && activeDeviceId != null
              ? {
                  Marker(
                    markerId: MarkerId(activeDeviceId!),
                    position: LatLng(lat!, lng!),
                    infoWindow: InfoWindow(
                      title: activeDeviceId,
                      snippet: gpsTime,
                    ),
                  ),
                }
              : {},
        ),

        // ===== EXIT MAP =====
        Positioned(
          top: 20,
          right: 20,
          child: FloatingActionButton(
            backgroundColor: Colors.red,
            child: const Icon(Icons.close),
            onPressed: () async {
              await locationSub?.cancel();
              setState(() {
                showMap = false;
                activeDeviceId = null;
                lat = null;
                lng = null;
              });
            },
          ),
        ),
      ],
    );
  }

  // ================= VERIFY DIALOG =================
  void _showVerifyDialog(String deviceId) {
    final codeCtrl = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Verify Device'),
        content: TextField(
          controller: codeCtrl,
          obscureText: true,
          decoration:
              const InputDecoration(labelText: 'Verification Code'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _verifyAndListen(deviceId, codeCtrl.text.trim());
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  // ================= VERIFY + REALTIME =================
  Future<void> _verifyAndListen(String deviceId, String code) async {
    final snap = await FirebaseFirestore.instance
        .collection('devices')
        .doc(deviceId)
        .get();

    if (!snap.exists || snap['verificationCode'] != code) {
      _toast('Verification failed', false);
      return;
    }

    _toast('Device verified', true);

    await locationSub?.cancel();
    setState(() {
      activeDeviceId = deviceId;
      showMap = true;
    });

    final ref = FirebaseDatabase.instance.ref('locations/$deviceId');
    locationSub = ref.onValue.listen((event) {
      if (!event.snapshot.exists) return;
      final data = event.snapshot.value as Map;
      setState(() {
        lat = data['latitude']?.toDouble();
        lng = data['longitude']?.toDouble();
        gpsTime = data['time'];
      });
    });
  }

  // ================= ADD FORM =================
  Widget _addForm() {
    return Positioned.fill(
      child: Container(
        color: Colors.black45,
        child: Center(
          child: Container(
            width: 460,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _input(deviceIdController, 'Device ID'),
                _passwordInput(),
                _input(brandController, 'Brand'),
                _input(modelController, 'Model'),
                _input(licenseController, 'License Plate'),
                _input(colorController, 'Color'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: loading ? null : submitVehicle,
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= SAVE DEVICE =================
  Future<void> submitVehicle() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => loading = true);

    final deviceId = deviceIdController.text.trim();

    await FirebaseFirestore.instance
        .collection('devices')
        .doc(deviceId)
        .set({
      'verificationCode': verificationCodeController.text.trim(),
      'userId': user.uid,
      'status': false,
      'vehicle': {
        'brand': brandController.text.trim(),
        'model': modelController.text.trim(),
        'licensePlate': licenseController.text.trim(),
        'color': colorController.text.trim(),
      },
    }, SetOptions(merge: true));

    setState(() {
      loading = false;
      showAddForm = false;
      resetForm();
    });
  }

  // ================= UTIL =================
  void _toast(String msg, bool ok) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: ok ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _infoRow(IconData icon, String? text) {
    if (text == null || text.isEmpty) return const SizedBox();
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 6),
        Text(text,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _passwordInput() {
    return TextField(
      controller: verificationCodeController,
      obscureText: hideCode,
      decoration: InputDecoration(
        labelText: 'Verification Code',
        suffixIcon: IconButton(
          icon:
              Icon(hideCode ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => hideCode = !hideCode),
        ),
      ),
    );
  }

  Widget _input(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
