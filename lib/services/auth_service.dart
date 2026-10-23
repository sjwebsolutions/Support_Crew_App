import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:scupporo_crew_app/model/otp_request_model.dart';
import 'package:scupporo_crew_app/model/otp_verify_request.dart';
import '../utils/constants/app_constants.dart';

class AuthService {
  final http.Client client;

  AuthService({http.Client? client}) : client = client ?? http.Client();

  Future<http.Response> requestOtp(OtpRequest request) async {
    final response = await client.post(
      Uri.parse(AppConstants.requestOtp),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent':
            'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36 ScupporoCrewApp/1.0.6',
      },
      body: jsonEncode(request.toJson()),
    );
    return response;
  }

  Future<http.Response> verifyOtp(OtpVerifyRequest request) async {
    final response = await client.post(
      Uri.parse(AppConstants.verifyOtp),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent':
            'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36 ScupporoCrewApp/1.0.6',
      },
      body: jsonEncode(request.toJson()),
    );
    return response;
  }
}
