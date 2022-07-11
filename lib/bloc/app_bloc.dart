import 'package:blocwithfirebaseexample/bloc/app_event.dart';
import 'package:blocwithfirebaseexample/bloc/app_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc()
      : super(
          const AppStateLoggedOut(isLoading: false),
        ) {
    on<AppEventGoToRegistration>((event, emit) {
      emit(
        const AppStateIsInRegistrationView(isLoading: false),
      );
    });
  }
}
