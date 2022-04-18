import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:weatherapp/models/condition.dart';
import 'package:weatherapp/models/current.dart';
import 'package:weatherapp/models/forecast/forecast.dart';
import 'package:weatherapp/models/forecast/forecastday.dart';
import 'package:weatherapp/models/location.dart';
import 'package:weatherapp/models/weather_model.dart';
import 'package:weatherapp/services/weather_api_service.dart';

enum ApiViewState { Idle, Busy }

class WeatherView extends ChangeNotifier {
  WeatherApiService _weatherApiService = WeatherApiService();
  ApiViewState? _state;
  WeatherModel weatherModel = WeatherModel();
  Condition? condition;
  Location? location;
  Current? current;
  Forecast? forecast;
  List<Forecastday>? forecastDayList;
  String? _city;

  get state => _state;

  set city(String city) {
    _city = city;
  }

  //TODO: city set edilecel
  WeatherView() {
    if (weatherModel.current == null) {
      getData(_city ?? "istanbul");
    }
  }

  Future<WeatherModel> getData(String city) async {
    _state = ApiViewState.Busy;
    String data = await _weatherApiService.getData(city);
    var json = jsonDecode(data);
    weatherModel = WeatherModel.fromJson(json);
    cast();
    _state = ApiViewState.Idle;
    notifyListeners();
    return weatherModel;
  }

  cast() {
    forecast = weatherModel.forecast;
    forecastDayList = forecast?.forecastday;
    location = weatherModel.location;
    current = weatherModel.current;
    condition = current?.condition;
  }
}
