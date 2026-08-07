class Party {
  final String id, name, phone, address, notes, type;
  int balance; // positive = party owes us for customer; supplier payable handled by type
  final DateTime createdAt;
  Party({
    required this.id, required this.name, this.phone='', this.address='',
    this.notes='', required this.type, this.balance=0, DateTime? createdAt
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String,dynamic> toMap()=>{'id':id,'name':name,'phone':phone,'address':address,'notes':notes,'type':type,'balance':balance,'createdAt':createdAt.toIso8601String()};
  factory Party.fromMap(Map m)=>Party(id:m['id'],name:m['name'],phone:m['phone']??'',address:m['address']??'',notes:m['notes']??'',type:m['type'],balance:m['balance']??0,createdAt:DateTime.tryParse(m['createdAt']??''));
}

class Txn {
  final String id, partyId, partyName, type, description, method;
  final int amount;
  final DateTime date;
  Txn({required this.id,required this.partyId,required this.partyName,required this.type,required this.amount,required this.date,this.description='',this.method='Cash'});
  Map<String,dynamic> toMap()=>{'id':id,'partyId':partyId,'partyName':partyName,'type':type,'amount':amount,'date':date.toIso8601String(),'description':description,'method':method};
  factory Txn.fromMap(Map m)=>Txn(id:m['id'],partyId:m['partyId'],partyName:m['partyName'],type:m['type'],amount:m['amount'],date:DateTime.parse(m['date']),description:m['description']??'',method:m['method']??'Cash');
}

class Product {
  final String id,name,sku,unit;
  final int buy,sell,stock,lowStock;
  Product({required this.id,required this.name,this.sku='',this.unit='pcs',this.buy=0,this.sell=0,this.stock=0,this.lowStock=5});
  Map<String,dynamic> toMap()=>{'id':id,'name':name,'sku':sku,'unit':unit,'buy':buy,'sell':sell,'stock':stock,'lowStock':lowStock};
  factory Product.fromMap(Map m)=>Product(id:m['id'],name:m['name'],sku:m['sku']??'',unit:m['unit']??'pcs',buy:m['buy']??0,sell:m['sell']??0,stock:m['stock']??0,lowStock:m['lowStock']??5);
}

class Expense {
  final String id,category,description,method;
  final int amount;
  final DateTime date;
  Expense({required this.id,required this.category,required this.amount,required this.date,this.description='',this.method='Cash'});
  Map<String,dynamic> toMap()=>{'id':id,'category':category,'description':description,'method':method,'amount':amount,'date':date.toIso8601String()};
  factory Expense.fromMap(Map m)=>Expense(id:m['id'],category:m['category'],amount:m['amount'],date:DateTime.parse(m['date']),description:m['description']??'',method:m['method']??'Cash');
}
