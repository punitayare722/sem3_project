import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecommendationPage extends StatefulWidget {
  const RecommendationPage({Key? key}) : super(key: key);

  @override
  _RecommendationPageState createState() => _RecommendationPageState();
}

class _RecommendationPageState extends State<RecommendationPage> {
  String weatherInfo = '';
  List<Map<String, String>> recommendedPlants = [];
  final TextEditingController _locationController =
      TextEditingController(text: 'London');

  Future<void> getWeather() async {
    final apiKey =
        '6beb44f850234b899f7153935242010'; // Replace with your WeatherAPI key
    final location = _locationController.text;
    final apiUrl =
        'https://api.weatherapi.com/v1/current.json?key=${apiKey}&q=${location}&aqi=no';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final double temperature =
            (data['current']['temp_c'] as num).toDouble();
        final double humidity = (data['current']['humidity'] as num).toDouble();
        final String weatherCondition =
            data['current']['condition']['text'] ?? 'Unknown';

        setState(() {
          weatherInfo =
              'Temperature: ${temperature}°C\nHumidity: ${humidity}%\nCondition: $weatherCondition';
          recommendedPlants = recommendPlants(temperature, humidity);
        });
      } else {
        setState(() {
          weatherInfo = 'Failed to fetch weather data';
        });
      }
    } catch (e) {
      setState(() {
        weatherInfo = 'Error: $e';
      });
    }
  }

  List<Map<String, String>> recommendPlants(
      double temperature, double humidity) {
    // Sample plant recommendations with associated images
    if (temperature > 30) {
      return [
        {"name": "Cactus", "image": "assets/images/cactus.jpg"},
        {"name": "Succulents", "image": "assets/images/succulent.jpg"},
        {"name": "Aloe Vera", "image": "assets/images/aloevera.jpg"}
      ];
    } else if (humidity > 70) {
      return [
        {"name": "Ferns", "image": "assets/images/fern.jpg"},
        {"name": "Bamboo", "image": "assets/images/bamboo.jpg"},
        {"name": "Peace Lily", "image": "assets/images/peacelily.jpg"}
      ];
    } else if (temperature >= 20 && temperature <= 30) {
      return [
        {"name": "Spider Plant", "image": "assets/images/spider_plant.jpg"},
        {"name": "Lettuce", "image": "assets/images/lettuce.jpg"},
        {"name": "Basil", "image": "assets/images/basil.jpg"}
      ];
    } else if (temperature >= 10 && temperature < 20) {
      return [
        {"name": "Spinach", "image": "assets/images/spinach.jpg"},
        {"name": "Carrots", "image": "assets/images/carrot.jpg"},
        {"name": "Rosemary", "image": "assets/images/rosemary.jpg"}
      ];
    } else if (temperature < 10) {
      return [
        {"name": "Kale", "image": "assets/images/kale.jpg"},
        {"name": "Thyme", "image": "assets/images/thyme.jpg"},
        {"name": "Brussels Sprouts", "image": "assets/images/brussels.jpg"}
      ];
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Recommended plants'),
          flexibleSpace: Container(
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
            colors: [Colors.green, Colors.teal],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter Location:',
              style: TextStyle(fontSize: 16),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your location',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: getWeather,
                  child: const Text('Get Weather'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              weatherInfo,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Recommended Plants Based on Weather:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: recommendedPlants.length,
                itemBuilder: (context, index) {
                  final plant = recommendedPlants[index];
                  return Card(
                    child: Row(
                      children: [
                        Image.asset(
                          plant['image']!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          plant['name']!,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
