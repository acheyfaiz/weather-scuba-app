import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../repositories/weather_repository.dart';
import 'weather_state.dart';

class WeatherCubit extends Cubit<WeatherState> {
  final WeatherRepository _weatherRepository;

  WeatherCubit(this._weatherRepository) : super(WeatherInitial());

  // To get weather data
  Future<void> getWeather({
    bool useCurrentLocation = false,
    double? lat,
    double? lon,
  }) async {
    emit(WeatherLoading());
    try {
      late double latitude;
      late double longitude;

      if (useCurrentLocation) {
        final position = await _getCurrentLocation();
        latitude = position.latitude;
        longitude = position.longitude;
      } else if (lat != null && lon != null) {
        latitude = lat;
        longitude = lon;
      } else {
        emit(const WeatherNoLocation("Please select a location"));
      }

      final weather = await _weatherRepository.getWeather(latitude, longitude);
      emit(WeatherLoaded(weather));
    } catch (e) {
      emit(WeatherError(e.toString()));
    }
  }

  // To get user current location
  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    return await Geolocator.getCurrentPosition();
  }
} 