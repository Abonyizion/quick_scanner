import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class ScanSessionEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class StartScanSessionEvent extends ScanSessionEvent {}

class AddPageToSessionEvent extends ScanSessionEvent {
  final String imagePath;
  AddPageToSessionEvent(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

class RemovePageFromSessionEvent extends ScanSessionEvent {
  final int index;
  RemovePageFromSessionEvent(this.index);

  @override
  List<Object?> get props => [index];
}

class ClearScanSessionEvent extends ScanSessionEvent {}

class FinalizeScanSessionEvent extends ScanSessionEvent {}


// States
abstract class ScanSessionState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ScanSessionInitial extends ScanSessionState {}

class ScanSessionActive extends ScanSessionState {
  final List<String> scannedPages;

  ScanSessionActive({required this.scannedPages});

  @override
  List<Object?> get props => [scannedPages];

  ScanSessionActive copyWith({List<String>? scannedPages}) {
    return ScanSessionActive(
      scannedPages: scannedPages ?? this.scannedPages,
    );
  }
}

class ScanSessionFinalized extends ScanSessionState {
  final List<String> finalPages;

  ScanSessionFinalized(this.finalPages);

  @override
  List<Object?> get props => [finalPages];
}

// BLoC
class ScanSessionBloc extends Bloc<ScanSessionEvent, ScanSessionState> {
  ScanSessionBloc() : super(ScanSessionInitial()) {
    on<StartScanSessionEvent>(_onStartSession);
    on<AddPageToSessionEvent>(_onAddPage);
    on<RemovePageFromSessionEvent>(_onRemovePage);
    on<ClearScanSessionEvent>(_onClearSession);
    on<FinalizeScanSessionEvent>(_onFinalizeSession);
  }

  void _onStartSession(
      StartScanSessionEvent event,
      Emitter<ScanSessionState> emit,
      ) {
    emit(ScanSessionActive(scannedPages: []));
  }

  void _onAddPage(
      AddPageToSessionEvent event,
      Emitter<ScanSessionState> emit,
      ) {
    if (state is ScanSessionActive) {
      final currentState = state as ScanSessionActive;
      final updatedPages = [...currentState.scannedPages, event.imagePath];

      emit(ScanSessionActive(scannedPages: updatedPages));
    } else {
      // If session is not active, start it with this page
      emit(ScanSessionActive(scannedPages: [event.imagePath]));
    }
  }

  void _onRemovePage(
      RemovePageFromSessionEvent event,
      Emitter<ScanSessionState> emit,
      ) {
    if (state is ScanSessionActive) {
      final currentState = state as ScanSessionActive;
      final updatedPages = [...currentState.scannedPages];
      if (event.index >= 0 && event.index < updatedPages.length) {
        updatedPages.removeAt(event.index);
        emit(ScanSessionActive(scannedPages: updatedPages));
      }
    }
  }

  void _onClearSession(
      ClearScanSessionEvent event,
      Emitter<ScanSessionState> emit,
      ) {
    emit(ScanSessionInitial());
  }

  void _onFinalizeSession(
      FinalizeScanSessionEvent event,
      Emitter<ScanSessionState> emit,
      ) {
    if (state is ScanSessionActive) {
      final currentState = state as ScanSessionActive;
      emit(ScanSessionFinalized(currentState.scannedPages));
    }
  }
}