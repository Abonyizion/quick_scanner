import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../bloc/camera/camera_bloc.dart';
import '../../bloc/camera/camera_event.dart';


class CameraControls extends StatelessWidget {

  const CameraControls({
    super.key});

  @override
  Widget build(BuildContext context) {
    final picker = ImagePicker();
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24),
      child: Row(
        children: [
          // Empty space to push capture button to center
          const Spacer(),

        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(44),
            child: InkWell(
               onTap: () {
          context.read<CameraBloc>().add(CaptureImageEvent());
          },
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.colorScheme.primary, width: 3),
                ),
                child: const Icon(Icons.camera_alt, size: 40),
              ),
            ),
          ),
        ),
         SizedBox(
           width: 32,
         ),
          // Gallery button
          InkWell(
            onTap: () async {
              try {
                final pickedFile = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 90,
                );
              } catch (e) {
                debugPrint('Failed to pick image from gallery: $e');
              }
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blueGrey,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.photo_library,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
