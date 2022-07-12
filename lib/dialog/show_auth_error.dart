import 'package:blocwithfirebaseexample/auth/auth_error.dart';
import 'package:blocwithfirebaseexample/dialog/generic_dialog.dart';
import 'package:flutter/material.dart' show BuildContext;

Future<void> showAuthError({
  required BuildContext context,
  required AuthError authError,
}) {
  return showGenericDialog<void>(
    context: context,
    title: authError.dialogTitle,
    content: authError.dialogText,
    optionsBuilder: () => {
      'OK': true,
    },
  );
}
