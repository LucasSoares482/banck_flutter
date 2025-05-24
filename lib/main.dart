// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'routes/app_routes.dart';
import 'services/auth_service.dart';
import 'services/transaction_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/currency_screen.dart';
import 'screens/transfer_screen.dart';
import 'screens/transfer_confirm_screen.dart';
import 'screens/register_screen.dart';
import 'screens/simple_currency_converter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => TransactionService()),
      ],
      child: MaterialApp(
        title: 'BankFlutter',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          // fontFamily: 'Montserrat',
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
        initialRoute: AppRoutes.login,
        routes: {
          AppRoutes.login: (context) => const LoginScreen(),
          AppRoutes.home: (context) => const HomeScreen(),
          AppRoutes.currency: (context) => const CurrencyScreen(),
          AppRoutes.transfer: (context) => const TransferScreen(),
          AppRoutes.register: (context) => const RegisterScreen(),
          AppRoutes.currencyConverter: (context) => const SimpleCurrencyConverter(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == AppRoutes.transferConfirm) {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => TransferConfirmScreen(
                recipient: args['recipient'],
                amount: args['amount'],
                description: args['description'],
              ),
            );
          }
          return null;
        },
      ),
    );
  }
}