import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:weatherapp/helper/colors.dart';
import 'package:weatherapp/helper/size.dart';
import 'package:weatherapp/home_page/home_page.dart';
import 'package:weatherapp/services/weather_view.dart';

void main() async {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.light,
  ));
  await Hive.initFlutter();

  Box box = await Hive.openBox('testBox');
  box.get('cities') ??
      Hive.box('testBox').put('cities', ['İstanbul', 'Kocaeli']);
  var cities = box.get('cities');
  WeatherView().city = cities[0];
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: primaryColor,
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: Colors.white,
            ),
      ),
      home: ChangeNotifierProvider(
          create: (context) => WeatherView(),
          child: const HomePage(title: 'Weather App')),
    );
  }
}
