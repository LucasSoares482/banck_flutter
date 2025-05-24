// lib/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../routes/app_routes.dart';
import '../utils/validators.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Simulando uma operação de rede
        await Future.delayed(const Duration(seconds: 1));

        // Obter SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        
        // Verificar se o email já está registrado
        final existingUsers = prefs.getStringList('registered_emails') ?? [];
        if (existingUsers.contains(_emailController.text)) {
          if (!mounted) return;
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Este email já está registrado.'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }

        // Salvar os dados do usuário
        existingUsers.add(_emailController.text);
        await prefs.setStringList('registered_emails', existingUsers);
        await prefs.setString('user_${_emailController.text}_name', _nameController.text);
        await prefs.setString('user_${_emailController.text}_password', _passwordController.text);

        if (!mounted) return;

        // Mostrar mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cadastro realizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        // Redirecionar para login
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      } catch (e) {
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao realizar cadastro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App logo
                  Icon(
                    Icons.account_balance,
                    size: 64,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 16),
                  
                  // App name
                  Text(
                    'Criar conta no BankFlutter',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Name field
                  CustomInput(
                    label: 'Nome completo',
                    hint: 'Digite seu nome completo',
                    controller: _nameController,
                    prefixIcon: const Icon(Icons.person),
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, informe seu nome';
                      }
                      if (value.trim().split(' ').length < 2) {
                        return 'Por favor, informe nome e sobrenome';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Email field
                  CustomInput(
                    label: 'Email',
                    hint: 'Digite seu email',
                    controller: _emailController,
                    prefixIcon: const Icon(Icons.email),
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                  ),
                  const SizedBox(height: 16),
                  
                  // Password field
                  CustomInput(
                    label: 'Senha',
                    hint: 'Crie uma senha',
                    controller: _passwordController,
                    prefixIcon: const Icon(Icons.lock),
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, informe uma senha';
                      }
                      if (value.length < 6) {
                        return 'A senha deve ter pelo menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Confirm password field
                  CustomInput(
                    label: 'Confirmar senha',
                    hint: 'Digite a senha novamente',
                    controller: _confirmPasswordController,
                    prefixIcon: const Icon(Icons.lock_outline),
                    obscureText: _obscureConfirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, confirme sua senha';
                      }
                      if (value != _passwordController.text) {
                        return 'As senhas não conferem';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Register button
                  CustomButton(
                    text: 'Cadastrar',
                    isLoading: _isLoading,
                    onPressed: _register,
                  ),
                  const SizedBox(height: 16),
                  
                  // Login option
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Já tem uma conta?'),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                        },
                        child: const Text('Entrar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}