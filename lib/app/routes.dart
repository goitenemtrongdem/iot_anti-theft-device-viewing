import 'package:flutter/material.dart';

import '../features/auth/landing_page.dart';
import '../features/auth/signup_page.dart';
import '../features/auth/signin_page.dart';
import '../features/auth/forgot_password_page.dart';
import '../features/profile/fill_all_to_submit_page.dart';
import '../features/main/main_page.dart';

class AppRoutes {
  static const String landing = '/';
  static const String signup = '/signup';
  static const String signin = '/signin';
  static const String forgotPassword = '/forgot-password';
  static const String fillProfile = '/fill-profile';
  static const String main = '/main';

  static Map<String, WidgetBuilder> routes = {
    landing: (context) => const LandingPage(),
    signup: (context) => const SignupPage(),
    signin: (context) => const SignInPage(),
    forgotPassword: (context) => const ForgotPasswordPage(),
    fillProfile: (context) => const FillAllToSubmitPage(),
    main: (context) => const MainPage(),
  };
}
