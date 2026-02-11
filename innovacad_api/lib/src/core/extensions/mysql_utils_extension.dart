import 'package:mysql_utils/mysql_utils.dart';

extension MysqlTransactionExtension on MysqlUtils {
  /// Executes an atomic transaction
  /// If [action] is successful, it commits.
  /// If [action] fails, it rolls back
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
    }
  }
}
