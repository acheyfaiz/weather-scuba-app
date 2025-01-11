class Weather {
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int precipitation;
  final String location;

  Weather({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.precipitation,
    required this.location,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      temperature: (json['current']['temperature_2m'] as num).toDouble(),
      feelsLike: (json['current']['apparent_temperature'] as num).toDouble(),
      humidity: (json['current']['relative_humidity_2m'] as num).toInt(),
      windSpeed: (json['current']['wind_speed_10m'] as num).toDouble(),
      precipitation: (json['current']['precipitation'] as num).toInt(),
      location: 'Current Location', // Open-Meteo doesn't provide location names
    );
  }
} 