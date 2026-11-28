enum MemoryContentType { photo, voice, identityCard }

class MemoryContent {
  final String id;
  final String patientId;
  final String fileUrl;
  final String? title;
  final String? description;
  final String relationship;
  final MemoryContentType contentType;
  final bool isActive;
  final String createdAt;
  final String uploaderId;
  final String? uploaderName;
  final String? uploaderProfilePhotoUrl;

  MemoryContent({
    required this.id,
    required this.patientId,
    required this.fileUrl,
    this.title,
    this.description,
    required this.relationship,
    required this.contentType,
    required this.isActive,
    required this.createdAt,
    required this.uploaderId,
    this.uploaderName,
    this.uploaderProfilePhotoUrl,
  });
}
