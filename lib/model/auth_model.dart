class LoginResponse {
  bool? success;
  String? message;
  Data? data;

  LoginResponse({this.success, this.message, this.data});

  LoginResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? token;
  String? activeSession;
  SupportCrew? supportCrew;

  Data({this.token, this.activeSession, this.supportCrew});

  Data.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    activeSession = json['active_session'];
    supportCrew = json['support_crew'] != null
        ? SupportCrew.fromJson(json['support_crew'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['token'] = token;
    data['active_session'] = activeSession;
    if (supportCrew != null) {
      data['support_crew'] = supportCrew!.toJson();
    }
    return data;
  }
}

class SupportCrew {
  int? id;
  String? name;
  String? staffType;
  dynamic designation;
  String? whatsappNumber;
  String? phone;
  dynamic email;
  int? schoolId;
  String? teacherUniqueId;
  String? gender;
  String? status;
  String? image;
  String? thumbnail;
  dynamic address;

  SupportCrew(
      {this.id,
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
      this.address});

  SupportCrew.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    staffType = json['staff_type'];
    designation = json['designation'];
    whatsappNumber = json['whatsapp_number'];
    phone = json['phone'];
    email = json['email'];
    schoolId = json['school_id'];
    teacherUniqueId = json['teacher_unique_id'];
    gender = json['gender'];
    status = json['status'];
    image = json['image'];
    thumbnail = json['thumbnail'];
    address = json['address'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['staff_type'] = staffType;
    data['designation'] = designation;
    data['whatsapp_number'] = whatsappNumber;
    data['phone'] = phone;
    data['email'] = email;
    data['school_id'] = schoolId;
    data['teacher_unique_id'] = teacherUniqueId;
    data['gender'] = gender;
    data['status'] = status;
    data['image'] = image;
    data['thumbnail'] = thumbnail;
    data['address'] = address;
    return data;
  }
}
