class SupportSettingsModel {
  bool? success;
  SupportSettingsData? data;

  SupportSettingsModel({this.success, this.data});

  SupportSettingsModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? SupportSettingsData.fromJson(json['data']) : null;
  }
}

class SupportSettingsData {
  String? name;
  String? whatsapp;
  String? mobile;
  String? email;

  SupportSettingsData({this.name, this.whatsapp, this.mobile, this.email});

  SupportSettingsData.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    whatsapp = json['whatsapp'];
    mobile = json['mobile'];
    email = json['email'];
  }
}
