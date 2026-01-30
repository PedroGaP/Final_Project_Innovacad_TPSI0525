// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'output_document_dao.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OutputDocumentDao _$OutputDocumentDaoFromJson(Map<String, dynamic> json) =>
    OutputDocumentDao(
      document_id: json['document_id'] as String,
      file_name: json['file_name'] as String,
      file_path: json['file_path'] as String,
      mime_type: json['mime_type'] as String,
      file_size_bytes: const NumberConverter().fromJson(
        json['file_size_bytes'] as Object,
      ),
      type_code: json['type_code'] as String,
      created_at: json['created_at'] as String,
    );

Map<String, dynamic> _$OutputDocumentDaoToJson(
  OutputDocumentDao instance,
) => <String, dynamic>{
  'document_id': instance.document_id,
  'file_name': instance.file_name,
  'file_path': instance.file_path,
  'mime_type': instance.mime_type,
  'file_size_bytes': const NumberConverter().toJson(instance.file_size_bytes),
  'type_code': instance.type_code,
  'created_at': instance.created_at,
};
