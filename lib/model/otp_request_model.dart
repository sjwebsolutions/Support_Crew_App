class OtpRequest {
  String? whatsappNumber;
  String? deviceUuid;
  String? deviceName;
  String? deviceOs;

  OtpRequest({
    this.whatsappNumber,
    this.deviceUuid,
    this.deviceName,
    this.deviceOs,
  });

  Map<String, dynamic> toJson() {
    return {
      "whatsapp_number": whatsappNumber,
      "device_uuid": deviceUuid,
      "device_name": deviceName,
      "device_os": deviceOs,
    };
  }
}
