// lib/screens/transfer_screen.dart (Atualizado com Conversor)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../routes/app_routes.dart';
import '../services/auth_service.dart';
import '../services/currency_service.dart';
import '../models/currency.dart';
import '../widgets/custom_button.dart';
import 'simple_currency_converter.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({Key? key}) : super(key: key);

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  final CurrencyService _currencyService = CurrencyService();
  List<Currency> _currencies = [];
  String _selectedCurrency = 'BRL';
  double _convertedToBRL = 0.0;
  bool _isLoadingCurrencies = false;
  
  // Mock recipients for auto-complete
  final List<Map<String, String>> _mockRecipients = [
    {'name': 'Maria Silva', 'account': '23456-7'},
    {'name': 'Carlos Oliveira', 'account': '34567-8'},
    {'name': 'Ana Santos', 'account': '45678-9'},
    {'name': 'Paulo Mendes', 'account': '56789-0'},
  ];
  
  // Símbolos das moedas
  final Map<String, String> _currencySymbols = {
    'BRL': 'R\$',
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'JPY': '¥',
    'CAD': 'C\$',
    'AUD': 'A\$',
    'CHF': 'CHF',
    'CNY': '¥',
    'ARS': '\$',
    'BTC': '₿',
  };
  
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
  
  String? _selectedRecipient;
  
  @override
  void initState() {
    super.initState();
    _loadCurrencies();
    _amountController.addListener(_onAmountChanged);
  }
  
  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  Future<void> _loadCurrencies() async {
    setState(() {
      _isLoadingCurrencies = true;
    });
    
    try {
      final currencies = await _currencyService.getCurrencies();
      setState(() {
        _currencies = currencies;
        _isLoadingCurrencies = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCurrencies = false;
      });
    }
  }
  
  void _onAmountChanged() {
    _convertToBRL();
  }
  
  Future<void> _convertToBRL() async {
    final input = _amountController.text.replaceAll(',', '.');
    final amount = double.tryParse(input) ?? 0.0;
    
    if (amount == 0 || _selectedCurrency == 'BRL') {
      setState(() {
        _convertedToBRL = amount;
      });
      return;
    }
    
    try {
      final currency = _currencies.firstWhere(
        (c) => c.code == _selectedCurrency,
        orElse: () => Currency(
          code: _selectedCurrency,
          name: '',
          value: 1.0,
          variation: 0.0,
          lastUpdate: DateTime.now(),
        ),
      );
      
      setState(() {
        _convertedToBRL = amount * currency.value;
      });
    } catch (e) {
      print('Erro na conversão: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;
    
    // Currency formatter
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    
    if (user == null) {
      // If no user is logged in, redirect to login
      Future.microtask(() {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transferência'),
        actions: [
          IconButton(
            icon: const Icon(Icons.currency_exchange),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SimpleCurrencyConverter(),
                ),
              );
            },
            tooltip: 'Conversor de Moedas',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance information
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Saldo disponível',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      currencyFormat.format(user.balance),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Recipient selection
              const Text(
                'Para quem você deseja transferir?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<String>.empty();
                  }
                  
                  return _mockRecipients
                      .where((recipient) => recipient['name']!
                          .toLowerCase()
                          .contains(textEditingValue.text.toLowerCase()))
                      .map((recipient) => '${recipient['name']} (${recipient['account']})')
                      .toList();
                },
                onSelected: (String selection) {
                  setState(() {
                    _selectedRecipient = selection;
                    _recipientController.text = selection;
                  });
                },
                fieldViewBuilder: (
                  BuildContext context,
                  TextEditingController controller,
                  FocusNode focusNode,
                  VoidCallback onFieldSubmitted,
                ) {
                  _recipientController.text = controller.text;
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      labelText: 'Nome ou conta do destinatário',
                      prefixIcon: const Icon(Icons.person),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.contact_page),
                        onPressed: () {
                          // Show contact picker
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Lista de contatos em breve!'),
                            ),
                          );
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, informe o destinatário';
                      }
                      return null;
                    },
                  );
                },
              ),
              
              const SizedBox(height: 16),
              
              // Amount input with currency selection
              const Text(
                'Qual valor você deseja transferir?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              
              Row(
                children: [
                  // Currency selector
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _selectedCurrency,
                      decoration: const InputDecoration(
                        labelText: 'Moeda',
                        border: OutlineInputBorder(),
                      ),
                      items: _currencyNames.keys.map((String currencyCode) {
                        return DropdownMenuItem<String>(
                          value: currencyCode,
                          child: Row(
                            children: [
                              Text(
                                _currencySymbols[currencyCode] ?? '',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 4),
                              Text(currencyCode),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCurrency = newValue!;
                        });
                        _convertToBRL();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Amount field
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        labelText: 'Valor',
                        prefixText: '${_currencySymbols[_selectedCurrency]} ',
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe o valor';
                        }
                        
                        final amount = double.tryParse(value);
                        if (amount == null) {
                          return 'Valor inválido';
                        }
                        
                        if (amount <= 0) {
                          return 'Valor deve ser maior que zero';
                        }
                        
                        // Check balance in BRL
                        final valueInBRL = _selectedCurrency == 'BRL' ? amount : _convertedToBRL;
                        if (valueInBRL > user.balance) {
                          return 'Saldo insuficiente';
                        }
                        
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              
              // Show conversion if not BRL
              if (_selectedCurrency != 'BRL' && _convertedToBRL > 0) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.blue,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Equivale a ${currencyFormat.format(_convertedToBRL)} em Real',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 16),
              
              // Description input
              const Text(
                'Descrição (opcional)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLength: 50,
              ),
              
              const SizedBox(height: 32),
              
              // Transfer button
              CustomButton(
                text: 'Continuar',
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Extract recipient name from selected recipient
                    final recipientName = _selectedRecipient != null
                        ? _selectedRecipient!.split(' (')[0]
                        : _recipientController.text;
                    
                    // Extract account number if available
                    final accountNumber = _selectedRecipient != null
                        ? _selectedRecipient!.split('(')[1].replaceAll(')', '')
                        : '';
                    
                    // Use BRL amount for transfer (converted if necessary)
                    final transferAmount = _selectedCurrency == 'BRL' 
                        ? double.parse(_amountController.text)
                        : _convertedToBRL;
                    
                    // Navigate to confirm screen with arguments
                    Navigator.of(context).pushNamed(
                      AppRoutes.transferConfirm,
                      arguments: {
                        'recipient': recipientName,
                        'account': accountNumber,
                        'amount': transferAmount,
                        'originalAmount': double.parse(_amountController.text),
                        'currency': _selectedCurrency,
                        'currencySymbol': _currencySymbols[_selectedCurrency],
                        'description': _descriptionController.text,
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}