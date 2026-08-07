import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'models.dart';

class DatabaseService {
  late Box _box;
  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox('digital_khata');
  }
  List<Party> parties() => ((_box.get('parties', defaultValue: <dynamic>[]) as List)).map((e)=>Party.fromMap(Map<String,dynamic>.from(e))).toList();
  List<Txn> txns() => ((_box.get('txns', defaultValue: <dynamic>[]) as List)).map((e)=>Txn.fromMap(Map<String,dynamic>.from(e))).toList();
  List<Product> products() => ((_box.get('products', defaultValue: <dynamic>[]) as List)).map((e)=>Product.fromMap(Map<String,dynamic>.from(e))).toList();
  List<Expense> expenses() => ((_box.get('expenses', defaultValue: <dynamic>[]) as List)).map((e)=>Expense.fromMap(Map<String,dynamic>.from(e))).toList();

  Future<void> saveParties(List<Party> x)=>_box.put('parties', x.map((e)=>e.toMap()).toList());
  Future<void> saveTxns(List<Txn> x)=>_box.put('txns', x.map((e)=>e.toMap()).toList());
  Future<void> saveProducts(List<Product> x)=>_box.put('products', x.map((e)=>e.toMap()).toList());
  Future<void> saveExpenses(List<Expense> x)=>_box.put('expenses', x.map((e)=>e.toMap()).toList());
  dynamic get(String key)=>_box.get(key);
  Future<void> put(String key,dynamic value)=>_box.put(key,value);
  Future<String> exportJson() async => jsonEncode({'parties':parties().map((e)=>e.toMap()).toList(),'txns':txns().map((e)=>e.toMap()).toList(),'products':products().map((e)=>e.toMap()).toList(),'expenses':expenses().map((e)=>e.toMap()).toList()});
}
