import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoder/services/base.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:weatherapp/helper/colors.dart';
import 'package:weatherapp/helper/location.dart';
import 'package:weatherapp/helper/size.dart';
import 'package:weatherapp/helper/styles.dart';
import 'package:weatherapp/helper/text_styles.dart';
import 'package:weatherapp/home_page/search_city.dart';
import 'package:weatherapp/home_page/widgets/weather_icon.dart';
import 'package:weatherapp/models/current.dart';
import 'package:weatherapp/models/weather_model.dart';
import 'package:weatherapp/services/weather_view.dart';

class Cities extends StatefulWidget {
  Cities({Key? key}) : super(key: key);

  @override
  State<Cities> createState() => _CitiesState();
}

class _CitiesState extends State<Cities> {
  @override
  void initState() {
    super.initState();
    getCurrentLocation();

    getCities();
  }

  List<WeatherModel> weatherModels = [];
  Box? box;
  List _cities = [];
  List _cityKeys = [];
  late WeatherView _weatherView;
  late Position position;
  late Address address;
  Current? locationCurrent;

  @override
  Widget build(BuildContext context) {
    _weatherView = Provider.of<WeatherView>(context);

    return Scaffold(
      body: Container(
        decoration: appBackground,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: Row(
                  children: [
                    BackButton(
                      color: purpletColor,
                    ),
                    Text(
                      "Choose City",
                      style: boldTextStyle(fontSize: 32),
                    ),
                  ],
                ),
              ),
              // Current locaiton
              locationCurrent != null
                  ? cityContainer(locationCurrent!, isCurrentLocation: true)
                  : SizedBox(),
              // cities
              Expanded(
                child: ListView.builder(
                  itemCount: weatherModels.length,
                  itemBuilder: (context, index) {
                    Current _currentCity = weatherModels[index].current!;
                    return Column(
                      children: [
                        // Saved Cities
                        weatherModels.length == _cities.length
                            ? cityItem(index, _currentCity)
                            : const CircularProgressIndicator(
                                color: Colors.white,
                              ),
                      ],
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: floatingActionButton(),
    );
  }

  Dismissible cityItem(int index, Current currentCity) {
    return Dismissible(
      onDismissed: (value) => deleteCity(index),
      key: _cityKeys[index],
      child: cityContainer(
        currentCity,
        index: index,
      ),
    );
  }

  GestureDetector cityContainer(Current currentCity,
      {int index = 0, bool isCurrentLocation = false}) {
    return GestureDetector(
      onTap: () => Navigator.pop(
          context, isCurrentLocation ? address.adminArea : _cities[index]),
      child: Container(
        height: 65,
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        padding: const EdgeInsets.all(15),
        width: width(context),
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
                SizedBox(
                  width: 80,
                  child: isCurrentLocation
                      ? Row(
                          children: [
                            Text(address.adminArea),
                            const SizedBox(
                              width: 4,
                            ),
                            const Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 16,
                            )
                          ],
                        )
                      : Text(
                          _cities[index],
                        ),
                ),
                const SizedBox(
                  width: 10,
                ),
                WeatherIcon(
                  url: "https:" + (currentCity.condition?.icon! ?? ""),
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
                  currentCity.condition?.text ?? "",
                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Text(
              currentCity.tempC.toString() + "°",
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ],
        ),
      ),
    );
  }

  FloatingActionButton floatingActionButton() {
    return FloatingActionButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider(
              create: (context) => WeatherView(), child: SearchCity()),
        ),
      ).then((value) {
        if (value != null) {
          addCity(value);
        }
      }),
      backgroundColor: primaryColor,
      child: const Icon(Icons.add),
    );
  }

  getCities() async {
    box = Hive.box('testBox');
    _cities = await box!.get('cities');
    _cities.forEach((value) => _cityKeys.add(ValueKey(value)));
    getWeatherModels();

    setState(() {});
  }

  addCity(String cityName) async {
    _cities.add(cityName);
    _cityKeys.add(ValueKey(cityName));
    await box!.put('cities', _cities);
    weatherModels.add(await _weatherView.getData(cityName));
    setState(() {});
  }

  deleteCity(int index) async {
    _cities.removeAt(index);
    _cityKeys.removeAt(index);
    await box!.put('cities', _cities);
    weatherModels.removeAt(index);

    setState(() {});
  }

  getWeatherModels() async {
    for (var i = 0; i < _cities.length; i++) {
      weatherModels.add(await _weatherView.getData(_cities[i]));
    }
  }

  void getCurrentLocation() async {
    position = await determinePosition();
    Coordinates coordinates =
        Coordinates(position.latitude, position.longitude);
    List addressList =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    address = addressList[0];
    WeatherModel locationWeatherModel =
        await _weatherView.getData(address.adminArea);
    locationCurrent = locationWeatherModel.current!;
  }
}
