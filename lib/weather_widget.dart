import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'api_service.dart';

class WeatherWidget extends StatefulWidget {
  final ApiService apiService;

  WeatherWidget({required this.apiService});

  @override
  _WeatherWidgetState createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  String _city = "";
  String? _weatherDescription;
  double? _temperature;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _weatherDescription = 'Error: Location service disabled';
        _isLoading = false;
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        setState(() {
          _weatherDescription = 'Error: Location permission denied';
          _isLoading = false;
        });
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    _fetchWeatherFromCoordinates(position.latitude, position.longitude);
  }

  Future<void> _fetchWeatherFromCoordinates(double lat, double lon) async {
    try {
      final weatherData = await widget.apiService.fetchWeatherFromCoordinates(lat, lon);
      setState(() {
        _weatherDescription = weatherData['weather'][0]['description'];
        _temperature = weatherData['main']['temp'];
        _city = weatherData['name'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _weatherDescription = 'Error fetching weather data';
        _temperature = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.blue,
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '$_city',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        _getWeatherIconPath(_weatherDescription),
                        width: 50,
                        height: 50,
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$_temperature°C',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$_weatherDescription',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  String _getWeatherIconPath(String? description) {
    if (description == null) return 'assets/weather_icons/cloudy.png'; // Par défaut, afficher nuageux

    // Utilisation de la description météo pour choisir l'icône
    if (description.toLowerCase().contains('clear')) {
      return 'assets/sunny.png'; // Soleil
    } else if (description.toLowerCase().contains('rain')) {
      return 'assets/rainy.png'; // Pluie
    } else {
      return 'assets/cloudy.png'; // Nuage (par défaut)
    }
  }
}