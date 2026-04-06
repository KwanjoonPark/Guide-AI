import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // 네이버 클라우드 플랫폼 (Maps API)
  static String get naverClientId => dotenv.env['NAVER_CLIENT_ID'] ?? '';
  static String get naverClientSecret => dotenv.env['NAVER_CLIENT_SECRET'] ?? '';

  static const String naverApiBaseUrl = 'https://maps.apigw.ntruss.com';

  static const String geocodingPath = '/map-geocode/v2/geocode';
  static const String reverseGeocodingPath = '/map-reversegeocode/v2/gc';
  static const String directionsPath = '/map-direction/v1/driving';

  // 카카오 (Local Search API)
  static String get kakaoRestApiKey => dotenv.env['KAKAO_REST_API_KEY'] ?? '';

  static const String kakaoBaseUrl = 'https://dapi.kakao.com';
  static const String kakaoKeywordSearchPath = '/v2/local/search/keyword.json';
}
