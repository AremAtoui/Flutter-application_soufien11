import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseCurrency;

  ApiService(this.baseCurrency);

  // API key pour OpenWeatherMap
  static const String weatherApiKey = '9af391e10cd6c47df83a85a288e7543b'; // Remplacez par votre propre clé API OpenWeatherMap
  static const String weatherUrl = 'https://api.openweathermap.org/data/2.5/weather';
  static const String exchangeRatesUrl =
      'https://api.exchangerate-api.com/v4/latest'; // API des taux de change
  static const String publicHolidaysUrl = 'https://date.nager.at/Api/v2/PublicHolidays'; // API des jours fériés

  // Fonction pour récupérer les taux de change
  Future<Map<String, double>> fetchExchangeRates() async {
    final response = await http.get(Uri.parse('$exchangeRatesUrl/$baseCurrency'));
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final Map<String, double> rates = {};
      
      // Conversion des taux de change pour toutes les devises
      data['rates'].forEach((key, value) {
        rates[key] = value.toDouble();
      });
      return rates;
    } else {
      throw Exception('Erreur lors de la récupération des taux de change');
    }
  }

  // Fonction pour récupérer la météo en utilisant la latitude et la longitude
  Future<Map<String, dynamic>> fetchWeatherFromCoordinates(double latitude, double longitude) async {
    final response = await http.get(Uri.parse(
        '$weatherUrl?lat=$latitude&lon=$longitude&appid=$weatherApiKey&units=metric&lang=fr'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Erreur lors de la récupération des données météo');
    }
  }

  // Fonction pour récupérer la météo par ville
  Future<Map<String, dynamic>> fetchWeatherByCity(String city) async {
    final response = await http.get(Uri.parse(
        '$weatherUrl?q=$city&appid=$weatherApiKey&units=metric&lang=fr'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Erreur lors de la récupération des données météo');
    }
  }

  // Fonction pour récupérer les jours fériés d'un pays pour une année donnée
  Future<List<DateTime>> fetchPublicHolidays(String countryCode, int year) async {
    final response = await http.get(Uri.parse(
        '$publicHolidaysUrl/$countryCode/$year'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      List<DateTime> holidays = [];
      
      // Extraction des jours fériés sous forme de DateTime
      for (var holiday in data) {
        String dateStr = holiday['date'];
        DateTime holidayDate = DateTime.parse(dateStr);
        holidays.add(holidayDate);
      }
      
      return holidays;
    } else {
      throw Exception('Erreur lors de la récupération des jours fériés');
    }
  }
}
