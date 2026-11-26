import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

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
  final String? patientId; // null gönderilirse seçimi kaldırır (marker küçülür)

  const PatientSelected(this.patientId);

  @override
  List<Object?> get props => [patientId];
}

/// Seçili hasta için "Safe-Zone Ayarla" modunu açar veya kapatır
class SafeZoneEditModeToggled extends TrackerMapEvent {
  final bool isEditing;

  const SafeZoneEditModeToggled(this.isEditing);

  @override
  List<Object?> get props => [isEditing];
}

/// Ekrandaki sabit çemberin o anki harita merkezine ve hesaplanan yarıçapa göre kaydedilmesi
class SafeZoneSaved extends TrackerMapEvent {
  final LatLng center;
  final double radiusInMeters;

  const SafeZoneSaved({
    required this.center,
    required this.radiusInMeters,
  });

  @override
  List<Object?> get props => [center, radiusInMeters];
}

/// Seçili hastanın mevcut Safe-Zone tanımlamasını siler
class SafeZoneRemoved extends TrackerMapEvent {
  const SafeZoneRemoved();
}

/// Gösterilen anlık işlem hatasını temizler
class TrackerMapErrorCleared extends TrackerMapEvent {
  const TrackerMapErrorCleared();
}
