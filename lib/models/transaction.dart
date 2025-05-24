// lib/models/transaction.dart
enum TransactionType {
  deposit,
  withdrawal,
  transfer,
}

class Transaction {
  final String id;
  final String senderId;
  final String senderName;
  final String? recipientId;
  final String? recipientName;
  final double amount;
  final DateTime date;
  final String description;
  final TransactionType type;

  Transaction({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.recipientId,
    this.recipientName,
    required this.amount,
    required this.date,
    required this.description,
    required this.type,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      recipientId: json['recipientId'] as String?,
      recipientName: json['recipientName'] as String?,
      amount: json['amount'] as double,
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String,
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == 'TransactionType.${json['type']}',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'recipientId': recipientId,
      'recipientName': recipientName,
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
      'type': type.toString().split('.').last,
    };
  }
}