import 'package:dio/dio.dart';
import '../models/user.dart';
import '../models/food_log.dart';

class ApiService {
  final Dio _dio;
  final String baseUrl;

  ApiService({String? baseUrl})
      : baseUrl = baseUrl ?? 'http://localhost:8000',
        _dio = Dio(BaseOptions(
          baseUrl: baseUrl ?? 'http://localhost:8000',
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ));

  // User endpoints
  Future<User> createUser(User user) async {
    try {
      final response = await _dio.post('/user/create', data: user.toJson());
      return User.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  // Speech endpoints
  Future<Map<String, dynamic>> uploadSpeech(String audioPath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(audioPath, filename: 'audio.wav'),
      });
      final response = await _dio.post('/speech/upload', data: formData);
      return response.data;
    } catch (e) {
      throw Exception('Failed to upload speech: $e');
    }
  }

  // Food endpoints
  Future<Map<String, dynamic>> parseFood(String text) async {
    try {
      final response = await _dio.post('/food/parse', data: {'text': text});
      return response.data;
    } catch (e) {
      throw Exception('Failed to parse food: $e');
    }
  }

  Future<FoodLog> logFood(FoodLog foodLog) async {
    try {
      final response = await _dio.post('/food/log', data: foodLog.toJson());
      return FoodLog.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to log food: $e');
    }
  }

  Future<Map<String, dynamic>> getTodayFood(int userId) async {
    try {
      final response = await _dio.get('/food/today', queryParameters: {'user_id': userId});
      return response.data;
    } catch (e) {
      throw Exception('Failed to get today food: $e');
    }
  }

  // Prediction endpoints
  Future<Map<String, dynamic>> getNextPrediction(int userId) async {
    try {
      final response = await _dio.get('/predict/next', queryParameters: {'user_id': userId});
      return response.data;
    } catch (e) {
      throw Exception('Failed to get prediction: $e');
    }
  }
}

