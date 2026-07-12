import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:weather/additional_info.dart';
import 'package:weather/api.dart';
import 'package:weather/hourly_forecast_item.dart';
import 'package:http/http.dart' as http;

class Weatherscreen extends StatefulWidget {
  const Weatherscreen({super.key});

  @override
  State<Weatherscreen> createState() => _WeatherscreenState();
}

class _WeatherscreenState extends State<Weatherscreen> {
  late Future<Map<String, dynamic>> weather;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCity = 'Erode';

  Future<Map<String, dynamic>> getCurrentWeather(String city) async {
    try {
      final res = await http.get(Uri.parse(
          "https://api.openweathermap.org/data/2.5/forecast?q=$city&units=metric&APPID=$openWeatherAPIKey"));
      final data = jsonDecode(res.body);

      if (data['cod'] != '200') {
        throw Exception(data['message'] ?? 'An unexpected error occurred');
      }

      return data;
    } catch (e) {
      throw e.toString().replaceAll("Exception: ", "");
    }
  }

  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather(_selectedCity);
    _searchController.text = _selectedCity;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchCity() {
    final city = _searchController.text.trim();
    if (city.isNotEmpty) {
      setState(() {
        _selectedCity = city;
        weather = getCurrentWeather(city);
      });
    }
  }

  IconData _getWeatherIcon(String mainCondition) {
    switch (mainCondition.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny_rounded;
      case 'clouds':
        return Icons.cloud_rounded;
      case 'rain':
        return Icons.water_drop_rounded;
      case 'drizzle':
        return Icons.grain_rounded;
      case 'thunderstorm':
        return Icons.thunderstorm_rounded;
      case 'snow':
        return Icons.ac_unit_rounded;
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return Icons.foggy;
      default:
        return Icons.wb_cloudy_rounded;
    }
  }

  Color _getWeatherColor(String mainCondition) {
    switch (mainCondition.toLowerCase()) {
      case 'clear':
        return const Color(0xFFFFD000);
      case 'clouds':
        return const Color(0xFF90CAF9);
      case 'rain':
      case 'drizzle':
        return const Color(0xFF64B5F6);
      case 'thunderstorm':
        return const Color(0xFFB39DDB);
      case 'snow':
        return const Color(0xFF80DEEA);
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return const Color(0xFFCFD8DC);
      default:
        return Colors.white70;
    }
  }

  List<Color> _getBackgroundGradient(String currentSky) {
    switch (currentSky.toLowerCase()) {
      case 'clear':
        return [
          const Color(0xFF0F1E36),
          const Color(0xFF1E3C72),
          const Color(0xFF020617),
        ];
      case 'clouds':
        return [
          const Color(0xFF1F2937),
          const Color(0xFF111827),
          const Color(0xFF030712),
        ];
      case 'rain':
      case 'drizzle':
        return [
          const Color(0xFF0B2545),
          const Color(0xFF134074),
          const Color(0xFF020617),
        ];
      case 'thunderstorm':
        return [
          const Color(0xFF1E152A),
          const Color(0xFF2E1065),
          const Color(0xFF020617),
        ];
      case 'snow':
        return [
          const Color(0xFF0D253F),
          const Color(0xFF1E3A5F),
          const Color(0xFF274D7E),
        ];
      default:
        return [
          const Color(0xFF0F172A),
          const Color(0xFF1E1B4B),
          const Color(0xFF020617),
        ];
    }
  }

  List<dynamic> _getDailyForecasts(List<dynamic> list) {
    List<dynamic> daily = [];
    Map<String, List<dynamic>> groupedByDay = {};

    // Skip the very first day in the forecast since it represents the current weather day
    DateTime firstItemDateTime = DateTime.parse(list[0]['dt_txt'].toString());
    String todayString = DateFormat('yyyy-MM-dd').format(firstItemDateTime);

    for (var item in list) {
      DateTime dateTime = DateTime.parse(item['dt_txt'].toString());
      String dayString = DateFormat('yyyy-MM-dd').format(dateTime);

      if (dayString == todayString) {
        continue;
      }

      groupedByDay.putIfAbsent(dayString, () => []).add(item);
    }

    groupedByDay.forEach((day, forecasts) {
      // Select the midday (12:00 PM) forecast for maximum representative value
      var middayForecast = forecasts.firstWhere(
        (x) => DateTime.parse(x['dt_txt'].toString()).hour == 12,
        orElse: () => forecasts[forecasts.length ~/ 2],
      );
      daily.add(middayForecast);
    });

    return daily;
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator.adaptive(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          const SizedBox(height: 20),
          Text(
            "Fetching weather forecast...",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
              fontFamily: GoogleFonts.poppins().fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.redAccent.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Colors.redAccent,
                      size: 56,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "City Not Found",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      error.contains("404")
                          ? "We couldn't find the city \"$_selectedCity\". Please check the spelling and try again."
                          : error,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedCity = 'Erode';
                          _searchController.text = 'Erode';
                          weather = getCurrentWeather(_selectedCity);
                        });
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text("Reset to default city"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.12),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: weather,
      builder: (context, snapshot) {
        String currentSky = 'clouds';
        if (snapshot.hasData) {
          currentSky = snapshot.data!['list'][0]['weather'][0]['main'];
        }

        final backgroundColors = _getBackgroundGradient(currentSky);

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: backgroundColors,
              ),
            ),
            child: SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    weather = getCurrentWeather(_selectedCity);
                  });
                },
                color: Colors.white,
                backgroundColor: backgroundColors[1],
                child: snapshot.connectionState == ConnectionState.waiting
                    ? _buildLoadingState()
                    : snapshot.hasError
                        ? _buildErrorState(snapshot.error.toString())
                        : _buildWeatherContent(snapshot.data!),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeatherContent(Map<String, dynamic> data) {
    final currentWeatherData = data['list'][0];
    final currentTemp = currentWeatherData['main']['temp'];
    final currentSky = currentWeatherData['weather'][0]['main'];
    final currentSkyDesc = currentWeatherData['weather'][0]['description'];
    final currentHumidity = currentWeatherData['main']['humidity'];
    final currentWindSpeed = currentWeatherData['wind']['speed'];
    final currentPressure = currentWeatherData['main']['pressure'];
    final currentFeelsLike = currentWeatherData['main']['feels_like'];
    final cityName = data['city']['name'];

    final weatherIcon = _getWeatherIcon(currentSky);
    final weatherColor = _getWeatherColor(currentSky);
    final dailyForecasts = _getDailyForecasts(data['list']);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Floating Glass-like Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.18),
                  width: 1.2,
                ),
              ),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _searchCity(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: "Search city...",
                  hintStyle: const TextStyle(
                    color: Colors.white38,
                    fontSize: 15,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Colors.white70,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear_rounded,
                            color: Colors.white70,
                            size: 20,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 14, horizontal: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Main Info Header: City and Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          color: Colors.redAccent,
                          size: 24,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          cityName,
                          style: GoogleFonts.outfit(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('EEEE, d MMMM').format(DateTime.now()),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white60,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      weather = getCurrentWeather(_selectedCity);
                    });
                  },
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: Colors.white70,
                    size: 26,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    padding: const EdgeInsets.all(10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Main Current Weather Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.18),
                  width: 1.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 32.0, horizontal: 24.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${currentTemp.round()}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 76,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    height: 1.0,
                                  ),
                                ),
                                Text(
                                  '°C',
                                  style: GoogleFonts.outfit(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white70,
                                    height: 1.6,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currentSky,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              currentSkyDesc.toString().split(' ').map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '').join(' '),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white60,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: weatherColor.withValues(alpha: 0.2),
                                blurRadius: 30,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                          child: Icon(
                            weatherIcon,
                            size: 92,
                            color: weatherColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 24-Hour Forecast Section Header
            Row(
              children: [
                const Icon(
                  Icons.watch_later_outlined,
                  color: Colors.white70,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  "24-Hour Forecast",
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Hourly List View
            SizedBox(
              height: 145,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: 8, // Extended to show 8 slots (24 hours total)
                itemBuilder: (context, index) {
                  final hourlyForecast = data['list'][index + 1];
                  final hourlySky = hourlyForecast['weather'][0]['main'];
                  final time = DateTime.parse(hourlyForecast['dt_txt'].toString());
                  final formattedTime = DateFormat('h a').format(time);
                  final isCurrent = index == 0;

                  return HourlyForecastItem(
                    time: formattedTime,
                    temperature: '${hourlyForecast['main']['temp'].round()}',
                    icon: _getWeatherIcon(hourlySky),
                    iconColor: _getWeatherColor(hourlySky),
                    isCurrent: isCurrent,
                  );
                },
              ),
            ),
            const SizedBox(height: 32),

            // 5-Day Forecast Section Header
            Row(
              children: [
                const Icon(
                  Icons.calendar_month_outlined,
                  color: Colors.white70,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  "5-Day Forecast",
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 5-Day Forecast Card Container
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1.2,
                ),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: dailyForecasts.length,
                separatorBuilder: (context, index) => Divider(
                  color: Colors.white.withValues(alpha: 0.08),
                  height: 24,
                ),
                itemBuilder: (context, index) {
                  final forecast = dailyForecasts[index];
                  final date = DateTime.parse(forecast['dt_txt'].toString());
                  final sky = forecast['weather'][0]['main'];
                  final skyDesc = forecast['weather'][0]['description'];
                  final temp = forecast['main']['temp'].round();

                  return Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          DateFormat('EEEE').format(date),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Row(
                          children: [
                            Icon(
                              _getWeatherIcon(sky),
                              color: _getWeatherColor(sky),
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                skyDesc.toString().split(' ').map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '').join(' '),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white60,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '$temp°C',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 32),

            // Additional Info Header
            Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: Colors.white70,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  "Weather Details",
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Additional Info 2x2 Grid
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AdditionalInfo(
                        icon: Icons.water_drop_rounded,
                        label: "Humidity",
                        value: "$currentHumidity%",
                        iconColor: const Color(0xFF4FC3F7),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AdditionalInfo(
                        icon: Icons.air_rounded,
                        label: "Wind Speed",
                        value: "${currentWindSpeed.toStringAsFixed(1)} m/s",
                        iconColor: const Color(0xFF81C784),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AdditionalInfo(
                        icon: Icons.speed_rounded,
                        label: "Pressure",
                        value: "$currentPressure hPa",
                        iconColor: const Color(0xFFFFB74D),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AdditionalInfo(
                        icon: Icons.thermostat_rounded,
                        label: "Feels Like",
                        value: "${currentFeelsLike.round()}°C",
                        iconColor: const Color(0xFFFF8A80),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
