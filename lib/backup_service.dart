import 'database_service.dart';
class BackupService {
  final DatabaseService db;
  BackupService(this.db);
  Future<String> createJsonBackup()=>db.exportJson();
}
