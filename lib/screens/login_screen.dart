// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../routes/app_routes.dart';
import '../services/auth_service.dart';
import '../widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  @override
  void initState() {
    super.initState();
    // Fill in demo credentials for ease of testing
    _emailController.text = 'user@example.com';
    _passwordController.text = '123456';
    
    // Check if biometric login is possible
    _checkBiometricAvailability();
  }
  
  Future<void> _checkBiometricAvailability() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final canUseBiometrics = await authService.isBiometricAvailable();
    
    if (canUseBiometrics) {
      // Show biometric prompt automatically
      _authenticateWithBiometrics();
    }
  }
  
  Future<void> _authenticateWithBiometrics() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final authenticated = await authService.authenticateWithBiometrics();
    
    if (authenticated) {
      _navigateToHome();
    }
  }
  
  void _navigateToHome() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }
  
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      // Verificar se o usuário está usando credenciais padrão
      if (_emailController.text == 'user@example.com' && _passwordController.text == '123456') {
        final success = await authService.login(
          _emailController.text,
          _passwordController.text,
        );
        
        if (success) {
          _navigateToHome();
        } else {
          // Show error message
          if (!mounted) return;
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Falha no login. Verifique suas credenciais.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      
      // Verificar credenciais em SharedPreferences para usuários cadastrados
      final prefs = await SharedPreferences.getInstance();
      final existingUsers = prefs.getStringList('registered_emails') ?? [];
      
      if (existingUsers.contains(_emailController.text)) {
        final savedPassword = prefs.getString('user_${_emailController.text}_password') ?? '';
        
        if (savedPassword == _passwordController.text) {
          // Login bem-sucedido para usuário registrado
          final userName = prefs.getString('user_${_emailController.text}_name') ?? 'Usuário';
          
          // Login personalizado usando os dados do SharedPreferences
          final success = await authService.loginWithCustomData(
            _emailController.text,
            userName,
            10000.00, // Saldo inicial para novos usuários
          );
          
          if (success) {
            _navigateToHome();
          } else {
            if (!mounted) return;
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Falha no login. Tente novamente.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          // Senha incorreta
          if (!mounted) return;
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Senha incorreta. Tente novamente.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // Email não cadastrado
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email não cadastrado. Crie uma conta primeiro.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.06),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width > 600 ? 400 : double.infinity,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // App logo
                    Icon(
                      Icons.account_balance,
                      size: MediaQuery.of(context).size.width * 0.2,
                      color: Theme.of(context).primaryColor,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    
                    // App name
                    Text(
                      'BankFlutter',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                        fontSize: MediaQuery.of(context).size.width * 0.07,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.06),
                    
                    // Email field
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira seu email';
                        }
                        if (!value.contains('@')) {
                          return 'Por favor, insira um email válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible 
                              ? Icons.visibility 
                              : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      obscureText: !_isPasswordVisible,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira sua senha';
                        }
                        if (value.length < 6) {
                          return 'A senha deve ter pelo menos 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    
                    // Remember me checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value ?? false;
                            });
                          },
                        ),
                        const Text('Lembrar de mim'),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            // Implement forgot password
                          },
                          child: const Text('Esqueceu a senha?'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Login button
                    CustomButton(
                      text: 'Entrar',
                      isLoading: authService.isLoading,
                      onPressed: _login,
                    ),
                    const SizedBox(height: 16),
                    
                    // Biometric login
                    FutureBuilder<bool>(
                      future: authService.isBiometricAvailable(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data == true) {
                          return OutlinedButton.icon(
                            icon: const Icon(Icons.fingerprint),
                            label: const Text('Entrar com biometria'),
                            onPressed: _authenticateWithBiometrics,
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 32),
                    
                    // Register option
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Não tem uma conta?'),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacementNamed(AppRoutes.register);
                          },
                          child: const Text('Cadastre-se'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}