int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value.trim());
  return null;
}

String? _parseString(dynamic value) {
  if (value == null) return null;
  final str = value.toString().trim();
  if (str.isEmpty || str == "null") return null;
  return str;
}

class DashboardModel {
  bool? success;
  DashboardData? data;

  DashboardModel({this.success, this.data});

  DashboardModel.fromJson(Map<String, dynamic> json) {
    success = json['success'] == true ||
        json['status'] == true ||
        json['success']?.toString().toLowerCase() == 'true' ||
        json['status']?.toString().toLowerCase() == 'true';

    // Handle nested 'data' map, root data, or dynamic maps
    if (json['data'] != null && json['data'] is Map) {
      data = DashboardData.fromJson(Map<String, dynamic>.from(json['data']));
    } else if (json.containsKey('support_crew') ||
        json.containsKey('supportCrew') ||
        json.containsKey('school') ||
        json.containsKey('user')) {
      data = DashboardData.fromJson(json);
    } else {
      data = null;
    }
  }
}

class DashboardData {
  SupportCrew? supportCrew;
  String? activeSession;
  School? school;
  AttendanceToday? attendanceToday;
  TodayInfo? todayInfo;

  DashboardData({
    this.supportCrew,
    this.activeSession,
    this.school,
    this.attendanceToday,
    this.todayInfo,
  });

  DashboardData.fromJson(Map<String, dynamic> json) {
    // 1. Parse Support Crew / User Profile
    final crewRaw = json['support_crew'] ??
        json['supportCrew'] ??
        json['user'] ??
        json['profile'] ??
        json['crew'] ??
        json['staff'];
    if (crewRaw != null && crewRaw is Map) {
      supportCrew = SupportCrew.fromJson(Map<String, dynamic>.from(crewRaw));
    } else {
      supportCrew = null;
    }

    // 2. Active Session
    activeSession = _parseString(
        json['active_session'] ?? json['activeSession'] ?? json['session']);

    // 3. School Details
    final schoolRaw = json['school'] ??
        json['school_info'] ??
        json['schoolInfo'] ??
        json['school_details'] ??
        json['schoolDetails'];
    if (schoolRaw != null && schoolRaw is Map) {
      school = School.fromJson(Map<String, dynamic>.from(schoolRaw));
    } else {
      school = null;
    }

    // 4. Attendance Today
    final attRaw = json['attendance_today'] ??
        json['attendanceToday'] ??
        json['attendance'] ??
        json['today_attendance'] ??
        json['todayAttendance'] ??
        json['attendance_status'] ??
        json['today_status'];

    if (attRaw != null) {
      if (attRaw is Map) {
        attendanceToday =
            AttendanceToday.fromJson(Map<String, dynamic>.from(attRaw));
      } else if (attRaw is List && attRaw.isNotEmpty && attRaw.first is Map) {
        attendanceToday = AttendanceToday.fromJson(
            Map<String, dynamic>.from(attRaw.first as Map));
      } else {
        attendanceToday = null;
      }
    } else {
      attendanceToday = null;
    }

    // 5. Today Info
    final todayRaw = json['today_info'] ??
        json['todayInfo'] ??
        json['today'] ??
        json['date_info'];
    if (todayRaw != null && todayRaw is Map) {
      todayInfo = TodayInfo.fromJson(Map<String, dynamic>.from(todayRaw));
    } else if (json.containsKey('today_date') ||
        json.containsKey('day_name') ||
        json.containsKey('date')) {
      todayInfo = TodayInfo.fromJson(json);
    } else {
      todayInfo = null;
    }
  }
}

class SupportCrew {
  int? id;
  String? name;
  String? staffType;
  dynamic designation;
  String? whatsappNumber;
  String? phone;
  String? email;
  int? schoolId;
  String? teacherUniqueId;
  String? gender;
  String? status;
  String? image;
  String? thumbnail;
  String? address;

  SupportCrew({
    this.id,
    this.name,
    this.staffType,
    this.designation,
    this.whatsappNumber,
    this.phone,
    this.email,
    this.schoolId,
    this.teacherUniqueId,
    this.gender,
    this.status,
    this.image,
    this.thumbnail,
    this.address,
  });

  SupportCrew.fromJson(Map<String, dynamic> json) {
    id = _parseInt(json['id']);
    name = _parseString(json['name'] ?? json['full_name'] ?? json['crew_name']);
    staffType = _parseString(json['staff_type'] ?? json['staffType'] ?? json['role']);
    designation = json['designation'];
    whatsappNumber = _parseString(json['whatsapp_number'] ??
        json['whatsappNumber'] ??
        json['whatsapp'] ??
        json['mobile'] ??
        json['phone']);
    phone = _parseString(json['phone'] ?? json['mobile']);
    email = _parseString(json['email']);
    schoolId = _parseInt(json['school_id'] ?? json['schoolId']);
    teacherUniqueId = _parseString(json['teacher_unique_id'] ??
        json['teacherUniqueId'] ??
        json['unique_id'] ??
        json['uniqueId'] ??
        json['crew_id'] ??
        json['employee_id'] ??
        json['staff_id']);
    gender = _parseString(json['gender']);
    status = _parseString(json['status']);
    image = _parseString(json['image'] ?? json['photo'] ?? json['avatar']);
    thumbnail = _parseString(json['thumbnail'] ??
        json['thumb'] ??
        json['image'] ??
        json['photo'] ??
        json['avatar']);
    address = _parseString(json['address']);
  }
}

class School {
  int? id;
  String? schoolName;
  String? address;
  String? phone;

  School({this.id, this.schoolName, this.address, this.phone});

  School.fromJson(Map<String, dynamic> json) {
    id = _parseInt(json['id']);
    schoolName = _parseString(json['school_name'] ??
        json['schoolName'] ??
        json['name'] ??
        json['title'] ??
        json['school']);
    address = _parseString(json['address'] ?? json['location']);
    phone = _parseString(json['phone'] ?? json['mobile'] ?? json['contact']);
  }
}

class AttendanceToday {
  String? status;
  String? label;
  String? clockIn;
  String? clockOut;

  AttendanceToday({this.status, this.label, this.clockIn, this.clockOut});

  AttendanceToday.fromJson(Map<String, dynamic> json) {
    status = _parseString(json['status'] ??
        json['attendance_status'] ??
        json['attendanceStatus'] ??
        json['attendance_value']);
    label = _parseString(json['label'] ?? json['status_label'] ?? json['statusLabel']);
    clockIn = _parseString(json['clock_in'] ??
        json['clockIn'] ??
        json['check_in'] ??
        json['checkIn'] ??
        json['in_time'] ??
        json['time_in'] ??
        json['clock_in_time'] ??
        json['clockInTime']);
    clockOut = _parseString(json['clock_out'] ??
        json['clockOut'] ??
        json['check_out'] ??
        json['checkOut'] ??
        json['out_time'] ??
        json['time_out'] ??
        json['clock_out_time'] ??
        json['clockOutTime']);
  }
}

class TodayInfo {
  String? date;
  String? dayName;

  TodayInfo({this.date, this.dayName});

  TodayInfo.fromJson(Map<String, dynamic> json) {
    date = _parseString(json['date'] ??
        json['today_date'] ??
        json['todayDate'] ??
        json['current_date']);
    dayName = _parseString(json['day_name'] ??
        json['dayName'] ??
        json['day'] ??
        json['day_of_week']);
  }
}
