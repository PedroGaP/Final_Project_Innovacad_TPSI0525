import 'dart:io';
import 'package:innovacad_api/config/mysql/mysql_configuration.dart';
import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/document/dao/output_document_dao.dart';
import 'package:mysql_utils/mysql_utils.dart';
import 'package:uuid/uuid.dart';
import 'package:vaden/vaden.dart';

@Repository()
class DocumentRepositoryImpl {
  Future<Result<String>> saveDocumentRecord({
    required String filePath,
    required String originalName,
    required String mimeType,
    required int size,
    required String typeCode,
    required String userId,
  }) async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.getConnection();

      await db.startTrans();

      BigInt bg = BigInt.zero;

      if (typeCode == "PROFILE_PIC") {
        bg = await db.update(
          table: 'user',
          updateData: {"image": filePath},
          where: {"id": userId},
        );
      } else {
        bg = await db.insert(
          table: 'documents',
          insertData: {
            'document_id': Uuid().v4(),
            'file_name': originalName,
            'file_path': filePath,
            'mime_type': mimeType,
            'file_size_bytes': size,
            'type_code': typeCode,
            'user_id': userId,
          },
        );
      }

      print(bg);
      print({
        'document_id': Uuid().v4(),
        'file_name': originalName,
        'file_path': filePath,
        'mime_type': mimeType,
        'file_size_bytes': size,
        'type_code': typeCode,
        'user_id': userId,
      });

      await db.commit();

      return Result.success("Upload successful");
    } catch (e, s) {
      if (db != null) await db.rollback();
      print("Upload Error: $e");
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Failed to save document record",
          details: {"error": e.toString(), "stack": s.toString()},
        ),
      );
    } finally {
      await MysqlConfiguration.closeConnection(db);
    }
  }

  Future<Result<List<OutputDocumentDao>>> getDocumentsByOwner(
    String ownerId,
  ) async {
    try {
      return await MysqlConfiguration.executeWithConnection((db) async {
        final sql = """
          SELECT 
            document_id, 
            file_name, 
            file_path, 
            mime_type, 
            file_size_bytes, 
            type_code, 
            created_at 
          FROM documents 
          WHERE user_id = ?
          ORDER BY created_at DESC
        """;

        final result = await db.query(
          sql,
          whereValues: [ownerId],
          isStmt: true,
        );

        if (result.numOfRows == 0) {
          return Result.success([]);
        }

        final list = result.rowsAssoc
            .map((row) => OutputDocumentDao.fromJson(row.assoc()))
            .toList();

        return Result.success(list);
      });
    } catch (e, s) {
      print("Error fetching documents: $e");
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Failed to fetch documents",
          details: {"error": e.toString(), "stack": s.toString()},
        ),
      );
    }
  }

  Future<Result<void>> deleteDocument(String docId) async {
    try {
      return await MysqlConfiguration.executeWithConnection((db) async {
        final docResult = await db.getOne(
          table: 'documents',
          where: {'document_id': docId},
        );

        if (docResult.isEmpty) {
          return Result.failure(
            AppError(AppErrorType.notFound, "Document not found"),
          );
        }

        final String filePath = docResult['file_path'];

        await db.delete(table: 'documents', where: {'document_id': docId});

        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
        }

        return Result.success(null);
      });
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Failed to delete document",
          details: {"error": e.toString(), "stack": s.toString()},
        ),
      );
    }
  }
}
