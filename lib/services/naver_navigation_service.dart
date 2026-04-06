import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import '../config/api_config.dart';
import '../model/location.dart';
import '../model/route_info.dart';

class NaverNavigationService {
  late final Dio _dio;
  late final Dio _searchDio;

  NaverNavigationService() {
    // 네이버 클라우드 (Maps API)
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.naverApiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'X-NCP-APIGW-API-KEY-ID': ApiConfig.naverClientId,
          'X-NCP-APIGW-API-KEY': ApiConfig.naverClientSecret,
        },
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print('API: $obj'),
      ),
    );

    // 카카오 (Local Search API)
    _searchDio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.kakaoBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Authorization': 'KakaoAK ${ApiConfig.kakaoRestApiKey}',
        },
      ),
    );

    _searchDio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print('SearchAPI: $obj'),
      ),
    );
  }

  // 현재 위치
  Future<Location?> getCurrentLocation() async {
    try {
      print('현재 위치를 확인하고 있습니다');

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('위치 서비스가 비활성화되어 있습니다');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('위치 권한이 거부되었습니다. 활성화해주세요');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('위치 권한이 영구적으로 거부되었습니다');
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print('현재 위치는 (${position.latitude}, ${position.longitude}) 입니다.');

      return Location(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      print('위치 가져오기에 실패하였습니다: $e');
      return null;
    }
  }

  // 장소명으로 검색 (카카오 Local Search API)
  Future<Location?> searchPlace(String query) async {
    try {
      print('장소 검색 중입니다: $query');

      final response = await _searchDio.get(
        ApiConfig.kakaoKeywordSearchPath,
        queryParameters: {
          'query': query,
          'size': 1,
        },
      );

      if (response.statusCode == 200) {
        var data = response.data;
        if (data['documents'] != null && data['documents'].isNotEmpty) {
          var item = data['documents'][0];

          double lng = double.parse(item['x']);
          double lat = double.parse(item['y']);
          String placeName = item['place_name'];
          String address = item['road_address_name'] ?? item['address_name'] ?? placeName;

          print('장소 검색 결과: $placeName ($lat, $lng)');
          print('주소: $address');

          return Location(
            latitude: lat,
            longitude: lng,
            address: address,
          );
        } else {
          print('장소 검색 결과가 없습니다');
        }
      }
      return null;
    } on DioException catch (e) {
      print('장소 검색 오류: ${e.message}');
      if (e.response != null) {
        print('오류 상세: ${e.response?.data}');
      }
      return null;
    }
  }

  // 주소에서 좌표 변환 (geocoding 실패 시 장소 검색으로 fallback)
  Future<Location?> findLocation(String query) async {
    // 1차: 주소 검색 (geocoding)
    Location? result = await geocoding(query);
    if (result != null) return result;

    // 2차: 장소명 검색 (local search)
    print('주소 검색 실패, 장소명으로 재검색합니다');
    return await searchPlace(query);
  }

  // 주소에서 좌표 변환
  Future<Location?> geocoding(String address) async {
    try {
      print('주소 검색 중입니다: $address');

      final response = await _dio.get(
        ApiConfig.geocodingPath,
        queryParameters: {'query': address},
      );

      if (response.statusCode == 200) {
        var data = response.data;
        if (data['addresses'] != null && data['addresses'].isNotEmpty) {
          var result = data['addresses'][0];

          return Location(
            latitude: double.parse(result['y']),
            longitude: double.parse(result['x']),
            address: result['roadAddress'] ?? result['jibunAddress'],
          );
        } else {
          print('주소 검색 결과가 없습니다');
        }
      }
      return null;
    } on DioException catch (e) {
      print('Geocoding 오류: ${e.message}');
      if (e.response != null) {
        print('오류 상세: ${e.response?.data}');
      }
      return null;
    }
  }

  // 좌표에서 주소 변환
  Future<String?> reverseGeocoding(double lat, double lng) async {
    try {
      print('주소 변환 중입니다: ($lat, $lng)');

      final response = await _dio.get(
        ApiConfig.reverseGeocodingPath,
        queryParameters: {
          'coords': '$lng,$lat',
          'orders': 'roadaddr',
          'output': 'json',
        },
      );

      if (response.statusCode == 200) {
        var results = response.data['results'];
        if (results != null && results.isNotEmpty) {
          var result = results[0];
          var region = result['region'];

          String area1 = region['area1']['name'] ?? '';
          String area2 = region['area2']['name'] ?? '';
          String area3 = region['area3']['name'] ?? '';

          var land = result['land'];
          String road = land['addition0']?['value'] ?? '';

          String fullAddress = '$area1 $area2 $area3 $road'.trim();
          print('주소는 : $fullAddress');
          return fullAddress;
        }
      }
      return null;
    } on DioException catch (e) {
      print('Reverse Geocoding 오류: ${e.message}');
      return null;
    }
  }

  // 경로 찾기
  Future<RouteInfo?> getRoute({
    required Location start,
    required Location goal,
    String option = 'trafast',
  }) async {
    try {
      print('경로 탐색 중입니다');
      print('출발: ${start.toCoords()}');
      print('도착: ${goal.toCoords()}');

      final response = await _dio.get(
        ApiConfig.directionsPath,
        queryParameters: {
          'start': start.toCoords(),
          'goal': goal.toCoords(),
          'option': option,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['code'] != 0) {
          print('API 오류 코드: ${data['code']}, 메시지: ${data['message']}');
          return null;
        }

        if (data['route'] != null) {
          final routeMap = data['route'] as Map<String, dynamic>;
          final actualOption = routeMap.keys.first;

          var routeData = routeMap[actualOption][0];
          RouteInfo routeInfo = RouteInfo.fromJson(routeData);

          print('사용된 경로 옵션: $actualOption');
          print('경로 찾기에 성공하였습니다');
          print('거리: ${routeInfo.distanceInKm}km');
          print('시간: ${routeInfo.durationInMinutes}분');
          print('통행료: ${routeInfo.tollFare}원');
          print('경로 포인트: ${routeInfo.path.length}개');
          print('안내: ${routeInfo.guides.length}개');

          return routeInfo;
        }
      }
      return null;
    } on DioException catch (e) {
      print('경로 탐색 오류: ${e.message}');
      if (e.response != null) {
        print('오류 상세: ${e.response?.data}');
      }
      return null;
    }
  }

  // 통합 경로 요청
  Future<RouteInfo?> getRouteByAddress({
    String? startAddress,
    required String goalAddress,
  }) async {
    try {
      // 출발지 결정 (주소가 없으면 현재 위치)
      Location? start;
      if (startAddress == null || startAddress.isEmpty) {
        start = await getCurrentLocation();
        if (start == null) {
          print('현재 위치를 가져올 수 없습니다');
          return null;
        }
      } else {
        start = await findLocation(startAddress);
        if (start == null) {
          print('출발지 주소를 찾을 수 없습니다');
          return null;
        }
      }

      // geocoding → 실패 시 장소 검색으로 fallback
      Location? goal = await findLocation(goalAddress);
      if (goal == null) {
        print('목적지를 찾을 수 없습니다');
        return null;
      }

      // 경로 탐색
      return await getRoute(start: start, goal: goal);
    } catch (e) {
      print('통합 경로 요청 실패: $e');
      return null;
    }
  }
}
