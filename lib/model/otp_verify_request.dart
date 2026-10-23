class OtpVerifyRequest {
  String? whatsappNumber;
  String? otpCode;
  String? deviceUuid;
  String? deviceName;
  String? deviceOs;
  String? fcmToken;

  OtpVerifyRequest({
    this.whatsappNumber,
    this.otpCode,
    this.deviceUuid,
    this.deviceName,
    this.deviceOs,
    this.fcmToken,
  });

  Map<String, dynamic> toJson() {
    return {
      "whatsapp_number": whatsappNumber,
      "otp_code": otpCode,
      "device_uuid": deviceUuid,
      "device_name": deviceName,
      "device_os": deviceOs,
      "fcm_token": fcmToken ?? "",
    };
  }
}
