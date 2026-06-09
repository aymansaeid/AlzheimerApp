import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/core/errors/exceptions.dart';
import '../models/medicine_model.dart';

abstract class MedicineRemoteDataSource {
  Future<MedicineModel> addMedicine(MedicineModel medicine);
  Future<List<MedicineModel>> getMedicines(String patientId);
  Future<MedicineModel> updateMedicine(MedicineModel medicine);
  Future<void> deleteMedicine(String id);
}

@LazySingleton(as: MedicineRemoteDataSource)
class MedicineRemoteDataSourceImpl implements MedicineRemoteDataSource {
  final Dio dio;

  MedicineRemoteDataSourceImpl(this.dio);

  @override
  Future<MedicineModel> addMedicine(MedicineModel medicine) async {
    try {
      final response = await dio.post(
        '/api/Medicine',
        data: medicine.toJson(),
      );
      return MedicineModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(message: _parseProblemDetails(e));
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<MedicineModel>> getMedicines(String patientId) async {
    try {
      final response = await dio.get('/api/Medicine/patient/$patientId');
      if (response.data is List) {
        return (response.data as List)
            .map((json) => MedicineModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw ServerException(message: _parseProblemDetails(e));
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<MedicineModel> updateMedicine(MedicineModel medicine) async {
    try {
      final response = await dio.put(
        '/api/Medicine/${medicine.id}',
        data: medicine.toJson(),
      );
      if (response.data is Map<String, dynamic>) {
        return MedicineModel.fromJson(response.data as Map<String, dynamic>);
      }
      return medicine;
    } on DioException catch (e) {
      throw ServerException(message: _parseProblemDetails(e));
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteMedicine(String id) async {
    try {
      await dio.delete('/api/Medicine/$id');
    } on DioException catch (e) {
      throw ServerException(message: _parseProblemDetails(e));
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  String _parseProblemDetails(DioException e) {
    if (e.response?.data is Map<String, dynamic>) {
      final data = e.response!.data as Map<String, dynamic>;
      if (data.containsKey('detail') && data['detail'] != null) {
        return data['detail'].toString();
      }
      if (data.containsKey('title') && data['title'] != null) {
        return data['title'].toString();
      }
    }
    return e.message ?? 'Bilinmeyen bir sunucu hatası oluştu.';
  }
}
