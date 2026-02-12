import 'package:mysql_utils/mysql_utils.dart';

extension MysqlTransactionExtension on MysqlUtils {
  /// Executes an atomic transaction with optimized lock handling
  Future<T> transaction<T>(Future<T> Function(MysqlUtils txn) action) async {
    bool isRootTransaction = false;
    try {
      await startTrans();
      isRootTransaction = true;
    } catch (e) {
      if (!e.toString().contains("Only supports startTrans once")) {
        rethrow;
      }
    }
    try {
      await query("SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;");
      await query("SET autocommit=0;");

      final result = await action(this);

      if (isRootTransaction) {
        await commit();
      }
      return result;
    } catch (e) {
      if (isRootTransaction) {
        await rollback();
      }
      rethrow;
    } finally {
      await query("SET autocommit=1;");
    }
  }
}
