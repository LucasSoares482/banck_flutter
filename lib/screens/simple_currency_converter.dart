// lib/screens/simple_currency_converter.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/currency_service.dart';
import '../models/currency.dart';

class SimpleCurrencyConverter extends StatefulWidget {
  const SimpleCurrencyConverter({Key? key}) : super(key: key);

  @override
  State<SimpleCurrencyConverter> createState() => _SimpleCurrencyConverterState();
}

class _SimpleCurrencyConverterState extends State<SimpleCurrencyConverter> {
  final CurrencyService _currencyService = CurrencyService();
  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  
  List<Currency> _currencies = [];
  bool _isLoading = true;
  String _currency1 = 'BRL';
  String _currency2 = 'USD';
  bool _isUpdating = false;
  
  final Map<String, String> _currencyNames = {
    'BRL': 'Real Brasileiro',
    'USD': 'Dólar Americano',
    'EUR': 'Euro',
    'GBP': 'Libra Esterlina',
    'JPY': 'Iene Japonês',
    'CAD': 'Dólar Canadense',
    'AUD': 'Dólar Australiano',
    'CHF': 'Franco Suíço',
    'CNY': 'Yuan Chinês',
    'ARS': 'Peso Argentino',
    'BTC': 'Bitcoin',
  };

  @override
  void initState() {
    super.initState();
    _loadCurrencies();
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  Future<void> _loadCurrencies() async {
    try {
      final currencies = await _currencyService.getCurrencies();
      setState(() {
        _currencies = currencies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onField1Changed(String value) {
    if (_isUpdating) return;
    _convertCurrency(value, _currency1, _currency2, _controller2);
  }

  void _onField2Changed(String value) {
    if (_isUpdating) return;
    _convertCurrency(value, _currency2, _currency1, _controller1);
  }

  Future<void> _convertCurrency(String value, String from, String to, TextEditingController targetController) async {
    final amount = double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
    
    if (amount == 0) {
      targetController.clear();
      return;
    }

    _isUpdating = true;
    
    try {
      double convertedValue = 0.0;
      
      if (from == to) {
        convertedValue = amount;
      } else if (from == 'BRL') {
        final currency = _currencies.firstWhere(
          (c) => c.code == to,
          orElse: () => Currency(code: to, name: '', value: 1.0, variation: 0.0, lastUpdate: DateTime.now()),
        );
        convertedValue = amount / currency.value;
      } else if (to == 'BRL') {
        final currency = _currencies.firstWhere(
          (c) => c.code == from,
          orElse: () => Currency(code: from, name: '', value: 1.0, variation: 0.0, lastUpdate: DateTime.now()),
        );
        convertedValue = amount * currency.value;
      } else {
        final currencyFrom = _currencies.firstWhere(
          (c) => c.code == from,
          orElse: () => Currency(code: from, name: '', value: 1.0, variation: 0.0, lastUpdate: DateTime.now()),
        );
        final currencyTo = _currencies.firstWhere(
          (c) => c.code == to,
          orElse: () => Currency(code: to, name: '', value: 1.0, variation: 0.0, lastUpdate: DateTime.now()),
        );
        final brlValue = amount * currencyFrom.value;
        convertedValue = brlValue / currencyTo.value;
      }
      
      targetController.text = convertedValue.toStringAsFixed(2);
    } catch (e) {
      print('Erro na conversão: $e');
    }
    
    _isUpdating = false;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Conversor de Moedas'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversor de Moedas'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            
            // Título
            Icon(
              Icons.swap_horiz, 
              size: MediaQuery.of(context).size.width * 0.15, 
              color: Colors.blue
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Text(
              'Conversor de Moedas',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.06, 
                fontWeight: FontWeight.bold, 
                color: Colors.blue
              ),
            ),
            
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            
            // Primeiro campo
            Container(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(12),
                color: Colors.blue.withOpacity(0.05),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Primeira Moeda',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.04, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.blue
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _currency1,
                              isExpanded: true,
                              items: _currencyNames.keys.map((String currency) {
                                return DropdownMenuItem<String>(
                                  value: currency,
                                  child: Text(currency, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _currency1 = newValue;
                                  });
                                  if (_controller1.text.isNotEmpty) {
                                    _onField1Changed(_controller1.text);
                                  }
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _controller1,
                          decoration: InputDecoration(
                            hintText: '0.00',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: MediaQuery.of(context).size.width * 0.03, 
                              vertical: MediaQuery.of(context).size.height * 0.02
                            ),
                          ),
                          style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,8}'))],
                          onChanged: _onField1Changed,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currencyNames[_currency1] ?? _currency1,
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.03, 
                      color: Colors.grey[600]
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: MediaQuery.of(context).size.height * 0.04),
            
            // Ícone de troca
            Container(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.swap_vert, 
                color: Colors.white, 
                size: MediaQuery.of(context).size.width * 0.06
              ),
            ),
            
            SizedBox(height: MediaQuery.of(context).size.height * 0.04),
            
            // Segundo campo
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(12),
                color: Colors.blue.withOpacity(0.05),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Segunda Moeda',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _currency2,
                              isExpanded: true,
                              items: _currencyNames.keys.map((String currency) {
                                return DropdownMenuItem<String>(
                                  value: currency,
                                  child: Text(currency, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _currency2 = newValue;
                                  });
                                  if (_controller2.text.isNotEmpty) {
                                    _onField2Changed(_controller2.text);
                                  }
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _controller2,
                          decoration: InputDecoration(
                            hintText: '0.00',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,8}'))],
                          onChanged: _onField2Changed,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currencyNames[_currency2] ?? _currency2,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Botão de atualizar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _loadCurrencies,
                icon: const Icon(Icons.refresh),
                label: const Text('Atualizar Cotações'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}