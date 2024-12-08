class Device {
  final int id;
  final String name;
  final String fcmToken;
  final String phoneNumber;
  final String secretKey;
  final int smsLimit;

  Device({
    required this.id,
    required this.name,
    required this.fcmToken,
    required this.phoneNumber,
    required this.secretKey,
    required this.smsLimit,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'],
      name: json['name'],
      fcmToken: json['fcm_token'],
      phoneNumber: json['phone_number'],
      secretKey: json['secret_key'],
      smsLimit: json['sms_limit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'fcm_token': fcmToken,
      'phone_number': phoneNumber,
      'secret_key': secretKey,
      'sms_limit': smsLimit,
    };
  }

  Device copyWith({
    int? id,
    String? name,
    String? fcmToken,
    String? phoneNumber,
    String? secretKey,
    int? smsLimit,
  }) {
    return Device(
      id: id ?? this.id,
      name: name ?? this.name,
      fcmToken: fcmToken ?? this.fcmToken,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      secretKey: secretKey ?? this.secretKey,
      smsLimit: smsLimit ?? this.smsLimit,
    );
  }
}
