import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool loading = false;
  bool verificationSent = false;
  String message = '';

  Future<void> handleNext() async {
    setState(() {
      loading = true;
      message = '';
    });

    try {
      // STEP 1: gửi mail xác thực
      if (!verificationSent) {
        await _authService.signUpWithEmail(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        setState(() {
          verificationSent = true;
          message =
              'Verification email sent.\nPlease check your Gmail and verify.';
        });
      }
      // STEP 2: kiểm tra xác thực
      else {
        final verified = await _authService.isEmailVerified();

        if (verified) {
          await _authService.saveUserToDatabase();
          Navigator.pushReplacementNamed(context, '/fill-profile');
        } else {
          setState(() {
            message = 'Email not verified yet. Please check your inbox.';
          });
        }
      }
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
            width: 420,
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back\nSign up to your account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),

                TextField(
                  controller: emailController,
                  enabled: !verificationSent,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: passwordController,
                  obscureText: true,
                  enabled: !verificationSent,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading ? null : handleNext,
                    child: loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            verificationSent
                                ? 'I have verified my email'
                                : 'Next',
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                if (message.isNotEmpty)
                  Text(
                    message,
                    style: TextStyle(
                      color:
                          verificationSent ? Colors.green : Colors.red,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
}