import 'package:http/http.dart' as http;

class WeatherApiService {
  Future<String> getData(String city) async {
    var response = await http.post(
        Uri.parse(
            'http://api.weatherapi.com/v1/forecast.json?key=3d44640a7a6a4235834221009220703&days=6&q=$city&aqi=no'),
        body: '"lang":"tr"');

    String data = response.body;
    return data;
  }
}
