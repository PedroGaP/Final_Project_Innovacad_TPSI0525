import 'package:innovacad_api/src/core/core.dart';
import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'output_document_dao.g.dart';

@DTO()
@annotation.JsonSerializable()
class OutputDocumentDao {
  @annotation.JsonKey(name: 'document_id')
  final String document_id;

  @annotation.JsonKey(name: 'file_name')
  final String file_name;

  @annotation.JsonKey(name: 'file_path')
  final String file_path;

  @annotation.JsonKey(name: 'mime_type')
  final String mime_type;

  @annotation.JsonKey(name: 'file_size_bytes')
  @NumberConverter()
  final int file_size_bytes;

  @annotation.JsonKey(name: 'type_code')
  final String type_code;

  @annotation.JsonKey(name: 'created_at')
  final String created_at;

  OutputDocumentDao({
    required this.document_id,
    required this.file_name,
    required this.file_path,
    required this.mime_type,
    required this.file_size_bytes,
    required this.type_code,
    required this.created_at,
  });
  Map<String, dynamic> toJson() => _$OutputDocumentDaoToJson(this);
  factory OutputDocumentDao.fromJson(Map<String, dynamic> json) =>
      _$OutputDocumentDaoFromJson(json);
}
