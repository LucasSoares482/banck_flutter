// lib/screens/transfer_confirm_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../routes/app_routes.dart';
import '../services/auth_service.dart';
import '../services/transaction_service.dart';
import '../widgets/custom_button.dart';

class TransferConfirmScreen extends StatefulWidget {
  final String recipient;
  final String? account;
  final double amount;
  final String description;

  const TransferConfirmScreen({
    Key? key,
    required this.recipient,
    this.account,
    required this.amount,
    required this.description,
  }) : super(key: key);

  @override
  State<TransferConfirmScreen> createState() => _TransferConfirmScreenState();
}

class _TransferConfirmScreenState extends State<TransferConfirmScreen> {
  bool _isLoading = false;
  bool _isTransferComplete = false;
  
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final transactionService = Provider.of<TransactionService>(context);
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
        title: const Text('Confirmar Transferência'),
      ),
      body: _isTransferComplete
          ? _buildSuccessScreen(context, transactionService)
          : _buildConfirmScreen(context, user, authService, transactionService, currencyFormat),
    );
  }
  
  Widget _buildConfirmScreen(
    BuildContext context,
    user,
    AuthService authService,
    TransactionService transactionService,
    NumberFormat currencyFormat,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Transfer summary card
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
                  'Resumo da transferência',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildInfoRow('De', user.name),
                const SizedBox(height: 8),
                
                _buildInfoRow('Para', widget.recipient),
                if (widget.account != null && widget.account!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _buildInfoRow('Conta', widget.account!),
                ],
                const SizedBox(height: 8),
                
                _buildInfoRow('Valor', currencyFormat.format(widget.amount)),
                const SizedBox(height: 8),
                
                if (widget.description.isNotEmpty) ...[
                  _buildInfoRow('Descrição', widget.description),
                  const SizedBox(height: 8),
                ],
                
                _buildInfoRow('Data', DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Warning text
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.orange.withOpacity(0.5),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.orange[700],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Confira todos os dados antes de confirmar a transferência.',
                    style: TextStyle(
                      color: Colors.orange[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            children: [
              // Cancel button
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 16),
              
              // Confirm button
              Expanded(
                child: CustomButton(
                  text: 'Confirmar',
                  isLoading: _isLoading,
                  onPressed: () async {
                    setState(() {
                      _isLoading = true;
                    });
                    
                    // Process transfer
                    final success = await transactionService.createTransaction(
                      sender: user,
                      recipientId: 'recipient_id', // Mock ID
                      recipientName: widget.recipient,
                      amount: widget.amount,
                      description: widget.description,
                    );
                    
                    if (success) {
                      // Update user balance
                      authService.updateBalance(user.balance - widget.amount);
                      
                      setState(() {
                        _isLoading = false;
                        _isTransferComplete = true;
                      });
                    } else {
                      setState(() {
                        _isLoading = false;
                      });
                      
                      if (!mounted) return;
                      
                      // Show error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Falha na transferência. Tente novamente.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildSuccessScreen(
    BuildContext context,
    TransactionService transactionService,
  ) {
    // Get the latest transaction (the one we just created)
    final latestTransaction = transactionService.getLatestTransaction();
    
    // Currency formatter
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Success icon
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: Colors.green[600],
          ),
          const SizedBox(height: 24),
          
          // Success message
          const Text(
            'Transferência realizada com sucesso!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          Text(
            'O valor de ${currencyFormat.format(widget.amount)} foi transferido para ${widget.recipient}.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          
          // Receipt card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey[300]!,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Comprovante',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'ID: ${latestTransaction?.id ?? ''}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const Divider(),
                
                _buildInfoRow('Beneficiário', widget.recipient),
                const SizedBox(height: 8),
                
                _buildInfoRow('Valor', currencyFormat.format(widget.amount)),
                const SizedBox(height: 8),
                
                _buildInfoRow('Data', DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())),
                const SizedBox(height: 8),
                
                if (widget.description.isNotEmpty) ...[
                  _buildInfoRow('Descrição', widget.description),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Action buttons
          Row(
            children: [
              // Share button
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.share),
                  label: const Text('Compartilhar'),
                  onPressed: () {
                    // Generate receipt text
                    final receiptText = '''
                      COMPROVANTE DE TRANSFERÊNCIA
                      
                      ID: ${latestTransaction?.id ?? ''}
                      De: ${latestTransaction?.senderName ?? ''}
                      Para: ${widget.recipient}
                      Valor: ${currencyFormat.format(widget.amount)}
                      Data: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}
                      ${widget.description.isNotEmpty ? 'Descrição: ${widget.description}' : ''}
                    ''';
                    
                    // Share receipt
                    Share.share(receiptText);
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Home button
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.home),
                  label: const Text('Início'),
                  onPressed: () {
                    Navigator.of(context).popUntil(
                      ModalRoute.withName(AppRoutes.home),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}