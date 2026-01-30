import 'dart:convert';
import 'dart:io';
import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/document/repository/document_repository_impl.dart';
import 'package:uuid/uuid.dart';
import 'package:vaden/vaden.dart';

@Api(tag: 'Document', description: 'Document management endpoints')
@Controller('/documents')
class DocumentController {
  final DocumentRepositoryImpl _repository = DocumentRepositoryImpl();

  @ApiOperation(summary: 'List documents by owner ID')
  @Get('/<ownerId>')
  Future<Response> getDocuments(
    Request request,
    @Param() String ownerId,
  ) async {
    final result = await _repository.getDocumentsByOwner(ownerId);

    if (result.isFailure) {
      return Response.internalServerError(
        body: jsonEncode({'error': result.error?.message}),
      );
    }

    final jsonResponse = jsonEncode(
      result.data!.map((e) => e.toJson()).toList(),
    );

    return Response.ok(
      jsonResponse,
      headers: {'content-type': 'application/json'},
    );
  }

  @ApiOperation(summary: 'Upload a document')
  @ApiParam(name: 'userId', description: 'The ID of the user', required: true)
  @Post('/upload/<userId>')
  Future<Response> uploadTraineeFile(
    Request request,
    @Param('userId') String userId,
  ) async {
    MultipartRequest? multipartRequest = MultipartRequest.of(request);

    if (multipartRequest == null) {
      return Response.badRequest(body: 'Not a multipart request');
    }

    String? typeCode;
    List<int>? fileBytes;
    String? filename;
    String? contentType;

    FormDataRequest formDataRequest = multipartRequest as FormDataRequest;

    try {
      await for (final formData in formDataRequest.formData) {
        if (formData.name == 'type') {
          typeCode = await formData.part.readString();
        } else if (formData.name == 'file') {
          filename = formData.filename;
          contentType = formData.part.headers['content-type'];
          fileBytes = await formData.part.readBytes();
        }
      }

      if (typeCode == null || typeCode.isEmpty) {
        return Response.badRequest(body: 'Missing required field: type');
      }
      if (fileBytes == null || filename == null) {
        return Response.badRequest(body: 'Missing required field: file');
      }

      final uploadDir = Directory('public/uploads/documents/$userId');
      if (!await uploadDir.exists()) {
        await uploadDir.create(recursive: true);
      }
      final uniqueName = "${Uuid().v4()}_$filename";
      final filePath = "${uploadDir.path}/$uniqueName";

      final file = File(filePath);
      await file.writeAsBytes(fileBytes);

      final result = await _repository.saveDocumentRecord(
        filePath: filePath,
        originalName: filename,
        mimeType: contentType ?? 'application/octet-stream',
        size: fileBytes.length,
        typeCode: typeCode,
        userId: userId,
      );

      if (result.isFailure) {
        if (await file.exists()) {
          await file.delete();
        }

        return Response.internalServerError(
          body: jsonEncode({'error': result.error?.message}),
        );
      }

      return Response.ok(
        jsonEncode({
          'message': 'File uploaded successfully',
          'id': result.data,
        }),
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Upload failed: ${e.toString()}'}),
      );
    }
  }

  @ApiOperation(summary: 'Delete a document')
  @Delete('/<docId>')
  Future<Response> deleteDocument(Request request, @Param() String docId) async {
    final result = await _repository.deleteDocument(docId);

    if (result.isFailure) {
      if (result.error?.type == AppErrorType.notFound) {
        return Response.notFound(jsonEncode({'message': 'Document not found'}));
      }
      return Response.internalServerError(
        body: jsonEncode({'message': result.error?.message}),
      );
    }

    return Response.ok(
      jsonEncode({'message': 'Document deleted successfully'}),
      headers: {'content-type': 'application/json'},
    );
  }
}
