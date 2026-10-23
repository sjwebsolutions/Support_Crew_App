class AppConstants {
  static const String baseUrl = 'https://smartaig.com/api/v1/support-crew';

  // Auth Endpoints
  static const String requestOtp = '$baseUrl/auth/otp/request';
  static const String verifyOtp = '$baseUrl/auth/otp/verify';
  static const String dashboard = '$baseUrl/dashboard';
  static const String supportSettings = '$baseUrl/support-settings';
  static const String policies = '$baseUrl/policies';
  static const String attendanceClock = '$baseUrl/attendance/clock';
  static const String banners = '$baseUrl/banners';
  static const String announcements = '$baseUrl/announcements';
}
