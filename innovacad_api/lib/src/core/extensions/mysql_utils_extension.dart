import 'package:mysql_utils/mysql_utils.dart';

extension MysqlTransactionExtension on MysqlUtils {
  Future<T> transaction<T>(Future<T> Function(MysqlUtils txn) action) async {
    await startTrans();

    try {
      final result = await action(this);

      await commit();
      return result;
    } catch (e) {
      await rollback();
      rethrow;
    }
  }
}
