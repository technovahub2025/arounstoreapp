import 'dart:convert';
import 'package:arunstore/model/role.dart';
import 'package:http/http.dart' as http;


class roleService {
  static const String baseUrl = "https://aroun-shopping-website-a2he.onrender.com/api/auth";

  static Future<http.Response> roleselection(Role role) async {
    final url = Uri.parse('$baseUrl/register');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(role.toJson()),
    );
    return response;
  }


}



