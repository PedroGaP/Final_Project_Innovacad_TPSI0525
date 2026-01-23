import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:innovacad_mobile/input_model/sign_in_input.dart';
import 'package:innovacad_mobile/service/sign_service.dart';
import 'package:innovacad_mobile/utils/overlays.dart';
import 'package:lucid_validation/lucid_validation.dart';
import 'package:provider/provider.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final _key = GlobalKey<FormState>();
  final SignInInput input = SignInInput();

  List<ValidationException> get emailExceptions =>
      input.getExceptionsByKey(input, 'email');
  List<ValidationException> get passwordExceptions =>
      input.getExceptionsByKey(input, 'password');

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    final colors = context.theme.colors;

    return SafeArea(
      child: FScaffold(
        resizeToAvoidBottomInset: true,

        scaffoldStyle: (style) => style.copyWith(
          backgroundColor: colors.background,
          childPadding: const EdgeInsets.all(16),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: typography.xl3.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          text: "Sign In",
                          children: [
                            TextSpan(
                              text:
                                  "\nEnter your email and password to securely access your account and manage your schedules.",
                              style: typography.xs.copyWith(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
                      // Formulário
                      Form(
                        key: _key,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 24,
                          children: [
                            FTextFormField.email(
                              hint: "Enter your email...",
                              control: FTextFieldControl.managed(
                                controller: input.email,
                              ),
                              validator: (value) {
                                if (emailExceptions.isNotEmpty) {
                                  return emailExceptions.first.message;
                                }
                                return null;
                              },
                            ),
                            Column(
                              spacing: 12,
                              children: [
                                FTextFormField.password(
                                  control: FTextFieldControl.managed(
                                    controller: input.password,
                                  ),
                                  hint: "Enter your password...",
                                  validator: (value) {
                                    if (passwordExceptions.isNotEmpty) {
                                      return passwordExceptions.first.message;
                                    }
                                    return null;
                                  },
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    "Forgot Password?",
                                    style: typography.sm.copyWith(
                                      color: colors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            FButton(
                              onPress: () async {
                                input.validate(input);
                                if (!_key.currentState!.validate()) return;

                                final result =
                                    await Provider.of<SignService>(
                                      context,
                                      listen: false,
                                    ).signInWithEmail(
                                      input.email.text,
                                      input.password.text,
                                    );

                                if (!result) {
                                  AppOverlay.showToast(
                                    context,
                                    type: AppOverlayType.error,
                                    title: "Not Signed In",
                                    description:
                                        "Couldn't sign in, verify your credentials and try again.",
                                  );
                                  return;
                                }

                                AppOverlay.showToast(
                                  context,
                                  type: AppOverlayType.success,
                                  title: "Signed In",
                                  description:
                                      "You'll be redirected to home page.",
                                );
                              },
                              child: const Text("Sign In"),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      const FDivider(),

                      const SizedBox(height: 32),

                      Text(
                        "OR",
                        style: typography.lg.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Botão Google
                      FButton(
                        style: (style) => style.copyWith(
                          decoration: FWidgetStateMap.all(
                            BoxDecoration(
                              color: colors.background,
                              border: Border.all(color: colors.secondary),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        onPress: () {},
                        prefix: SizedBox(
                          height: 32,
                          width: 32,
                          child: Image.network(
                            'http://pngimg.com/uploads/google/google_PNG19635.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Text(
                          "Sign In with Google",
                          style: typography.sm.copyWith(
                            color: colors.secondaryForeground,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
