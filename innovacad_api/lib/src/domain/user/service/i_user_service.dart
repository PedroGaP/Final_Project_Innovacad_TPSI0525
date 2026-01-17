import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/user/dto/link/user_link_account_dto.dart';

abstract class IUserService<T, CreateUserDto, UpdateUserDto> {
  Future<Result<T>> create(CreateUserDto dto);

  Future<Result<T>> update(String id, UpdateUserDto dto);

  Future<Result<T>> delete(String id);

  Future<Result<List<T>>> getAll();

  Future<Result<T>> getById(String id);

  Future<Result<T>> linkAccount(UserLinkAccountDto dto);
}
