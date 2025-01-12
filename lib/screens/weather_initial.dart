import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/cubits/weather_cubit.dart';

class UIInitial extends StatelessWidget {
  const UIInitial({super.key});

  @override
  Widget build(BuildContext context) {
     return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: () => context.read<WeatherCubit>().getWeather(),
        child: const Text(
          'Get Weather',
          style: TextStyle(color: Color(0xFF1E88E5)),
        ),
      ),
    );
  }
}