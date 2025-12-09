import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/landmark.dart';

class ApiService {
  static const String baseUrl = 'https://labs.anontech.info/cse489/t3/api.php';

  // GET - Retrieve all landmarks
  Future<List<Landmark>> fetchLandmarks() async {
    try {
      print('=== FETCH LANDMARKS START ===');
      print('URL: $baseUrl');

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body}');
      print('Response Body Length: ${response.body.length}');

      if (response.statusCode == 200) {
        // Try to parse the response
        try {
          final dynamic data = json.decode(response.body);
          print('Parsed data type: ${data.runtimeType}');

          List<Landmark> landmarks = [];

          // Handle different response formats
          if (data is List) {
            print('Response is a List with ${data.length} items');
            landmarks = data.map((json) => Landmark.fromJson(json)).toList();
          } else if (data is Map) {
            print('Response is a Map with keys: ${data.keys}');
            if (data['data'] is List) {
              print('Found data array with ${data['data'].length} items');
              landmarks = (data['data'] as List)
                  .map((json) => Landmark.fromJson(json))
                  .toList();
            } else if (data['landmarks'] is List) {
              landmarks = (data['landmarks'] as List)
                  .map((json) => Landmark.fromJson(json))
                  .toList();
            }
          }

          print('Parsed ${landmarks.length} landmarks');
          for (var landmark in landmarks) {
            print('  - ID: ${landmark.id}, Title: ${landmark.title}');
          }

          print('=== FETCH LANDMARKS SUCCESS ===');
          return landmarks;
        } catch (parseError) {
          print('JSON Parse Error: $parseError');
          print('Raw response: ${response.body}');
          throw Exception('Failed to parse response: $parseError');
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        print('Error body: ${response.body}');
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e, stackTrace) {
      print('=== FETCH LANDMARKS ERROR ===');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Network error: $e');
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
      if (imageFile != null) {
        print('Image path: ${imageFile.path}');
        print('Image exists: ${await imageFile.exists()}');
        print('Image size: ${await imageFile.length()} bytes');
      }

      var request = http.MultipartRequest('POST', Uri.parse(baseUrl));

      // Add headers
      request.headers['Accept'] = 'application/json';

      // Add text fields
      request.fields['title'] = title;
      request.fields['lat'] = lat.toString();
      request.fields['lon'] = lon.toString();

      print('Request fields: ${request.fields}');

      // Add image file if provided
      if (imageFile != null) {
        try {
          var multipartFile = await http.MultipartFile.fromPath(
            'image',
            imageFile.path,
            filename: imageFile.path.split('/').last,
          );
          request.files.add(multipartFile);
          print('Image attached: ${multipartFile.filename}, ${multipartFile.length} bytes');
        } catch (imageError) {
          print('Error attaching image: $imageError');
          throw Exception('Failed to attach image: $imageError');
        }
      }

      print('Sending request...');
      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );

      var response = await http.Response.fromStream(streamedResponse);

      print('Response Status: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          if (response.body.trim().isEmpty) {
            print('Empty response body, assuming success');
            return {'success': true, 'message': 'Created successfully'};
          }

          final responseData = json.decode(response.body);
          print('Parsed response: $responseData');
          print('=== CREATE LANDMARK SUCCESS ===');

          return responseData is Map<String, dynamic>
              ? responseData
              : {'success': true, 'data': responseData};
        } catch (e) {
          print('JSON decode error: $e');
          print('Assuming success based on status code');
          return {'success': true, 'message': response.body};
        }
      } else {
        print('=== CREATE LANDMARK FAILED ===');
        print('Status: ${response.statusCode}');
        print('Body: ${response.body}');
        throw Exception('Server error ${response.statusCode}: ${response.body}');
      }
    } catch (e, stackTrace) {
      print('=== CREATE LANDMARK ERROR ===');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Upload error: $e');
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
      print('Title: $title');
      print('Lat: $lat, Lon: $lon');
      print('Has new image: ${imageFile != null}');

      var request = http.MultipartRequest('POST', Uri.parse(baseUrl));

      // Add headers
      request.headers['Accept'] = 'application/json';

      // Add method override for PUT
      request.fields['_method'] = 'PUT';
      request.fields['id'] = id.toString();
      request.fields['title'] = title;
      request.fields['lat'] = lat.toString();
      request.fields['lon'] = lon.toString();

      print('Request fields: ${request.fields}');

      // Add image file if provided
      if (imageFile != null) {
        try {
          var multipartFile = await http.MultipartFile.fromPath(
            'image',
            imageFile.path,
            filename: imageFile.path.split('/').last,
          );
          request.files.add(multipartFile);
          print('New image attached: ${multipartFile.filename}');
        } catch (imageError) {
          print('Error attaching image: $imageError');
        }
      }

      print('Sending update request...');
      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );

      var response = await http.Response.fromStream(streamedResponse);

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          if (response.body.trim().isEmpty) {
            print('Empty response, assuming success');
            return {'success': true};
          }

          final responseData = json.decode(response.body);
          print('=== UPDATE LANDMARK SUCCESS ===');
          return responseData is Map<String, dynamic>
              ? responseData
              : {'success': true, 'data': responseData};
        } catch (e) {
          print('JSON decode error, assuming success');
          return {'success': true, 'message': response.body};
        }
      } else {
        print('=== UPDATE LANDMARK FAILED ===');
        throw Exception('Server error ${response.statusCode}: ${response.body}');
      }
    } catch (e, stackTrace) {
      print('=== UPDATE LANDMARK ERROR ===');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Update error: $e');
    }
  }

  // DELETE - Remove landmark
  Future<void> deleteLandmark(int id) async {
    try {
      print('=== DELETE LANDMARK START ===');
      print('URL: $baseUrl');
      print('ID: $id');

      var request = http.MultipartRequest('POST', Uri.parse(baseUrl));

      // Add headers
      request.headers['Accept'] = 'application/json';

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
        throw Exception('Server error ${response.statusCode}: ${response.body}');
      }
    } catch (e, stackTrace) {
      print('=== DELETE LANDMARK ERROR ===');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Delete error: $e');
    }
  }
}