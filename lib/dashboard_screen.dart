import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'theme.dart';
import 'ledger_provider.dart';
import 'customer_ledger_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customers = ref.watch(ledgerProvider);
    
    double totalToGive = 0;
    double totalToGet = 0;
    
    for (var c in customers) {
      if (c.balance > 0) totalToGet += c.balance;
      if (c.balance < 0) totalToGive += c.balance.abs();
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.book, color: AppTheme.primaryGreen),
            const SizedBox(width: 8),
            const Text('OK Book'),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryItem('You will give', '₹${totalToGive.toStringAsFixed(0)}', AppTheme.primaryRed),
                ),
                Container(width: 1, height: 40, color: Colors.grey.shade300),
                Expanded(
                  child: _buildSummaryItem('You will get', '₹${totalToGet.toStringAsFixed(0)}', AppTheme.primaryGreen),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('CUSTOMERS', style: TextStyle(color: AppTheme.textLight, fontSize: 12, fontWeight: FontWeight.bold)),
                const Icon(Icons.filter_list, size: 20, color: AppTheme.textLight),
              ],
            ),
          ),

          Expanded(
            child: ListView.separated(
              itemCount: customers.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade200),
              itemBuilder: (context, index) {
                final customer = customers[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                    child: Text(customer.name[0].toUpperCase(), style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  subtitle: Text(
                    customer.transactions.isNotEmpty ? DateFormat('dd MMM, hh:mm a').format(customer.transactions.last.date) : 'No transactions',
                    style: const TextStyle(color: AppTheme.textLight, fontSize: 13),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('₹${customer.balance.abs().toStringAsFixed(0)}', 
                        style: TextStyle(
                          color: customer.balance >= 0 ? AppTheme.primaryGreen : AppTheme.primaryRed,
                          fontWeight: FontWeight.bold,
                          fontSize: 16
                        )
                      ),
                      Text(customer.balance >= 0 ? 'Advance' : 'Due', style: const TextStyle(color: AppTheme.textLight, fontSize: 11)),
                    ],
                  ),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CustomerLedgerScreen(customer: customer))),
                ).animate().fadeIn(delay: (100 * index).ms).slideX();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryRed,
        onPressed: () {},
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('ADD CUSTOMER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String amount, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: AppTheme.textLight, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Text(amount, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
