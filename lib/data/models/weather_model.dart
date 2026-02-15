class WeatherForecast {
  final String date;
  final int temperatureC;
  final String summary;

  WeatherForecast({
    required this.date,
    required this.temperatureC,
    required this.summary,
  });

  // Factory constructor to create a WeatherForecast from JSON
  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    return WeatherForecast(
      date: json['date'] as String,
      temperatureC: json['temperatureC'] as int,
      summary: json['summary'] as String? ?? 'No Summary', // Handle nulls safely
    );
  }
}