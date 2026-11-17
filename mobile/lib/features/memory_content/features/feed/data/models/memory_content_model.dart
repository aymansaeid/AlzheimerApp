import '../../domain/entities/memory_content.dart';

class MemoryContentModel extends MemoryContent {
  MemoryContentModel({
    required super.id,
    required super.fileUrl,
    super.title,
    super.description,
    required super.relationship,
    required super.contentType,
    required super.isActive,
    required super.patientId,
    required super.createdAt,
    required super.uploaderId,
  });

  factory MemoryContentModel.fromJson(Map<String, dynamic> json) {
    return MemoryContentModel(
      id: json['id'],
      fileUrl: json['fileUrl'],
      title: json['title'],
      description: json['description'],
      relationship: json['relationship'] ?? '',
      contentType: MemoryContentType.values[json['contentType'] ?? 0],
      isActive: json['isActive'] ?? true,
      patientId: json['patientId'] ?? '',
      createdAt: json['createdAt'] ?? '',
      uploaderId: json['uploaderId'] ?? '',
    );
  }

  // POST isteği atarken body'e koyacağımız JSON çevirici (MemoryContentRequest şeması)
  static Map<String, dynamic> toJsonRequest({
    required String patientId,
    required String fileUrl,
    String? title,
    String? description,
    required String relationship,
    required int contentType,
    required String uploaderId,
  }) {
    return {
      "patientId": patientId,
      "fileUrl": fileUrl,
      "title": title,
      "description": description,
      "relationship": relationship,
      "contentType": contentType,
      "uploaderId": uploaderId,
    };
  }
}
