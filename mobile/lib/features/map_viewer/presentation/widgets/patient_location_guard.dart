import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/core/di/injection.dart';
import 'package:mobile/features/location_tracking/data/services/location_bg_service.dart';
import 'package:mobile/features/location_tracking/data/services/location_permission_service.dart';
import 'package:mobile/features/map_viewer/presentation/pages/location_permission_required.dart';

/// Hasta rolünde konum servisi ve "Her Zaman" konum izni verilmeden
/// uygulamanın kullanımına izin vermeyen ve izin aktifken takip servisini
/// otomatik başlatan koruyucu bileşen.
class PatientLocationGuard extends StatefulWidget {
  final Widget child;

  const PatientLocationGuard({super.key, required this.child});

  @override
  State<PatientLocationGuard> createState() => _PatientLocationGuardState();
}

class _PatientLocationGuardState extends State<PatientLocationGuard>
    with WidgetsBindingObserver {
  final LocationPermissionService _permissionService =
      getIt<LocationPermissionService>();

  LocationAccessStatus? _status;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermission();
    }
  }

  Future<void> _checkPermission() async {
    final status = await _permissionService.checkStatus(requireAlways: true);
    if (!mounted) return;

    setState(() {
      _status = status;
    });

    if (status == LocationAccessStatus.granted) {
      unawaited(LocationBgService.startTrackingIfNeeded());
    } else {
      unawaited(LocationBgService.stopTracking());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_status == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_status != LocationAccessStatus.granted) {
      return LocationPermissionRequiredPage(
        onPermissionGranted: _checkPermission,
      );
    }

    return widget.child;
  }
}
