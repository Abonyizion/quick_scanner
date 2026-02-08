
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/camera/camera_bloc.dart';
import '../bloc/camera/camera_event.dart';
import 'camera_view.dart';


class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {


  @override
  void initState() {
    super.initState();
    context.read<CameraBloc>().add(InitializeCameraEvent());
  }

  @override
  Widget build(BuildContext context) {
    return const CameraView();
  }
}

