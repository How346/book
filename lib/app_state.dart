import 'package:flutter/material.dart';
import 'database_service.dart';
import 'models.dart';
import 'accounting_service.dart';

class AppState extends ChangeNotifier {
  final DatabaseService db;
  AppState(this.db);
  ThemeMode themeMode = ThemeMode.system;
  List<Party> parties=[], suppliers=[], customers=[];
  List<Txn> txns=[];
  List<Product> products=[];
  List<Expense> expenses=[];
  bool loaded=false;
  Future<void> load() async {
    parties=db.parties(); txns=db.txns(); products=db.products(); expenses=db.expenses();
    customers=parties.where((p)=>p.type=='customer').toList();
    suppliers=parties.where((p)=>p.type=='supplier').toList();
    final t=db.get('theme');
    if(t=='dark') themeMode=ThemeMode.dark; else if(t=='light') themeMode=ThemeMode.light;
    loaded=true; notifyListeners();
  }
  Future<void> addParty({required String name,required String phone,required String type}) async {
    final p=Party(id:DateTime.now().microsecondsSinceEpoch.toString(),name:name,phone:phone,type:type);
    parties.add(p); await db.saveParties(parties); await load();
  }
  Future<void> addTxn({required Party party,required int amount,required String type,String description='',String method='Cash'}) async {
    final t=Txn(id:DateTime.now().microsecondsSinceEpoch.toString(),partyId:party.id,partyName:party.name,type:type,amount:amount,date:DateTime.now(),description:description,method:method);
    txns.insert(0,t); await db.saveTxns(txns); await load();
  }
  Future<void> addExpense({required int amount,required String category,String description='',String method='Cash'}) async {
    expenses.insert(0,Expense(id:DateTime.now().microsecondsSinceEpoch.toString(),category:category,amount:amount,date:DateTime.now(),description:description,method:method));
    await db.saveExpenses(expenses); await load();
  }
  Future<void> addProduct({required String name,required int sell,required int stock}) async {
    products.add(Product(id:DateTime.now().microsecondsSinceEpoch.toString(),name:name,sell:sell,stock:stock));
    await db.saveProducts(products); await load();
  }
  int balance(Party p)=>AccountingService.balanceFor(p,txns);
  int get receivable=>customers.fold(0,(s,p)=>s+(balance(p)>0?balance(p):0));
  int get payable=>suppliers.fold(0,(s,p)=>s+(balance(p)<0?-balance(p):0));
  int get todayReceived=>txns.where((t)=>t.type=='receive'&&DateUtils.isSameDay(t.date,DateTime.now())).fold(0,(s,t)=>s+t.amount);
  int get todayGiven=>txns.where((t)=>t.type=='give'&&DateUtils.isSameDay(t.date,DateTime.now())).fold(0,(s,t)=>s+t.amount);
  Future<void> setTheme(ThemeMode m) async {themeMode=m; await db.put('theme',m==ThemeMode.dark?'dark':m==ThemeMode.light?'light':'system');notifyListeners();}
}
