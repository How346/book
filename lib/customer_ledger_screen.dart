import 'package:flutter/material.dart';
import 'models.dart';
import 'theme.dart';

class CustomerLedgerScreen extends StatelessWidget {
  final Party party;
  const CustomerLedgerScreen({super.key, required this.party});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(party.name),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          'Ledger for ${party.name}',
          style: const TextStyle(fontSize: 18, color: AppTheme.textDark),
        ),
      ),
    );
  }
}
