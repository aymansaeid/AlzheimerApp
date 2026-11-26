import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/safe_zone_calculator.dart';
import '../../domain/entities/patient_entity.dart';
import '../bloc/tracker_map_bloc.dart';
import '../bloc/tracker_map_event.dart';
import '../bloc/tracker_map_state.dart';
import '../widgets/expandable_patient_marker.dart';
import '../widgets/follower_location_marker.dart';
import '../widgets/patient_horizontal_list.dart';
import '../widgets/patient_quick_actions_bar.dart';
import '../widgets/safe_zone_setup_overlay.dart';

class TrackerMapPage extends StatelessWidget {
  final String? initialPatientId;

  const TrackerMapPage({super.key, this.initialPatientId});

  @override
  Widget build(BuildContext context) {
    TrackerMapBloc? existingBloc;
    try {
      existingBloc = context.read<TrackerMapBloc>();
    } catch (_) {}

    if (existingBloc != null) {
      return _TrackerMapView(initialPatientId: initialPatientId);
    }

    return BlocProvider(
      create: (_) => getIt<TrackerMapBloc>(),
      child: _TrackerMapView(initialPatientId: initialPatientId),
    );
  }
}

class _TrackerMapView extends StatefulWidget {
  final String? initialPatientId;

  const _TrackerMapView({this.initialPatientId});

  @override
  State<_TrackerMapView> createState() => _TrackerMapViewState();
}

class _TrackerMapViewState extends State<_TrackerMapView>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();

  final LatLng _cameraCenter = const LatLng(40.9880, 29.0255);
  final double _cameraZoom = 14.5;

  bool _isMapReady = false;
  bool _hasAutoCentered = false;
  bool _isCenteredOnFollower = false;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<TrackerMapBloc>();
    if (bloc.state.status == TrackerMapStatus.initial) {
      bloc.add(TrackerMapStarted(initialPatientId: widget.initialPatientId));
    } else if (widget.initialPatientId != null) {
      bloc.add(PatientSelected(widget.initialPatientId));
    }
  }

  @override
  void didUpdateWidget(covariant _TrackerMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialPatientId != null &&
        widget.initialPatientId != oldWidget.initialPatientId) {
      context.read<TrackerMapBloc>().add(
        PatientSelected(widget.initialPatientId),
      );
      _focusPatientIfReady(widget.initialPatientId!);
    }
  }

  void _focusPatientIfReady(String patientId) {
    if (!_isMapReady) return;
    final state = context.read<TrackerMapBloc>().state;
    final target = state.patients.cast<PatientEntity?>().firstWhere(
      (p) => p?.id == patientId,
      orElse: () => null,
    );
    if (target != null) {
      final hasMissingBanner = state.patients.any((p) => p.safeZone == null);
      _focusOnPatient(target, hasMissingBanner: hasMissingBanner);
    }
  }

  void _focusOnPatient(
    PatientEntity patient, {
    required bool hasMissingBanner,
  }) {
    if (!_isMapReady) return;
    _isCenteredOnFollower = false;

    final safeZone = patient.safeZone;
    if (safeZone != null) {
      const distance = Distance();
      final points = <LatLng>[
        distance.offset(safeZone.center, safeZone.radiusInMeters, 0),
        distance.offset(safeZone.center, safeZone.radiusInMeters, 90),
        distance.offset(safeZone.center, safeZone.radiusInMeters, 180),
        distance.offset(safeZone.center, safeZone.radiusInMeters, 270),
        if (patient.currentLocation != null) patient.currentLocation!,
      ];

      final bounds = LatLngBounds.fromPoints(points);
      final fitted = CameraFit.bounds(
        bounds: bounds,
        padding: EdgeInsets.fromLTRB(
          36,
          hasMissingBanner ? 175 : 120,
          36,
          200,
        ),
        maxZoom: 16.5,
        minZoom: 3.0,
      ).fit(_mapController.camera);

      _animatedMapMove(fitted.center, fitted.zoom);
      return;
    }

    if (patient.currentLocation != null) {
      final currentZoom = _mapController.camera.zoom;
      _animatedMapMove(
        patient.currentLocation!,
        currentZoom < 15.5 ? 15.5 : currentZoom,
      );
    }
  }

  void _tryAutoCenter(TrackerMapState state) {
    if (_hasAutoCentered || !_isMapReady) return;
    final selected = state.selectedPatient;
    if (selected != null &&
        (selected.safeZone != null || selected.currentLocation != null)) {
      _hasAutoCentered = true;
      final hasMissingBanner = state.patients.any((p) => p.safeZone == null);
      _focusOnPatient(selected, hasMissingBanner: hasMissingBanner);
      return;
    }

    final targetLocation = state.patients
        .where((p) => p.currentLocation != null)
        .map((p) => p.currentLocation!)
        .firstOrNull;
    if (targetLocation != null) {
      _hasAutoCentered = true;
      _mapController.move(targetLocation, _cameraZoom);
    }
  }

  /// Haritayı animasyonlu olarak belirli bir konuma, zoom'a ve açıya taşır
  void _animatedMapMove(
    LatLng destLocation,
    double destZoom, {
    double? destRotation,
  }) {
    final camera = _mapController.camera;

    final latTween = Tween<double>(
      begin: camera.center.latitude,
      end: destLocation.latitude,
    );
    final lngTween = Tween<double>(
      begin: camera.center.longitude,
      end: destLocation.longitude,
    );
    final zoomTween = Tween<double>(
      begin: camera.zoom,
      end: destZoom,
    );

    double startRotation = camera.rotation % 360;
    if (startRotation > 180) startRotation -= 360;
    if (startRotation < -180) startRotation += 360;

    final double targetRotation = destRotation ?? startRotation;

    final rotateTween = Tween<double>(
      begin: startRotation,
      end: targetRotation,
    );

    final controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    final Animation<double> animation = CurvedAnimation(
      parent: controller,
      curve: Curves.fastOutSlowIn,
    );

    controller.addListener(() {
      _mapController.moveAndRotate(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
        rotateTween.evaluate(animation),
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  /// ÜSTTEKİ BUTON: Nerede olursa olsun haritayı Kuzey'e (0.0 dereceye) döndürür
  void _resetNorth() {
    _animatedMapMove(
      _mapController.camera.center,
      _mapController.camera.zoom,
      destRotation: 0.0,
    );
  }

  /// ALTTAKİ ANA FAB: İlk basışta mevcut zoom'u koruyarak merkeze alır,
  /// ikinci basışta (zaten merkezdeyken) yakınlaştırır.
  void _centerOnFollower(LatLng? followerLocation) {
    if (followerLocation == null || !_isMapReady) return;

    final camera = _mapController.camera;
    final centerPx = camera.projectAtZoom(camera.center);
    final followerPx = camera.projectAtZoom(followerLocation);
    final isAlreadyCentered = (centerPx - followerPx).distance <= 12.0;

    if (!_isCenteredOnFollower && !isAlreadyCentered) {
      _isCenteredOnFollower = true;
      _animatedMapMove(followerLocation, camera.zoom);
    } else {
      _isCenteredOnFollower = true;
      final targetZoom = camera.zoom < 16.0 ? 16.0 : camera.zoom;
      _animatedMapMove(followerLocation, targetZoom);
    }
  }

  // Sadece pusula dönüşünü, zoom seviyesini ve Safe-Zone yarıçapını dinleyecek izleyiciler
  final ValueNotifier<double> _mapRotationNotifier = ValueNotifier(0.0);
  final ValueNotifier<double> _mapZoomNotifier = ValueNotifier(14.5);
  final ValueNotifier<double> _safeZoneRadiusNotifier = ValueNotifier(0.0);

  @override
  void dispose() {
    _mapRotationNotifier.dispose();
    _mapZoomNotifier.dispose();
    _safeZoneRadiusNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Takipçi Haritası'),
      ),
      body: BlocConsumer<TrackerMapBloc, TrackerMapState>(
        listener: (context, state) {
          if (state.status == TrackerMapStatus.loaded) {
            _tryAutoCenter(state);
          }

          if (state.actionErrorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.actionErrorMessage!)),
            );
            context.read<TrackerMapBloc>().add(const TrackerMapErrorCleared());
          }
        },
        builder: (context, state) {
          final bloc = context.read<TrackerMapBloc>();
          final selectedPatient = state.selectedPatient;

          return Stack(
            children: [
              // 1. ANA HARİTA KATMANI
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _cameraCenter,
                  initialZoom: _cameraZoom,
                  onPositionChanged: (camera, hasGesture) {
                    if (hasGesture) {
                      _isCenteredOnFollower = false;
                    }

                    // Eğer Safe-Zone düzenleme modundaysak, çemberin yarıçapını güncelle
                    if (state.isEditingSafeZone) {
                      _safeZoneRadiusNotifier
                          .value = SafeZoneCalculator.calculateRadiusInMeters(
                        latitude: camera.center.latitude,
                        zoom: camera.zoom,
                        circleRadiusInPixels: SafeZoneSetupOverlay.circleRadius,
                      );
                    }

                    // AÇIYI VE ZOOM SEVİYESİNİ GÜNCELLE
                    _mapRotationNotifier.value = camera.rotation;
                    _mapZoomNotifier.value = camera.zoom;
                  },
                  onTap: (_, _) {
                    // Haritanın boş bir yerine tıklanırsa seçimi kaldır (marker küçülür)
                    if (!state.isEditingSafeZone &&
                        state.selectedPatientId != null) {
                      bloc.add(const PatientSelected(null));
                    }
                  },
                  onMapReady: () {
                    _isMapReady = true;
                    _mapZoomNotifier.value = _mapController.camera.zoom;
                    _safeZoneRadiusNotifier
                        .value = SafeZoneCalculator.calculateRadiusInMeters(
                      latitude: _mapController.camera.center.latitude,
                      zoom: _mapController.camera.zoom,
                      circleRadiusInPixels: SafeZoneSetupOverlay.circleRadius,
                    );
                    _tryAutoCenter(bloc.state);
                  },
                  onMapEvent: (event) {
                    _mapRotationNotifier.value = _mapController.camera.rotation;
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.alzcare.mobile',
                  ),

                  // 2. KAYITLI SAFE-ZONE ÇEMBERLERİ KATMANI
                  CircleLayer(
                    circles: state.patients
                        .where((patient) {
                          // 1. Safe-zone tanımlanmamışsa çizme
                          if (patient.safeZone == null) return false;

                          // 2. DÜZENLEME MODU: Eğer bu hastanın safe-zone'unu şu an düzenliyorsak, haritadaki eski çemberi gizle.
                          // (Çünkü ekranın ortasında mor renkli SafeZoneSetupOverlay çemberi var. Üst üste binmesinler.)
                          if (state.isEditingSafeZone &&
                              patient.id == state.selectedPatientId) {
                            return false;
                          }

                          // 3. İHLAL DURUMU (KIRMIZI): Sınır dışındaysa her zaman göster.
                          if (patient.isOutOfSafeZone) return true;

                          // 4. GÜVENDE OLMA DURUMU (YEŞİL): İhlal yoksa, SADECE marker expanded (seçili) ise göster.
                          if (patient.id == state.selectedPatientId) {
                            return true;
                          }

                          // 5. Diğer tüm durumlar (Güvende ve marker'ı kapalı olanlar): Gizle.
                          return false;
                        })
                        .map((patient) {
                          final isOut = patient.isOutOfSafeZone;
                          return CircleMarker(
                            point: patient.safeZone!.center,
                            radius: patient.safeZone!.radiusInMeters,
                            useRadiusInMeter: true,
                            color: isOut
                                ? Colors.red.withValues(alpha: 0.22)
                                : Colors.green.withValues(alpha: 0.18),
                            borderColor: isOut ? Colors.red : Colors.green,
                            borderStrokeWidth: 2.5,
                          );
                        })
                        .toList(),
                  ),

                  // 3. MARKER KATMANI (Takipçi + Hastalar)
                  MarkerLayer(
                    rotate: true,
                    markers: [
                      // Takipçinin Kendi Konumu (Mavi Nokta + Yön Oku)
                      if (state.followerLocation != null)
                        Marker(
                          point: state.followerLocation!,
                          width: 64,
                          height: 64,
                          rotate: false,
                          child: const FollowerLocationMarker(),
                        ),

                      // Hasta Marker'ları (Konumu olan hastalar için)
                      ...state.patients
                          .where((patient) => patient.currentLocation != null)
                          .map((patient) {
                            final isSelected =
                                patient.id == state.selectedPatientId &&
                                !state.isEditingSafeZone;
                            final hasMissingBanner = state.patients.any(
                              (p) => p.safeZone == null,
                            );

                            return Marker(
                              point: patient.currentLocation!,
                              width: 84,
                              height: 100,
                              alignment: Alignment.topCenter,
                              rotate: true,
                              child: ValueListenableBuilder<double>(
                                valueListenable: _mapZoomNotifier,
                                builder: (context, zoom, _) {
                                  final markerScale =
                                      0.6 +
                                      0.4 *
                                          ((zoom - 9.0) / 6.0).clamp(0.0, 1.0);
                                  return ExpandablePatientMarker(
                                    patient: patient,
                                    isSelected: isSelected,
                                    scale: markerScale,
                                    onTap: () {
                                      bloc.add(PatientSelected(patient.id));
                                      _focusOnPatient(
                                        patient,
                                        hasMissingBanner: hasMissingBanner,
                                      );
                                    },
                                  );
                                },
                              ),
                            );
                          }),
                    ],
                  ),
                ],
              ),

              if (state.status == TrackerMapStatus.loading &&
                  state.patients.isEmpty)
                const Center(child: CircularProgressIndicator()),

              // 4. ÜST YATAY HASTA LİSTESİ
              if (!state.isEditingSafeZone && state.patients.isNotEmpty)
                Positioned(
                  top: 8,
                  left: 0,
                  right: 0,
                  child: PatientHorizontalList(
                    patients: state.patients,
                    selectedPatientId: state.selectedPatientId,
                    onPatientTap: (patient) {
                      bloc.add(PatientSelected(patient.id));
                      if (patient.currentLocation != null ||
                          patient.safeZone != null) {
                        final hasMissingBanner = state.patients.any(
                          (p) => p.safeZone == null,
                        );
                        _focusOnPatient(
                          patient,
                          hasMissingBanner: hasMissingBanner,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${patient.name} henüz konum göndermedi.',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),

              // 4.5. GÜVENLİ BÖLGESİ OLMAYAN HASTALAR İÇİN UYARI (Floating Alert)
              if (!state.isEditingSafeZone)
                Builder(
                  builder: (context) {
                    final missingSafeZonePatients = state.patients
                        .where((p) => p.safeZone == null)
                        .toList();

                    if (missingSafeZonePatients.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    final isSingle = missingSafeZonePatients.length == 1;
                    final text = isSingle
                        ? '${missingSafeZonePatients.first.name} için güvenli bölge tanımlanmamış.'
                        : '${missingSafeZonePatients.length} hastanız için güvenli bölge eksik.';

                    return Positioned(
                      top: 115, // Yatay listenin (100px) hemen altına hizalanır
                      left: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange.shade300,
                            width: 1.5,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.orange.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                text,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

              // 5. ALT BİLGİ VE AKSİYON KARTI (Hasta seçiliyse görünür)
              if (selectedPatient != null && !state.isEditingSafeZone)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: PatientQuickActionsBar(
                    selectedPatient: selectedPatient,
                    onClose: () => bloc.add(const PatientSelected(null)),
                    onEditSafeZone: () {
                      final target =
                          selectedPatient.currentLocation ??
                          selectedPatient.safeZone?.center ??
                          state.followerLocation;
                      if (target != null) {
                        _animatedMapMove(target, _cameraZoom);
                      }
                      bloc.add(const SafeZoneEditModeToggled(true));
                    },
                  ),
                ),

              // 6. SAĞ ALT BUTON GRUBU: ÜSTTE KUZEY (NORTH) BUTONU + ALTTA KONUMUM (FAB)
              if (!state.isEditingSafeZone)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  right: 16,
                  bottom: selectedPatient != null ? 172 : 24,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ÜSTTEKİ KUZEYE DÖNDÜRME (NORTH) BUTONU
                      ValueListenableBuilder<double>(
                        valueListenable: _mapRotationNotifier,
                        builder: (context, rotation, child) {
                          // Açı -1 ile 1 derece arasındaysa sıfır kabul et ve gizle
                          final normalized = rotation % 360;
                          final isRotated =
                              normalized.abs() > 1.0 &&
                              (normalized.abs() - 360).abs() > 1.0;

                          return AnimatedScale(
                            scale: isRotated ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: FloatingActionButton.small(
                                heroTag: 'reset_north_fab',
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.redAccent,
                                tooltip: 'Kuzeye Döndür',
                                onPressed: _resetNorth,
                                child: Transform.rotate(
                                  // Canlı rotasyon değerini kullan
                                  angle: rotation * (3.1415926535 / 180.0),
                                  child: const Icon(Icons.explore),
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      // ALTTAKİ KONUMUMA ODAKLAN (FAB) BUTONU
                      FloatingActionButton(
                        heroTag: 'center_my_location_fab',
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blueAccent,
                        tooltip: 'Konumuma Odaklan',
                        onPressed: () =>
                            _centerOnFollower(state.followerLocation),
                        child: const Icon(Icons.my_location),
                      ),
                    ],
                  ),
                ),

              // 7. SAFE-ZONE AYARLAMA OVERLAY KATMANI
              if (state.isEditingSafeZone && selectedPatient != null)
                ValueListenableBuilder<double>(
                  valueListenable: _safeZoneRadiusNotifier,
                  builder: (context, radius, child) {
                    return SafeZoneSetupOverlay(
                      patientName: selectedPatient.name,
                      currentRadiusInMeters: radius,
                      hasExistingSafeZone: selectedPatient.safeZone != null,
                      onCancel: () =>
                          bloc.add(const SafeZoneEditModeToggled(false)),
                      onRemove: () => bloc.add(const SafeZoneRemoved()),
                      onSave: () => bloc.add(
                        SafeZoneSaved(
                          center: _mapController.camera.center,
                          radiusInMeters: radius,
                        ),
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}
