import 'package:uuid/uuid.dart';

class Transaction {
  final String id;
  final DateTime date;
  final double amount;
  final bool isPaymentGot; 
  final String note;

  Transaction({
    String? id,
    required this.date,
    required this.amount,
    required this.isPaymentGot,
    this.note = '',
  }) : id = id ?? const Uuid().v4();
}

class Customer {
  final String id;
  final String name;
  final String phone;
  final List<Transaction> transactions;

  Customer({
    String? id,
    required this.name,
    required this.phone,
    this.transactions = const [],
  }) : id = id ?? const Uuid().v4();

  double get balance {
    return transactions.fold(0.0, (sum, tx) => sum + (tx.isPaymentGot ? -tx.amount : tx.amount));
  }
}
