import 'package:flutter/material.dart';
import 'package:innovacad_mobile/models/user_model.dart';
import 'package:innovacad_mobile/repository/sign_in_repository.dart';
import 'package:innovacad_mobile/utils/result.dart';

class SignService extends ChangeNotifier {
  final SignInRepository _signRepository = SignInRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  UserModel _user = UserModel.guest();
  UserModel get user => _user;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<bool> signInWithEmail(String email, String password) async {
    setLoading(true);

    Result<UserModel?> user = await _signRepository.signInWithEmail(
      email,
      password,
    );

    print("Passa");

    if (!user.isSuccess) {
      _user = UserModel.guest();
      print(user.error!.details);
    } else {
      _user = user.value!;
    }

    setLoading(false);

    return !_user.isGuest;
  }
}
