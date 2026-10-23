class BannerResponseModel {
  bool? success;
  BannerData? data;

  BannerResponseModel({this.success, this.data});

  BannerResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'] == true || json['status'] == true || json['success']?.toString().toLowerCase() == 'true';
    if (json['data'] != null && json['data'] is Map) {
      data = BannerData.fromJson(Map<String, dynamic>.from(json['data']));
    } else {
      data = null;
    }
  }
}

class BannerData {
  List<BannerItem>? banners;

  BannerData({this.banners});

  BannerData.fromJson(Map<String, dynamic> json) {
    if (json['banners'] != null && json['banners'] is List) {
      banners = (json['banners'] as List)
          .map((v) => BannerItem.fromJson(Map<String, dynamic>.from(v as Map)))
          .toList();
    }
  }
}

class BannerItem {
  int? id;
  String? name;
  String? category;
  String? type;
  String? imageUrl;
  String? wishing;
  int? displayDays;
  String? publishedAt;

  BannerItem({
    this.id,
    this.name,
    this.category,
    this.type,
    this.imageUrl,
    this.wishing,
    this.displayDays,
    this.publishedAt,
  });

  BannerItem.fromJson(Map<String, dynamic> json) {
    id = json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '');
    name = json['name']?.toString() ?? json['title']?.toString();
    category = json['category']?.toString();
    type = json['type']?.toString();
    imageUrl = json['image_url']?.toString() ??
        json['imageUrl']?.toString() ??
        json['image']?.toString() ??
        json['banner_image']?.toString();
    wishing = json['wishing']?.toString() ?? json['description']?.toString() ?? json['details']?.toString();
    displayDays = json['display_days'] is int
        ? json['display_days'] as int
        : int.tryParse(json['display_days']?.toString() ?? '');
    publishedAt = json['published_at']?.toString() ??
        json['publishedAt']?.toString() ??
        json['created_at']?.toString() ??
        json['date']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['category'] = category;
    data['type'] = type;
    data['image_url'] = imageUrl;
    data['wishing'] = wishing;
    data['display_days'] = displayDays;
    data['published_at'] = publishedAt;
    return data;
  }
}
