import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'models.dart';
import 'theme.dart';
import 'providers.dart';
import 'pdf_generator.dart';

class CustomerLedgerScreen extends ConsumerWidget {
  final Party party;
  const CustomerLedgerScreen({super.key, required this.party});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                if (context.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
