import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'theme.dart';
import 'models.dart';
import 'providers.dart';
import 'pdf_generator.dart';

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
                      _BalCol('You will give', totalGive, AppTheme.primaryRed),
                      Container(width: 1, height: 40, color: Colors.grey),
                      _BalCol('You will get', totalGet, AppTheme.primaryGreen),
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
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LedgerScreen(party: p))),
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

  Widget _BalCol(String title, int paise, Color c) {
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

class LedgerScreen extends ConsumerWidget {
  final Party party;
  const LedgerScreen({super.key, required this.party});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We should ideally watch a specific provider for this party's balance update, but for simplicity we rely on the list provider and transactions provider.
    final txsAsync = ref.watch(transactionsProvider(party.id));
    final updatedParty = ref.watch(partiesProvider).valueOrNull?.firstWhere((p) => p.id == party.id, orElse: () => party) ?? party;

    return Scaffold(
      appBar: AppBar(
        title: Text(updatedParty.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () {
              if (txsAsync.value != null) {
                PdfService.generateAndShareStatement(updatedParty, txsAsync.value!);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.message),
            onPressed: () async {
               final msg = Uri.encodeComponent('Hi ${updatedParty.name}, your pending balance is Rs ${(updatedParty.balancePaise.abs() / 100).toStringAsFixed(2)}. Please clear it.');
               final url = Uri.parse('whatsapp://send?phone=${updatedParty.phone}&text=$msg');
               if (await canLaunchUrl(url)) {
                 await launchUrl(url);
               }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Net Balance: ₹${(updatedParty.balancePaise.abs() / 100).toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: updatedParty.balancePaise >= 0 ? AppTheme.primaryGreen : AppTheme.primaryRed),
            ),
          ),
          Expanded(
            child: txsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) => Center(child: Text('Error: $err')),
              data: (txs) => ListView.builder(
                itemCount: txs.length,
                itemBuilder: (ctx, i) {
                  final tx = txs[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ListTile(
                      title: Text(tx.note.isEmpty ? 'Transaction' : tx.note),
                      subtitle: Text('${tx.date.day}/${tx.date.month}/${tx.date.year}'),
                      trailing: Text(
                        '₹${(tx.amountPaise / 100).toStringAsFixed(2)}',
                        style: TextStyle(
                          color: tx.isGot ? AppTheme.primaryGreen : AppTheme.primaryRed,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          _buildActionButtons(context, ref),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed, padding: const EdgeInsets.all(16)),
              onPressed: () => _showTxDialog(context, ref, false),
              child: const Text('YOU GAVE (-)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen, padding: const EdgeInsets.all(16)),
              onPressed: () => _showTxDialog(context, ref, true),
              child: const Text('YOU GOT (+)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _showTxDialog(BuildContext context, WidgetRef ref, bool isGot) {
    final amtCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isGot ? 'Payment Received' : 'Credit Given'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: amtCtrl, decoration: const InputDecoration(labelText: 'Amount (₹)'), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
            TextField(controller: noteCtrl, decoration: const InputDecoration(labelText: 'Notes/Items')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final amtDouble = double.tryParse(amtCtrl.text);
              if (amtDouble != null && amtDouble > 0) {
                final tx = TransactionModel(
                  id: const Uuid().v4(),
                  partyId: party.id,
                  amountPaise: (amtDouble * 100).round(),
                  isGot: isGot,
                  note: noteCtrl.text,
                  date: DateTime.now(),
                );
                await ref.read(partiesProvider.notifier).addTransaction(tx);
                ref.invalidate(transactionsProvider(party.id));
                if(context.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
