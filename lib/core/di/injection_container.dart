import 'package:get_it/get_it.dart';
import '../../features/scanner/data/datasources/camera_local_datasource.dart';
import '../../features/scanner/data/repositories/camera_repository_impl.dart';
import '../../features/scanner/domain/repositories/camera_repository.dart';
import '../../features/scanner/domain/usecases/capture_image.dart';
import '../../features/scanner/domain/usecases/initialize_camera.dart';
import '../../features/scanner/domain/usecases/toggle_flash.dart';
import '../../features/scanner/presentation/bloc/camera/camera_bloc.dart';
import '../../features/scanner/presentation/bloc/camera/scan_session_bloc.dart';
import '../image_processing/process_scanned_image.dart';


final sl = GetIt.instance;

Future<void> init() async {
  // BLoC
  sl.registerFactory(
        () => CameraBloc(
      initializeCamera: sl(),
      captureImage: sl(),
      toggleFlash: sl(),
    ),
  );
  // In injection_container.dart
  sl.registerFactory(() => ScanSessionBloc());

  // Use cases
  sl.registerLazySingleton(() => InitializeCamera(sl()));
  sl.registerLazySingleton(() => CaptureImage(sl()));
  sl.registerLazySingleton(() => ToggleFlash(sl()));
  sl.registerLazySingleton<ProcessScannedImage>(() => ProcessScannedImage());

  // Repository
  sl.registerLazySingleton<CameraRepository>(
        () => CameraRepositoryImpl(sl()),
  );

  // Data sources
  sl.registerLazySingleton<CameraLocalDataSource>(
        () => CameraLocalDataSourceImpl(),
  );
}