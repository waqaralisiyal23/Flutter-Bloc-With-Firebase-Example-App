import 'dart:io';

import 'package:blocwithfirebaseexample/auth/auth_error.dart';
import 'package:blocwithfirebaseexample/bloc/app_event.dart';
import 'package:blocwithfirebaseexample/bloc/app_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

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

    on<AppEventGoToLogin>((event, emit) {
      emit(
        const AppStateLoggedOut(isLoading: false),
      );
    });

    on<AppEventInitialize>((event, emit) async {
      // get the current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(
          const AppStateLoggedOut(
            isLoading: false,
          ),
        );
      } else {
        // go grab the user's uploaded images
        final images = await _getImages(user.uid);
        emit(
          AppStateLoggedIn(
            isLoading: false,
            user: user,
            images: images,
          ),
        );
      }
    });

    on<AppEventLogIn>((event, emit) async {
      // start loading
      emit(
        const AppStateLoggedOut(isLoading: true),
      );
      final email = event.email;
      final password = event.password;

      try {
        // log the user in
        final credential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        if (credential.user != null) {
          // get images for user
          final images = await _getImages(credential.user!.uid);
          emit(
            AppStateLoggedIn(
              user: credential.user!,
              images: images,
              isLoading: false,
            ),
          );
        } else {
          emit(
            const AppStateLoggedOut(
              isLoading: false,
              authError: AuthErrorUnknown(),
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        emit(
          AppStateLoggedOut(
            isLoading: false,
            authError: AuthError.from(e),
          ),
        );
      }
    });

    on<AppEventRegister>((event, emit) async {
      // start loading
      emit(
        const AppStateIsInRegistrationView(isLoading: true),
      );
      final email = event.email;
      final password = event.password;

      try {
        // create the user
        final credential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        if (credential.user != null) {
          emit(
            AppStateLoggedIn(
              user: credential.user!,
              images: const [],
              isLoading: false,
            ),
          );
        } else {
          emit(
            const AppStateIsInRegistrationView(
              isLoading: false,
              authError: AuthErrorUnknown(),
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        emit(
          AppStateIsInRegistrationView(
            isLoading: false,
            authError: AuthError.from(e),
          ),
        );
      }
    });

    // log out event
    on<AppEventLogOut>((event, emit) async {
      emit(
        const AppStateLoggedOut(isLoading: true),
      );
      // log the user out
      await FirebaseAuth.instance.signOut();
      // log the user out in the UI as well
      emit(
        const AppStateLoggedOut(isLoading: false),
      );
    });

    // handle account deletion
    on<AppEventDeleteAccount>((event, emit) async {
      final user = FirebaseAuth.instance.currentUser;
      // log the user out if we don't have a current user
      if (user == null) {
        emit(
          const AppStateLoggedOut(isLoading: false),
        );
        return;
      }
      // start loading
      emit(
        AppStateLoggedIn(
          isLoading: true,
          user: user,
          images: state.images ?? [],
        ),
      );

      try {
        // delete the user folder
        final ListResult folderContents =
            await FirebaseStorage.instance.ref(user.uid).listAll();
        for (Reference reference in folderContents.items) {
          await reference
              .delete()
              .catchError((_) {}); // maybe handle the error?
        }
        // delete the folder itself
        await FirebaseStorage.instance
            .ref(user.uid)
            .delete()
            .catchError((_) {});

        // delete the user
        await user.delete();
        // log the user out
        await FirebaseAuth.instance.signOut();
        // log the user out in the UI as well
        emit(
          const AppStateLoggedOut(isLoading: false),
        );
      } on FirebaseAuthException catch (e) {
        emit(
          AppStateLoggedIn(
            user: user,
            images: state.images ?? [],
            isLoading: false,
            authError: AuthError.from(e),
          ),
        );
      } on FirebaseException {
        // we might not be able to delete the folder
        // log the user out
        emit(
          const AppStateLoggedOut(
            isLoading: false,
          ),
        );
      }
    });

    // handle uploading images
    on<AppEventUploadImage>((event, emit) async {
      final User? user = state.user;
      if (user == null) {
        emit(
          const AppStateLoggedOut(isLoading: false),
        );
        return;
      }
      // starts the loading process
      emit(
        AppStateLoggedIn(
          user: user,
          images: state.images ?? [],
          isLoading: true,
        ),
      );

      // upload the file
      final File file = File(event.filePathToUpload);
      bool result = await _uploadImage(
        file: file,
        userId: user.uid,
      );
      if (result) {
        // after upload is complete, grab the latest file references
        final images = await _getImages(user.uid);
        // emit the new images and turn off loading
        emit(
          AppStateLoggedIn(
            user: user,
            images: images,
            isLoading: false,
          ),
        );
      }
    });
  }

  Future<Iterable<Reference>> _getImages(String userId) async {
    ListResult listResult = await FirebaseStorage.instance.ref(userId).list();
    return listResult.items;
  }

  Future<bool> _uploadImage({
    required File file,
    required String userId,
  }) async {
    try {
      await FirebaseStorage.instance
          .ref(userId)
          .child(const Uuid().v4())
          .putFile(file);
      return true;
    } catch (e) {
      return false;
    }
  }
}
