import 'dart:convert';
import 'package:arunstore/model/model/authmodel.dart';
import 'package:http/http.dart' as http;


class ApiService {
  static const String baseUrl = "https://aroun-shopping-website-a2he.onrender.com/api/auth";

  static Future<http.Response> register(User user) async {
    final url = Uri.parse('$baseUrl/register');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(user.toJson()),
    );
    return response;
  }

  static Future<http.Response> login(String phone, String password) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'phone': phone, 'password': password}),
    );
    return response;
  }
}
