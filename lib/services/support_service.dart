import 'package:http/http.dart' as http;
import 'package:scupporo_crew_app/utils/constants/app_constants.dart';
import 'package:scupporo_crew_app/utils/token_manager.dart';

class SupportService {
  final http.Client client;

  SupportService({http.Client? client}) : client = client ?? http.Client();

  Future<http.Response> getSupportSettings() async {
    String? token = await TokenManager.getToken();
    final response = await client.get(
      Uri.parse(AppConstants.supportSettings),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return response;
  }

  Future<http.Response> getPolicies() async {
    String? token = await TokenManager.getToken();
    final response = await client.get(
      Uri.parse(AppConstants.policies),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return response;
  }
}
