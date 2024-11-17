import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/services/weather_services.dart';
import 'package:weather_app/widget/weather_data_tile.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _controller = TextEditingController();
  String _bgImg = 'assets/images/clear.jpg';
  String _iconImg = 'assets/icons/Clear.png';
  String _cityName = '';
  String _temperature = '';
  String _description = '';
  String _tempMax = '';
  String _tempMin = '';
  String _sunrise = '';
  String _sunset = '';
  String _pressure = '';
  String _humidity = '';
  String _visibility = '';
  String _windSpeed = '';

  getData(String cityName) async {
    final weatherServices = WeatherServices();
    var weatherData;
    if (cityName == '') {
      weatherData = await weatherServices.fetchWeather();
    } else {
      weatherData = await weatherServices.getWeather(cityName);
    }

    debugPrint(weatherData.toString());
    setState(() {
      _cityName = weatherData['name'];
      _temperature = weatherData['main']['temp'].toStringAsFixed(0);
      _description = weatherData['weather'][0]['main'];
      _tempMax = weatherData['main']['temp_max'].toStringAsFixed(0);
      _tempMin = weatherData['main']['temp_min'].toStringAsFixed(0);
      _sunrise = DateFormat('hh:mm a').format(
          DateTime.fromMillisecondsSinceEpoch(
              weatherData['sys']['sunrise'] * 1000));
      _sunset = DateFormat('hh:mm a').format(
          DateTime.fromMillisecondsSinceEpoch(
              weatherData['sys']['sunset'] * 1000));
      _pressure = weatherData['main']['pressure'].toString();
      _humidity = weatherData['main']['humidity'].toString();
      _visibility = (weatherData['visibility'] / 1000).toString();
      _windSpeed = weatherData['wind']['speed'].toString();

      if (_description == 'Clear') {
        _bgImg = 'assets/images/clear.jpg';
        _iconImg = 'assets/icons/Clear.png';
      } else if (_description == 'Clouds') {
        _bgImg = 'assets/images/clouds.jpg';
        _iconImg = 'assets/icons/Clouds.png';
      } else if (_description == 'Rain') {
        _bgImg = 'assets/images/rain.jpg';
        _iconImg = 'assets/icons/Rain.png';
      } else if (_description == 'Fog') {
        _bgImg = 'assets/images/fog.jpg';
        _iconImg = 'assets/icons/Snow.png';
      } else if (_description == 'Haze') {
        _bgImg = 'assets/images/haze.jpg';
        _iconImg = 'assets/icons/Haze.png';
      } else {
        _bgImg = 'assets/images/thunderstorm.jpg';
        _iconImg = 'assets/icons/ThunderStorm.png';
      }
    });
  }

  Future<bool> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
      getData('');
    }
    getData('');
    return true;
  }

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            _bgImg,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 40,
                  ),
                  TextField(
                    controller: _controller,
                    onChanged: (value) {
                      getData(value);
                    },
                    decoration: const InputDecoration(
                      suffixIcon: Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.black26,
                      hintText: 'Enter city name',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16))),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on),
                      Text(
                        _cityName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Text(
                    '$_temperature°c',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 90,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Text(_description,
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w500,
                          )),
                      Image.asset(_iconImg, height: 80),
                    ],
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Row(
                    children: [
                      const Icon(Icons.arrow_upward),
                      Text(
                        '$_tempMax°c',
                        style: const TextStyle(
                            fontSize: 22, fontStyle: FontStyle.italic),
                      ),
                      const Icon(Icons.arrow_downward),
                      Text(
                        '$_tempMin°c',
                        style: const TextStyle(
                            fontSize: 22, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Card(
                    color: Colors.transparent,
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          WeatherDataTile(
                              index1: "Sunrise",
                              index2: "Sunset",
                              value1: _sunrise,
                              value2: _sunset),
                          const SizedBox(height: 15),
                          WeatherDataTile(
                              index1: "Humidity",
                              index2: "Visibility",
                              value1: '$_humidity %',
                              value2: '$_visibility Km'),
                          const SizedBox(height: 15),
                          WeatherDataTile(
                              index1: "Pressure",
                              index2: "Wind speed",
                              value1: '$_pressure hPa',
                              value2: '$_windSpeed Km/hr'),
                          const SizedBox(height: 15),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
