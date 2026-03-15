import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/purchase/purchase_screen.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/transactions/transactions_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String purchase = '/purchase';
  static const String transactions = '/transactions';
  static const String reports = '/reports';

  static Map<String, WidgetBuilder> routes = {
    splash: (_) => const SplashScreen(),
    login: (_) => const LoginScreen(),
    signup: (_) => const SignupScreen(),
    home: (_) => const HomeScreen(),
    purchase: (_) => const PurchaseScreen(),
    transactions: (_) => const TransactionsScreen(),
    reports: (_) => const ReportsScreen(),
  };
}
