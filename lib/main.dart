import 'package:blocwithfirebaseexample/bloc/app_bloc.dart';
import 'package:blocwithfirebaseexample/bloc/app_event.dart';
import 'package:blocwithfirebaseexample/bloc/app_state.dart';
import 'package:blocwithfirebaseexample/dialog/show_auth_error.dart';
import 'package:blocwithfirebaseexample/firebase_options.dart';
import 'package:blocwithfirebaseexample/loading/loading_screen.dart';
import 'package:blocwithfirebaseexample/screens/home_screen.dart';
import 'package:blocwithfirebaseexample/screens/login_screen.dart';
import 'package:blocwithfirebaseexample/screens/register_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppBloc>(
      create: (_) => AppBloc()..add(const AppEventInitialize()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Bloc With Firebase Example',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: BlocConsumer<AppBloc, AppState>(
          listener: (context, appState) {
            // Manage Loading
            if (appState.isLoading) {
              LoadingScreen.instance().show(
                context: context,
                text: 'Loading...',
              );
            } else {
              LoadingScreen.instance().hide();
            }

            // Manage AuthError
            final authError = appState.authError;
            if (authError != null) {
              showAuthError(context: context, authError: authError);
            }
          },
          builder: (context, appState) {
            if (appState is AppStateLoggedOut) {
              return const LoginScreen();
            } else if (appState is AppStateIsInRegistrationView) {
              return const RegisterScreen();
            } else if (appState is AppStateLoggedIn) {
              return const HomeScreen();
            } else {
              // this should never happen
              return Container();
            }
          },
        ),
      ),
    );
  }
}
