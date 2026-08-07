import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'theme.dart';
import 'models.dart';
import 'providers.dart';
import 'pdf_generator.dart';
import 'customer_ledger_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partiesState = ref.watch(partiesProvider);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('OK Book Pro', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(settings['isDark'] ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => ref.read(settingsProvider.notifier).toggleTheme(),
          ),
        ],
      ),
      body: partiesState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
        data: (parties) {
          int totalGet = 0;
          int totalGive = 0;
          for (var p in parties) {
            if (p.balancePaise > 0) totalGet += p.balancePaise;
            if (p.balancePaise < 0) totalGive += p.balancePaise.abs();
          }

          return Column(
            children: [
              Card(
                margin: const EdgeInsets.all(16),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _balCol('You will give', totalGive, AppTheme.primaryRed),
                      Container(width: 1, height: 40, color: Colors.grey),
                      _balCol('You will get', totalGet, AppTheme.primaryGreen),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: parties.length,
                  itemBuilder: (ctx, i) {
                    final p = parties[i];
                    return ListTile(
                      leading: CircleAvatar(child: Text(p.name[0].toUpperCase())),
                      title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(p.phone),
                      trailing: Text(
                        '₹${(p.balancePaise.abs() / 100).toStringAsFixed(2)}',
                        style: TextStyle(
                          color: p.balancePaise >= 0 ? AppTheme.primaryGreen : AppTheme.primaryRed,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CustomerLedgerScreen(party: p))),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context, ref),
        icon: const Icon(Icons.person_add),
        label: const Text('Add Party'),
      ),
    );
  }

  Widget _balCol(String title, int paise, Color c) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        Text('₹${(paise / 100).toStringAsFixed(2)}', style: TextStyle(color: c, fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Customer/Supplier'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone'), keyboardType: TextInputType.phone),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                final p = Party(
                  id: const Uuid().v4(),
                  name: nameCtrl.text,
                  phone: phoneCtrl.text,
                  type: PartyType.customer,
                  balancePaise: 0,
                  createdAt: DateTime.now(),
                );
                ref.read(partiesProvider.notifier).addParty(p);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
