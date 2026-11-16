import 'package:equatable/equatable.dart';

abstract class NotificationPermissionState extends Equatable {
  const NotificationPermissionState();

  @override
  List<Object?> get props => [];
}

class NotificationPermissionInitial extends NotificationPermissionState {
  const NotificationPermissionInitial();
}

class NotificationPermissionChecking extends NotificationPermissionState {
  const NotificationPermissionChecking();
}

class NotificationPermissionGranted extends NotificationPermissionState {
  const NotificationPermissionGranted();
}

class NotificationPermissionDenied extends NotificationPermissionState {
  final bool isPermanentlyDenied;

  const NotificationPermissionDenied({this.isPermanentlyDenied = false});

  @override
  List<Object?> get props => [isPermanentlyDenied];
}
