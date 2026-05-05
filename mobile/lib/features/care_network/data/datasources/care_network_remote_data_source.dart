import 'package:injectable/injectable.dart';

abstract class CareNetworkRemoteDataSource {
  Future<List<Map<String, dynamic>>> getNetworkUsers();
}

@LazySingleton(as: CareNetworkRemoteDataSource)
class CareNetworkRemoteDataSourceImpl implements CareNetworkRemoteDataSource {
  @override
  Future<List<Map<String, dynamic>>> getNetworkUsers() async {
    // Backend'i simüle etmek için 2 saniye bekle
    await Future.delayed(const Duration(seconds: 2));

    return [
      {
        'id': 'patient_1',
        'fullName': 'Ahmet Bey',
        'role': 'patient',
        'avatarUrl': '👴',
        'isMe': false,
      },
      {
        'id': 'patient_2',
        'fullName': 'Ayşe Hanım',
        'role': 'patient',
        'avatarUrl': '👵',
        'isMe': false,
      },
      {
        'id': 'caregiver_1',
        'fullName': 'Siz',
        'role': 'caregiver',
        'avatarUrl': '👩‍⚕️',
        'isMe': true,
      },
      {
        'id': 'caregiver_2',
        'fullName': 'Mehmet Yılmaz',
        'role': 'caregiver',
        'avatarUrl': '👨',
        'isMe': false,
      },
      {
        'id': 'caregiver_3',
        'fullName': 'Zeynep Yılmaz',
        'role': 'caregiver',
        'avatarUrl': '👩',
        'isMe': false,
      },
    ];
  }
}
