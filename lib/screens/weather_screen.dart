import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/cubits/weather_cubit.dart';
import 'package:weather_app/cubits/weather_state.dart';
import 'package:weather_app/models/diving_spot_model.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

import 'package:weather_app/screens/appbar.dart';
import 'package:weather_app/screens/bg_color.dart';
import 'package:weather_app/screens/forecast.dart';
import 'package:weather_app/screens/scuba_description.dart';
import 'package:weather_app/screens/weather_initial.dart';
import 'package:weather_app/screens/weather_items.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  List<DivingSpot>? _divingSpots;
  DivingSpot? _selectedSpot;

  @override
  void initState() {
    super.initState();
    _loadDivingSpots();
  }

  // Load diving spots from JSON file
  Future<void> _loadDivingSpots() async {
    final String jsonString = await rootBundle.loadString('assets/diving_spots.json');
    final data = json.decode(jsonString);
    setState(() {
      _divingSpots = (data['diving_spots'] as List)
        .map((spot) => DivingSpot.fromJson(spot))
        .toList();
      _selectedSpot = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BodyBackgroundColor(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Custom App Bar
              const CustomAppBar(),

              // Location Selector
              if (_divingSpots != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<DivingSpot?>(
                        value: _selectedSpot,
                        hint: const Text(
                          'Please Select Location',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        isExpanded: true,
                        dropdownColor: const Color(0xFF1E88E5),
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        items: [
                          ..._divingSpots?.map((spot) {
                            return DropdownMenuItem(
                              value: spot,
                              child: Text(spot.name, style: const TextStyle(
                                color: Colors.white, 
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              )),
                            );
                          }).toList() ?? [],
                        ],
                        onChanged: (DivingSpot? spot) {
                          setState(() {
                            _selectedSpot = spot;
                          });
                          if (spot != null) {
                            context.read<WeatherCubit>().getWeather(
                              lat: spot.latitude,
                              lon: spot.longitude,
                            );
                          } 
                        },
                      ),
                    ),
                  ),
                ),

              // Selected Location Description
              if (_selectedSpot != null)
                ScubaDescription(description: _selectedSpot!.description),

              // Weather Content
              Expanded(
                child: BlocConsumer<WeatherCubit, WeatherState>(
                  listener: (context, state) {
                    // To show error message if no location is selected
                    if (state is WeatherNoLocation) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.message), 
                        duration: const Duration(seconds: 2)),
                      );
                    }
                  },
                  builder: (context, state) {

                    if (state is WeatherInitial) {
                      return const UIInitial();
                    }

                    else if (state is WeatherLoading) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }

                    else if (state is WeatherLoaded) {
                      return _buildWeatherContent(context, state.weather);
                    }

                    else if (state is WeatherError) {
                      return const UIInitial();
                    }

                    return const SizedBox();
                  },
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherContent(BuildContext context, Weather weather) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Current Weather Card
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  Text(
                    '${weather.temperature.round()}°C',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Display the "feels like" temperature which accounts for humidity and wind
                  WeatherItem(
                    icon: Icons.thermostat,
                    label: 'Feels like',
                    value: '${weather.feelsLike.round()}°C',
                  ),

                  // Show current humidity percentage in the air
                  WeatherItem(
                    icon: Icons.water_drop,
                    label: 'Humidity',
                    value: '${weather.humidity}%',
                  ),

                  // Display wind speed in kilometers per hour
                  WeatherItem(
                    icon: Icons.air,
                    label: 'Wind Speed',
                    value: '${weather.windSpeed} km/h',
                  ),

                  // Show precipitation amount in millimeters
                  WeatherItem(
                    icon: Icons.umbrella,
                    label: 'Precipitation',
                    value: '${weather.precipitation} mm',
                  ),

                ],
              ),
            ),
          ),

          // Forecast Section
          ForecastSection(weather: weather),
        ],
      ),
    );
  }

} 