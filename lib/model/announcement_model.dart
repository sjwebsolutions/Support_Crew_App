class AnnouncementResponseModel {
  bool? success;
  List<AnnouncementItem>? data;

  AnnouncementResponseModel({this.success, this.data});

  AnnouncementResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'] == true || json['status'] == true || json['success']?.toString().toLowerCase() == 'true';
    if (json['data'] != null && json['data'] is List) {
      data = (json['data'] as List)
          .map((v) => AnnouncementItem.fromJson(Map<String, dynamic>.from(v as Map)))
          .toList();
    }
  }
}

class AnnouncementItem {
  int? id;
  String? title;
  String? description;
  String? imageUrl;
  String? type;
  String? fromDate;
  String? fromTime;
  String? toDate;
  String? toTime;
  String? createdBy;

  AnnouncementItem({
    this.id,
    this.title,
    this.description,
    this.imageUrl,
    this.type,
    this.fromDate,
    this.fromTime,
    this.toDate,
    this.toTime,
    this.createdBy,
  });

  AnnouncementItem.fromJson(Map<String, dynamic> json) {
    id = json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '');
    title = json['title']?.toString() ?? json['name']?.toString() ?? json['heading']?.toString();
    description = json['description']?.toString() ?? json['message']?.toString() ?? json['details']?.toString();
    imageUrl = json['image_url']?.toString() ??
        json['imageUrl']?.toString() ??
        json['image']?.toString() ??
        json['announcement_image']?.toString();
    type = json['type']?.toString() ?? json['category']?.toString();
    fromDate = json['from_date']?.toString() ?? json['fromDate']?.toString() ?? json['date']?.toString();
    fromTime = json['from_time']?.toString() ?? json['fromTime']?.toString() ?? json['time']?.toString();
    toDate = json['to_date']?.toString() ?? json['toDate']?.toString();
    toTime = json['to_time']?.toString() ?? json['toTime']?.toString();
    createdBy = json['created_by']?.toString() ?? json['createdBy']?.toString() ?? json['author']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['image_url'] = imageUrl;
    data['type'] = type;
    data['from_date'] = fromDate;
    data['from_time'] = fromTime;
    data['to_date'] = toDate;
    data['to_time'] = toTime;
    data['created_by'] = createdBy;
    return data;
  }
}
