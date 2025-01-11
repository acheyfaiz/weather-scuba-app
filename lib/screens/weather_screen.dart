import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/cubits/weather_cubit.dart';
import 'package:weather_app/cubits/weather_state.dart';

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scuba Weather'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              context.read<WeatherCubit>().getWeather(useCurrentLocation: true);
            },
          ),
        ],
      ),
      body: BlocBuilder<WeatherCubit, WeatherState>(
        builder: (context, state) {
          if (state is WeatherInitial) {
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  context.read<WeatherCubit>().getWeather();
                },
                child: const Text('Get Weather'),
              ),
            );
          }

          if (state is WeatherLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WeatherLoaded) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.weather.location,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 40),
                  Text(
                    '${state.weather.temperature.round()}°C',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  const SizedBox(height: 20),
                  _WeatherInfoRow(
                    icon: Icons.thermostat,
                    label: 'Feels like',
                    value: '${state.weather.feelsLike.round()}°C',
                  ),
                  _WeatherInfoRow(
                    icon: Icons.water_drop,
                    label: 'Humidity',
                    value: '${state.weather.humidity}%',
                  ),
                  _WeatherInfoRow(
                    icon: Icons.air,
                    label: 'Wind Speed',
                    value: '${state.weather.windSpeed} km/h',
                  ),
                  _WeatherInfoRow(
                    icon: Icons.umbrella,
                    label: 'Precipitation',
                    value: '${state.weather.precipitation} mm',
                  ),
                ],
              ),
            );
          }

          if (state is WeatherError) {
            return Center(
              child: Text(
                'Error: ${state.message}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}

class _WeatherInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _WeatherInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
} 