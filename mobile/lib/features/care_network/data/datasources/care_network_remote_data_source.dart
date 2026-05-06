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
      'email': 'deneme00@gmail.com',
      'phoneNumber': '5555555550',
    },
    {
      'id': 'patient_2',
      'fullName': 'Ayşe Hanım',
      'role': 'patient',
      'avatarUrl': '👵',
      'isMe': false,
      'email': 'deneme0@gmail.com',
      'phoneNumber': '5555555551',
    },
    {
      'id': 'caregiver_1',
      'fullName': 'Siz',
      'role': 'caregiver',
      'avatarUrl': '👩‍⚕️',
      'isMe': true,
      'email': 'deneme1@gmail.com',
      'phoneNumber': '5555555552',
    },
    {
      'id': 'caregiver_2',
      'fullName': 'Mehmet Yılmaz',
      'role': 'caregiver',
      'avatarUrl': '👨',
      'isMe': false,
      'email': 'deneme2@gmail.com',
      'phoneNumber': '5555555553',
    },
    {
      'id': 'caregiver_3',
      'fullName': 'Zeynep Yılmaz',
      'role': 'caregiver',
      'avatarUrl': '👩',
      'isMe': false,
      'email': 'deneme3@gmail.com',
      'phoneNumber': '5555555554',
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
