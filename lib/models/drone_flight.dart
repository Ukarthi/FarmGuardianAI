class DroneFlight {
  final String id;
  final String timestamp;
  final String zone;
  final String cropName;
  String status; // pending, launching, active, scanning, completed, failed
  final String reason;
  final String triggerType; // autonomous, manual
  int battery;
  Map<String, dynamic>? diagnostics;

  DroneFlight({
    required this.id,
    required this.timestamp,
    required this.zone,
    required this.cropName,
    required this.status,
    required this.reason,
    required this.triggerType,
    required this.battery,
    this.diagnostics,
  });

  factory DroneFlight.fromJson(Map<String, dynamic> json) {
    return DroneFlight(
      id: json['id'],
      timestamp: json['timestamp'],
      zone: json['zone'],
      cropName: json['cropName'],
      status: json['status'],
      reason: json['reason'],
      triggerType: json['triggerType'],
      battery: json['battery'],
      diagnostics: json['diagnostics'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp,
    'zone': zone,
    'cropName': cropName,
    'status': status,
    'reason': reason,
    'triggerType': triggerType,
    'battery': battery,
    'diagnostics': diagnostics,
  };
}
