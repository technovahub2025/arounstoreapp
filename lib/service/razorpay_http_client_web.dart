import 'package:http/browser_client.dart';
import 'package:http/http.dart' as http;

http.Client createRazorpayHttpClient({bool withCredentials = false}) {
  final client = BrowserClient();
  client.withCredentials = withCredentials;
  return client;
}

