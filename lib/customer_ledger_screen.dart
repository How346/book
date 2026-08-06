import 'package:flutter/material.dart';
import 'ledger_models.dart';
import 'theme.dart';

class CustomerLedgerScreen extends StatelessWidget {
  final Customer customer;
  const CustomerLedgerScreen({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(customer.name),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          'Ledger for ${customer.name}',
          style: const TextStyle(fontSize: 18, color: AppTheme.textDark),
        ),
      ),
    );
  }
}
