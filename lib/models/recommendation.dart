class Recommendation {
  final String id;
  final String timestamp;
  final String zone;
  final String cropName;
  final String title;
  final String description;
  final String severity; // critical, warning, normal
  final List<String> recommendations;
  bool resolved;
  String? resolvedAt;

  Recommendation({
    required this.id,
    required this.timestamp,
    required this.zone,
    required this.cropName,
    required this.title,
    required this.description,
    required this.severity,
    required this.recommendations,
    required this.resolved,
    this.resolvedAt,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      id: json['id'],
      timestamp: json['timestamp'],
      zone: json['zone'],
      cropName: json['cropName'],
      title: json['title'],
      description: json['description'],
      severity: json['severity'],
      recommendations: List<String>.from(json['recommendations']),
      resolved: json['resolved'],
      resolvedAt: json['resolvedAt'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp,
    'zone': zone,
    'cropName': cropName,
    'title': title,
    'description': description,
    'severity': severity,
    'recommendations': recommendations,
    'resolved': resolved,
    'resolvedAt': resolvedAt,
  };
}
