import 'models.dart';
class AccountingService {
  static int signedCustomerBalance(String transactionType, int amount) {
    if (transactionType == 'give') return amount;
    if (transactionType == 'receive') return -amount;
    return 0;
  }
  static int balanceFor(Party p, List<Txn> txns) {
    var value = p.balance;
    for (final t in txns.where((x)=>x.partyId==p.id)) {
      value += signedCustomerBalance(t.type, t.amount);
    }
    return value;
  }
}
