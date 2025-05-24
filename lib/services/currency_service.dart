// lib/services/currency_service.dart (Corrigido)
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/currency.dart';

class CurrencyService {
  final String baseUrl = 'https://economia.awesomeapi.com.br';
  
  // Lista das principais moedas que vamos exibir
  final List<String> _currencies = [
    'USD-BRL',  // Dólar
    'EUR-BRL',  // Euro
    'GBP-BRL',  // Libra
    'ARS-BRL',  // Peso Argentino
    'CAD-BRL',  // Dólar Canadense
    'AUD-BRL',  // Dólar Australiano
    'JPY-BRL',  // Iene
    'CHF-BRL',  // Franco Suíço
    'CNY-BRL',  // Yuan Chinês
    'BTC-BRL',  // Bitcoin
  ];
  
  // Obter cotações atuais de múltiplas moedas
  Future<List<Currency>> getCurrencies() async {
    try {
      // Criar string com todas as moedas separadas por vírgula
      final currencyString = _currencies.join(',');
      final url = '$baseUrl/last/$currencyString'; // Corrigido: removido /json
      
      print('Fazendo requisição para: $url'); // Debug
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'BankFlutter/1.0',
        },
      ).timeout(const Duration(seconds: 15)); // Timeout aumentado
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        List<Currency> currencies = [];
        
        // Processar cada moeda na resposta
        data.forEach((key, value) {
          try {
            currencies.add(
              Currency(
                code: value['code'],
                name: value['name'],
                value: double.parse(value['bid']), // Valor de compra
                variation: double.parse(value['pctChange']), // Variação percentual
                lastUpdate: DateTime.fromMillisecondsSinceEpoch(
                  int.parse(value['timestamp']) * 1000,
                ),
              ),
            );
          } catch (e) {
            print('Erro ao processar moeda $key: $e');
          }
        });
        
        // Se não conseguiu processar nenhuma moeda, usar mock
        if (currencies.isEmpty) {
          print('Nenhuma moeda processada, usando dados mock');
          return _getMockCurrencies();
        }
        
        // Ordenar por código da moeda
        currencies.sort((a, b) => a.code.compareTo(b.code));
        
        return currencies;
      } else {
        print('Status code: ${response.statusCode}');
        throw Exception('Falha ao carregar cotações. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro no getCurrencies: $e');
      // Retornar dados mock em caso de erro para demonstração
      return _getMockCurrencies();
    }
  }
  
  // Obter cotação específica de uma moeda
  Future<Currency?> getSpecificCurrency(String currencyCode) async {
    try {
      final url = '$baseUrl/last/$currencyCode-BRL'; // Corrigido: removido /json
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'BankFlutter/1.0',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final String key = data.keys.first;
        final Map<String, dynamic> currencyData = data[key];
        
        return Currency(
          code: currencyData['code'],
          name: currencyData['name'],
          value: double.parse(currencyData['bid']),
          variation: double.parse(currencyData['pctChange']),
          lastUpdate: DateTime.fromMillisecondsSinceEpoch(
            int.parse(currencyData['timestamp']) * 1000,
          ),
        );
      } else {
        throw Exception('Falha ao carregar cotação específica');
      }
    } catch (e) {
      print('Erro no getSpecificCurrency: $e');
      return null;
    }
  }
  
  // Obter histórico de uma moeda (últimos N dias)
  Future<List<Currency>> getCurrencyHistory(String currencyCode, int days) async {
    try {
      final url = '$baseUrl/daily/$currencyCode-BRL/$days'; // Corrigido: removido /json
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'BankFlutter/1.0',
        },
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        List<Currency> history = [];
        
        for (var item in data) {
          try {
            history.add(
              Currency(
                code: item['code'],
                name: item['name'],
                value: double.parse(item['bid']),
                variation: double.parse(item['pctChange']),
                lastUpdate: DateTime.fromMillisecondsSinceEpoch(
                  int.parse(item['timestamp']) * 1000,
                ),
              ),
            );
          } catch (e) {
            print('Erro ao processar item do histórico: $e');
          }
        }
        
        return history;
      } else {
        throw Exception('Falha ao carregar histórico');
      }
    } catch (e) {
      print('Erro no getCurrencyHistory: $e');
      return [];
    }
  }
  
  // Obter taxa de conversão entre duas moedas
  Future<double> getConversionRate(String fromCurrency, String toCurrency) async {
    try {
      if (fromCurrency == toCurrency) {
        return 1.0;
      }
      
      // Se uma das moedas for BRL, usar a API diretamente
      if (toCurrency == 'BRL') {
        final currency = await getSpecificCurrency(fromCurrency);
        return currency?.value ?? 0.0;
      } else if (fromCurrency == 'BRL') {
        final currency = await getSpecificCurrency(toCurrency);
        return currency != null ? 1.0 / currency.value : 0.0;
      } else {
        // Para conversão entre duas moedas diferentes de BRL, 
        // converter primeiro para BRL e depois para a moeda desejada
        final fromToBrl = await getSpecificCurrency(fromCurrency);
        final toBrl = await getSpecificCurrency(toCurrency);
        
        if (fromToBrl != null && toBrl != null) {
          return fromToBrl.value / toBrl.value;
        }
        
        throw Exception('Não foi possível obter taxas de conversão');
      }
    } catch (e) {
      print('Erro no getConversionRate: $e');
      return 0.0;
    }
  }
  
  // Dados mock para fallback em caso de erro
  List<Currency> _getMockCurrencies() {
    return [
      Currency(
        code: 'USD',
        name: 'Dólar Americano/Real Brasileiro',
        value: 5.73,
        variation: -0.15,
        lastUpdate: DateTime.now(),
      ),
      Currency(
        code: 'EUR',
        name: 'Euro/Real Brasileiro',
        value: 6.21,
        variation: 0.23,
        lastUpdate: DateTime.now(),
      ),
      Currency(
        code: 'GBP',
        name: 'Libra Esterlina/Real Brasileiro',
        value: 7.15,
        variation: 0.45,
        lastUpdate: DateTime.now(),
      ),
      Currency(
        code: 'BTC',
        name: 'Bitcoin/Real Brasileiro',
        value: 485000.00,
        variation: 2.34,
        lastUpdate: DateTime.now(),
      ),
      Currency(
        code: 'ARS',
        name: 'Peso Argentino/Real Brasileiro',
        value: 0.0061,
        variation: -1.23,
        lastUpdate: DateTime.now(),
      ),
      Currency(
        code: 'CAD',
        name: 'Dólar Canadense/Real Brasileiro',
        value: 4.18,
        variation: 0.12,
        lastUpdate: DateTime.now(),
      ),
    ];
  }
  
  // Obter lista de moedas disponíveis
  List<String> getAvailableCurrencies() {
    return _currencies;
  }
  
  // Verificar se a API está funcionando
  Future<bool> isApiWorking() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/last/USD-BRL'), // Corrigido: removido /json
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'BankFlutter/1.0',
        },
      ).timeout(const Duration(seconds: 10));
      
      return response.statusCode == 200;
    } catch (e) {
      print('API não está funcionando: $e');
      return false;
    }
  }
}