import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:weatherapp/helper/colors.dart';
import 'package:weatherapp/home_page/home_page.dart';
import 'package:weatherapp/services/weather_view.dart';

void main() async {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  await Hive.initFlutter();

  await Hive.openBox('testBox');
  //Hive.box('testBox').put('cities', ['İstanbul', 'Kocaeli']);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
