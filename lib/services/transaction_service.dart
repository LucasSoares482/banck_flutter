// lib/services/transaction_service.dart
import 'package:flutter/foundation.dart';
import 'dart:math';
import '../models/transaction.dart';
import '../models/user.dart';

class TransactionService with ChangeNotifier {
  final List<Transaction> _transactions = [];
  
  List<Transaction> get transactions => [..._transactions];
  
  // Constructor initializes with mock data
  TransactionService() {
    _initMockData();
  }
  
  // Initialize with mock transactions
  void _initMockData() {
    final random = Random();
    
    // Generate 10 mock transactions
    for (int i = 1; i <= 10; i++) {
      final bool isDeposit = random.nextBool();
      final type = isDeposit ? TransactionType.deposit : TransactionType.withdrawal;
      
      _transactions.add(
        Transaction(
          id: 'trans_$i',
          senderId: isDeposit ? 'external_${i + 100}' : '1',
          senderName: isDeposit ? 'Depósito' : 'João Silva',
          recipientId: isDeposit ? '1' : 'external_${i + 200}',
          recipientName: isDeposit ? 'João Silva' : 'Pagamento',
          amount: (random.nextDouble() * 1000).roundToDouble(),
          date: DateTime.now().subtract(Duration(days: random.nextInt(30))),
          description: isDeposit ? 'Depósito recebido' : 'Pagamento efetuado',
          type: type,
        ),
      );
    }
    
    // Sort transactions by date (newest first)
    _transactions.sort((a, b) => b.date.compareTo(a.date));
  }
  
  // Get transactions for a specific user
  List<Transaction> getUserTransactions(String userId) {
    return _transactions.where((trans) => 
      trans.senderId == userId || trans.recipientId == userId
    ).toList();
  }
  
  // Create a new transaction
  Future<bool> createTransaction({
    required User sender,
    required String recipientId,
    required String recipientName,
    required double amount,
    required String description,
  }) async {
    try {
      // In a real app, this would be a server request
      await Future.delayed(const Duration(seconds: 1));
      
      // Check if the sender has enough balance
      if (sender.balance < amount) {
        return false;
      }
      
      // Create the transaction
      final newTransaction = Transaction(
        id: 'trans_${_transactions.length + 1}',
        senderId: sender.id,
        senderName: sender.name,
        recipientId: recipientId,
        recipientName: recipientName,
        amount: amount,
        date: DateTime.now(),
        description: description,
        type: TransactionType.transfer,
      );
      
      // Add to the list and notify listeners
      _transactions.insert(0, newTransaction);
      notifyListeners();
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Get the most recent transaction
  Transaction? getLatestTransaction() {
    if (_transactions.isEmpty) {
      return null;
    }
    return _transactions.first;
  }
}