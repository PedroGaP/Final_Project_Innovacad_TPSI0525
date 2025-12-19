import 'package:vaden/vaden.dart';
import 'package:vaden_security/vaden_security.dart';

@Service()
class UserDetailsServiceImpl implements UserDetailsService {
  @override
  Future<UserDetails?> loadUserByUsername(String userId) async {
    print("$userId ????");
    return null;
  }
}
