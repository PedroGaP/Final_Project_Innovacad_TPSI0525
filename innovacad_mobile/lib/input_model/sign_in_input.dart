import 'package:flutter/material.dart';
import 'package:lucid_validation/lucid_validation.dart';

class SignInInput extends LucidValidator<SignInInput> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  SignInInput() {
    ruleFor((e) => e.password.text, key: 'password').notEmptyOrNull();
    ruleFor((e) => e.email.text, key: 'email').notEmptyOrNull().validEmail();
  }
}
