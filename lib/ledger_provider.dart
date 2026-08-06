import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ledger_models.dart';

class LedgerNotifier extends StateNotifier<List<Customer>> {
  LedgerNotifier() : super([
    Customer(name: 'Rahul Sharma', phone: '+91 9876543210', transactions: [
      Transaction(date: DateTime.now().subtract(const Duration(days: 1)), amount: 500, isPaymentGot: false, note: 'Milk & Bread'),
    ]),
  ]);

  void addCustomer(String name, String phone) {
    state = [...state, Customer(name: name, phone: phone)];
  }

  void addTransaction(String customerId, double amount, bool isGot, String note) {
    state = state.map((c) {
      if (c.id == customerId) {
        final newTx = Transaction(date: DateTime.now(), amount: amount, isPaymentGot: isGot, note: note);
        return Customer(id: c.id, name: c.name, phone: c.phone, transactions: [...c.transactions, newTx]);
      }
      return c;
    }).toList();
  }
}

final ledgerProvider = StateNotifierProvider<LedgerNotifier, List<Customer>>((ref) => LedgerNotifier());
