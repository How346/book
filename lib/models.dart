import 'package:uuid/uuid.dart';

enum PartyType { customer, supplier }

class Party {
  final String id;
  final String name;
  final String phone;
  final PartyType type;
  final int balancePaise;
  final DateTime createdAt;

  const Party({
    required this.id,
    required this.name,
    required this.phone,
    required this.type,
    required this.balancePaise,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'phone': phone,
        'type': type.index,
        'balancePaise': balancePaise,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Party.fromMap(Map<String, dynamic> map) => Party(
        id: map['id'] as String,
        name: map['name'] as String,
        phone: map['phone'] as String,
        type: PartyType.values[map['type'] as int],
        balancePaise: map['balancePaise'] as int,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
}

class TransactionModel {
  final String id;
  final String partyId;
  final int amountPaise;
  final bool isGot;
  final String note;
  final DateTime date;

  const TransactionModel({
    required this.id,
    required this.partyId,
    required this.amountPaise,
    required this.isGot,
    required this.note,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'partyId': partyId,
        'amountPaise': amountPaise,
        'isGot': isGot ? 1 : 0,
        'note': note,
        'date': date.toIso8601String(),
      };

  factory TransactionModel.fromMap(Map<String, dynamic> map) => TransactionModel(
        id: map['id'] as String,
        partyId: map['partyId'] as String,
        amountPaise: map['amountPaise'] as int,
        isGot: (map['isGot'] as int) == 1,
        note: map['note'] as String,
        date: DateTime.parse(map['date'] as String),
      );
}

class CashbookEntry {
  final String id;
  final int amountPaise;
  final bool isIncome;
  final String category;
  final String note;
  final DateTime date;

  const CashbookEntry({
    required this.id,
    required this.amountPaise,
    required this.isIncome,
    required this.category,
    required this.note,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'amountPaise': amountPaise,
        'isIncome': isIncome ? 1 : 0,
        'category': category,
        'note': note,
        'date': date.toIso8601String(),
      };

  factory CashbookEntry.fromMap(Map<String, dynamic> map) => CashbookEntry(
        id: map['id'] as String,
        amountPaise: map['amountPaise'] as int,
        isIncome: (map['isIncome'] as int) == 1,
        category: map['category'] as String,
        note: map['note'] as String,
        date: DateTime.parse(map['date'] as String),
      );
}

class Item {
  final String id;
  final String name;
  final int stockCount;
  final int pricePaise;

  const Item({
    required this.id,
    required this.name,
    required this.stockCount,
    required this.pricePaise,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'stockCount': stockCount,
        'pricePaise': pricePaise,
      };

  factory Item.fromMap(Map<String, dynamic> map) => Item(
        id: map['id'] as String,
        name: map['name'] as String,
        stockCount: map['stockCount'] as int,
        pricePaise: map['pricePaise'] as int,
      );
}
