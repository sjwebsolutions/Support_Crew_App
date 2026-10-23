class AttendanceClockRequest {
  final String qrToken;
  final double latitude;
  final double longitude;

  AttendanceClockRequest({
    required this.qrToken,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'qr_token': qrToken,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class AttendanceClockResponse {
  bool? success;
  String? message;
  AttendanceClockData? data;

  AttendanceClockResponse({
    this.success,
    this.message,
    this.data,
  });

  AttendanceClockResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null
        ? AttendanceClockData.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    dataMap['success'] = success;
    dataMap['message'] = message;
    if (data != null) {
      dataMap['data'] = data!.toJson();
    }
    return dataMap;
  }
}

class AttendanceClockData {
  String? clockIn;
  String? clockOut;
  String? status;
  String? attendanceValue;

  AttendanceClockData({
    this.clockIn,
    this.clockOut,
    this.status,
    this.attendanceValue,
  });

  AttendanceClockData.fromJson(Map<String, dynamic> json) {
    clockIn = (json['clock_in'] ??
            json['clockIn'] ??
            json['check_in'] ??
            json['checkIn'] ??
            json['in_time'] ??
            json['time_in'] ??
            json['clock_in_time'])
        ?.toString();
    clockOut = (json['clock_out'] ??
            json['clockOut'] ??
            json['check_out'] ??
            json['checkOut'] ??
            json['out_time'] ??
            json['time_out'] ??
            json['clock_out_time'])
        ?.toString();
    status = json['status']?.toString();
    attendanceValue = json['attendance_value']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    dataMap['clock_in'] = clockIn;
    dataMap['clock_out'] = clockOut;
    dataMap['status'] = status;
    dataMap['attendance_value'] = attendanceValue;
    return dataMap;
  }
}
