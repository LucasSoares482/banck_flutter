// lib/widgets/transaction_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;

  const TransactionCard({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Currency formatter
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    
    // Determine if this is income or expense for the current user
    final bool isIncome = transaction.type == TransactionType.deposit;
    
    // Format transaction date
    final String formattedDate = DateFormat('dd/MM/yyyy').format(transaction.date);
    
    // Responsive values
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;
    
    return Card(
      margin: EdgeInsets.only(bottom: screenWidth * 0.03),
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Row(
          children: [
            // Transaction icon
            Container(
              width: isLargeScreen ? 48 : 40,
              height: isLargeScreen ? 48 : 40,
              decoration: BoxDecoration(
                color: isIncome ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                color: isIncome ? Colors.green : Colors.red,
                size: isLargeScreen ? 24 : 20,
              ),
            ),
            SizedBox(width: screenWidth * 0.04),
            
            // Transaction details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isIncome
                        ? 'Recebido de ${transaction.senderName}'
                        : 'Enviado para ${transaction.recipientName ?? "Desconhecido"}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.035,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: screenWidth * 0.01),
                  Text(
                    transaction.description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: screenWidth * 0.03,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: screenWidth * 0.01),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: screenWidth * 0.03,
                    ),
                  ),
                ],
              ),
            ),
            
            // Transaction amount
            Text(
              isIncome
                  ? '+${currencyFormat.format(transaction.amount)}'
                  : '-${currencyFormat.format(transaction.amount)}',
              style: TextStyle(
                color: isIncome ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: screenWidth * 0.035,
              ),
            ),
          ],
        ),
      ),
    );
  }
}