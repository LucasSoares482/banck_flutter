// lib/utils/formatters.dart
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

// Currency input formatter
class CurrencyInputFormatter extends TextInputFormatter {
  final int maxDigits;
  
  CurrencyInputFormatter({this.maxDigits = 10});
  
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }
    
    // Remove all non-digit characters
    String newText = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    // Limit the maximum number of digits
    if (newText.length > maxDigits) {
      newText = newText.substring(0, maxDigits);
    }
    
    // Convert to double and format
    double value = double.parse(newText) / 100;
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: '');
    
    String formattedValue = formatter.format(value);
    
    return TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );
  }
}

// CPF input formatter (Brazilian ID)
class CPFInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;
    
    if (newText.isEmpty) {
      return newValue;
    }
    
    // Remove all non-digit characters
    final digitsOnly = newText.replaceAll(RegExp(r'[^\d]'), '');
    
    // Format as CPF: XXX.XXX.XXX-XX
    final formattedValue = _formatCPF(digitsOnly);
    
    return TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );
  }
  
  String _formatCPF(String value) {
    // Limit to 11 digits
    if (value.length > 11) {
      value = value.substring(0, 11);
    }
    
    // Apply CPF formatting
    final result = StringBuffer();
    
    for (var i = 0; i < value.length; i++) {
      if (i == 3 || i == 6) {
        result.write('.');
      } else if (i == 9) {
        result.write('-');
      }
      result.write(value[i]);
    }
    
    return result.toString();
  }
}

// Phone number formatter
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;
    
    if (newText.isEmpty) {
      return newValue;
    }
    
    // Remove all non-digit characters
    final digitsOnly = newText.replaceAll(RegExp(r'[^\d]'), '');
    
    // Format as phone: (XX) XXXXX-XXXX
    final formattedValue = _formatPhone(digitsOnly);
    
    return TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );
  }
  
  String _formatPhone(String value) {
    // Limit to 11 digits (with area code)
    if (value.length > 11) {
      value = value.substring(0, 11);
    }
    
    // Apply phone formatting
    final result = StringBuffer();
    
    for (var i = 0; i < value.length; i++) {
      if (i == 0) {
        result.write('(');
      }
      if (i == 2) {
        result.write(') ');
      }
      if (i == 7) {
        result.write('-');
      }
      result.write(value[i]);
    }
    
    return result.toString();
  }
}

// Date formatter
class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;
    
    if (newText.isEmpty) {
      return newValue;
    }
    
    // Remove all non-digit characters
    final digitsOnly = newText.replaceAll(RegExp(r'[^\d]'), '');
    
    // Format as date: DD/MM/YYYY
    final formattedValue = _formatDate(digitsOnly);
    
    return TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );
  }
  
  String _formatDate(String value) {
    // Limit to 8 digits
    if (value.length > 8) {
      value = value.substring(0, 8);
    }
    
    // Apply date formatting
    final result = StringBuffer();
    
    for (var i = 0; i < value.length; i++) {
      if (i == 2 || i == 4) {
        result.write('/');
      }
      result.write(value[i]);
    }
    
    return result.toString();
  }
}