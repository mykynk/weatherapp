import 'package:flutter/material.dart';

class WeatherIcon extends StatelessWidget {
  const WeatherIcon(
      {Key? key,
      required this.url,
      this.color = Colors.white,
      this.width = 30,
      this.height = 30})
      : super(key: key);
  final String url;
  final Color color;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4.0),
      height: height,
      width: width,
      child: ColorFiltered(
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          child: Image.network(url,fit: BoxFit.contain,)),
    );
  }
}
