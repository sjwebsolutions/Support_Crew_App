import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:scupporo_crew_app/utils/constants/app_constants.dart';
import 'package:scupporo_crew_app/utils/token_manager.dart';

class DashboardService {
  final http.Client client;

  DashboardService({http.Client? client}) : client = client ?? http.Client();

  Future<http.Response> getDashboardData() async {
    final String? token = await TokenManager.getToken();
    debugPrint("🔑 [DASHBOARD SERVICE] Token present: ${token != null && token.isNotEmpty}");

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.trim().isNotEmpty && token != "null") {
      headers['Authorization'] = 'Bearer ${token.trim()}';
    }

    final response = await client
        .get(
          Uri.parse(AppConstants.dashboard),
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

