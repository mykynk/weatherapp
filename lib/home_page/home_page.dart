import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:weatherapp/helper/location.dart';
import 'package:weatherapp/helper/text_styles.dart';
import 'package:weatherapp/home_page/cities.dart';
import 'package:weatherapp/widgets/gradient_text.dart';
import 'package:weatherapp/helper/colors.dart';
import 'package:weatherapp/helper/styles.dart';
import 'package:weatherapp/home_page/widgets/weather_icon.dart';
import 'package:weatherapp/models/day.dart';
import 'package:weatherapp/models/hour.dart';
import 'package:weatherapp/models/weather_model.dart';
import 'package:weatherapp/services/weather_view.dart';
import 'package:weatherapp/helper/size.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late WeatherView _weatherView;
  late WeatherModel weatherModel;
  late Position position;

  @override
  Widget build(BuildContext context) {
    _weatherView = Provider.of<WeatherView>(context);
    weatherModel = _weatherView.weatherModel;

    return Scaffold(
      body: _weatherView.state == ApiViewState.Busy
          ? const Center(child: CircularProgressIndicator())
          : Container(
              height: height(context),
              width: width(context),
              decoration: appBackground,
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 30.0),
                            child: IconButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChangeNotifierProvider(
                                      create: (context) => WeatherView(),
                                      child: Cities()),
                                ),
                              ).then(
                                (value) async {
                                  if (value != null) {
                                    await _weatherView.getData(value);
                                    setState(() {});
                                  }
                                },
                              ),
                              icon: Icon(
                                Icons.location_city_rounded,
                                color: purpletColor,
                              ),
                            ),
                          ),
                        ),
                        head(),
                        hours(),
                        days(),
                        weatherDetails()
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  head() {
    return Column(children: <Widget>[
      const SizedBox(
        height: 0,
      ),
      Text(
        weatherModel.location?.region.toString() ?? "",
        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
      ),
      Text(
        weatherModel.current?.condition?.text! ?? "",
        style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.bold),
      ),
      Container(
        width: width(context),
        alignment: Alignment.center,
        child: FittedBox(
          child: GradientText(
            (weatherModel.current?.tempC!.toInt().toString() ?? "") + "°",
            style: const TextStyle(fontSize: 200, fontWeight: FontWeight.bold),
            gradient: textGradient,
          ),
        ),
      ),
    ]);
  }

  hours() {
    // localtime is coming "2024-06-08 17:06".
    int localtime = int.parse(_weatherView.location?.localtime
            ?.substring(11, 13)
            .replaceAll(":", "")
            .trim() ??
        "");

    int i = 0;
    return Container(
      width: width(context) * 0.85,
      padding: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
          color: boxColor, borderRadius: BorderRadius.circular(5)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          boxTitle("HOURLY"),
          SizedBox(
            width: width(context) * 0.85,
            height: 100,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 24,
                itemBuilder: (context, index) {
                  if (localtime + index > 23) {
                    i = 1;
                    localtime = 0;
                  }
                  Hour hour = _weatherView
                          .forecastDayList?[i].hour?[localtime + index] ??
                      Hour();

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Text(
                            hour.time?.substring(11) ?? "asd",
                          ),
                        ),
                        WeatherIcon(
                          url: "https:" + (hour.condition?.icon! ?? ""),
                          color: purpleColor,
                        ),
                        /* Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Text(
                            hour.condition?.text ?? "",
                            style: const lowWhiteTextStyle,
                          ),
                        ),*/
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Text(
                            hour.tempC.toString() + "°",
                            style: lowWhiteTextStyle,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }

  days() {
    return Container(
      width: width(context) * 0.85,
      height: 300,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
          color: boxColor, borderRadius: BorderRadius.circular(5)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          boxTitle("DAYS"),
          Expanded(
            child: ListView.builder(
                itemCount: 3,
                itemBuilder: (context, index) {
                  Day day = _weatherView.forecastDayList?[index].day ?? Day();
                  String date = _weatherView.forecastDayList?[index].date ?? "";
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Container(
                      height: 65,
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 4),
                      padding: const EdgeInsets.all(15),
                      width: width(context) * 0.8,
                      decoration: BoxDecoration(
                        color: purpleColor.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Mar " + date.substring(8),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              WeatherIcon(
                                url: "https:" + (day.condition?.icon! ?? ""),
                                color: secondaryColor,
                                width: 50,
                                height: 50,
                              ),
                            ],
                          ),
                          SizedBox(
                            width: width(context) * 0.25,
                            child: Center(
                              child: Text(
                                day.condition?.text ?? "",
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.7)),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Text(
                            day.avgtempC.toString() + "°",
                            style:
                                TextStyle(color: Colors.white.withOpacity(0.7)),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }

  Widget weatherDetails() {
    return Container(
      width: width(context) * 0.85,
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
          color: boxColor, borderRadius: BorderRadius.circular(5)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          boxTitle("DETAILS"),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    weatherDetailItem(
                        "Wind",
                        (weatherModel.current?.windKph.toString() ?? "") +
                            " Km/h"),
                    weatherDetailItem("Visibility",
                        (weatherModel.current?.visKm.toString() ?? "") + " km"),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    weatherDetailItem(
                        "Humidity",
                        (weatherModel.current?.humidity.toString() ?? "") +
                            "%"),
                    weatherDetailItem(
                        "Precipitation",
                        (weatherModel.current?.precipMm.toString() ?? "") +
                            " Mm"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  weatherDetailItem(String head, String data) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Text(
            head,
            style: const TextStyle(fontSize: 15, color: Colors.white),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            data,
            style: const TextStyle(fontSize: 18, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  boxTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, top: 10.0, bottom: 5.0),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          title,
          style: boxTitleStyle,
        ),
      ),
    );
  }
}
