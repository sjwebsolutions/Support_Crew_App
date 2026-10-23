import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:scupporo_crew_app/model/attendance_clock_model.dart';
import 'package:scupporo_crew_app/utils/constants/app_constants.dart';
import 'package:scupporo_crew_app/utils/token_manager.dart';

class AttendanceService {
  final http.Client client;

  AttendanceService({http.Client? client}) : client = client ?? http.Client();

  Future<http.Response> clockAttendance(AttendanceClockRequest request) async {
    String? token = await TokenManager.getToken();
    final url = Uri.parse(AppConstants.attendanceClock);
    final bodyJson = jsonEncode(request.toJson());

    debugPrint("======== [ATTENDANCE CLOCK REQUEST] ========");
    debugPrint("URL: $url");
    debugPrint("Token: $token");
    debugPrint("Body: $bodyJson");

    final response = await client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: bodyJson,
    );

    debugPrint("======== [ATTENDANCE CLOCK RESPONSE] ========");
    debugPrint("Status Code: ${response.statusCode}");
    debugPrint("Response Body: ${response.body}");
    debugPrint("=============================================");

    return response;
  }
}
