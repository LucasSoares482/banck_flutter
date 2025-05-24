// lib/models/currency.dart (Atualizado)
class Currency {
  final String code;
  final String name;
  final double value;
  final double variation;
  final DateTime lastUpdate;
  final double? high;
  final double? low;
  final double? bid;
  final double? ask;

  Currency({
    required this.code,
    required this.name,
    required this.value,
    required this.variation,
    required this.lastUpdate,
    this.high,
    this.low,
    this.bid,
    this.ask,
  });

  factory Currency.fromAwesomeApi(Map<String, dynamic> json) {
    return Currency(
      code: json['code'] as String,
      name: json['name'] as String,
      value: double.parse(json['bid'] as String), // Valor de compra
      variation: double.parse(json['pctChange'] as String), // Variação percentual
      lastUpdate: DateTime.fromMillisecondsSinceEpoch(
        int.parse(json['timestamp'] as String) * 1000,
      ),
      high: double.tryParse(json['high'] as String? ?? ''),
      low: double.tryParse(json['low'] as String? ?? ''),
      bid: double.tryParse(json['bid'] as String? ?? ''),
      ask: double.tryParse(json['ask'] as String? ?? ''),
    );
  }

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      code: json['code'] as String,
      name: json['name'] as String,
      value: json['value'] as double,
      variation: json['variation'] as double,
      lastUpdate: DateTime.parse(json['lastUpdate'] as String),
      high: json['high'] as double?,
      low: json['low'] as double?,
      bid: json['bid'] as double?,
      ask: json['ask'] as double?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'value': value,
      'variation': variation,
      'lastUpdate': lastUpdate.toIso8601String(),
      'high': high,
      'low': low,
      'bid': bid,
      'ask': ask,
    };
  }

  Currency copyWith({
    String? code,
    String? name,
    double? value,
    double? variation,
    DateTime? lastUpdate,
    double? high,
    double? low,
    double? bid,
    double? ask,
  }) {
    return Currency(
      code: code ?? this.code,
      name: name ?? this.name,
      value: value ?? this.value,
      variation: variation ?? this.variation,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      high: high ?? this.high,
      low: low ?? this.low,
      bid: bid ?? this.bid,
      ask: ask ?? this.ask,
    );
  }

  @override
  String toString() {
    return 'Currency(code: $code, name: $name, value: $value, variation: $variation%)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Currency &&
        other.code == code &&
        other.name == name &&
        other.value == value &&
        other.variation == variation &&
        other.lastUpdate == lastUpdate;
  }

  @override
  int get hashCode {
    return code.hashCode ^
        name.hashCode ^
        value.hashCode ^
        variation.hashCode ^
        lastUpdate.hashCode;
  }
}