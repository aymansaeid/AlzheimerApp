import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:signalr_netcore/signalr_client.dart';

abstract class LocationHubDataSource {
  Stream<Map<String, dynamic>> get locationUpdates;
  Future<void> connectAndSubscribe(Iterable<String> patientIds);
  Future<void> disconnect();
}

@LazySingleton(as: LocationHubDataSource)
class LocationHubDataSourceImpl implements LocationHubDataSource {
  final FlutterSecureStorage _secureStorage;

  HubConnection? _hub;
  final Set<String> _subscribedPatientIds = {};
  final StreamController<Map<String, dynamic>> _locationUpdatesController =
      StreamController<Map<String, dynamic>>.broadcast();

  LocationHubDataSourceImpl(this._secureStorage);

  @override
  Stream<Map<String, dynamic>> get locationUpdates =>
      _locationUpdatesController.stream;

  @override
  Future<void> connectAndSubscribe(Iterable<String> patientIds) async {
    final rawBaseUrl = dotenv.env['BASE_URL'] ?? '';
    if (rawBaseUrl.isEmpty) {
      debugPrint('LocationHubDataSource: BASE_URL boş, SignalR bağlanamadı.');
      return;
    }

    final cleanBaseUrl = rawBaseUrl.endsWith('/')
        ? rawBaseUrl.substring(0, rawBaseUrl.length - 1)
        : rawBaseUrl;

    _subscribedPatientIds
      ..clear()
      ..addAll(patientIds.where((id) => id.isNotEmpty));

    if (_hub == null) {
      _hub = HubConnectionBuilder()
          .withUrl(
            '$cleanBaseUrl/hubs/location',
            options: HttpConnectionOptions(
              accessTokenFactory: () async =>
                  (await _secureStorage.read(key: 'jwt_token')) ?? '',
            ),
          )
          .withAutomaticReconnect()
          .build();

      _hub!.on('ReceiveLocationUpdate', (args) {
        if (args == null || args.isEmpty) return;
        final raw = args[0];
        if (raw is Map) {
          _locationUpdatesController.add(Map<String, dynamic>.from(raw));
        }
      });

      _hub!.onreconnected(({String? connectionId}) {
        debugPrint('LocationHubDataSource: Yeniden bağlandı ($connectionId).');
        unawaited(_resubscribe());
      });
    }

    if (_hub!.state == HubConnectionState.Disconnected) {
      await _hub!.start();
    }

    await _resubscribe();
  }

  Future<void> _resubscribe() async {
    final hub = _hub;
    if (hub == null || hub.state != HubConnectionState.Connected) return;

    for (final id in _subscribedPatientIds) {
      try {
        await hub.invoke('SubscribeToPatientTracking', args: [id]);
      } catch (e) {
        debugPrint('LocationHubDataSource: $id aboneliği başarısız: $e');
      }
    }
  }

  @override
  Future<void> disconnect() async {
    final hub = _hub;
    _hub = null;
    _subscribedPatientIds.clear();
    if (hub != null && hub.state != HubConnectionState.Disconnected) {
      try {
        await hub.stop();
      } catch (e) {
        debugPrint('LocationHubDataSource: stop hatası: $e');
      }
    }
  }
}
