import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Network {
  final String _url = 'http://localhost:8000/api';
  var token;

  _getToken() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    token = jsonDecode(localStorage.getString('token')!);
  }

  _getUser() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    token = jsonDecode(localStorage.getString('user')!);
  }

  authData(data, apiUrl) async {
    var fullUrl = _url + apiUrl;
    final Uri url = Uri.parse(fullUrl);
    return await http.post(url, body: jsonEncode(data), headers: _setHeaders());
  }

  getData(apiUrl) async {
    var fullUrl = _url + apiUrl;
    final Uri url = Uri.parse(fullUrl);
    await _getToken();
    return await http.get(url, headers: _setHeaders());
  }

  postData(apiUrl, data) async {
    var fullUrl = _url + apiUrl;
    final Uri url = Uri.parse(fullUrl);
    await _getToken();
    return await http.post(url, body: jsonEncode(data), headers: _setHeaders());
  }

  _setHeaders() => {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      };
}
