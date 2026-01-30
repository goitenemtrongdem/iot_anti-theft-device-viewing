import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();
  final AuthService _authService = AuthService();

  bool loading = false;
  bool emailSent = false;
  String message = '';

  Future<void> handleReset() async {
    setState(() {
      loading = true;
      message = '';
    });

    try {
      await _authService.sendResetPasswordEmail(
        emailController.text.trim(),
      );

      setState(() {
        emailSent = true;
        message =
            'Password reset link sent.\nPlease check your Gmail.';
      });
    } catch (e) {
      setState(() {
        message = 'Failed to send reset email';
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
          // BACK
          Positioned(
            top: 32,
            left: 24,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: Row(
                children: const [
                  Icon(Icons.arrow_back_ios, size: 18),
                  SizedBox(width: 4),
                  Text('Back'),
                ],
              ),
            ),
          ),

          Center(
            child: Container(
              width: 420,
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reset your password',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),

                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: loading ? null : handleReset,
                      child: loading
                          ? const CircularProgressIndicator()
                          : const Text('Next'),
                    ),
                  ),

                  if (emailSent) ...[
                    const SizedBox(height: 16),
                    Text(
                      message,
                      style: const TextStyle(color: Colors.green),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Back to Sign in'),
                    ),
                  ],

                  if (!emailSent && message.isNotEmpty)
                    Text(message,
                        style: const TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
