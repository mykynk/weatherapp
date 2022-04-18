import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weatherapp/helper/colors.dart';
import 'package:weatherapp/helper/size.dart';
import 'package:http/http.dart' as http;
import 'package:weatherapp/helper/styles.dart';
import 'package:weatherapp/helper/text_styles.dart';
import 'package:weatherapp/services/weather_view.dart';
import 'package:hive/hive.dart';

class SearchCity extends StatefulWidget {
  SearchCity({Key? key}) : super(key: key);

  @override
  State<SearchCity> createState() => _SearchCityState();
}

class _SearchCityState extends State<SearchCity> {
  TextEditingController _textEditingController = TextEditingController();
  List list = [];
  late WeatherView _weatherView;

  @override
  Widget build(BuildContext context) {
    _weatherView = Provider.of<WeatherView>(context);
    var box = Hive.box('testBox');
    return Scaffold(
      body: Container(
        decoration: appBackground,
        child: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: purpletColor,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: TextField(
                        controller: _textEditingController,
                        cursorColor: purpletColor,
                        autofocus: true,
                        decoration: InputDecoration.collapsed(
                          hintText: "Search Location",
                          hintStyle: lowWhiteTextStyle,
                          
                        ),
                        onChanged: (value) async {
                          var response = await http.post(
                              Uri.parse(
                                  'http://api.weatherapi.com/v1/search.json?key=3d44640a7a6a4235834221009220703&q=$value'),
                              body: '"lang":"tr"');
                          String data = response.body;
                          setState(() {
                            list = jsonDecode(response.body);
                          });
                          print(list);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) => ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(list[index]['name'].toString(),style: boldTextStyle(),),
                        Text(list[index]['region'].toString() + ", " + list[index]['country'].toString(),style: const TextStyle(fontSize: 14),),
                      ],
                    ),
                    onTap: () {
                      Navigator.pop(context, list[index]['name']);
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

//_textEditingController.text = "İstanbul";
//TextEditingController _textEditingController = TextEditingController();
 /*Container(
                  width: 250,
                  padding: EdgeInsets.all(20),
                  child: TextField(
                    controller: _textEditingController,
                    decoration: InputDecoration(hintText: "Location"),
                  ),
                ),
                Text(weatherModel.location?.name ?? ""),
                Text(weatherModel.location?.region ?? "")*/
/* floatingActionButton: FloatingActionButton(
        onPressed: getData,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),*/
