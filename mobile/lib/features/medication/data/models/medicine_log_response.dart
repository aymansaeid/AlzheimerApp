class MedicineLogResponse {
  final String id;
  final String medicineId;
  final int status; // 0=Pending, 1=Taken, 2=Missed

  MedicineLogResponse({
    required this.id,
    required this.medicineId,
    required this.status,
  });

  factory MedicineLogResponse.fromJson(Map<String, dynamic> json) {
    return MedicineLogResponse(
      id: (json['id'] ?? '').toString(),
      medicineId:
          (json['medicineId'] ??
                  json['medicine_id'] ??
                  json['medicineScheduleId'] ??
                  json['medicine_schedule_id'] ??
                  '')
              .toString(),
      status: json['status'] ?? 0,
    );
  }
}
