// ignore_for_file: use_build_context_synchronously

import 'package:blocwithfirebaseexample/bloc/app_bloc.dart';
import 'package:blocwithfirebaseexample/bloc/app_event.dart';
import 'package:blocwithfirebaseexample/bloc/app_state.dart';
import 'package:blocwithfirebaseexample/screens/views/main_popup_menu_button.dart';
import 'package:blocwithfirebaseexample/screens/views/storage_image_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends HookWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final picker = useMemoized(() => ImagePicker(), [key]);
    final images = context.watch<AppBloc>().state.images ?? [];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Gallery'),
        actions: [
          IconButton(
            onPressed: () async {
              final image = await picker.pickImage(
                source: ImageSource.gallery,
              );
              if (image == null) {
                return;
              }
              context.read<AppBloc>().add(
                    AppEventUploadImage(filePathToUpload: image.path),
                  );
            },
            icon: const Icon(Icons.upload),
          ),
          const MainPopupMenuButton(),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(8),
        mainAxisSpacing: 20.0,
        crossAxisSpacing: 20.0,
        children: images
            .map((imageRef) => StorageImageView(image: imageRef))
            .toList(),
      ),
    );
  }
}
