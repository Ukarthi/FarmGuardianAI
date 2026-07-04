class SensorReading {
  final String zone;
  final String cropName;
  double temperature;
  int soilMoisture;
  double ph;
  int nitrogen;
  int phosphorus;
  int potassium;
  String status; // Online, Warning, Offline
  List<String> anomalies;

  SensorReading({
    required this.zone,
    required this.cropName,
    required this.temperature,
    required this.soilMoisture,
    required this.ph,
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.status,
    required this.anomalies,
  });

  factory SensorReading.fromJson(Map<String, dynamic> json) {
    return SensorReading(
      zone: json['zone'],
      cropName: json['cropName'],
      temperature: json['temperature'].toDouble(),
      soilMoisture: json['soilMoisture'],
      ph: json['ph'].toDouble(),
      nitrogen: json['nitrogen'],
      phosphorus: json['phosphorus'],
      potassium: json['potassium'],
      status: json['status'],
      anomalies: List<String>.from(json['anomalies']),
    );
  }

  Map<String, dynamic> toJson() => {
    'zone': zone,
    'cropName': cropName,
    'temperature': temperature,
    'soilMoisture': soilMoisture,
    'ph': ph,
    'nitrogen': nitrogen,
    'phosphorus': phosphorus,
    'potassium': potassium,
    'status': status,
    'anomalies': anomalies,
  };
}
