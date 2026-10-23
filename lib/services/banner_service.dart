import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:scupporo_crew_app/utils/constants/app_constants.dart';
import 'package:scupporo_crew_app/utils/token_manager.dart';

class BannerService {
  final http.Client client;

  BannerService({http.Client? client}) : client = client ?? http.Client();

  Future<http.Response> getBanners() async {
    final String? token = await TokenManager.getToken();
    debugPrint("🔑 [BANNER SERVICE] Token present: ${token != null && token.isNotEmpty}");

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.trim().isNotEmpty && token != "null") {
      headers['Authorization'] = 'Bearer ${token.trim()}';
    }

    final response = await client
        .get(
          Uri.parse(AppConstants.banners),
          headers: headers,
        )
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () => http.Response(
            '{"success":false,"message":"Connection timeout. Please check your internet connection."}',
            408,
          ),
        );

    return response;
  }
}
