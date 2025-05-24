// lib/screens/currency_screen.dart (Atualizado com API Real)
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/currency.dart';
import '../services/currency_service.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({Key? key}) : super(key: key);

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  final CurrencyService _currencyService = CurrencyService();
  List<Currency> _currencies = [];
  bool _isLoading = true;
  String _errorMessage = '';
  
  // Selected currency for detailed view
  Currency? _selectedCurrency;
  List<Currency> _currencyHistory = [];
  bool _isLoadingHistory = false;
  
  @override
  void initState() {
    super.initState();
    _loadCurrencies();
  }
  
  Future<void> _loadCurrencies() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      // Verificar se a API está funcionando
      final isWorking = await _currencyService.isApiWorking();
      
      if (!isWorking) {
        throw Exception('API temporariamente indisponível');
      }
      
      final currencies = await _currencyService.getCurrencies();
      
      setState(() {
        _currencies = currencies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Falha ao carregar cotações: $e';
        _isLoading = false;
      });
    }
  }
  
  Future<void> _selectCurrency(Currency currency) async {
    setState(() {
      _selectedCurrency = currency;
      _isLoadingHistory = true;
    });
    
    try {
      // Carregar histórico dos últimos 30 dias
      final history = await _currencyService.getCurrencyHistory(currency.code, 30);
      
      setState(() {
        _currencyHistory = history;
        _isLoadingHistory = false;
      });
    } catch (e) {
      setState(() {
        _currencyHistory = [];
        _isLoadingHistory = false;
      });
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao carregar histórico: $e'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cotações em Tempo Real'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCurrencies,
            tooltip: 'Atualizar cotações',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadCurrencies,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
                ? _buildErrorView()
                : Column(
                    children: [
                      // API Status indicator
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        color: Colors.green.withOpacity(0.1),
                        child: Row(
                          children: [
                            Icon(
                              Icons.wifi,
                              color: Colors.green,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Conectado à API AwesomeAPI - Dados em tempo real',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Currency detail view
                      if (_selectedCurrency != null) _buildCurrencyDetailView(),
                      
                      // Currency list
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _currencies.length,
                          itemBuilder: (context, index) {
                            final currency = _currencies[index];
                            return _buildCurrencyCard(currency);
                          },
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
  
  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadCurrencies,
            child: const Text('Tentar novamente'),
          ),
          const SizedBox(height: 16),
          Text(
            'Dados fornecidos pela AwesomeAPI',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCurrencyCard(Currency currency) {
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final isPositiveVariation = currency.variation >= 0;
    
    final isSelected = _selectedCurrency?.code == currency.code;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 2,
      color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
      child: InkWell(
        onTap: () => _selectCurrency(currency),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Currency icon/flag
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    currency.code,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected 
                          ? Colors.white
                          : Theme.of(context).primaryColor,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Currency details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currency.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Atualizado: ${DateFormat('dd/MM HH:mm').format(currency.lastUpdate)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Currency value and variation
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currencyFormat.format(currency.value),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isPositiveVariation
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPositiveVariation
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 12,
                          color: isPositiveVariation ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${isPositiveVariation ? '+' : ''}${currency.variation.toStringAsFixed(2)}%',
                          style: TextStyle(
                            color: isPositiveVariation ? Colors.green : Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCurrencyDetailView() {
    if (_selectedCurrency == null) return const SizedBox.shrink();
    
    final currency = _selectedCurrency!;
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final isPositiveVariation = currency.variation >= 0;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${currency.code} - ${currency.name}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _selectedCurrency = null;
                    _currencyHistory = [];
                  });
                },
              ),
            ],
          ),
          
          // Currency value and variation
          Row(
            children: [
              Text(
                currencyFormat.format(currency.value),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isPositiveVariation
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPositiveVariation
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      size: 12,
                      color: isPositiveVariation ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${isPositiveVariation ? '+' : ''}${currency.variation.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: isPositiveVariation ? Colors.green : Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Chart or loading indicator
          Container(
            height: 150,
            padding: const EdgeInsets.all(8),
            child: _isLoadingHistory
                ? const Center(child: CircularProgressIndicator())
                : _currencyHistory.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.show_chart,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Histórico não disponível',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : _buildChart(),
          ),
          
          const SizedBox(height: 16),
          
          // Info text
          Text(
            'Última atualização: ${DateFormat('dd/MM/yyyy HH:mm').format(currency.lastUpdate)}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          
          Text(
            'Fonte: AwesomeAPI - Dados do Banco Central',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildChart() {
    if (_currencyHistory.isEmpty) return const SizedBox.shrink();
    
    final spots = _currencyHistory.reversed.toList().asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value % 5 != 0) return const SizedBox.shrink();
                
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '${value.toInt()}d',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Theme.of(context).colorScheme.background,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
                return LineTooltipItem(
                  currencyFormat.format(spot.y),
                  TextStyle(color: Theme.of(context).primaryColor),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Theme.of(context).primaryColor,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).primaryColor.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}