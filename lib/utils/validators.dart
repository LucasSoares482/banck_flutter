// lib/utils/validators.dart
class Validators {
  // Email validator
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, informe seu email';
    }
    
    final emailRegExp = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    if (!emailRegExp.hasMatch(value)) {
      return 'Por favor, informe um email válido';
    }
    
    return null;
  }
  
  // Password validator
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, informe sua senha';
    }
    
    if (value.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }
    
    return null;
  }
  
  // Account number validator
  static String? validateAccountNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, informe o número da conta';
    }
    
    final accountRegExp = RegExp(r'^\d{5}-\d{1}$');
    if (!accountRegExp.hasMatch(value)) {
      return 'Formato inválido. Use: 12345-6';
    }
    
    return null;
  }
  
  // Amount validator
  static String? validateAmount(String? value, double availableBalance) {
    if (value == null || value.isEmpty) {
      return 'Por favor, informe o valor';
    }
    
    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Valor inválido';
    }
    
    if (amount <= 0) {
      return 'O valor deve ser maior que zero';
    }
    
    if (amount > availableBalance) {
      return 'Saldo insuficiente';
    }
    
    return null;
  }
}