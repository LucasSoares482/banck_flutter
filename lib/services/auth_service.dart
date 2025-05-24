// lib/services/auth_service.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import '../models/user.dart';

class AuthService with ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();
  
  User? _currentUser;
  bool _isLoading = false;
  
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  
  // Mock user for demonstration purposes
  final User _mockUser = User(
    id: '1',
    name: 'João Silva',
    email: 'joao@email.com',
    accountNumber: '12345-6',
    balance: 2500.00,
    avatarUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
  );

  // Login with email and password
  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Simulate API request delay
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock validation (in a real app, this would be a server request)
      if (email == 'user@example.com' && password == '123456') {
        _currentUser = _mockUser;
        
        // Save user session
        await _storage.write(key: 'user_id', value: _currentUser!.id);
        await _storage.write(key: 'user_email', value: _currentUser!.email);
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
    Future<bool> loginWithCustomData(String email, String name, double initialBalance) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Simular atraso de rede
      await Future.delayed(const Duration(seconds: 1));
      
      // Criar usuário com dados personalizados
      _currentUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // ID único baseado no timestamp
        name: name,
        email: email,
        accountNumber: '${10000 + DateTime.now().millisecondsSinceEpoch % 90000}',
        balance: initialBalance,
        avatarUrl: '', // Sem avatar para evitar erros de carregamento
      );
      
      // Salvar sessão do usuário
      await _storage.write(key: 'user_id', value: _currentUser!.id);
      await _storage.write(key: 'user_email', value: _currentUser!.email);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Check if biometric authentication is available
  Future<bool> isBiometricAvailable() async {
    try {
      final canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final canAuthenticate = canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();
      return canAuthenticate;
    } catch (e) {
      return false;
    }
  }
  
  // Authenticate with biometrics
  Future<bool> authenticateWithBiometrics() async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Autentique-se para acessar o aplicativo',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      
      if (authenticated) {
        // Check if there's a stored user session
        final userId = await _storage.read(key: 'user_id');
        
        if (userId != null) {
          // In a real app, you would fetch user data from the server
          // Here we use the mock user
          _currentUser = _mockUser;
          notifyListeners();
          return true;
        }
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }
  
  // Logout
  Future<void> logout() async {
    _currentUser = null;
    await _storage.deleteAll();
    notifyListeners();
  }
  
  // Check if user is already logged in (for auto-login)
  Future<bool> tryAutoLogin() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final userId = await _storage.read(key: 'user_id');
      
      if (userId != null) {
        // In a real app, you would fetch user data from the server
        // Here we use the mock user
        _currentUser = _mockUser;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Update user balance (for transfers)
  void updateBalance(double newBalance) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(balance: newBalance);
      notifyListeners();
    }
  }
}