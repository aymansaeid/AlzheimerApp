import 'package:injectable/injectable.dart';

abstract class CareNetworkRemoteDataSource {
  Future<List<Map<String, dynamic>>> getNetworkUsers();
  Future<String> generatePatientInviteLink();
  Future<String> generateCaregiverInviteLink();
}

@LazySingleton(as: CareNetworkRemoteDataSource)
class CareNetworkRemoteDataSourceImpl implements CareNetworkRemoteDataSource {
  final List<Map<String, dynamic>> _mockUsers = [
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

  @override
  Future<List<Map<String, dynamic>>> getNetworkUsers() async {
    await Future.delayed(const Duration(seconds: 1));
    return _mockUsers;
  }

  @override
  Future<String> generatePatientInviteLink() async {
    // Backend API call simülasyonu
    // final response = await dio.post('/api/invites/patient');
    // return response.data['invite_url'];
    
    await Future.delayed(const Duration(seconds: 1));
    return 'https://alzheimerapp.com/invite/patient/${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<String> generateCaregiverInviteLink() async {
    // Backend API call simülasyonu
    // final response = await dio.post('/api/invites/caregiver');
    // return response.data['invite_url'];

    await Future.delayed(const Duration(seconds: 1));
    return 'https://alzheimerapp.com/invite/caregiver/${DateTime.now().millisecondsSinceEpoch}';
  }
}
