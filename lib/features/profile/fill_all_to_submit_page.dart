import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';

class FillAllToSubmitPage extends StatefulWidget {
  const FillAllToSubmitPage({super.key});

  @override
  State<FillAllToSubmitPage> createState() => _FillAllToSubmitPageState();
}

class _FillAllToSubmitPageState extends State<FillAllToSubmitPage> {
  final _authService = AuthService();

  final fullNameController = TextEditingController();
  final addressController = TextEditingController();
  final birthdayController = TextEditingController();
  final citizenController = TextEditingController();

  bool loading = false;
  String message = '';

  Future<void> submitProfile() async {
    setState(() {
      loading = true;
      message = '';
    });

    try {
      await _authService.saveUserProfile(
        fullName: fullNameController.text.trim(),
        address: addressController.text.trim(),
        dateOfBirth: birthdayController.text.trim(),
        citizenNumber: citizenController.text.trim(),
      );

     Navigator.pushNamedAndRemoveUntil(
  context,
  '/main',
  (route) => false,
);
    } catch (e) {
      setState(() {
        message = e.toString();
      });
    }

    setState(() {
      loading = false;
    });
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        // BACK BUTTON
        Positioned(
          top: 32,
          left: 24,
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(30),
            child: Row(
              children: const [
                Icon(Icons.arrow_back_ios, size: 18),
                SizedBox(width: 4),
                Text(
                  'Back',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),

        // MAIN CONTENT
        Center(
          child: Container(
            width: 450,
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Fill all to submit',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),

                TextField(
                  controller: fullNameController,
                  decoration: const InputDecoration(
                    labelText: 'Your fullname',
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Your address',
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: birthdayController,
                  decoration: const InputDecoration(
                    labelText: 'Your birthday (DD/MM/YYYY)',
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: citizenController,
                  decoration: const InputDecoration(
                    labelText: 'Your citizen number',
                  ),
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading ? null : submitProfile,
                    child: loading
                        ? const CircularProgressIndicator()
                        : const Text('Next'),
                  ),
                ),

                if (message.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
}