import 'package:innovacad_api/src/core/core.dart';

abstract class IUserService<T, CreateUserDto, UpdateUserDto> {
  Future<Result<T>> create(CreateUserDto dto);

  Future<Result<T>> update(String id, UpdateUserDto dto);

  Future<Result<T>> delete(String id);

  Future<Result<List<T>>> getAll();

  Future<Result<T>> getById(String id);
}
