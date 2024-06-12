// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'api_key.dart';

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String cityname = 'Chennai';
      final res = await http.get(
        Uri.parse(
            "https://api.openweathermap.org/data/2.5/forecast?q=$cityname&APPID=$openWeatherAPIKey"),
      );
      final data = jsonDecode(res.body);
      if (data['cod'] != '200') {
        throw 'An unexpected error occured!';
      } else {
        return data;
      }
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        body: FutureBuilder(
          future: getCurrentWeather(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }
            final data = snapshot.data!;
            final currentTemp = data['list'][0]['main']['temp'];
            final currentWeather = data['list'][0]['weather'][0]['main'];
            final humidity = data['list'][0]['main']['humidity'];
            final windSpeeed = data['list'][0]['wind']['speed'];
            final pressure = data['list'][2]['main']['pressure'];

            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFF5c584d),
              ),
              height: h,
              width: w,
              child: Column(
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Weather App",
                          style: TextStyle(
                            color: Colors.white,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w200,
                            fontSize: 34,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {});
                        },
                        icon: const Icon(
                          Icons.refresh,
                          color: Colors.white,
                        ),
                        iconSize: 40,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Container(
                    height: h * 0.30,
                    width: w * 0.75,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(0, 0, 0, 0.38),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.white,
                          offset: Offset(5, 5),
                          blurRadius: 10,
                          spreadRadius: 2,
                          blurStyle: BlurStyle.outer,
                        ),
                        BoxShadow(
                          color: Colors.black38,
                          offset: Offset(0, 0),
                          blurRadius: 0,
                          spreadRadius: 0,
                          blurStyle: BlurStyle.outer,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "$currentTemp K",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w300),
                        ),
                        currentWeather == 'Clouds' || currentWeather == 'Rain'
                            ? const Icon(
                                Icons.cloud,
                                color: Colors.white,
                                size: 90,
                              )
                            : const Icon(
                                Icons.sunny,
                                color: Colors.white,
                                size: 90,
                              ),
                        Text(
                          currentWeather.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const Text(
                    "Weather Forecast",
                    style: TextStyle(
                        color: Colors.white, fontSize: 36, letterSpacing: 1.5),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: w,
                    height: h * 0.15,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          String dt = data['list'][index + 1]['dt_txt'];
                          final time = DateTime.parse(dt);
                          return WeatherCard(
                            time: DateFormat.j().format(time),
                            icon: data['list'][index + 1]['weather'][0]
                                            ['main'] ==
                                        'Clouds' ||
                                    data['list'][index + 1]['weather'][0]
                                            ['main'] ==
                                        'Rain'
                                ? Icons.cloud
                                : Icons.sunny,
                            weather: data['list'][index + 1]['main']['temp']
                                .toString(),
                          );
                        }),
                    // SingleChildScrollView(
                    //   scrollDirection: Axis.horizontal,
                    //   child: Row(
                    //     children: [
                    //       for (int i = 0; i < 5; i++)
                    // WeatherCard(
                    //   time: data['list'][i + 1]['dt'].toString(),
                    //   icon: data['list'][i + 1]['weather'][0]['main'] ==
                    //               'Clouds' ||
                    //           data['list'][i + 1]['weather'][0]
                    //                   ['main'] ==
                    //               'Rain'
                    //       ? Icons.cloud
                    //       : Icons.sunny,
                    //   weather: data['list'][i + 1]['main']['temp']
                    //       .toString(),
                    // ),
                    //     ],
                    //   ),
                    // ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const Text(
                    "Additional Information",
                    style: TextStyle(
                        color: Colors.white, fontSize: 32, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ShadowBox(
                        icon: Icons.water_drop,
                        data: humidity.toString(),
                        text: "Humidity",
                      ),
                      ShadowBox(
                        icon: Icons.air,
                        data: windSpeeed.toString(),
                        text: "Wind Speed",
                      ),
                      ShadowBox(
                        icon: Icons.beach_access,
                        data: pressure.toString(),
                        text: "Pressure",
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class WeatherCard extends StatelessWidget {
  const WeatherCard({
    super.key,
    required this.time,
    required this.icon,
    required this.weather,
  });

  final String time;
  final IconData icon;
  final String weather;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black38,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 85,
            child: Column(
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  maxLines: 1,
                ),
                const SizedBox(
                  height: 10,
                ),
                Icon(
                  icon,
                  color: Colors.white,
                  size: 30,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  weather,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ShadowBox extends StatelessWidget {
  const ShadowBox(
      {super.key, required this.icon, required this.text, required this.data});

  final IconData icon;
  final String text;
  final String data;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.black38,
        boxShadow: const [
          BoxShadow(
            color: Colors.white,
            offset: Offset(3, 3),
            blurRadius: 6,
            spreadRadius: 2,
            blurStyle: BlurStyle.outer,
          ),
          BoxShadow(
            color: Colors.black38,
            offset: Offset(0, 0),
            blurRadius: 0,
            spreadRadius: 0,
            blurStyle: BlurStyle.outer,
          ),
        ],
      ),
      width: MediaQuery.of(context).size.width * 0.3,
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 30,
          ),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          Text(
            data,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
            ),
          ),
        ],
      ),
    );
  }
}
