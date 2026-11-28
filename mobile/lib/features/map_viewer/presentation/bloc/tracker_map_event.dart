import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/safe_zone_entity.dart';

abstract class TrackerMapEvent extends Equatable {
  const TrackerMapEvent();

  @override
  List<Object?> get props => [];
}

/// Sayfa açıldığında ilk hasta konumlarını çeker, SignalR'a bağlanır ve stream'leri başlatır
class TrackerMapStarted extends TrackerMapEvent {
  final String? initialPatientId;

  const TrackerMapStarted({this.initialPatientId});

  @override
  List<Object?> get props => [initialPatientId];
}

/// Sekmeye geri dönüldüğünde veya yenileme istendiğinde hasta listesini günceller
class TrackerMapRefreshRequested extends TrackerMapEvent {
  final String? selectPatientId;

  const TrackerMapRefreshRequested({this.selectPatientId});

  @override
  List<Object?> get props => [selectPatientId];
}

/// Üstteki yatay listeden veya haritadaki marker'dan bir hasta seçildiğinde
class PatientSelected extends TrackerMapEvent {
  final String? patientId; // null gönderilirse seçimi kaldırır

  const PatientSelected(this.patientId);

  @override
  List<Object?> get props => [patientId];
}

/// Seçili hasta için "Safe-Zone Ekle / Düzenle" modunu açar veya kapatır.
/// [editingZone] null ise yeni bölge ekleme, dolu ise o bölgeyi düzenleme modu açılır.
class SafeZoneEditModeToggled extends TrackerMapEvent {
  final bool isEditing;
  final SafeZoneEntity? editingZone;

  const SafeZoneEditModeToggled(this.isEditing, {this.editingZone});

  @override
  List<Object?> get props => [isEditing, editingZone];
}

/// Ekrandaki sabit çemberin o anki harita merkezine, yarıçapına ve adına göre kaydedilmesi
class SafeZoneSaved extends TrackerMapEvent {
  final String name;
  final LatLng center;
  final double radiusInMeters;

  const SafeZoneSaved({
    required this.name,
    required this.center,
    required this.radiusInMeters,
  });

  @override
  List<Object?> get props => [name, center, radiusInMeters];
}

/// Seçili hastanın belirtilen Safe-Zone kaydını siler
class SafeZoneRemoved extends TrackerMapEvent {
  final String? safeZoneId;

  const SafeZoneRemoved({this.safeZoneId});

  @override
  List<Object?> get props => [safeZoneId];
}

/// Gösterilen anlık işlem hatasını temizler
class TrackerMapErrorCleared extends TrackerMapEvent {
  const TrackerMapErrorCleared();
}
