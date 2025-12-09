import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/landmark.dart';

class ApiService {
  static const String baseUrl = 'https://labs.anontech.info/cse489/t3/api.php';
  static const String imageBaseUrl = 'https://labs.anontech.info/cse489/t3/';

  // Helper to build full image URL
  static String getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty || imagePath == 'null') {
      return 'https://via.placeholder.com/400x300?text=No+Image';
    }
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

      if (response.statusCode == 200) {
        try {
          final dynamic data = json.decode(response.body);

          List<Landmark> landmarks = [];

          if (data is List) {
            print('Response is a List with ${data.length} items');

            // Filter out invalid landmarks (empty title, lat, lon)
            final validData = data.where((json) {
              final title = json['title']?.toString() ?? '';
              final lat = json['lat']?.toString() ?? '';
              final lon = json['lon']?.toString() ?? '';

              return title.isNotEmpty && lat.isNotEmpty && lon.isNotEmpty;
            }).toList();

            print('Filtered to ${validData.length} valid landmarks');

            landmarks = validData.map((json) {
              if (json['image'] != null && json['image'] != '' && json['image'] != 'null') {
                json['image'] = getFullImageUrl(json['image']);
              } else {
                json['image'] = 'https://via.placeholder.com/400x300?text=No+Image';
              }
              return Landmark.fromJson(json);
            }).toList();
          } else if (data is Map && data['data'] is List) {
            final items = data['data'] as List;

            final validData = items.where((json) {
              final title = json['title']?.toString() ?? '';
              final lat = json['lat']?.toString() ?? '';
              final lon = json['lon']?.toString() ?? '';

              return title.isNotEmpty && lat.isNotEmpty && lon.isNotEmpty;
            }).toList();

            print('Filtered to ${validData.length} valid landmarks');

            landmarks = validData.map((json) {
              if (json['image'] != null && json['image'] != '' && json['image'] != 'null') {
                json['image'] = getFullImageUrl(json['image']);
              } else {
                json['image'] = 'https://via.placeholder.com/400x300?text=No+Image';
              }
              return Landmark.fromJson(json);
            }).toList();
          }

          print('Parsed ${landmarks.length} valid landmarks');
          print('=== FETCH LANDMARKS SUCCESS ===');
          return landmarks;
        } catch (parseError, stackTrace) {
          print('JSON Parse Error: $parseError');
          print('Stack trace: $stackTrace');
          throw Exception('Failed to parse response: $parseError');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: Failed to fetch landmarks');
      }
    } catch (e, stackTrace) {
      print('=== FETCH LANDMARKS ERROR ===');
      print('Error: $e');
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
      print('Title: $title, Lat: $lat, Lon: $lon');

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
        print('Image attached: ${multipartFile.length} bytes');
      }

      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      var response = await http.Response.fromStream(streamedResponse);

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('=== CREATE LANDMARK SUCCESS ===');
        return {'success': true};
      } else {
        throw Exception('Failed to create: ${response.body}');
      }
    } catch (e) {
      print('=== CREATE LANDMARK ERROR: $e ===');
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
      print('ID: $id, Title: $title, Lat: $lat, Lon: $lon');

      // Try using PUT method directly with query parameter
      final uri = Uri.parse('$baseUrl?id=$id');

      var request = http.MultipartRequest('PUT', uri);

      // Add fields
      request.fields['id'] = id.toString();
      request.fields['title'] = title;
      request.fields['lat'] = lat.toString();
      request.fields['lon'] = lon.toString();

      // Add image if provided
      if (imageFile != null) {
        var multipartFile = await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
        );
        request.files.add(multipartFile);
        print('Image attached');
      }

      print('Sending PUT request to: $uri');
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
        throw Exception('Failed to update: ${response.body}');
      }
    } catch (e) {
      print('=== UPDATE LANDMARK ERROR: $e ===');
      rethrow;
    }
  }

  // DELETE - Remove landmark
  Future<void> deleteLandmark(int id) async {
    try {
      print('=== DELETE LANDMARK START ===');
      print('ID: $id');

      // Try using DELETE method directly with query parameter
      final uri = Uri.parse('$baseUrl?id=$id');

      print('Sending DELETE request to: $uri');
      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 ||
          response.statusCode == 204 ||
          response.statusCode == 201) {
        print('=== DELETE LANDMARK SUCCESS ===');
        return;
      } else {
        throw Exception('Failed to delete: ${response.body}');
      }
    } catch (e) {
      print('=== DELETE LANDMARK ERROR: $e ===');
      rethrow;
    }
  }
}