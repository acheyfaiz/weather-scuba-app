import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../repositories/weather_repository.dart';
import 'weather_state.dart';

class WeatherCubit extends Cubit<WeatherState> {
  final WeatherRepository _weatherRepository;

  WeatherCubit(this._weatherRepository) : super(WeatherInitial());

  // Hardcoded coordinates for Sipadan Island, Malaysia
  static const double defaultLat = 4.1150;
  static const double defaultLon = 118.6292;

  Future<void> getWeather({bool useCurrentLocation = false}) async {
    emit(WeatherLoading());
    try {
      double lat = defaultLat;
      double lon = defaultLon;

      if (useCurrentLocation) {
        final position = await _getCurrentLocation();
        lat = position.latitude;
        lon = position.longitude;
      }

      final weather = await _weatherRepository.getWeather(lat, lon);
      emit(WeatherLoaded(weather));
    } catch (e) {
      emit(WeatherError(e.toString()));
    }
  }

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