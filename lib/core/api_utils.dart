import 'package:shared_preferences/shared_preferences.dart';


Future<String> getBaseUrl() async {
  final prefs = await SharedPreferences.getInstance();
  String baseUrl =
      prefs.getString('server_url') ??
      'https://api-unidades-manager.onrender.com/api/v1/units/';
  if (!baseUrl.endsWith('/')) baseUrl += '/';
  return baseUrl;
}
