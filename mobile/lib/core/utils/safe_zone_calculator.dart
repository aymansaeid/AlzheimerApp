import 'dart:math' as math;

class SafeZoneCalculator {
  /// Ekranda sabit piksel yarıçapına sahip bir çemberin, haritanın o anki
  /// merkez enlemi (latitude) ve zoom seviyesinde gerçek dünyada kaç metre
  /// yarıçapa denk geldiğini hesaplar.
  ///
  /// [latitude]: Harita merkezinin enlemi
  /// [zoom]: Haritanın o anki zoom seviyesi
  /// [circleRadiusInPixels]: Ekranda çizilen sabit çemberin piksel yarıçapı (Örn: 240px çap için 120px)
  static double calculateRadiusInMeters({
    required double latitude,
    required double zoom,
    required double circleRadiusInPixels,
  }) {
    // Ekvatorda zoom 0 seviyesinde 256px tile başına metre sabiti
    const double earthCircumferencePerTile = 156543.03392;

    final double latRadians = latitude * (math.pi / 180.0);
    final double metersPerPixel =
        (earthCircumferencePerTile * math.cos(latRadians)) /
        math.pow(2.0, zoom);

    return metersPerPixel * circleRadiusInPixels;
  }

  /// Metre değerini kullanıcıya okunaklı göstermek için formatlar (Örn: "350 m" veya "1.4 km")
  static String formatRadius(double radiusInMeters) {
    if (radiusInMeters >= 1000) {
      final km = radiusInMeters / 1000.0;
      return '${km.toStringAsFixed(1)} km';
    }
    return '${radiusInMeters.round()} m';
  }
}
