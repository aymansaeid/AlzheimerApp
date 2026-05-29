import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/core/errors/exceptions.dart';
import 'package:intl/intl.dart';

import '../models/medication_model.dart';
import '../models/medicine_request.dart';
import '../models/medicine_response.dart';
import '../models/medicine_log_response.dart';

abstract class MedicationRemoteDataSource {
  Future<List<MedicationModel>> getMedicationsByDate(
    String patientId,
    DateTime date,
  );
  Future<MedicationModel> addMedication(MedicationModel medication);
  Future<MedicationModel> updateMedication(MedicationModel medication);
  Future<void> deleteMedication(String id);
  Future<void> markAsTaken(String id, DateTime date);
}

@LazySingleton(as: MedicationRemoteDataSource)
class MedicationRemoteDataSourceImpl implements MedicationRemoteDataSource {
  final Dio dio;

  // In-memory map to link medicine schedule ID to daily log ID
  final Map<String, String> _scheduleToLogIdMap = {};

  MedicationRemoteDataSourceImpl(this.dio);

  @override
  Future<List<MedicationModel>> getMedicationsByDate(
    String patientId,
    DateTime date,
  ) async {
    try {
      // 1. Fetch all medicine schedules for the patient
      final schedulesResponse = await dio.get(
        '/api/Medicine/patient/$patientId',
      );
      List<MedicineResponse> schedules = [];
      if (schedulesResponse.data is List) {
        schedules = (schedulesResponse.data as List)
            .map(
              (json) => MedicineResponse.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }

      // If the patient has no medicine schedules at all, return empty immediately
      // (no point calling MedicineLogs — API may 400 for patients with no logs)
      if (schedules.isEmpty) {
        return [];
      }

      // 2. Fetch daily logs for the patient on the selected date (Format: YYYY-MM-DD)
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      List<MedicineLogResponse> logs = [];
      try {
        final logsResponse = await dio.get(
          '/api/MedicineLogs/patient/$patientId/date/$dateStr',
        );
        if (logsResponse.data is List) {
          logs = (logsResponse.data as List)
              .map(
                (json) =>
                    MedicineLogResponse.fromJson(json as Map<String, dynamic>),
              )
              .toList();
        }
      } on DioException catch (e) {
        // If the logs endpoint fails (e.g. 400 for no logs), continue gracefully
        // with an empty logs list — schedules will still render with isTaken=false
        debugPrint(
          'MedicationRemoteDataSource [getMedicationsByDate] Logs fetch failed (non-fatal): ${e.message}',
        );
      }

      // 3. Populate our in-memory schedule-to-log mapping
      for (final log in logs) {
        if (log.medicineId.isNotEmpty && log.id.isNotEmpty) {
          _scheduleToLogIdMap[log.medicineId] = log.id;
        }
      }

      // 4. Merge schedules with daily intake logs
      final List<MedicationModel> medications = [];
      final queryDate = DateTime(date.year, date.month, date.day);

      for (final schedule in schedules) {
        // Filter out inactive schedules
        if (!schedule.isActive) continue;

        // Parse days of week "1,2,3" into List<int>
        final days = schedule.daysOfWeek
            .split(',')
            .map((e) => int.tryParse(e.trim()))
            .whereType<int>()
            .toList();

        // Check if the medication is scheduled for this weekday
        if (!days.contains(date.weekday)) continue;

        // Check date boundaries
        final start = DateTime(
          schedule.startDate.year,
          schedule.startDate.month,
          schedule.startDate.day,
        );
        if (queryDate.isBefore(start)) continue;

        if (schedule.endDate != null) {
          final end = DateTime(
            schedule.endDate!.year,
            schedule.endDate!.month,
            schedule.endDate!.day,
          );
          if (queryDate.isAfter(end)) continue;
        }

        // Determine if the medication was taken (status == 1)
        final log = logs.firstWhere(
          (l) => l.medicineId == schedule.id,
          orElse: () => MedicineLogResponse(id: '', medicineId: '', status: 0),
        );
        final isTaken = log.status == 1;

        medications.add(schedule.toDomainModel(isTaken: isTaken));
      }

      return medications;
    } on DioException catch (e) {
      final parsedMsg = _parseProblemDetails(e);
      debugPrint(
        'MedicationRemoteDataSource [getMedicationsByDate] DioException: $parsedMsg',
      );
      throw ServerException(message: parsedMsg);
    } catch (e, stack) {
      debugPrint(
        'MedicationRemoteDataSource [getMedicationsByDate] Generic Exception: $e\n$stack',
      );
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<MedicationModel> addMedication(MedicationModel medication) async {
    try {
      final request = MedicineRequest.fromDomain(medication);
      final response = await dio.post('/api/Medicine', data: request.toJson());
      if (response.data is Map<String, dynamic>) {
        final res = MedicineResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
        return res.toDomainModel();
      }
      throw ServerException(message: 'Sunucudan geçersiz bir yanıt alındı.');
    } on DioException catch (e) {
      final parsedMsg = _parseProblemDetails(e);
      debugPrint(
        'MedicationRemoteDataSource [addMedication] DioException: $parsedMsg',
      );
      throw ServerException(message: parsedMsg);
    } catch (e, stack) {
      debugPrint(
        'MedicationRemoteDataSource [addMedication] Generic Exception: $e\n$stack',
      );
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<MedicationModel> updateMedication(MedicationModel medication) async {
    try {
      final request = MedicineRequest.fromDomain(medication);
      final response = await dio.put(
        '/api/Medicine/${medication.id}',
        data: request.toJson(),
      );
      if (response.data is Map<String, dynamic>) {
        final res = MedicineResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
        return res.toDomainModel();
      }
      // If server returns No Content (204) for update, just return the passed model back
      return medication;
    } on DioException catch (e) {
      final parsedMsg = _parseProblemDetails(e);
      debugPrint(
        'MedicationRemoteDataSource [updateMedication] DioException: $parsedMsg',
      );
      throw ServerException(message: parsedMsg);
    } catch (e, stack) {
      debugPrint(
        'MedicationRemoteDataSource [updateMedication] Generic Exception: $e\n$stack',
      );
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteMedication(String id) async {
    try {
      await dio.delete('/api/Medicine/$id');
    } on DioException catch (e) {
      final parsedMsg = _parseProblemDetails(e);
      debugPrint(
        'MedicationRemoteDataSource [deleteMedication] DioException: $parsedMsg',
      );
      throw ServerException(message: parsedMsg);
    } catch (e, stack) {
      debugPrint(
        'MedicationRemoteDataSource [deleteMedication] Generic Exception: $e\n$stack',
      );
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> markAsTaken(String id, DateTime date) async {
    try {
      final logId = _scheduleToLogIdMap[id];
      if (logId == null || logId.isEmpty) {
        throw ServerException(message: 'Günlük ilaç kaydı bulunamadı.');
      }
      await dio.put(
        '/api/MedicineLogs/$logId/status',
        data: {
          'status': 1, // Taken
          'note': 'Taken via Alzheimer Takip Mobile Client',
        },
      );
    } on DioException catch (e) {
      final parsedMsg = _parseProblemDetails(e);
      debugPrint(
        'MedicationRemoteDataSource [markAsTaken] DioException: $parsedMsg',
      );
      throw ServerException(message: parsedMsg);
    } catch (e, stack) {
      debugPrint(
        'MedicationRemoteDataSource [markAsTaken] Generic Exception: $e\n$stack',
      );
      throw ServerException(message: e.toString());
    }
  }

  String _parseProblemDetails(DioException e) {
    if (e.response?.data is Map<String, dynamic>) {
      final data = e.response!.data as Map<String, dynamic>;
      if (data.containsKey('detail') &&
          data['detail'] != null &&
          data['detail'].toString().isNotEmpty) {
        return data['detail'].toString();
      }
      if (data.containsKey('title') &&
          data['title'] != null &&
          data['title'].toString().isNotEmpty) {
        return data['title'].toString();
      }
      if (data.containsKey('errors') && data['errors'] is Map) {
        final errors = data['errors'] as Map;
        final messages = <String>[];
        errors.forEach((key, value) {
          if (value is List) {
            messages.add(value.join(', '));
          } else if (value is String) {
            messages.add(value);
          }
        });
        if (messages.isNotEmpty) {
          return messages.join('\n');
        }
      }
    }
    return e.message ?? 'Bilinmeyen bir sunucu hatası oluştu.';
  }
}
