import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:jiffy/jiffy.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    position= await Geolocator.getCurrentPosition();
    var lo=position?.longitude;
    var lat=position?.longitude;
    // print("Longtitue ${lo}");
    // print("Late ${lat}");
    getWeatherData();
  }
  Position? position;
  @override
  void initState() {
    determinePosition();
    super.initState();
  }
  Map<String, dynamic>? weatherMap;
  Map<String, dynamic>? forCastMap;

  getWeatherData() async{
    var weather="https://api.openweathermap.org/data/2.5/weather?lat=${position!.latitude}&lon='${position!.longitude}'&appid=53ffc8dd6078f83db0ca25d5c408a962";
    var weatherData= await http.get(Uri.parse(weather));

    // print("Weather Data ${weatherData.body}");
    var forecast="https://api.openweathermap.org/data/2.5/forecast?lat=${position!.latitude}&lon='${position!.longitude}'&appid=53ffc8dd6078f83db0ca25d5c408a962";
    var forecastData= await http.get(Uri.parse(forecast));
    // print("=================================================================");
    // print("ForeCust Data ${forecastData.body}");

    var weathers=jsonDecode(weatherData.body);
    var forecusts=jsonDecode(forecastData.body);
    setState(() {
      weatherMap=Map<String, dynamic>.from(weathers);
      forCastMap=Map<String, dynamic>.from(forecusts);
    });
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child:weatherMap!=null? Scaffold(
        body: Container(
          color: Colors.white60,
          child: Column(
            children: [
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      children: [
                        Text("${Jiffy.parse("${DateTime.now()}").format(pattern: 'MMMM do yyyy, h:mm:ss a')}"),
                        Text("${weatherMap!['name']}")
                      ],
                    ),
                  ),
                )
            ],
          ),
        )
      ):Center(child: CircularProgressIndicator(),),
    );
  }
}
