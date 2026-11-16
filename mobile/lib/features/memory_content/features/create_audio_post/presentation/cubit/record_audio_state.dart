import 'package:equatable/equatable.dart';

enum RecordStep {
  initial, // Başlangıç, kayıt bekleniyor
  recording, // Mikrofon devrede, kayıt yapılıyor
  paused, // Kayıt geçici duraklatıldı
  review, // Kayıt tamamlandı, önizleme dinleniyor
  submitting, // Feed'e gönderiliyor
  success, // Paylaşıldı
  failure, // Hata
}

class RecordAudioState extends Equatable {
  final RecordStep step;
  final Duration recordDuration;
  final Duration previewPosition;
  final Duration previewTotalDuration;
  final bool isPreviewPlaying;
  final String? audioPath;
  final bool permissionDenied;
  final String? errorMessage;

  const RecordAudioState({
    this.step = RecordStep.initial,
    this.recordDuration = Duration.zero,
    this.previewPosition = Duration.zero,
    this.previewTotalDuration = Duration.zero,
    this.isPreviewPlaying = false,
    this.audioPath,
    this.permissionDenied = false,
    this.errorMessage,
  });

  RecordAudioState copyWith({
    RecordStep? step,
    Duration? recordDuration,
    Duration? previewPosition,
    Duration? previewTotalDuration,
    bool? isPreviewPlaying,
    String? Function()? audioPath,
    bool? permissionDenied,
    String? Function()? errorMessage,
  }) {
    return RecordAudioState(
      step: step ?? this.step,
      recordDuration: recordDuration ?? this.recordDuration,
      previewPosition: previewPosition ?? this.previewPosition,
      previewTotalDuration: previewTotalDuration ?? this.previewTotalDuration,
      isPreviewPlaying: isPreviewPlaying ?? this.isPreviewPlaying,
      audioPath: audioPath != null ? audioPath() : this.audioPath,
      permissionDenied: permissionDenied ?? this.permissionDenied,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    step,
    recordDuration,
    previewPosition,
    previewTotalDuration,
    isPreviewPlaying,
    audioPath,
    permissionDenied,
    errorMessage,
  ];
}
