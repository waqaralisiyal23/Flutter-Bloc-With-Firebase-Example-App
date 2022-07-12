import 'package:blocwithfirebaseexample/bloc/app_bloc.dart';
import 'package:blocwithfirebaseexample/bloc/app_event.dart';
import 'package:blocwithfirebaseexample/dialog/generic_dialog.dart';
import 'package:blocwithfirebaseexample/extensions/if_debugging.dart';
import 'package:blocwithfirebaseexample/res/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class RegisterScreen extends HookWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final emailController = useTextEditingController(
      text: 'waqar@gmail.com'.ifDebugging,
    );
    final passwordController = useTextEditingController(
      text: 'waqar123'.ifDebugging,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                hintText: 'Enter your email here...',
              ),
              keyboardType: TextInputType.emailAddress,
              keyboardAppearance: Brightness.dark,
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                hintText: 'Enter your password here...',
              ),
              keyboardAppearance: Brightness.dark,
              obscureText: true,
              obscuringCharacter: '◉',
            ),
            TextButton(
              onPressed: () {
                final email = emailController.text;
                final password = passwordController.text;
                if (email.isEmpty || password.isEmpty) {
                  showGenericDialog<bool>(
                    context: context,
                    title: Constants.emailOrPasswordEmptyDialogTitle,
                    content: Constants.emailOrPasswordEmptyDescription,
                    optionsBuilder: () => {
                      'Ok': true,
                    },
                  );
                } else {
                  context.read<AppBloc>().add(
                        AppEventRegister(
                          email: email,
                          password: password,
                        ),
                      );
                }
              },
              child: const Text('Register'),
            ),
            TextButton(
              onPressed: () {
                context.read<AppBloc>().add(
                      const AppEventGoToLogin(),
                    );
              },
              child: const Text('Already registered? Log in here!'),
            ),
          ],
        ),
      ),
    );
  }
}
