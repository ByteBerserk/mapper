import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/landmark.dart';

class ApiService {
  static const String baseUrl = 'https://labs.anontech.info/cse489/t3/api.php';
  static const String imageBaseUrl = 'https://labs.anontech.info/cse489/t3/';

  // Helper to build full image URL
  static String getFullImageUrl(String imagePath) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    // Remove leading slash if present
    final cleanPath = imagePath.startsWith('/') ? imagePath.substring(1) : imagePath;
    return '$imageBaseUrl$cleanPath';
  }

  // GET - Retrieve all landmarks
  Future<List<Landmark>> fetchLandmarks() async {
    try {
      print('=== FETCH LANDMARKS START ===');
      print('URL: $baseUrl');

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final dynamic data = json.decode(response.body);
          print('Parsed data type: ${data.runtimeType}');

          List<Landmark> landmarks = [];

          if (data is List) {
            print('Response is a List with ${data.length} items');
            landmarks = data.map((json) {
              // Ensure image has full URL (handle null images)
              if (json['image'] != null && json['image'] != '') {
                json['image'] = getFullImageUrl(json['image']);
              } else {
                json['image'] = 'https://via.placeholder.com/400x300?text=No+Image';
              }
              return Landmark.fromJson(json);
            }).toList();
          } else if (data is Map) {
            print('Response is a Map with keys: ${data.keys}');

            // Try different possible keys
            List? items;
            if (data['data'] is List) {
              items = data['data'] as List;
            } else if (data['landmarks'] is List) {
              items = data['landmarks'] as List;
            } else if (data['items'] is List) {
              items = data['items'] as List;
            } else if (data['records'] is List) {
              items = data['records'] as List;
            }

            if (items != null) {
              print('Found array with ${items.length} items');
              landmarks = items.map((json) {
                if (json['image'] != null && json['image'] != '') {
                  json['image'] = getFullImageUrl(json['image']);
                } else {
                  json['image'] = 'https://via.placeholder.com/400x300?text=No+Image';
                }
                return Landmark.fromJson(json);
              }).toList();
            } else {
              print('Could not find landmarks array in response');
            }
          }

          print('Parsed ${landmarks.length} landmarks');
          for (var landmark in landmarks) {
            print('  - ID: ${landmark.id}, Title: ${landmark.title}');
          }

          print('=== FETCH LANDMARKS SUCCESS ===');
          return landmarks;
        } catch (parseError, stackTrace) {
          print('JSON Parse Error: $parseError');
          print('Stack trace: $stackTrace');
          print('Raw response: ${response.body}');
          throw Exception('Failed to parse response: $parseError');
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        print('Error body: ${response.body}');
        throw Exception('HTTP ${response.statusCode}: Failed to fetch landmarks');
      }
    } catch (e, stackTrace) {
      print('=== FETCH LANDMARKS ERROR ===');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // POST - Create new landmark
  Future<Map<String, dynamic>> createLandmark({
    required String title,
    required double lat,
    required double lon,
    File? imageFile,
  }) async {
    try {
      print('=== CREATE LANDMARK START ===');
      print('URL: $baseUrl');
      print('Title: $title');
      print('Lat: $lat, Lon: $lon');
      print('Has image: ${imageFile != null}');

      var request = http.MultipartRequest('POST', Uri.parse(baseUrl));

      // Add text fields
      request.fields['title'] = title;
      request.fields['lat'] = lat.toString();
      request.fields['lon'] = lon.toString();

      // Add image file if provided
      if (imageFile != null) {
        var multipartFile = await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
        );
        request.files.add(multipartFile);
        print('Image attached: ${multipartFile.filename}, ${multipartFile.length} bytes');
      }

      print('Sending request...');
      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );

      var response = await http.Response.fromStream(streamedResponse);

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('=== CREATE LANDMARK SUCCESS ===');
        return {'success': true, 'message': 'Created successfully'};
      } else {
        print('=== CREATE LANDMARK FAILED ===');
        throw Exception('Failed to create landmark: ${response.body}');
      }
    } catch (e, stackTrace) {
      print('=== CREATE LANDMARK ERROR ===');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // PUT - Update existing landmark
  Future<Map<String, dynamic>> updateLandmark({
    required int id,
    required String title,
    required double lat,
    required double lon,
    File? imageFile,
  }) async {
    try {
      print('=== UPDATE LANDMARK START ===');
      print('URL: $baseUrl');
      print('ID: $id');

      var request = http.MultipartRequest('POST', Uri.parse(baseUrl));

      // Use _method field to simulate PUT request
      request.fields['_method'] = 'PUT';
      request.fields['id'] = id.toString();
      request.fields['title'] = title;
      request.fields['lat'] = lat.toString();
      request.fields['lon'] = lon.toString();

      print('Request fields: ${request.fields}');

      // Add image if provided
      if (imageFile != null) {
        var multipartFile = await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
        );
        request.files.add(multipartFile);
        print('New image attached');
      }

      print('Sending update request...');
      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );

      var response = await http.Response.fromStream(streamedResponse);

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('=== UPDATE LANDMARK SUCCESS ===');
        return {'success': true};
      } else {
        print('=== UPDATE LANDMARK FAILED ===');
        throw Exception('Failed to update landmark: ${response.body}');
      }
    } catch (e, stackTrace) {
      print('=== UPDATE LANDMARK ERROR ===');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // DELETE - Remove landmark
  Future<void> deleteLandmark(int id) async {
    try {
      print('=== DELETE LANDMARK START ===');
      print('URL: $baseUrl');
      print('ID: $id');

      var request = http.MultipartRequest('POST', Uri.parse(baseUrl));

      // Use _method field to simulate DELETE request
      request.fields['_method'] = 'DELETE';
      request.fields['id'] = id.toString();

      print('Request fields: ${request.fields}');
      print('Sending delete request...');

      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );

      var response = await http.Response.fromStream(streamedResponse);

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 ||
          response.statusCode == 204 ||
          response.statusCode == 201) {
        print('=== DELETE LANDMARK SUCCESS ===');
        return;
      } else {
        print('=== DELETE LANDMARK FAILED ===');
        throw Exception('Failed to delete landmark: ${response.body}');
      }
    } catch (e, stackTrace) {
      print('=== DELETE LANDMARK ERROR ===');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
}