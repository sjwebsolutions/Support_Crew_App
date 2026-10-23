class PolicyModel {
  bool? success;
  PolicyData? data;

  PolicyModel({this.success, this.data});

  PolicyModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? PolicyData.fromJson(json['data']) : null;
  }
}

class PolicyData {
  String? termsOfUse;
  String? privacyPolicy;

  PolicyData({this.termsOfUse, this.privacyPolicy});

  PolicyData.fromJson(Map<String, dynamic> json) {
    termsOfUse = json['terms_of_use'];
    privacyPolicy = json['privacy_policy'];
  }
}
